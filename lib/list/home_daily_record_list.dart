
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/item/home_daily_record_list_item.dart';
import 'package:bookkeeping/item/monthly_record_item.dart';
import 'package:bookkeeping/model/daily_record.dart';
import 'package:bookkeeping/model/monthly_record.dart';
import 'package:bookkeeping/model/record.dart';
import 'package:flutter/cupertino.dart';

/// 主页日度记录列表视图
class HomeDailyRecordList extends StatefulWidget {

  HomeDailyRecordListState state;

  void setMonthRecord(MonthlyRecord monthlyRecord) => state.setMonthRecord(monthlyRecord);
  
  void setOnPressCallBack(Function(Record) onPressCallback) => state.onPressCallback = onPressCallback;

  void addControllerListener(Function(ScrollController) controllerListener) =>
      state.addControllerListener(controllerListener);

  @override
  State<StatefulWidget> createState() {
    state = HomeDailyRecordListState();
    return state;
  }
}

class HomeDailyRecordListState extends State<HomeDailyRecordList> {

  List<DailyRecord> _list = [];

  MonthlyRecord _monthlyRecord;
  
  Function(Record) onPressCallback;

  ScrollController _controller = ScrollController();

  void addControllerListener(Function(ScrollController) controllerListener) {
    _controller.addListener(() {
      if (null != controllerListener) controllerListener(_controller);
    });
  }

  void setMonthRecord(MonthlyRecord monthlyRecord) {
    if (null == monthlyRecord) return;
    this._monthlyRecord = monthlyRecord;
    List<DailyRecord> list = List.from(_monthlyRecord.records.values);
    list.sort((a, b) => b.time - a.time);
    Set<DailyRecord> deletedDailyRecords = {};
    list.forEach((dr) {
      if (null == dr || 0 >= dr.records.length) deletedDailyRecords.add(dr);
    });
    deletedDailyRecords.forEach((ddr)=>list.remove(ddr));
    this._list = list;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<DailyRecord> sevenDailyRecordList = [];
    List<String> sevenDayList = getSevenDayList();
    sevenDayList.forEach((day) {
      DailyRecord dailyRecord = _monthlyRecord != null ? _monthlyRecord.records[day] : null;
      if (dailyRecord == null) {
        dailyRecord = DailyRecord(time: DateTimeUtil.getTimestampByDay(day));
      }
      sevenDailyRecordList.add(dailyRecord);
    });
    
    return ListView.builder(
        controller: _controller,
        itemCount: _list.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (0 == index) {
            return BarChartItem(sevenDailyRecordList);
          } else {
            return HomeDailyRecordListItem(_list[index-1], (record) {
              if (null != onPressCallback) onPressCallback(record);
            }); 
          }
        }
    );
  }

  /// 寻找本月的七天（七号之前早前七天）
  List<String> getSevenDayList() {
    List<String> result = [];
    DateTime now = DateTime.now();
    int day = now.day;
    for (int i = 0; i < (day >= 7 ? 7 : day); i++) {
      DateTime dateTime = now.subtract(Duration(days: i));
      result.add(DateTimeUtil.formatLineDay(dateTime));
    }
    for (int i = 1; i < (day >= 7 ? 0 : 7 - day + 1); i++) {
      DateTime dateTime = now.add(Duration(days: i));
      result.add(DateTimeUtil.formatLineDay(dateTime));
    }
    result.sort();
    return result;
  }
}
