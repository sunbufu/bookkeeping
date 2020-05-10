import 'package:bookkeeping/storage/storage_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharePreferences 存储适配器
class SharedPreferencesStorageAdapter implements StorageAdapter {

  Future<SharedPreferences> _sharedPreferences;

  SharedPreferencesStorageAdapter() {
    _init();
  }

  void _init () {
    _sharedPreferences = SharedPreferences.getInstance();
  }

  @override
  Future<List<String>> list() async {
    return _sharedPreferences.then((prefs) => prefs.getKeys().toList());
  }

  @override
  Future<bool> exist(String fileName) async {
    return _sharedPreferences.then((prefs) {
      String content = prefs.getString(fileName);
      return null != content && content.isNotEmpty;
    });
  }

  @override
  Future<bool> delete(String fileName) async {
    return (await _sharedPreferences).remove(fileName);
  }

  @override
  Future<String> read(String fileName) async {
    if (!await exist(fileName)) return '';
    return _sharedPreferences.then((prefs) => prefs.getString(fileName));
  }

  @override
  Future<bool> write(String fileName, String content) async {
    return (await _sharedPreferences).setString(fileName, content);
  }
}
