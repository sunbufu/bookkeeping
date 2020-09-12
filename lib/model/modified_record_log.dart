import 'package:flutter/cupertino.dart';

import 'record.dart';

/// 记录修改日志
class ModifiedRecordLog {

  Record record;
  /// 操作类型 0 删除，1 新增
  int operation;

  ModifiedRecordLog({@required Record record, @required int operation}) {
    this.record = record;
    this.operation = operation;
  }

  factory ModifiedRecordLog.fromJson(Map<String, dynamic> json) => ModifiedRecordLog(
    record: Record.fromJson(json["record"]),
    operation: json["operation"]
  );

  Map<String, dynamic> toJson() => {"record": record.toJson(), "operation": operation};
}

class Operations {
  /// 删除
  static const DELETE = 0;
  /// 新增
  static const INSERT = 1;
}
