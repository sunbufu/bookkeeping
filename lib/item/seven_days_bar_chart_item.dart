import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/model/daily_record.dart';
import 'package:bookkeeping/model/directions.dart';
import 'package:bookkeeping/model/monthly_record.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 七日柱状图
class SevenDaysBarChartItem extends StatelessWidget {
  MonthlyRecord _monthlyRecord;

  List<DateTime> sevenDayList = [];

  List<DailyBalance> sevenDailyBalanceList = [];

  /// 最大值
  int max = 20;

  /// 系数
  int factor = 20;

  SevenDaysBarChartItem({MonthlyRecord monthlyRecord}) {
    this._monthlyRecord = monthlyRecord;
    _init();
  }

  void _init() {
    _initSevenDay();
    _initSevenDailyBalanceList();
    factor = max ~/ 20;
  }

  /// 寻找本月的七天（七号之前早前七天）
  void _initSevenDay() {
    DateTime now = DateTime.now();
    int day = now.day;
    for (int i = 0; i < (day >= 7 ? 7 : day); i++) {
      DateTime dateTime = now.subtract(Duration(days: i));
      sevenDayList.add(dateTime);
    }
    for (int i = 1; i < (day >= 7 ? 0 : 7 - day + 1); i++) {
      DateTime dateTime = now.add(Duration(days: i));
      sevenDayList.add(dateTime);
    }
    sevenDayList.sort();
  }

  /// 汇总七日数据
  void _initSevenDailyBalanceList() {
    for (DateTime dateTime in sevenDayList) {
      String day = DateTimeUtil.getDayByTimestamp(DateTimeUtil.getTimestampByDateTime(dateTime));
      DailyRecord dailyRecord = _monthlyRecord.records[day];
      if (null == dailyRecord) {
        sevenDailyBalanceList.add(DailyBalance(day: '${dateTime.day}'));
      } else {
        int expenses = 1;
        int receipts = 1;
        dailyRecord.records.values.forEach((r) {
          if (Directions.EXPENSE == r.direction) {
            expenses += r.amount;
          } else if (1 == r.direction) {
            receipts += r.amount;
          }
        });
        sevenDailyBalanceList.add(DailyBalance(day: '${dateTime.day}', expenses: expenses, receipts: receipts));
        // 记录最大值
        max = expenses > max ? expenses : max;
        max = receipts > max ? receipts : max;
      }
    }
  }

  /// 获取柱状图组
  List<BarChartGroupData> _getGroupData() {
    List<BarChartGroupData> result = [];
    for (int i = 0; i < sevenDailyBalanceList.length; i++) {
      DailyBalance dailyBalance = sevenDailyBalanceList[i];
      result.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(y: dailyBalance.expenses / factor, color: Colors.deepOrange),
        BarChartRodData(y: dailyBalance.receipts / factor, color: Colors.blue),
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
                getTitles: (double value) => sevenDailyBalanceList[value.toInt()].day,
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
