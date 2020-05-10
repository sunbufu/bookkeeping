import 'dart:convert';

import 'package:bookkeeping/common/constants.dart';
import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/storage/storage_adapter.dart';

/// 常用备注服务
class FrequentlyMarkService {
  List<String> _frequentlyMarkList = ['早饭', '午饭', '晚饭'];

  /// 读取常用备注
  Future<void> fetchFrequentlyMarkList(StorageAdapter storageAdapter) async {
    String content = await storageAdapter.read(Constants.FREQUENTLY_MARK_FILE_NAME);
    if ('' != content) {
      _frequentlyMarkList = List<String>.from(json.decode(content).map((e) => e));
    }
  }

  get frequentlyMarkList => _frequentlyMarkList;

  /// 添加常用备注
  void addFrequentlyMark(String mark) {
    if (null == mark || '' == mark) return;
    _frequentlyMarkList.remove(mark);
    _frequentlyMarkList.insert(0, mark);
    while (_frequentlyMarkList.length > 16) _frequentlyMarkList.removeLast();
    // 保存到本地
    Runtime.sharedPreferencesStorageAdapter.write(Constants.FREQUENTLY_MARK_FILE_NAME, json.encode(_frequentlyMarkList));
  }
}
