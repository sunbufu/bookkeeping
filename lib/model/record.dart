import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/common/id_util.dart';
import 'package:flutter/cupertino.dart';

/// 记录
class Record {
  String id;

  // 金额（分为单位）
  int amount;

  // 流向（0 支出，1 收入）
  int direction;

  // 分类
  String category;

  // 备注
  String remark;

  // 记录时间
  int time;

  // 创建时间
  int createdTime;

  // 创建人
  String createdUser;

  Record(
      {String id,
      @required int amount,
      int direction,
      String category,
      String remark,
      int time,
      int createdTime,
      String createdUser}) {
    this.id = id;
    this.amount = amount;
    this.direction = direction;
    this.category = category;
    this.remark = remark;
    this.time = time;
    this.createdTime = createdTime;
    this.createdUser = createdUser;

    _init();
  }

  void _init() {
    if (null == id || id.isEmpty) id = IdUtil.generateId();
    if (null == direction) direction = 0;
    if (null == category) category = '';
    if (null == remark) remark = '';
    if (null == time) time = DateTimeUtil.getTimestamp();
    if (null == createdTime) createdTime = DateTimeUtil.getTimestamp();
    if (null == createdUser) createdUser = '';
  }

  factory Record.fromJson(Map<String, dynamic> json) => Record(
        id: json["id"],
        amount: json["amount"],
        direction: json["direction"],
        category: json["category"],
        remark: json["remark"],
        time: json["time"],
        createdTime: json["createdTime"],
        createdUser: json["createdUser"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "direction": direction,
        "category": category,
        "remark": remark,
        "time": time,
        "createdTime": createdTime,
        "createdUser": createdUser,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Record &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              amount == other.amount &&
              direction == other.direction &&
              category == other.category &&
              remark == other.remark &&
              time == other.time &&
              createdTime == other.createdTime &&
              createdUser == other.createdUser;

  @override
  int get hashCode =>
      id.hashCode ^
      amount.hashCode ^
      direction.hashCode ^
      category.hashCode ^
      remark.hashCode ^
      time.hashCode ^
      createdTime.hashCode ^
      createdUser.hashCode;



}
