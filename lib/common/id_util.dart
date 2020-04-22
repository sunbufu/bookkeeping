import 'dart:math';

import 'package:bookkeeping/common/date_time_util.dart';

/// id 工具类
class IdUtil {
  /// 生成id
  static String generateId() {
    String timestamp = DateTimeUtil.getTimestamp().toString();
    return timestamp.substring(4, timestamp.length) + Random().nextInt(9999).toString();
  }
}
