import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/dialog/loading_dialog.dart';
import 'package:bookkeeping/dialog/month_picker_dialog.dart';
import 'package:bookkeeping/item/monthly_record_item.dart';
import 'package:bookkeeping/model/daily_record.dart';
import 'package:bookkeeping/model/directions.dart';
import 'package:bookkeeping/model/monthly_record.dart';
import 'package:bookkeeping/model/record.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 统计页面
class StatisticPage extends StatefulWidget {
  String month;
  MonthlyRecord monthlyRecord;

  StatisticPage(this.month) {
    monthlyRecord = Runtime.monthlyRecordMap[month];
  }

  @override
  State<StatefulWidget> createState() => StatisticPageState();
}

class StatisticPageState extends State<StatisticPage> {

  /// 流向（0 支出，1 收入）
  int direction = 0;

  /// 饼图点击的下标
  int pieChartTouchedIndex;

  /// 收入分类数据
  Map<String, List<Record>> receiptsCategoryRecordMap = {};

  /// 收入分类统计数据
  Map<String, int> receiptsCategoryAmountMap = {};

  /// 收入总计
  int receiptsAmountSum = 0;

  /// 收入饼图数据
  List<PieChartItemData> receiptsPieChartItemDataList = [];

  /// 支出分类数据
  Map<String, List<Record>> expensesCategoryRecordMap = {};

  /// 支出分类统计数据
  Map<String, int> expensesCategoryAmountMap = {};

  /// 支出总计
  int expensesAmountSum = 0;

  /// 支出饼图数据
  List<PieChartItemData> expensesPieChartItemDataList = [];

