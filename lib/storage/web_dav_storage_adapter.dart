import 'dart:convert';
import 'dart:typed_data';

import 'package:bookkeeping/model/web_dav_storage_server_configuration.dart';
import 'package:bookkeeping/storage/file_storage_adapter.dart';
import 'package:bookkeeping/storage/storage_adapter.dart';
import 'package:webdav/webdav.dart';

/// WebDav 存储适配器
class WebDavStorageAdapter implements StorageAdapter {

  /// 路径分隔符
  static const PATH_SEPARATOR = '/';

  /// WebDav 客户端
  Client _client;

  /// WebDav 配置
  WebDavStorageServerConfiguration webDavStorageServer;

  /// 本地文件存储适配器
  FileStorageAdapter _fileStorageAdapter;

  WebDavStorageAdapter(WebDavStorageServerConfiguration webDavStorageServer) {
    this.webDavStorageServer = webDavStorageServer;
    _init();
  }

  void _init() {
    // 从url中解析出host, path, protocol
    RegExp exp = RegExp(r'^(\w+):\/\/(\S+)');
    var matches = exp.allMatches(webDavStorageServer.url);
    if (1 > matches.length) throw Exception('Can not init client with $webDavStorageServer.url');
    var elementAt = matches.elementAt(0);
    var protocol = elementAt.group(1);
    var fullHost = elementAt.group(2);
    var lastIndex = fullHost.lastIndexOf(PATH_SEPARATOR);
    if (-1 == lastIndex) throw Exception('Can not find path by $webDavStorageServer.url');
    var host = fullHost.substring(0, lastIndex);
    var path = fullHost.substring(lastIndex + 1, fullHost.length);
    // 初始化连接
    _client = Client(host, webDavStorageServer.username, webDavStorageServer.password, path, protocol: protocol);
    _fileStorageAdapter = FileStorageAdapter();
  }

  @override
  Future<bool> exist(String fileName) async {
    return (await list()).contains(fileName);
  }

  @override
  Future<List<String>> list() async {
    return (await _client.ls('')).map((f) => _getFileNameFromPath(f.name)).toList();
  }

  @override
  Future<String> read(String fileName) async {
    if (!await exist(fileName)) return '';
    return _client.downloadToBinaryString(fileName);
  }

  @override
  Future<bool> write(String fileName, String content) async {
    _client.upload(Uint8List.fromList(utf8.encode(content)), fileName);
    return true;
  }

  @override
  Future<bool> delete(String fileName) async {
    if (!await exist(fileName)) return false;
    _client.delete(fileName);
    return true;
  }

  /// 从 path 中获取 fileName
  String _getFileNameFromPath(String path) {
    var lastIndex = path.lastIndexOf(PATH_SEPARATOR);
    return -1 == lastIndex ? path : path.substring(lastIndex + 1, path.length);
  }
}
