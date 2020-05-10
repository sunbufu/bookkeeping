import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/item/monthly_days_bar_chart_item.dart';
import 'package:bookkeeping/item/seven_days_bar_chart_item.dart';
import 'package:bookkeeping/model/directions.dart';
import 'package:bookkeeping/model/monthly_record.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 月度汇总
class MonthlyRecordItem extends StatelessWidget {
  MonthlyRecord _monthlyRecord;

  String month;
  // 结余
  int balance = 0;
  // 收入
  int receipts = 0;
  // 支出
  int expenses = 0;

  // 详情模式（展示该月每日柱状图）
  bool _detailed = false;

  MonthlyRecordItem(MonthlyRecord _monthlyRecord, {detailed: false}) {
    this._monthlyRecord = _monthlyRecord;
    this._detailed = detailed;
    if (null != this._monthlyRecord) {
      month = null != _monthlyRecord ? DateTimeUtil.getMonthByTimestamp(_monthlyRecord.time) : '';
      _monthlyRecord.records.forEach((m, dr) {
        dr.records.forEach((id, r) {
          if (Directions.EXPENSE == r.direction) {
            balance -= r.amount;
            expenses += r.amount;
          } else if (1 == r.direction) {
            balance += r.amount;
            receipts += r.amount;
          }
        });
      });
    }
  }

  Widget _getBalance() {
    return Column(
      children: <Widget>[
        Container(height: 10),
        Text('月结余', style: TextStyle(fontSize: 12)),
        Text(
          (Decimal.fromInt(balance) / Decimal.fromInt(100)).toStringAsFixed(2),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _getReceipts() {
    return Column(
      children: <Widget>[
        Text('月收入', style: TextStyle(fontSize: 12)),
        Text(
          (Decimal.fromInt(receipts) / Decimal.fromInt(100)).toStringAsFixed(2),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _getExpenses() {
    return Column(
      children: <Widget>[
        Text('月支出', style: TextStyle(fontSize: 12)),
        Text(
          (Decimal.fromInt(expenses) / Decimal.fromInt(100)).toStringAsFixed(2),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if(null == _monthlyRecord) return Container();
    return Container(
      margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        color: DarkModeUtil.isDarkMode(context) ? Color(0xFF222222) : Colors.white,
      ),
      child: Column(children: <Widget>[
        _getBalance(),
        Row(children: <Widget>[
          Expanded(child: _getReceipts(),),
          Expanded(child: _getExpenses(),),
        ],),
        Container(height: 10),
        _getBarChart(),
      ]),
    );
  }

  /// 柱状图
  Widget _getBarChart() {
    if (_detailed) {
      return MonthlyDaysBarChartItem(_monthlyRecord);
    }
    if (DateTimeUtil.isCurrentMonth(_monthlyRecord.time)) {
      return SevenDaysBarChartItem(monthlyRecord: _monthlyRecord);
    }
    return Container();
  }
}
