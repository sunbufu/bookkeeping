import 'package:bookkeeping/model/storage_server_configuration.dart';

/// web dav 存储配置
class WebDavStorageServerConfiguration implements StorageServerConfiguration {
  String url;
  String username;
  String password;

  WebDavStorageServerConfiguration({
    String url,
    String username,
    String password,
  }) {
    this.url = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    this.username = username;
    this.password = password;
  }

  factory WebDavStorageServerConfiguration.fromJson(Map<String, dynamic> json) => WebDavStorageServerConfiguration(
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
