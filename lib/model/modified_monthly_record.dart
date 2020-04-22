import 'monthly_record.dart';

/// 变更数据
class ModifiedMonthlyRecord {
  Map<String, MonthlyRecord> deletedRecordMap;
  Map<String, MonthlyRecord> addedRecordMap;

  ModifiedMonthlyRecord({Map<String, MonthlyRecord> deletedRecordMap, Map<String, MonthlyRecord> addedRecordMap}) {
    this.deletedRecordMap = deletedRecordMap ?? {};
    this.addedRecordMap = addedRecordMap ?? {};
  }

  factory ModifiedMonthlyRecord.fromJson(Map<String, dynamic> json) => ModifiedMonthlyRecord(
    deletedRecordMap: Map<String, MonthlyRecord>.from(json["deletedRecordMap"].map((k, v) => MapEntry(k, MonthlyRecord.fromJson(v)))),
    addedRecordMap: Map<String, MonthlyRecord>.from(json["addedRecordMap"].map((k, v) => MapEntry(k, MonthlyRecord.fromJson(v)))),
  );

  Map<String, dynamic> toJson() =>
      {
        "deletedRecordMap": Map<dynamic, dynamic>.from(deletedRecordMap.map((k, v) => MapEntry(k, v.toJson()))),
        "addedRecordMap": Map<dynamic, dynamic>.from(addedRecordMap.map((k, v) => MapEntry(k, v.toJson())))
      };
}