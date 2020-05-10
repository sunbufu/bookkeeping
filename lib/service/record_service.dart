import 'dart:convert';

import 'package:bookkeeping/common/constants.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/model/monthly_record.dart';
import 'package:bookkeeping/storage/storage_adapter.dart';

/// 记录服务
class RecordService {

  int lastFetchTime = 0;

  /// 月度记录
  Map<String, MonthlyRecord> monthlyRecordMap = {};

  /// 获取存储的数据，并刷新到内存缓存（strict true 严谨模式下，如果读取失败抛出异常。非严谨模式下，会从本地读取）
  Future<void> fetchRecordFromStorage(StorageAdapter storageAdapter, String month, {bool strict : false}) async {
    String fileName = Constants.getMonthlyRecordFileNameByMonth(month);
    MonthlyRecord monthlyRecord;
    // 获取数据
    if (null == monthlyRecord) {
      String content = '';
      try {
        content = await storageAdapter.read(fileName);
      } catch (e) {
        if (strict) rethrow;
      }
      if ('' != content) {
        monthlyRecord = MonthlyRecord.fromJson(json.decode(content));
        // 更新内存
        monthlyRecordMap[month] = monthlyRecord;
        // 覆盖本地数据
        if (storageAdapter != Runtime.sharedPreferencesStorageAdapter)
          Runtime.sharedPreferencesStorageAdapter.write(fileName, content);
      }
    }
    lastFetchTime = DateTimeUtil.getTimestamp();
    // 本地数据
    if (null == monthlyRecord) await fetchRecordFromLocal(month);
  }

  /// 从本地资源获取月度记录（先读内存，内存没有则读文件）
  Future<void> fetchRecordFromLocal(String month) async {
    String fileName = Constants.getMonthlyRecordFileNameByMonth(month);
    MonthlyRecord monthlyRecord;
    // 内存缓存
    if (null == monthlyRecord) monthlyRecord = monthlyRecordMap[month];
    // 本地数据
    if (null == monthlyRecord) {
      String content = await Runtime.sharedPreferencesStorageAdapter.read(fileName);
      if ('' != content) monthlyRecord = MonthlyRecord.fromJson(json.decode(content));
    }
    // 没有获取到，创建月度记录
    if (null == monthlyRecord) monthlyRecord = MonthlyRecord(time: DateTimeUtil.getTimestampByMonth(month));
    // 更新内存
    monthlyRecordMap[month] = monthlyRecord;
  }
}
