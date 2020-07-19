import 'dart:convert';

import 'package:bookkeeping/common/constants.dart';
import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/storage/storage_adapter.dart';

/// 常用备注服务
class FrequentlyMarkService {

  /// 单个分类最大备注数量
  static const int MAX_SIZE_PRE_CATEGORY = 16;

  Map<String, List<String>> _frequentlyMarkMap = {};

  /// 读取常用备注
  Future<void> fetchFrequentlyMarkMap(StorageAdapter storageAdapter) async {
    String content = await storageAdapter.read(Constants.FREQUENTLY_MARK_FILE_NAME);
    if ('' == content) return;
    try {
      _frequentlyMarkMap = Map<String, List<String>>.from(json.decode(content).map((k, v) => MapEntry(k, List<String>.from(v))));
    } catch (e) {
      print('解析常用备注数据失败 content=$content');
    }
  }

  get frequentlyMarkMap => _frequentlyMarkMap;

  /// 获取指定分类的常用备注
  List<String> getFrequentlyMarkList(String category) => _frequentlyMarkMap[category];

  /// 添加常用备注
  void putFrequentlyMark(String category, String mark) {
    if (null == category || '' == category) return;
    if (null == mark || '' == mark) return;
    List<String> list = _frequentlyMarkMap[category] ?? [];
    list.remove(mark);
    list.insert(0, mark);
    while (list.length > MAX_SIZE_PRE_CATEGORY) list.removeLast();
    _frequentlyMarkMap[category] = list;
    // 保存到本地
    Runtime.sharedPreferencesStorageAdapter.write(Constants.FREQUENTLY_MARK_FILE_NAME, json.encode(_frequentlyMarkMap));
  }
}
