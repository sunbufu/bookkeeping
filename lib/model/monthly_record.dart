import 'package:bookkeeping/model/daily_record.dart';
import 'package:flutter/cupertino.dart';

/// 月度记录
class MonthlyRecord {
  /// 月份时间戳（日期时间为 -01 00:00:00）
  int time;

  /// 记录（key 日期 2020-04-04，value 日记录）
  Map<String, DailyRecord> records;

  MonthlyRecord({@required int time, Map<String, DailyRecord> records}) {
    this.time = time;
    this.records = records ?? {};
  }

  factory MonthlyRecord.fromJson(Map<String, dynamic> json) => MonthlyRecord(
        time: json["time"],
        records: Map<String, DailyRecord>.from(json["records"].map((k, v) => MapEntry(k, DailyRecord.fromJson(v)))),
      );

  Map<String, dynamic> toJson() =>
      {"time": time, "records": Map<dynamic, dynamic>.from(records.map((k, v) => MapEntry(k, v.toJson())))};
}
