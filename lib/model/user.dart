import 'package:bookkeeping/model/storage_server_configuration.dart';
import 'package:bookkeeping/model/web_dav_storage_server_configuration.dart';

class User {
  // 用户名
  String username;

  // 存储服务类型（1：webdav）
  int storageServerType;

  int syncOnModify;

  // 存储服务
  StorageServerConfiguration storageServer;

  User({
    this.username,
    this.syncOnModify,
    this.storageServerType,
    this.storageServer,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
      username: json["username"],
      syncOnModify: json["syncOnModify"],
      storageServerType: json["storageServerType"],
      storageServer: WebDavStorageServerConfiguration.fromJson(json["storageServer"]));

  Map<String, dynamic> toJson() => {
        "username": username,
        "syncOnModify": syncOnModify,
        "storageServerType": storageServerType,
        "storageServer": (storageServer as WebDavStorageServerConfiguration).toJson()
      };
}

class Enables {
  static const OFF = 0;
  static const ON = 1;
}
