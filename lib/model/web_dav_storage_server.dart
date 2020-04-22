import 'package:bookkeeping/model/storage_server.dart';

/// web dav 存储配置
class WebDavStorageServer implements StorageServer {
  String url;
  String username;
  String password;

  WebDavStorageServer({
    this.url,
    this.username,
    this.password,
  });

  factory WebDavStorageServer.fromJson(Map<String, dynamic> json) => WebDavStorageServer(
        url: json["url"],
        username: json["username"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "username": username,
        "password": password,
      };
}
