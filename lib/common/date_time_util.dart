import 'package:date_format/date_format.dart';

/// 日期时间工具类
class DateTimeUtil {

  static const List<String> WEEKDAY_LIST = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  static int getMillisecondsSinceEpoch() => new DateTime.now().millisecondsSinceEpoch;

  static int getTimestamp() => getTimestampByDateTime(DateTime.now());

  static String getDayByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [yyyy, '-', mm, '-', dd]);
  }

  static String getMonthByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [yyyy, '-', mm]);
  }

  static String getMonthDayByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [mm, '-', dd]);
  }

  static String getMonthDayTimeByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [mm, '-', dd, ' ', hh, ':', nn]);
  }

  static int getTimestampByString(String str) {
    DateTime dateTime = DateTime.tryParse(str);
    if (null == dateTime) return 0;
    return getTimestampByDateTime(dateTime);
  }

  static int getTimestampByDateTime(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  static int getTimestampByMonth(String month) {
    return getTimestampByString(month += '-01');
  }

  static int getTimestampByDay(String day) {
    return getTimestampByString(day);
  }

  static DateTime getDateTimeByMonth(String month) {
    return DateTime.tryParse(month += '-01');
  }

  static String getCompactMonthByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [yyyy, mm]);
  }

  static DateTime getDateTimeByTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  /// 获取当前月第一天零点的时间戳
  static int getMonthTimeByTimestamp(int timestamp) {
    DateTime dateTime = getDateTimeByTimestamp(timestamp);
    Duration duration = Duration(
        days: (dateTime.day - 1), hours: dateTime.hour, minutes: dateTime.minute, seconds: dateTime.second);
    return getTimestampByDateTime(dateTime.subtract(duration));
  }

  /// 获取当前天零点的时间戳
  static int getDayTimeByTimestamp(int timestamp) {
    DateTime dateTime = getDateTimeByTimestamp(timestamp);
    Duration duration = Duration(hours: dateTime.hour, minutes: dateTime.minute, seconds: dateTime.second);
    return getTimestampByDateTime(dateTime.subtract(duration));
  }

  /// 是否是当前月份
  static bool isCurrentMonth(int timestamp) {
    return getMonthByTimestamp(getTimestamp()) == getMonthByTimestamp(timestamp);
  }

}
