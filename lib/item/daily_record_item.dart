import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/model/daily_record.dart';
import 'package:bookkeeping/model/directions.dart';
import 'package:bookkeeping/model/record.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DailyRecordItem extends StatelessWidget {
  final DailyRecord _dailyRecord;
  final Function _onPressCallBack;

  DailyRecordItem(this._dailyRecord, this._onPressCallBack);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    rows.add(_getTitleWidget());
    rows.addAll(_getRecordWidgetList());

    return Container(
      margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        color: DarkModeUtil.isDarkMode(context) ? Color(0xFF222222) : Colors.white,
      ),
      child: Column(children: rows),
    );
  }

  Widget _getTitleWidget() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
      child: Row(children: <Widget>[
        Expanded(child: Text(_getDateStr(), textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w700))),
        Expanded(
            child: Text(_getBalanceStr(), textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700)))
      ]),
    );
  }

  List<Widget> _getRecordWidgetList() {
    List<Widget> result = [];
    List<Record> recordList = List.from(_dailyRecord.records.values);
    recordList.sort((a, b) => b.time - a.time);
    for (Record record in recordList) {
      result.add(_getRecordWidget(record));
    }
    return result;
  }

  Widget _getRecordWidget(Record record) {
    return FlatButton(
      onPressed: () {
        if (null != _onPressCallBack) _onPressCallBack(record);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Icon(Icons.fiber_manual_record, color: _getColor(record), size: 10),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(record.category, style: TextStyle(fontSize: 15)),
                _getRemarkWidget(record.remark),
              ],
            ),
            Expanded(
              child: Text(
                _getAmount(record),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 16, color: _getColor(record)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 返回备注组件
  Widget _getRemarkWidget(String remark) {
    return null != remark && '' != remark
        ? Container(constraints: BoxConstraints(maxWidth: 100), child: Text(
            remark, style: TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis))
        : Container();
  }

  String _getDateStr() {
    DateTime dateTime = DateTimeUtil.getDateTimeByTimestamp(_dailyRecord.time);
    return formatDate(dateTime, [mm, '-', dd, ' ']) + DateTimeUtil.WEEKDAY_LIST[dateTime.weekday - 1];
  }

  String _getBalanceStr() {
    int expenses = 0;
    int receipts = 0;
    for (Record record in _dailyRecord.records.values) {
      if (Directions.EXPENSE == record.direction)
        expenses += record.amount;
      else
        receipts += record.amount;
    }
    return (receipts > 0 ? ' 收: ' + (receipts / 100).toStringAsFixed(2) : '') +
        ' 支: ' +
        (expenses / 100).toStringAsFixed(2);
  }

  Color _getColor(Record record) => Directions.EXPENSE == record.direction ? Colors.deepOrange : Colors.blue;

  String _getAmount(Record record) => (Directions.EXPENSE == record.direction ? '-' : '+') + (record.amount / 100).toStringAsFixed(2);
}
