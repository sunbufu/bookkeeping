import 'dart:convert';
import 'dart:io';

import 'package:bookkeeping/common/action_entry.dart';
import 'package:bookkeeping/common/constants.dart';
import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/dialog/loading_dialog.dart';
import 'package:bookkeeping/dialog/month_picker_dialog.dart';
import 'package:bookkeeping/dialog/web_dav_login_dialog.dart';
import 'package:bookkeeping/item/menu_item.dart';
import 'package:bookkeeping/list/daily_record_list.dart';
import 'package:bookkeeping/model/daily_record.dart';
import 'package:bookkeeping/model/directions.dart';
import 'package:bookkeeping/model/modified_record_log.dart';
import 'package:bookkeeping/model/monthly_record.dart';
import 'package:bookkeeping/model/record.dart';
import 'package:bookkeeping/model/user.dart';
import 'package:bookkeeping/model/web_dav_storage_server_configuration.dart';
import 'package:bookkeeping/pages/detail_page.dart';
import 'package:bookkeeping/pages/import_page.dart';
import 'package:bookkeeping/pages/statistic_page.dart';
import 'package:bookkeeping/storage/storage_adapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:quiver/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  /// 菜单
  List<MenuItem> _menuItemList = [];

  /// 标题
  String _title = 'bookkeeping';

  /// 展示的月份
  String _month = '2020-05';

  /// 列表展示组件
  DailyRecordList _dailyRecordListView = DailyRecordList();

  /// 是否展示浮动按钮
  bool showFloatingButton = true;

  final QuickActions _quickActions = QuickActions();

  @override
  void initState() {
    super.initState();
    // 获取当前月份
    _month = DateTimeUtil.getMonthByTimestamp(DateTimeUtil.getTimestamp());
    // 初始化菜单按钮
    _initMenuItem();
    // 初始化 quick action
    _initQuickAction();
    // 添加恢复监听器
    Runtime.resumedListenerList.add(_resumedListener);
    // 添加暂停监听器
    Runtime.pausedListenerList.add(_pausedListener);

    _init();
  }

  @override
  void dispose() {
    // 移除恢复监听器
    Runtime.resumedListenerList.remove(_resumedListener);
    // 移除暂停监听器
    Runtime.pausedListenerList.remove(_pausedListener);
    super.dispose();
  }

  /// 异步初始化
  void _init() async {
    await _refreshDataFromStorage(Runtime.sharedPreferencesStorageAdapter);
    // 初始化用户配置
    await _initUserProperties(Runtime.sharedPreferencesStorageAdapter);
    // 设置列表回调
    _initRecordListCallBack();
    // 抓取常用备注数据
    Runtime.frequentlyMarkService.fetchFrequentlyMarkMap(Runtime.sharedPreferencesStorageAdapter);
  }

  /// 设置完成用户配置后，刷新存储数据
  void _afterSetUser() async {
    _initWebDavStorageServer(Runtime.user.storageServer as WebDavStorageServerConfiguration);
    try {
      await Runtime.storageService.list();
      await _flushRecordToStorage(Runtime.storageService);
      await _refreshDataFromStorage(Runtime.storageService);
    } catch (e) {
      Fluttertoast.showToast(msg: '连接失败');
    }
  }

  /// 重新获取存储中的数据
  Future<void> _refreshDataFromStorage(StorageAdapter storageAdapter) async {
    // 抓取分类数据
    Runtime.categoryService.fetchCategoryFromStorage(storageAdapter);
    // 抓取列表数据
    await Runtime.recordService.fetchRecordFromStorage(storageAdapter, _month);
    // 刷新列表页面
    _refreshRecordListView();
  }
  
  /// 初始化用户配置
  Future<void> _initUserProperties(StorageAdapter storageAdapter) async {
    if (await Runtime.sharedPreferencesStorageAdapter.exist(Constants.USER_INFO_FILE_NAME) || await Runtime.fileStorageAdapter.exist(Constants.USER_INFO_FILE_NAME)) {
      String userContent = await Runtime.sharedPreferencesStorageAdapter.read(Constants.USER_INFO_FILE_NAME);
      // 兼容之前的文件存储
      if (userContent.isEmpty) {
        userContent = await Runtime.fileStorageAdapter.read(Constants.USER_INFO_FILE_NAME);
        Runtime.sharedPreferencesStorageAdapter
            .write(Constants.USER_INFO_FILE_NAME, userContent)
            .then((result) {
              if (result) Runtime.fileStorageAdapter.delete(Constants.USER_INFO_FILE_NAME);
            });
      }
      User user = User.fromJson(json.decode(userContent));
      Runtime.user = user;
      await _afterSetUser();
    } else {
      WebDavLoginDialog().show(context, null, (user) {
        Runtime.user = user;
        Runtime.sharedPreferencesStorageAdapter.write(Constants.USER_INFO_FILE_NAME, json.encode(user));
        _afterSetUser();
      });
    }
  }

  /// 初始化 webdav
  void _initWebDavStorageServer(WebDavStorageServerConfiguration configuration) {
    LoadingDialog.runWithLoading(context, (){
      Runtime.storageService.init(
          configuration: configuration,
          success: (_) {},
          fail: (e) => Fluttertoast.showToast(msg: '连接失败')
      );
    });
  }

  /// 初始化菜单
  void _initMenuItem() {
    // 准备 menu 数据
    _menuItemList = [
      MenuItem('手动同步', () {
        LoadingDialog.runWithLoadingAsync(context, () async {
          try {
            await _flushRecordToStorage(Runtime.storageService);
            await Runtime.recordService.fetchRecordFromStorage(Runtime.storageService, _month, strict: true).then((_) {
              _refreshRecordListView();
            });
            Fluttertoast.showToast(msg: '同步完成');
          } catch (e) {
            Fluttertoast.showToast(msg: 'webdav连接失败');
          }
        });
      }),
      MenuItem('设置账号', () =>
          WebDavLoginDialog().show(context, Runtime.user, (user) {
            Runtime.user = user;
            Runtime.sharedPreferencesStorageAdapter.write(Constants.USER_INFO_FILE_NAME, json.encode(user));
            _afterSetUser();
          })),
      MenuItem('清除缓存', () {
        Runtime.sharedPreferencesStorageAdapter.delete(Constants.MODIFIED_MONTHLY_RECORD_FILE_NAME);
        Fluttertoast.showToast(msg: '清除成功');
      }),
      MenuItem('数据导入', () {
        if (!Runtime.storageService.isReady) {
          Fluttertoast.showToast(msg: 'webdav 连接未成功，请配置完成后再试');
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProgressHUD(child: ImportPage()))).then((value) {
            if (null != value && value is List<Record>) _importRecordList(value);
          });
        }
      }),
      MenuItem('数据导出', () {
        if (!Runtime.storageService.isReady) {
          Fluttertoast.showToast(msg: 'webdav 连接未成功，请配置完成后再试');
        } else {
          String exportFileName = Constants.getExportFileName(DateTimeUtil.getTimestamp());
          showDialog(
              context: context,
              child: AlertDialog(
                title: Text('数据导出'),
                  content: Text('导出时间的长短与网络和数据量有关，请勿将应用置于后台! 数据将被导出到 webdav 的【$exportFileName】上。'),
                  actions: <Widget>[
                  FlatButton(child: Text('取消'), onPressed: () => Navigator.pop(context)),
                  FlatButton(
                      child: Text('导出'),
                      onPressed: () {
                      Navigator.pop(context);
                      LoadingDialog.runWithLoadingAsync(context, () async {
                        await _exportRecordList(exportFileName);
                      });
                    })
              ]));
        }
      }),
      MenuItem('使用教程', () {
        launch('https://www.sunbufu.club/2020/05/02/bookkeeping');
      }),
      MenuItem('关于我们', () {
        launch('https://www.sunbufu.club/2020/05/02/bookkeeping/#%E5%9B%9B-%E5%85%B3%E4%BA%8E');
      }),
    ];
  }

  /// 数据导入
  void _importRecordList(List<Record> recordList) {
    LoadingDialog.show(context);
    List<ModifiedRecordLog> modifiedRecordLogList =
        recordList.map((record) => ModifiedRecordLog(record: record, operation: 1)).toList();
    _addModifiedRecordLog(modifiedRecordLogList).then((_){
      _saveRecordAndRefresh(
          flush: true,
          finishCallback: () {
            LoadingDialog.dismiss();
            Fluttertoast.showToast(msg: '导入成功');
          });
    });
  }

  /// 恢复监听器
  void _resumedListener() {
    if(20 < DateTimeUtil.getTimestamp() - Runtime.recordService.lastFetchTime)
      Runtime.recordService
          .fetchRecordFromStorage(Runtime.storageService, _month)
          .then((_) => _refreshRecordListView());
  }

  /// 暂停监听器
  void _pausedListener() {
    _saveRecordAndRefresh(flush: true);
  }

  /// 数据导出
  void _exportRecordList(String exportFileName) async {
    LoadingDialog.show(context);
    // 获取全部数据
    List<MonthlyRecord> monthlyRecordList = [];
    List<String> fileNameList = await Runtime.storageService.list();
    for (String fileName in fileNameList) {
      if (!fileName.startsWith('monthly_record_')) continue;
      String content = await Runtime.storageService.read(fileName);
      if ('' == content) continue;
      monthlyRecordList.add(MonthlyRecord.fromJson(json.decode(content)));
    }
    String exportContent = Constants.TEMPLATE_FILE_HEAD;
    // 根据时间降序排序
    monthlyRecordList.sort((a, b) => b.time - a.time);
    for (MonthlyRecord monthlyRecord in monthlyRecordList) {
      List<DailyRecord> dailyRecordList = monthlyRecord.records.values.toList();
      dailyRecordList.sort((a, b) => b.time - a.time);
      for (DailyRecord dailyRecord in dailyRecordList) {
        List<Record> recordList = dailyRecord.records.values.toList();
        recordList.sort((a, b) => b.time - a.time);
        // 拼接数据
        recordList.forEach((record) => exportContent += _convertRecordToCSV(record));
      }
    }
    // 导出
    await Runtime.storageService.write(exportFileName, exportContent);
    LoadingDialog.dismiss();
    Fluttertoast.showToast(msg: '导出成功');
  }

  /// 转化 record 为 csv 字符串
  String _convertRecordToCSV(Record record) {
    return DateTimeUtil.getYearMonthDayTimeByTimestamp(record.time) +
        ',' +
        record.category +
        ',' +
        (record.direction == Directions.EXPENSE ? '支出' : '收入') +
        ',' +
        (record.amount / 100).toStringAsFixed(2) +
        ',' +
        record.remark +
        ',' +
        record.createdUser +
        '\n';
  }

  void _initQuickAction() {
    // 配置 quick action
    _quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(type: 'add_record', localizedTitle: '添加一笔', icon: 'ic_add'),
    ]);
    _quickActions.initialize((String shortcutType) {
      if ('add_record' == shortcutType && !Runtime.detailPageShowing) {
        Runtime.detailPageShowing = true;
        Future.delayed(Duration(milliseconds: Platform.isAndroid ? 200 : 700), () => gotoDetailPageAndCreateRecord());
      }
    });
  }

  /// 设置列表回调
  void _initRecordListCallBack() {
    _dailyRecordListView.setOnPressCallBack(onRecordListPress);
    _dailyRecordListView.addControllerListener(onRecordListListener);
  }

  /// 列表点击
  void onRecordListPress(Record record) {
    // 删除、修改
    gotoDetailPage(record: record, callback: (action) {
      if (action.oldEntry == action.newEntry) return;
      if (action.deleted) {
        _addModifiedRecordLog([ModifiedRecordLog(record: action.oldEntry, operation: 0)]).then((_) {
          _saveRecordAndRefresh();
        });
      } else if (action.oldEntry != action.newEntry) {
        if (isBlank(action.newEntry.createdUser)) action.newEntry.createdUser = Runtime.username;
        _addModifiedRecordLog([
          ModifiedRecordLog(record: action.oldEntry, operation: 0),
          ModifiedRecordLog(record: action.newEntry, operation: 1)
        ]).then((_){
          _saveRecordAndRefresh();
        });
      }
    });
  }

  /// 列表监听器
  void onRecordListListener(ScrollController controller) {
    if (controller.offset > 50 && showFloatingButton)
      setState(() => showFloatingButton = false);
    else if (controller.offset <= 50 && !showFloatingButton)
      setState(() => showFloatingButton = true);
  }

  /// 标题点击
  void onTitlePress() {
    MonthPickerDialog.showDialog(context, _month, (dateTime) {
      _month = DateTimeUtil.getMonthByTimestamp(DateTimeUtil.getTimestampByDateTime(dateTime));
      LoadingDialog.runWithLoadingAsync(context, () async {
        _flushRecordToStorage(Runtime.storageService);
        await Runtime.recordService.fetchRecordFromStorage(Runtime.storageService, _month);
        _refreshRecordListView();
      });
    });
  }

  ///  跳转到详情页
  void gotoDetailPage({Record record, Function(ActionEntry<Record>) callback}) async {
    Runtime.detailPageShowing = true;
    // 增加
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProgressHUD(child: DetailPage(record: record)))).then((actionEntry) {
      Runtime.detailPageShowing = false;
      if (null == actionEntry || !(actionEntry is ActionEntry<Record>)) return;
      if (null != callback) callback(actionEntry);
    });
  }

  ///  跳转到详情页，并创建记录
  void gotoDetailPageAndCreateRecord() async {
    gotoDetailPage(callback: (action) {
      if (null == action.newEntry || 0 >= action.newEntry.amount) return;
      if (isBlank(action.newEntry.createdUser)) action.newEntry.createdUser = Runtime.username;
      _addModifiedRecordLog([ModifiedRecordLog(record: action.newEntry, operation: 1)]).then((_) {
        _saveRecordAndRefresh();
      });
    });
  }

  /// 保存并刷新（先更新内存，刷新展示；再同步存储，刷新展示）
  void _saveRecordAndRefresh({bool flush: false, Function finishCallback}) async {
    Future.microtask(() {
      _saveRecordList().then((_) {
        _refreshRecordListView();
      });
    });
    if (Runtime.syncWhenModify || flush) {
      LoadingDialog.runWithLoadingAsync(context, () async {
        await _flushRecordToStorage(Runtime.storageService);
        _refreshRecordListView();
        if (null != finishCallback) finishCallback();
      });
    }
  }

  /// 使用内存数据刷新列表组件
  Future<void> _refreshRecordListView() async {
    _dailyRecordListView.setMonthRecord(Runtime.monthlyRecordMap[_month]);
    setState(() => _title = _month);
  }

  /// 获取内存中日份的记录
  DailyRecord _getDailyRecord(String day) {
    String month = DateTimeUtil.getMonthByTimestamp(DateTimeUtil.getTimestampByDay(day));
    if (null == Runtime.monthlyRecordMap[month])
      Runtime.monthlyRecordMap[month] = MonthlyRecord(time: DateTimeUtil.getTimestampByMonth(month));
    MonthlyRecord monthlyRecord = Runtime.monthlyRecordMap[month];
    if (null == monthlyRecord.records[day])
      monthlyRecord.records[day] = DailyRecord(time: DateTimeUtil.getTimestampByDay(day));
    return monthlyRecord.records[day];
  }

  /// 添加修改记录到本地存储
  Future<void> _addModifiedRecordLog(List<ModifiedRecordLog> recordList) async {
    if (null == recordList || recordList.isEmpty) return;
    List<ModifiedRecordLog> modifiedRecordLogList = await _getModifiedRecordLogList();
    modifiedRecordLogList.addAll(recordList);
    await Runtime.sharedPreferencesStorageAdapter.write(Constants.MODIFIED_MONTHLY_RECORD_FILE_NAME, json.encode(modifiedRecordLogList));
  }

  /// 从本地存储获取待提交的修改记录
  Future<List<ModifiedRecordLog>> _getModifiedRecordLogList() async {
    String content = await Runtime.sharedPreferencesStorageAdapter.read(Constants.MODIFIED_MONTHLY_RECORD_FILE_NAME);
    if ('' == content) return List<ModifiedRecordLog>();
    return List.from(json.decode(content).map((e) => ModifiedRecordLog.fromJson(e)));
  }

  /// 同步修改数据到内存（从内存读取数据，变更后只修改内存）
  Future<void> _saveRecordList() async {
    // 读取待提交的数据
    List<ModifiedRecordLog> modifiedRecordLogList = await _getModifiedRecordLogList();
    if (modifiedRecordLogList.isEmpty) {
      print('没有需要同步的数据');
      return;
    }
    // 改动数据涉及到的月份
    Set<String> months = {DateTimeUtil.getMonthByTimestamp(DateTimeUtil.getTimestamp())};
    modifiedRecordLogList.forEach((log) => months.add(DateTimeUtil.getMonthByTimestamp(log.record.time)));
    for (String month in months) {
      await Runtime.recordService.fetchRecordFromLocal(month);
    }
    // 变更应用到本地数据
    modifiedRecordLogList.forEach((log) {
      DailyRecord dailyRecord = _getDailyRecord(DateTimeUtil.getDayByTimestamp(log.record.time));
      if (0 == log.operation) {
        // 删除
        dailyRecord.records.remove(log.record.id);
      } else if (1 == log.operation) {
        // 新增
        dailyRecord.records[log.record.id] = log.record;
      }
    });
  }

  /// 同步修改数据到存储（从存储读取数据，变更后同步到存储，并删除待修改记录）
  Future<void> _flushRecordToStorage(StorageAdapter storageAdapter) async {
    // 读取待提交的数据
    List<ModifiedRecordLog> modifiedRecordLogList = await _getModifiedRecordLogList();
    if (modifiedRecordLogList.isEmpty) return;
    // 改动数据涉及到的月份
    Set<String> months = {DateTimeUtil.getMonthByTimestamp(DateTimeUtil.getTimestamp())};
    modifiedRecordLogList.forEach((log) => months.add(DateTimeUtil.getMonthByTimestamp(log.record.time)));
    for (String month in months) {
      await Runtime.recordService.fetchRecordFromStorage(Runtime.storageService, month, strict: true);
    }
    // 变更应用到本地数据
    modifiedRecordLogList.forEach((log) {
      DailyRecord dailyRecord = _getDailyRecord(DateTimeUtil.getDayByTimestamp(log.record.time));
      if (0 == log.operation) {
        // 删除
        dailyRecord.records.remove(log.record.id);
      } else if (1 == log.operation) {
        // 新增
        dailyRecord.records[log.record.id] = log.record;
      }
    });
    // 同步数据
    // TODO 此处考虑同步过程中失败的解决方案
    for (String month in months) {
      try {
        await Runtime.sharedPreferencesStorageAdapter.write(Constants.getMonthlyRecordFileNameByMonth(month), json.encode(Runtime.monthlyRecordMap[month]));
        await Runtime.storageService.write(Constants.getMonthlyRecordFileNameByMonth(month), json.encode(Runtime.monthlyRecordMap[month]));
      } catch (e) {
        Fluttertoast.showToast(msg: '同步$month失败');
      }
      Runtime.sharedPreferencesStorageAdapter.delete(Constants.MODIFIED_MONTHLY_RECORD_FILE_NAME);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkModeUtil.isDarkMode(context) ? Colors.black : Color(0xFFEEEEEE),
      appBar: AppBar(
        title: FlatButton.icon(
          onPressed: onTitlePress,
          icon: Icon(Icons.expand_more, color: Colors.white,),
          label: Text(_title, style: TextStyle(fontSize: 20, color: Colors.white),),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.equalizer), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProgressHUD(child: StatisticPage(_month))));
          }),
          PopupMenuButton<MenuItem>(
            onSelected: (menuItem) => menuItem.onSelected(),
            itemBuilder: (BuildContext context) {
              return _menuItemList
                  .map((menuItem) => PopupMenuItem<MenuItem>(value: menuItem, child: Text(menuItem.title)))
                  .toList();
            },
          ),
        ],
      ),
      body: _dailyRecordListView,
      floatingActionButton: showFloatingButton
          ? FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white,),
              onPressed: gotoDetailPageAndCreateRecord,
              backgroundColor: DarkModeUtil.isDarkMode(context) ? Colors.blue : Colors.blue)
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
