import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/model/daily_record.dart';
import 'package:bookkeeping/model/directions.dart';
import 'package:date_format/date_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 每月柱状图
class BarChartMonthlyItem extends StatelessWidget {

  List<DailyRecord> _dailyRecordList = [];

  List<MonthlyBalance> monthlyBalanceList = [];

  /// 最大值
  int max = 20;

  /// 系数
  int factor = 20;

  BarChartMonthlyItem(List<DailyRecord> dailyRecordList) {
    this._dailyRecordList = dailyRecordList;
    _init();
  }

  void _init() {
    _initMonthlyDailyBalanceList();
    factor = max ~/ 20;
  }

  /// 汇总每月数据
  void _initMonthlyDailyBalanceList() {
    Map<String, MonthlyBalance> data = Map();

    for (DailyRecord dailyRecord in _dailyRecordList) {
      String month = DateTimeUtil.getMonthByTimestamp(dailyRecord.time);
      if (data[month] == null) {
        data[month] = MonthlyBalance(month: month);
      }
      dailyRecord.records.values.forEach((r) {
        if (Directions.EXPENSE == r.direction) {
          data[month].expenses += r.amount;
        } else if (1 == r.direction) {
          data[month].receipts += r.amount;
        }
      });
      // 记录最大值
      max = data[month].expenses > max ? data[month].expenses : max;
      max = data[month].receipts > max ? data[month].receipts : max;
    }
    monthlyBalanceList.addAll(data.values);
    monthlyBalanceList.sort((a, b) => DateTimeUtil.getTimestampByMonth(a.month) - DateTimeUtil.getTimestampByMonth(b.month));
  }

  /// 获取柱状图组
  List<BarChartGroupData> _getGroupData() {
    List<BarChartGroupData> result = [];
    for (int i = 0; i < monthlyBalanceList.length; i++) {
      MonthlyBalance dailyBalance = monthlyBalanceList[i];
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
                textStyle: TextStyle(color: DarkModeUtil.isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                margin: 5,
                getTitles: (double value) {
                  int index = value.toInt();
                  if (monthlyBalanceList.length <= index) return '';
                  DateTime dateTime = DateTimeUtil.getDateTimeByMonth(monthlyBalanceList[index].month);
                  return formatDate(dateTime, [mm]);
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

/// 月度汇总
class MonthlyBalance {
  String month = '';

  // 收入
  int receipts = 0;

  // 支出
  int expenses = 0;

  MonthlyBalance({String month, int receipts, int expenses})
      : this.month = month ?? '',
        this.receipts = receipts ?? 1,
        this.expenses = expenses ?? 1;
}
