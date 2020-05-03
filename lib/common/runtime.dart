import 'package:bookkeeping/model/user.dart';
import 'package:bookkeeping/service/category_service.dart';
import 'package:bookkeeping/service/storage_service.dart';
import 'package:bookkeeping/storage/file_storage_adapter.dart';

/// 运行时信息
class Runtime {
  /// 用户名
  static User user;

  static get username => null != user ? user.username : '';

  /// 是否每次修改都同步
  static bool syncEveryModify = false;

  /// 本地存储（存储用户本地配置）
  static FileStorageAdapter _fileStorageAdapter = FileStorageAdapter();

  static set fileStorageAdapter(fileStorageAdapter) => _fileStorageAdapter = fileStorageAdapter;

  static get fileStorageAdapter => _fileStorageAdapter;

  /// 存储适配器
  static StorageService storageService = StorageService();

  /// 分类服务
  static CategoryService categoryService = CategoryService();

  /// 应用回到前台时监听
  static List<Function> resumedListenerList = [];

  /// 应用进入后台时监听
  static List<Function> pausedListenerList = [];
}
