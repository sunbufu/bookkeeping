import 'package:bookkeeping/common/constants.dart';
import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/dialog/loading_dialog.dart';
import 'package:bookkeeping/model/record.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 数据导入
class ImportPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => ImportPageState();
}

class ImportPageState extends State<ImportPage> {

  Decimal decimal_100 = Decimal.fromInt(100);

  String stepOneMessage = '';
  String stepThreeMessage = '';

  /// 导入
  void _import () async {
    LoadingDialog.show(context);
    // 读取数据
    String content = await Runtime.storageService.read(Constants.TEMPLATE_FILE_NAME);
    List<String> recordContentList = [];
    if (recordContentList.isEmpty && content.contains('\r\n')) recordContentList = content.split('\r\n');
    if (recordContentList.isEmpty && content.contains('\n')) recordContentList = content.split('\n');
    LoadingDialog.dismiss();
    if (1 >= recordContentList.length) {
      setState(() => stepThreeMessage = '\n【导入失败，未读取到有效数据，请检查文件后重试】');
      return;
    }
    // 转化为 record
    List<Record> recordList = [];
    for (int i = 1; i < recordContentList.length; i++) {
      if (null == recordContentList[i] || '' == recordContentList[i]) continue;
      Record record;
      try {
        record = _convert(recordContentList[i].split(','));
      } catch (e) {
        setState(() => stepThreeMessage = '\n【导入失败，第 ${i + 1} 行数据有误，请检查后重试】');
        return;
      }
      if (null == record) continue;
      recordList.add(record);
    }
    // 弹出提示框
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: Text('读取到 ${recordList.length} 条记录'),
            content: Text('导入时间的长短与网络和数据量有关，请勿将应用置于后台!'),
            actions: <Widget>[
              FlatButton(child: Text('取消'), onPressed: () => Navigator.pop(context)),
              FlatButton(
                  child: Text('导出'),
                  onPressed: () {
                    setState(() => stepThreeMessage = '\n【导入成功】');
                    Navigator.pop(context);
                    Navigator.pop(context, recordList);
                  })
            ]));
  }

  Record _convert (List<String> recordFieldList) {
    if (5 > recordFieldList.length || '' == recordFieldList[0]) return null;
    int time = DateTimeUtil.getTimestampByFormat(recordFieldList[0], 'yyyy/MM/dd HH:mm:ss');
    if (0 == time) time = DateTimeUtil.getTimestampByFormat(recordFieldList[0], 'yyyy/MM/dd HH:mm');
    if (0 == time) time = DateTimeUtil.getTimestampByString(recordFieldList[0]);
    String category = recordFieldList[1];
    int direction = '收入' == recordFieldList[2] ? 1 : 0;
    int amount = (Decimal.parse(recordFieldList[3]) * decimal_100).toInt();
    String remark = recordFieldList.length > 4 ? recordFieldList[4] : '';
    String createdUser = recordFieldList.length > 5 ? recordFieldList[5] : '';
    return Record(
        amount: amount,
        direction: direction,
        category: category,
        remark: remark,
        time: time,
        createdUser: createdUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkModeUtil.isDarkMode(context) ? Colors.black : Color(0xFFEEEEEE),
      appBar: AppBar(title: Text('数据导入'), centerTitle: true),
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          color: DarkModeUtil.isDarkMode(context) ? Color(0xFF222222) : Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(margin: EdgeInsets.only(top: 20)),
              Text('1. 生成模板', style: TextStyle(fontSize: 20)),
              OutlineButton(child: Text('生成模版'), onPressed: () {
                Runtime.storageService.write(Constants.TEMPLATE_FILE_NAME, Constants.TEMPLATE_FILE_HEAD);
                setState(() => stepOneMessage = '\n【生成成功】');
              }),
              Text('点击"生成模版"，在 webdav 服务器中查看。$stepOneMessage'),
              Image(image: AssetImage('images/import_step1.png')),
              Container(margin: EdgeInsets.only(top: 20)),
              Text('2. 适配数据', style: TextStyle(fontSize: 20)),
              Text('下载模板"${Constants.TEMPLATE_FILE_NAME}"，按照模板补充待导入的数据。'),
              Image(image: AssetImage('images/import_step2.png')),
              Text('注：时间、分类、收入或支出、金额为必填项。', style: TextStyle(fontSize: 11, color: Colors.red)),
              Container(margin: EdgeInsets.only(top: 20)),
              Text('3. 数据导入', style: TextStyle(fontSize: 20)),
              OutlineButton(child: Text('数据导入'), onPressed: () => _import()),
              Text('上传表格到 WebDav 服务器，点击"数据导入"导入数据。$stepThreeMessage'),
              Container(margin: EdgeInsets.only(top: 20)),
            ],
          ),
        ),
      )
    );
  }
}
