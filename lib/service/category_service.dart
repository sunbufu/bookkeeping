
import 'dart:convert';

import 'package:bookkeeping/common/constants.dart';
import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/model/category_tab.dart';
import 'package:bookkeeping/storage/storage_adapter.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 分类服务
class CategoryService {

  /// 分类 tab
  static List<CategoryTab> _categoryTabList = [CategoryTab(name: '支出', direction: 0), CategoryTab(name: '收入', direction: 1)];

  List<CategoryTab> get categoryTabList => _categoryTabList;

  set categoryTabList(categoryTabList) {
    _categoryTabList = categoryTabList;
    // 保存数据到存储
    String content = json.encode(_categoryTabList);
    Runtime.sharedPreferencesStorageAdapter.write(Constants.CATEGORY_FILE_NAME, content);
    if (Runtime.storageService.isReady) {
      Runtime.storageService.write(Constants.CATEGORY_FILE_NAME, content);
    } else {
      Fluttertoast.showToast(msg: 'web dav 连接失败，本次改动可能丢失');
    }
  }

  /// 从存储中重新获取分类数据
  Future<void> fetchCategoryFromStorage(StorageAdapter storageAdapter) async {
    String content = await storageAdapter.read(Constants.CATEGORY_FILE_NAME);
    if ('' != content) {
      _categoryTabList = List<CategoryTab>.from(json.decode(content).map((e) => CategoryTab.fromJson(e)));
    }
    // 保存数据到本地文件存储
    if (storageAdapter != Runtime.sharedPreferencesStorageAdapter)
      Runtime.sharedPreferencesStorageAdapter.write(Constants.CATEGORY_FILE_NAME, json.encode(_categoryTabList));
  }
}