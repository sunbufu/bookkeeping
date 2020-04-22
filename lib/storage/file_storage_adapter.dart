import 'dart:io';

import 'package:bookkeeping/storage/storage_adapter.dart';
import 'package:path_provider/path_provider.dart';

/// 本地文件存储适配器
class FileStorageAdapter implements StorageAdapter {
  Future<Directory> _directory;

  FileStorageAdapter() {
    _init();
  }

  void _init() {
    _directory = getApplicationSupportDirectory();
  }

  @override
  Future<bool> exist(String fileName) async {
    return File(await getFullPath(fileName)).exists();
  }

  @override
  Future<List<String>> list() async {
    return (await _directory).list().map((f) => _getFileNameFromPath(f.path)).toList();
  }

  @override
  Future<String> read(String fileName) async {
    if (!await exist(fileName)) return '';
    return File(await getFullPath(fileName)).readAsString();
  }

  @override
  Future<bool> write(String fileName, String content) async {
    File(await getFullPath(fileName)).writeAsString(content, flush: true);
    return true;
  }

  @override
  Future<bool> delete(String fileName) async {
    if (!await exist(fileName)) return false;
    File(await getFullPath(fileName)).delete();
    return true;
  }

  /// 从 path 中获取 fileName
  String _getFileNameFromPath(String path) {
    var lastIndex = path.lastIndexOf(Platform.pathSeparator);
    if (-1 == lastIndex)
      return path;
    else
      return path.substring(lastIndex + 1, path.length);
  }

  /// 获取文件系统中的绝对路径
  Future<String> getFullPath(String fileName) async {
    return (await _directory).path + Platform.pathSeparator + fileName;
  }
}
