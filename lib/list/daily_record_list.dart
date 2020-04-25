
import 'package:bookkeeping/item/daily_record_item.dart';
import 'package:bookkeeping/item/monthly_record_item.dart';
import 'package:bookkeeping/model/daily_record.dart';
import 'package:bookkeeping/model/monthly_record.dart';
import 'package:bookkeeping/model/record.dart';
import 'package:flutter/cupertino.dart';

/// 日度记录列表视图
class DailyRecordList extends StatefulWidget {

  DailyRecordListState state;

  void setMonthRecord(MonthlyRecord monthlyRecord) => state.setMonthRecord(monthlyRecord);
  
  void setOnPressCallBack(Function(Record) onPressCallback) => state.onPressCallback = onPressCallback;

  void addControllerListener(Function(ScrollController) controllerListener) =>
      state.addControllerListener(controllerListener);

  @override
  State<StatefulWidget> createState() {
    state = DailyRecordListState();
    return state;
  }
}

class DailyRecordListState extends State<DailyRecordList> {

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
    list.sort((a, b) => a.time - b.time);
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
    return ListView.builder(
        controller: _controller,
        itemCount: _list.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (0 == index) {
            return MonthlyRecordItem(_monthlyRecord);
          } else {
            return DailyRecordItem(_list[index-1], (record) {
              if (null != onPressCallback) onPressCallback(record);
            }); 
          }
        }
    );
  }
}
