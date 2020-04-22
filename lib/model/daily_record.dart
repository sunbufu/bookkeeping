import 'package:bookkeeping/model/record.dart';
import 'package:flutter/cupertino.dart';

/// 日度的记录
class DailyRecord {
  /// 日期时间戳（时间为 00:00:00）
  int time;

  /// 记录（key id，value 记录）
  Map<String, Record> records;

  DailyRecord({@required int time, Map<String, Record> records}) {
    this.time = time;
    this.records = records ?? {};
  }

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        time: json["time"],
        records: Map<String, Record>.from(json["records"].map((k, v) => MapEntry(k, Record.fromJson(v)))),
      );

  Map<String, dynamic> toJson() =>
      {"time": time, "records": Map<dynamic, dynamic>.from(records.map((k, v) => MapEntry(k, v.toJson())))};
}
