import 'package:bookkeeping/common/date_time_util.dart';

/// 常量
class Constants {
  /// 用户信息的文件名
  static const String USER_INFO_FILE_NAME = 'user_info.json';

  /// 待提交记录的文件名
  static const String MODIFIED_MONTHLY_RECORD_FILE_NAME = 'modified_monthly_record.json';

  /// 分类的文件名
  static const String CATEGORY_FILE_NAME = 'category.json';

  /// 常用备注的文件名
  static const String FREQUENTLY_MARK_FILE_NAME = 'frequently_mark.json';

  /// 导入导出模板文件名
  static const String TEMPLATE_FILE_NAME = 'template.csv';

  /// 导入导出模板文件头
  static const String TEMPLATE_FILE_HEAD = '时间,分类,收入或支出,金额,备注,用户昵称\n';

  /// 获取导出文件名
  static String getExportFileName(int time) {
    return 'bookkeeping_'+DateTimeUtil.getCompactMonthDayByTimestamp(time)+'.csv';
  }

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
