import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/model/storage_server_configuration.dart';
import 'package:bookkeeping/model/web_dav_storage_server_configuration.dart';
import 'package:bookkeeping/storage/storage_adapter.dart';
import 'package:bookkeeping/storage/web_dav_storage_adapter.dart';

class StorageService extends StorageAdapter {
  StorageAdapter _storageAdapter;

  bool get isReady => null != _storageAdapter;

  /// 监听器
  List<Function(StorageAdapter)> listenerList = [];

  /// 注册监听器
  void addListener(Function(StorageAdapter) listener) => listenerList.add(listener);

  void init({StorageServerConfiguration configuration, Function(StorageAdapter) success, Function(Exception) fail}) {
    try {
      if (1 == Runtime.user.storageServerType) {
        _storageAdapter =
            WebDavStorageAdapter(configuration ?? Runtime.user.storageServer as WebDavStorageServerConfiguration);
        if (null != success)
          success(_storageAdapter);
        // 调用监听器
        for (Function(StorageAdapter) listener in listenerList) {
          listener(_storageAdapter);
        }
      }
    } catch (e) {
      if (null != fail)
        fail(e);
    }
  }

  @override
  Future<bool> delete(String fileName) => _storageAdapter.delete(fileName);

  @override
  Future<bool> exist(String fileName) => _storageAdapter.exist(fileName);

  @override
  Future<List<String>> list() => _storageAdapter.list();

  @override
  Future<String> read(String fileName) => _storageAdapter.read(fileName);

  @override
  Future<bool> write(String fileName, String content) => _storageAdapter.write(fileName, content);
}
