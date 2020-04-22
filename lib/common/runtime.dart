import 'package:bookkeeping/model/category_tab.dart';
import 'package:bookkeeping/storage/storage_adapter.dart';

/// 运行时信息
class Runtime {
  /// 用户名
  static String userName;

  /// 是否每次修改都同步
  static bool syncEveryModify = false;

  /// 本地存储（存储用户本地配置）
  static StorageAdapter fileStorageAdapter;

  /// 存储适配器
  static StorageAdapter storageAdapter;

  /// 分类 tab
  static List<CategoryTab> categoryTabList = [];
}
