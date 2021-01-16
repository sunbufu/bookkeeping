import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/model/daily_record.dart';
import 'package:bookkeeping/model/directions.dart';
import 'package:date_format/date_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 细每日柱状图（可展示30天数据）
class BarChartDailyThinItem extends StatelessWidget {

  List<DailyRecord> _dailyRecordList = [];

  List<DailyBalance> dailyBalanceList = [];

  /// 最大值
  int max = 20;

  /// 系数
  int factor = 20;

  BarChartDailyThinItem(List<DailyRecord> dailyRecordList) {
    this._dailyRecordList = dailyRecordList;
    _init();
  }

  void _init() {
    _initMonthlyDailyBalanceList();
    factor = max ~/ 20;
  }

  /// 汇总每日数据
  void _initMonthlyDailyBalanceList() {
    for (DailyRecord dailyRecord in _dailyRecordList) {
      String day = DateTimeUtil.getDayByTimestamp(dailyRecord.time);
      int expenses = 1;
      int receipts = 1;
      dailyRecord.records.values.forEach((r) {
        if (Directions.EXPENSE == r.direction) {
          expenses += r.amount;
        } else if (1 == r.direction) {
          receipts += r.amount;
        }
      });
      dailyBalanceList.add(DailyBalance(day: day, expenses: expenses, receipts: receipts));
      // 记录最大值
      max = expenses > max ? expenses : max;
      max = receipts > max ? receipts : max;
    }
  }

  /// 获取柱状图组
  List<BarChartGroupData> _getGroupData() {
    List<BarChartGroupData> result = [];
    for (int i = 0; i < dailyBalanceList.length; i++) {
      DailyBalance dailyBalance = dailyBalanceList[i];
      result.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(y: dailyBalance.expenses / factor, color: Colors.deepOrange, width: 3),
        BarChartRodData(y: dailyBalance.receipts / factor, color: Colors.blue, width: 3),
      ]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.9,
      child: Card(
        color: DarkModeUtil.isDarkMode(context) ? Color(0xFF222222) : Colors.white,
        margin: EdgeInsets.only(left: 10, right: 10),
        elevation: 0,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 20,
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.transparent,
                tooltipPadding: const EdgeInsets.all(0),
                tooltipBottomMargin: 8,
                getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
                  return BarTooltipItem(
                      rod.y.round().toString(), TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: SideTitles(
                showTitles: true,
                textStyle: TextStyle(
                    color: DarkModeUtil.isDarkMode(context) ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
                margin: 5,
                getTitles: (double value) {
                  int index = value.toInt();
                  if (dailyBalanceList.length <= index) return '';
                  DateTime dateTime = DateTimeUtil.getDateTimeByDay(dailyBalanceList[index].day);
                  String day = formatDate(dateTime, [dd]);
                  return (int.parse(day) - 1) % 4 == 0 ? day : '';
                },
              ),
              leftTitles: SideTitles(showTitles: false),
            ),
            borderData: FlBorderData(show: false),
            barGroups: _getGroupData(),
          ),
        ),
      ),
    );
  }
}

/// 日度汇总
class DailyBalance {
  String day = '';

  // 收入
  int receipts = 0;

  // 支出
  int expenses = 0;

  DailyBalance({String day, int receipts, int expenses})
      : this.day = day ?? '',
        this.receipts = receipts ?? 1,
        this.expenses = expenses ?? 1;
}
