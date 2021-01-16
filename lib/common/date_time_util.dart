import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

/// 日期时间工具类
class DateTimeUtil {

  static const List<String> WEEKDAY_LIST = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  static int getMillisecondsSinceEpoch() => new DateTime.now().millisecondsSinceEpoch;

  static int getTimestamp() => getTimestampByDateTime(DateTime.now());

  static String getDayByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [yyyy, '-', mm, '-', dd]);
  }

  static String formatLineDay(DateTime dateTime) {
    return formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
  }

  static String getMonthByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [yyyy, '-', mm]);
  }

  static String formatLineMonth(DateTime dateTime) {
    return formatDate(dateTime, [yyyy, '-', mm]);
  }

  static String getMonthDayByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [mm, '-', dd]);
  }

  static String getMonthDayTimeByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [mm, '-', dd, ' ', hh, ':', nn]);
  }

  static String getYearMonthDayTimeByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss]);
  }

  static int getTimestampByString(String str) {
    DateTime dateTime = DateTime.tryParse(str);
    if (null == dateTime) return 0;
    return getTimestampByDateTime(dateTime);
  }

  static int getTimestampByFormat(String str, String format) {
    DateTime dateTime;
    try {
      dateTime = DateFormat(format).parse(str);
    } catch (e) {}
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

  static DateTime getDateTimeByDay(String day) {
    return DateTime.tryParse(day);
  }

  static DateTime getDateTimeByMonth(String month) {
    return DateTime.tryParse(month += '-01');
  }

  static String getCompactMonthByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [yyyy, mm]);
  }

  static String getCompactMonthDayByTimestamp(int timestamp) {
    return formatDate(getDateTimeByTimestamp(timestamp), [yyyy, mm, dd]);
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
  
  /// 获取删个月到时间
  static DateTime getNextMonthTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month + 1, dateTime.day, dateTime.hour, dateTime.minute, dateTime.second);
  }
}
