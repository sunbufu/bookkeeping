import 'dart:convert';

import 'package:bookkeeping/common/action_entry.dart';
import 'package:bookkeeping/common/constants.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/dialog/loading_dialog.dart';
import 'package:bookkeeping/dialog/month_picker_dialog.dart';
import 'package:bookkeeping/dialog/web_dav_login_dialog.dart';
import 'package:bookkeeping/item/menu_item.dart';
import 'package:bookkeeping/list/daily_record_list.dart';
import 'package:bookkeeping/model/daily_record.dart';
import 'package:bookkeeping/model/modified_record_log.dart';
import 'package:bookkeeping/model/monthly_record.dart';
import 'package:bookkeeping/model/record.dart';
import 'package:bookkeeping/model/user.dart';
import 'package:bookkeeping/model/web_dav_storage_server_configuration.dart';
import 'package:bookkeeping/pages/detail_page.dart';
import 'package:bookkeeping/storage/storage_adapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quick_actions/quick_actions.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  /// 菜单
  List<MenuItem> _menuItemList = [];

  /// 月度记录
  Map<String, MonthlyRecord> _monthlyRecordMap = {};

  /// 标题
  String _title = 'bookkeeping';

  /// 展示的月份
  String _month = '2020-05';

  /// 列表展示组件
  DailyRecordList _dailyRecordListView = DailyRecordList();

  /// 是否展示浮动按钮
  bool showFloatingButton = true;

  @override
  void initState() {
    super.initState();
    // 获取当前月份
    _month = DateTimeUtil.getMonthByTimestamp(DateTimeUtil.getTimestamp());
    // 初始化菜单按钮
    _initMenuItem();
    // 初始化 quick action
    _initQuickAction();

    _init();
  }

  /// 异步初始化
  void _init() async {
    await _refreshDataFromStorage(Runtime.fileStorageAdapter);
    // 初始化用户配置
    await _initUserProperties(Runtime.fileStorageAdapter, (user){
      _initWebDavStorageServer(Runtime.user.storageServer as WebDavStorageServerConfiguration);
      _flushRecordToStorage(Runtime.storageService).then((_) {
        _refreshDataFromStorage(Runtime.storageService);
      });
    });
    // 设置列表回调
    _initRecordListCallBack();
  }
  
  /// 重新获取存储中的数据
  Future<void> _refreshDataFromStorage(StorageAdapter storageAdapter) async {
    // 抓取分类数据
    Runtime.categoryService.fetchCategoryFromStorage(storageAdapter);
    // 抓取列表数据
    await _fetchRecordFromStorage(storageAdapter, _month);
    // 刷新列表页面
    _refreshRecordListView();
  }
  
  /// 初始化用户配置
  Future<void> _initUserProperties(StorageAdapter storageAdapter, Function(User user) callback) async {
    if (await Runtime.fileStorageAdapter.exist(Constants.USER_INFO_FILE_NAME)) {
      User user = User.fromJson(json.decode(await Runtime.fileStorageAdapter.read(Constants.USER_INFO_FILE_NAME)));
      Runtime.user = user;
      if (null != callback) callback(user);
    } else {
      WebDavLoginDialog().show(context, null, (user) {
        Runtime.user = user;
        if (null != callback) callback(user);
      });
    }
  }

  /// 初始化 webdav
  void _initWebDavStorageServer(WebDavStorageServerConfiguration configuration) {
    LoadingDialog.runWithLoading(context, '连接中...', (){
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
      MenuItem('设置账号', () =>
          WebDavLoginDialog().show(context, Runtime.user, (user) async {
            Runtime.user = user;
            Runtime.fileStorageAdapter.write(Constants.USER_INFO_FILE_NAME, json.encode(user));
            _initWebDavStorageServer(Runtime.user.storageServer as WebDavStorageServerConfiguration);
            _refreshDataFromStorage(Runtime.storageService);
          })),
      MenuItem('清除缓存', () {
        Runtime.fileStorageAdapter.delete(Constants.MODIFIED_MONTHLY_RECORD_FILE_NAME);
        Fluttertoast.showToast(msg: '清除成功');
      }),
      MenuItem('使用教程', () {}),
      MenuItem('关于我们', () {}),
    ];
  }

  void _initQuickAction() {
    // 配置 quick action
    QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      if ('add_record' == shortcutType)
        Future.delayed(Duration(milliseconds: 200), () => gotoDetailPageAndCreateRecord());
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      // NOTE: This first action icon will only work on iOS.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
        type: 'add_record',
        localizedTitle: '添加一笔',
        icon: 'AppIcon',
      ),
      // NOTE: This second action icon will only work on Android.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
        type: 'add_two',
        localizedTitle: '记录分析',
        icon: 'ic_launcher',
      ),
    ]);
  }

  /// 设置列表回调
  void _initRecordListCallBack() {
    _dailyRecordListView.setOnPressCallBack(onRecordListPress);
    _dailyRecordListView.addControllerListener(onRecordListListener);
  }

  /// 列表点击
  void onRecordListPress(Record record) {
    // 删除、修改
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => DetailPage(record: record)))
        .then((actionEntry) {
          if (null == actionEntry || !(actionEntry is ActionEntry<Record>)) return;
          ActionEntry<Record> action = actionEntry as ActionEntry<Record>;
          if (action.oldEntry == action.newEntry) return;
          if (action.deleted) {
            _addModifiedRecordLog([ModifiedRecordLog(record: action.oldEntry, operation: 0)]).then((_) {
              _saveRecordAndRefresh();
            });
          } else if (action.oldEntry != action.newEntry) {
            action.newEntry.createdUser = Runtime.username;
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
      LoadingDialog.runWithLoadingAsync(context, '加载中...', () async {
        await _fetchRecordFromStorage(Runtime.storageService, _month);
        _refreshRecordListView();
      });
    });
  }

  ///  跳转到详情页，并创建记录
  void gotoDetailPageAndCreateRecord() async {
    // 增加
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage())).then((actionEntry) {
      if (null == actionEntry || !(actionEntry is ActionEntry<Record>)) return;
      ActionEntry<Record> action = actionEntry as ActionEntry<Record>;
      if (null == action.newEntry || 0 >= action.newEntry.amount) return;
      action.newEntry.createdUser = Runtime.username;
      _addModifiedRecordLog([ModifiedRecordLog(record: action.newEntry, operation: 1)]).then((_) {
        _saveRecordAndRefresh();
      });
    });
  }

  /// 保存并刷新（先更新内存，刷新展示；再同步存储，刷新展示）
  void _saveRecordAndRefresh() async {
    Future.microtask(() {
      _saveRecordList().then((_) {
        _refreshRecordListView();
      });
    });
    if (Runtime.syncEveryModify) {
      LoadingDialog.runWithLoadingAsync(context, '同步中...', () async {
        await _flushRecordToStorage(Runtime.storageService);
        _refreshRecordListView();
      });
    }
  }

  /// 使用内存数据刷新列表组件
  Future<void> _refreshRecordListView() async {
    _dailyRecordListView.setMonthRecord(_monthlyRecordMap[_month]);
    setState(() => _title = _month);
  }

  /// 获取内存中日份的记录
  DailyRecord _getDailyRecord(String day) {
    String month = DateTimeUtil.getMonthByTimestamp(DateTimeUtil.getTimestampByDay(day));
    if (null == _monthlyRecordMap[month])
      _monthlyRecordMap[month] = MonthlyRecord(time: DateTimeUtil.getTimestampByMonth(month));
    MonthlyRecord monthlyRecord = _monthlyRecordMap[month];
    if (null == monthlyRecord.records[day])
      monthlyRecord.records[day] = DailyRecord(time: DateTimeUtil.getTimestampByDay(day));
    return monthlyRecord.records[day];
  }

  /// 添加修改记录到本地存储
  Future<void> _addModifiedRecordLog(List<ModifiedRecordLog> recordList) async {
    if (null == recordList || recordList.isEmpty) return;
    List<ModifiedRecordLog> modifiedRecordLogList = await _getModifiedRecordLogList();
    modifiedRecordLogList.addAll(recordList);
    await Runtime.fileStorageAdapter.write(Constants.MODIFIED_MONTHLY_RECORD_FILE_NAME, json.encode(modifiedRecordLogList));
  }

  /// 从本地存储获取待提交的修改记录
  Future<List<ModifiedRecordLog>> _getModifiedRecordLogList() async {
    String content = await Runtime.fileStorageAdapter.read(Constants.MODIFIED_MONTHLY_RECORD_FILE_NAME);
    if ('' == content) return List<ModifiedRecordLog>();
    return List.from(json.decode(content).map((e) => ModifiedRecordLog.fromJson(e)));
  }

  /// 获取存储的数据，并刷新到内存缓存
  Future<void> _fetchRecordFromStorage(StorageAdapter storageAdapter, String month) async {
    String fileName = Constants.getMonthlyRecordFileNameByMonth(month);
    MonthlyRecord monthlyRecord;
    // 获取数据
    if (null == monthlyRecord) {
      String content = '';
      try {
        content = await storageAdapter.read(fileName);
      } catch (e) {
        Fluttertoast.showToast(msg: '连接失败，请检查网络和webdav配置');
      }
      if ('' != content) monthlyRecord = MonthlyRecord.fromJson(json.decode(content));
      // 更新内存
      _monthlyRecordMap[month] = monthlyRecord;
      // 覆盖本地数据
      if (storageAdapter != Runtime.fileStorageAdapter)
        Runtime.fileStorageAdapter.write(fileName, content);
    }
    // 本地数据
    if (null == monthlyRecord) await _fetchRecordFromLocal(month);
  }

  /// 从本地资源获取月度记录（先读内存，内存没有则读文件）
  Future<void> _fetchRecordFromLocal(String month) async {
    String fileName = Constants.getMonthlyRecordFileNameByMonth(month);
    MonthlyRecord monthlyRecord;
    // 内存缓存
    if (null == monthlyRecord) monthlyRecord = _monthlyRecordMap[month];
    // 本地数据
    if (null == monthlyRecord) {
      String content = await Runtime.fileStorageAdapter.read(fileName);
      if ('' != content) monthlyRecord = MonthlyRecord.fromJson(json.decode(content));
    }
    // 没有获取到，创建月度记录
    if (null == monthlyRecord) monthlyRecord = MonthlyRecord(time: DateTimeUtil.getTimestampByMonth(month));
    // 更新内存
    _monthlyRecordMap[month] = monthlyRecord;
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
      await _fetchRecordFromLocal(month);
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
    // 改动数据涉及到的月份
    Set<String> months = {DateTimeUtil.getMonthByTimestamp(DateTimeUtil.getTimestamp())};
    modifiedRecordLogList.forEach((log) => months.add(DateTimeUtil.getMonthByTimestamp(log.record.time)));
    for (String month in months) {
      await _fetchRecordFromStorage(Runtime.storageService, month);
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
        await Runtime.fileStorageAdapter.write(Constants.getMonthlyRecordFileNameByMonth(month), json.encode(_monthlyRecordMap[month]));
        await Runtime.storageService.write(Constants.getMonthlyRecordFileNameByMonth(month), json.encode(_monthlyRecordMap[month]));
      } catch (e) {
        Fluttertoast.showToast(msg: '同步$month失败');
      }
      Runtime.fileStorageAdapter.delete(Constants.MODIFIED_MONTHLY_RECORD_FILE_NAME);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xEEEEEEEE),
      appBar: AppBar(
        title: FlatButton.icon(
          onPressed: onTitlePress,
          icon: Icon(Icons.expand_more, color: Colors.white,),
          label: Text(_title, style: TextStyle(fontSize: 20, color: Colors.white),),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.sync), onPressed: () {
              LoadingDialog.runWithLoadingAsync(context, '同步中...', () async {
                await _flushRecordToStorage(Runtime.storageService);
                _refreshRecordListView();
                Fluttertoast.showToast(msg: '同步完成');
              });
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
          ? FloatingActionButton(child: Icon(Icons.add), onPressed: gotoDetailPageAndCreateRecord)
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