  /// 标题点击
  void onTitlePress() {
    MonthPickerDialog.showDialog(context, widget.month, (dateTime) {
      LoadingDialog.show(context);
      widget.month = DateTimeUtil.getMonthByTimestamp(DateTimeUtil.getTimestampByDateTime(dateTime));
      Runtime.recordService.fetchRecordFromStorage(Runtime.storageService, widget.month).then((_) {
        LoadingDialog.dismiss();
        widget.monthlyRecord = Runtime.monthlyRecordMap[widget.month];
        _initData();
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // 初始化收入数据
    receiptsCategoryRecordMap = {};
    receiptsCategoryAmountMap = {};
    receiptsAmountSum = 0;
    receiptsPieChartItemDataList = [];
    // 初始化支出数据
    expensesCategoryRecordMap = {};
    expensesCategoryAmountMap = {};
    expensesAmountSum = 0;
    expensesPieChartItemDataList = [];

    if (null == widget.monthlyRecord || null == widget.monthlyRecord.records) return;
    for (DailyRecord dailyRecord in widget.monthlyRecord.records.values) {
      if(null == dailyRecord.records) continue;
      dailyRecord.records.values.forEach((record) {
        if (1 == record.direction) {
          // 收入
          receiptsAmountSum += record.amount;
          if (!receiptsCategoryRecordMap.containsKey(record.category)) receiptsCategoryRecordMap[record.category] = <Record>[];
          receiptsCategoryRecordMap[record.category].add(record);
          if (!receiptsCategoryAmountMap.containsKey(record.category)) receiptsCategoryAmountMap[record.category] = 0;
          receiptsCategoryAmountMap[record.category] += record.amount;
        } else {
          // 支出
          expensesAmountSum += record.amount;
          if (!expensesCategoryRecordMap.containsKey(record.category)) expensesCategoryRecordMap[record.category] = <Record>[];
          expensesCategoryRecordMap[record.category].add(record);
          if (!expensesCategoryAmountMap.containsKey(record.category)) expensesCategoryAmountMap[record.category] = 0;
          expensesCategoryAmountMap[record.category] += record.amount;
        }
      });
    }
    // 收入
    Decimal receiptsAmountSumDecimal = Decimal.fromInt(receiptsAmountSum);
    receiptsCategoryAmountMap.forEach((category, amount) {
      receiptsPieChartItemDataList
          .add(PieChartItemData(Decimal.fromInt(amount) / receiptsAmountSumDecimal, amount / 100, category));
    });
    receiptsPieChartItemDataList.sort((a, b) => (b.value * 100 - a.value * 100).toInt());
    for (int i = 0; i < receiptsPieChartItemDataList.length; i++) {
      receiptsPieChartItemDataList[i].index = i;
    }
    // 支出
    Decimal expensesAmountSumDecimal = Decimal.fromInt(expensesAmountSum);
    expensesCategoryAmountMap.forEach((category, amount) {
      expensesPieChartItemDataList
          .add(PieChartItemData(Decimal.fromInt(amount) / expensesAmountSumDecimal, amount / 100, category));
    });
    expensesPieChartItemDataList.sort((a, b) => (b.value * 100 - a.value * 100).toInt());
    for (int i = 0; i < expensesPieChartItemDataList.length; i++) {
      expensesPieChartItemDataList[i].index = i;
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
          label: Text(widget.month, style: TextStyle(fontSize: 20, color: Colors.white),),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 月度汇总
            MonthlyRecordItem(Runtime.monthlyRecordMap[widget.month], detailed: true),
            // 分类汇总
            buildPieChart()
          ],
        ),
      )
    );
  }

  /// 分类统计模块
  Widget buildPieChart() {
    return Container(
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
            padding: EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              color: DarkModeUtil.isDarkMode(context) ? Color(0xFF222222) : Colors.white,
            ),
            child: Column(
              children: <Widget>[
                Text('分类统计'),
                PieChart(PieChartData(
                    pieTouchData: PieTouchData(touchCallback: (touch) {
                      if (touch.touchInput is FlPanStart || touch.touchInput is FlLongPressMoveUpdate) {
                        int newIndex = touch.touchedSectionIndex ?? -1;
                        if(pieChartTouchedIndex != newIndex)
                          setState(() => pieChartTouchedIndex = newIndex);
                      }
                    }),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 0,
                    sections: Directions.EXPENSE == direction
                        ? generatePieChartSectionDataList(expensesPieChartItemDataList)
                        : generatePieChartSectionDataList(receiptsPieChartItemDataList))),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Text('收入'),
                  Switch(value: direction == Directions.EXPENSE, onChanged: (v) {
                    direction = (v ? Directions.EXPENSE : Directions.RECEIPTS);
                    setState((){});
                  }),
                  Text('支出'),
                ]),
                Column(children: _getCategoryItemList(),),
              ],
            )
          );
  }

  /// 饼图颜色
  List<Color> pieChartColorList = [Colors.blue, Colors.orangeAccent, Colors.purple, Colors.green];
  /// 饼图字体
  TextStyle pieChartTitleStyle = TextStyle(fontSize: 15, color: Colors.white);
  /// 饼图点击字体
  TextStyle pieChartTitleTouchedStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white);

  /// 生成饼图数据
  List<PieChartSectionData> generatePieChartSectionDataList(List<PieChartItemData> pieCharItemDateList) {
    if(null == pieCharItemDateList || pieCharItemDateList.isEmpty) {
      return [generatePieChartSectionData(PieChartItemData(Decimal.fromInt(1), 1, '', index: 0))];
    }
    return pieCharItemDateList.map((e) => generatePieChartSectionData(e)).toList();
  }

  /// 饼图数据转化为展示区域数据
  PieChartSectionData generatePieChartSectionData(PieChartItemData pieChartData) {
    bool isTouched = pieChartTouchedIndex == pieChartData.index;
    String title = '';
    if ('' != pieChartData.title) {
      title = pieChartData.percentage >= Decimal.parse('0.19') || pieChartData.index < 2 || isTouched
          ? '${pieChartData.title}${(pieChartData.percentage * Decimal.fromInt(100)).toStringAsFixed(2)}%'
          : '';
    }
    return PieChartSectionData(
      color: pieChartColorList[pieChartData.index % pieChartColorList.length].withOpacity(isTouched ? 0.6 : 1),
      value: pieChartData.value,
      title: title,
      radius: 120,
      titleStyle: isTouched ? pieChartTitleTouchedStyle : pieChartTitleStyle,
      titlePositionPercentageOffset: 0.6,
    );
  }

  /// 分类列表
  List<Widget> _getCategoryItemList() {
    List<Widget> result = [];
    List<PieChartItemData> pieChartItemDataList =
        Directions.EXPENSE == direction ? expensesPieChartItemDataList : receiptsPieChartItemDataList;
    for (PieChartItemData pieChartItemData in pieChartItemDataList) {
      result.add(_getCategoryItem(pieChartItemData));
    }
    return result;
  }

  /// 分类
  Widget _getCategoryItem(PieChartItemData pieChartItemData) {
    return FlatButton(
      onPressed: () => _showCategoryItemDetail(pieChartItemData),
      child: Container(
        padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
        child: Row(
          children: <Widget>[
            CircleAvatar(child: Text(pieChartItemData.title.substring(0, 1)), foregroundColor: Colors.white),
            Container(padding: EdgeInsets.only(left: 15)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(pieChartItemData.title),
              Text('${(pieChartItemData.percentage * Decimal.fromInt(100)).toStringAsFixed(2)}%'),
            ]),
            Expanded(child: Text(Directions.EXPENSE == direction
                ? '-${(expensesCategoryAmountMap[pieChartItemData.title] / 100).toStringAsFixed(2)}'
                : '+${(receiptsCategoryAmountMap[pieChartItemData.title] / 100).toStringAsFixed(2)}',
              style: TextStyle(color: _getAmountColor()),
              textAlign: TextAlign.right,),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAmountColor() => Directions.EXPENSE == direction ? Colors.deepOrange : Colors.blue;

  /// 展示分类弹出框
  void _showCategoryItemDetail(PieChartItemData pieChartItemData) {
    Map<String, List<Record>> categoryRecordMap = Directions.EXPENSE == direction ? expensesCategoryRecordMap : receiptsCategoryRecordMap;
    List<Record> categoryRecordList = categoryRecordMap[pieChartItemData.title];
    showModalBottomSheet(context: context, builder: (context) {
      return Container(height: (100 + 60 * categoryRecordList.length).toDouble(),
          child: SingleChildScrollView(padding: EdgeInsets.all(0), child: Column(children: _getCategoryItemDetailList(pieChartItemData))),
      );
    });
  }

  /// 分类弹出框详情列表
  List<Widget> _getCategoryItemDetailList(PieChartItemData pieChartItemData) {
    List<Widget> result = [];
    Map<String, int> categoryAmountMap = Directions.EXPENSE == direction ? expensesCategoryAmountMap : receiptsCategoryAmountMap;
    Map<String, List<Record>> categoryRecordMap = Directions.EXPENSE == direction ? expensesCategoryRecordMap : receiptsCategoryRecordMap;
    List<Record> categoryRecordList = categoryRecordMap[pieChartItemData.title];
    categoryRecordList.sort((a, b) => b.time - a.time);
    result.add(Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          Text('${pieChartItemData.title} (${categoryRecordList.length}条)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
                '${Directions.EXPENSE == direction ? '-' : '+'}${(categoryAmountMap[pieChartItemData.title] / 100).toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 15, color: _getAmountColor(), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    ));
    categoryRecordList.forEach((record) {
      String title =
          '${record.createdUser.isEmpty ? '' : '创建人:' + record.createdUser + ' '}${record.remark.isEmpty ? '' : '备注:' + record.remark}';
      result.add(Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          children: <Widget>[
            Container(margin: EdgeInsets.only(right: 10), child: Icon(Icons.fiber_manual_record, color: _getAmountColor(), size: 10),),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('${DateTimeUtil.getYearMonthDayTimeByTimestamp(record.time)}'),
              title.isEmpty ? Container() : Text(title, style: TextStyle(fontSize: 12)),
            ]),
            Expanded(child: Text(
                '${Directions.EXPENSE == direction ? '-' : '+'}${(record.amount / 100).toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 15, color: _getAmountColor())),
            )
          ],
        )
      ));
    });
    result.add(Container(margin: EdgeInsets.only(bottom: 30)));
    return result;
  }
}

/// 饼图数据
class PieChartItemData {
  int index;
  Decimal percentage;
  double value;
  String title;

  PieChartItemData(this.percentage, this.value, this.title, {this.index : 0});
}
