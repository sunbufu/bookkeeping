import 'package:bookkeeping/common/date_time_util.dart';

/// 常量
class Constants {
  /// 用户信息的文件名
  static const String USER_INFO_FILE_NAME = 'user_info.json';

  /// 待提交记录的文件名
  static const String MODIFIED_MONTHLY_RECORD_FILE_NAME = 'modified_monthly_record.json';

  /// 分类的文件名
  static const String CATEGORY_FILE_NAME = 'category.json';

  /// 获取月度记录文件名
  static String getMonthlyRecordFileNameByTime(int time) {
    return getMonthlyRecordFileName(DateTimeUtil.getCompactMonthByTimestamp(time));
  }

  /// 获取月度记录文件名
  static String getMonthlyRecordFileNameByMonth(String month) {
    int time = DateTimeUtil.getTimestampByMonth(month);
    return getMonthlyRecordFileName(DateTimeUtil.getCompactMonthByTimestamp(time));
  }

  /// 获取月度记录文件名
  static String getMonthlyRecordFileName(String time) {
    return 'monthly_record_' + time + '.json';
  }
}
