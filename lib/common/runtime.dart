import 'package:bookkeeping/model/user.dart';
import 'package:bookkeeping/service/category_service.dart';
import 'package:bookkeeping/service/frequently_mark_service.dart';
import 'package:bookkeeping/service/record_service.dart';
import 'package:bookkeeping/service/storage_service.dart';
import 'package:bookkeeping/storage/file_storage_adapter.dart';
import 'package:bookkeeping/storage/shared_preferences_storage_adapter.dart';

/// 运行时信息
class Runtime {
  /// 用户名
  static User user;

  static get username => null != user ? user.username : '';

  /// 是否每次修改都同步
  static get syncOnModify {
    if (null != user) {
      return Enables.ON == user.syncOnModify;
    }
    return false;
  }

  /// 本地存储（存储用户本地配置）
  static FileStorageAdapter _fileStorageAdapter = FileStorageAdapter();

  @deprecated
  static get fileStorageAdapter => _fileStorageAdapter;

  /// SharedPreferences 存储适配器
  static SharedPreferencesStorageAdapter _sharedPreferencesStorageAdapter = SharedPreferencesStorageAdapter();

  static get sharedPreferencesStorageAdapter => _sharedPreferencesStorageAdapter;

  /// 存储适配器
  static StorageService storageService = StorageService();

  /// 分类服务
  static CategoryService categoryService = CategoryService();

  /// 应用回到前台时监听
  static List<Function> resumedListenerList = [];

  /// 应用进入后台时监听
  static List<Function> pausedListenerList = [];

  /// 常用备注服务
  static FrequentlyMarkService frequentlyMarkService = FrequentlyMarkService();

  /// 常用备注列表
  static List<String> getFrequentlyMarkList(String category) => frequentlyMarkService.getFrequentlyMarkList(category);

  /// 添加常用备注
  static void putFrequentlyMark(String category, String mark) => frequentlyMarkService.putFrequentlyMark(category, mark);

  /// 详情页面有没有展示
  static bool detailPageShowing = false;

  /// 记录服务
  static RecordService recordService = RecordService();

  /// 月度记录
  static get monthlyRecordMap => recordService.monthlyRecordMap;
}
