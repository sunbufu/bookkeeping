import 'package:bookkeeping/model/storage_server.dart';
import 'package:bookkeeping/model/web_dav_storage_server.dart';

class User {
  // 用户名
  String username;

  // 存储服务类型（1：webdav）
  int storageServerType;

  // 存储服务
  StorageServer storageServer;

  User({
    this.username,
    this.storageServerType,
    this.storageServer,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
      username: json["username"],
      storageServerType: json["storageServerType"],
      storageServer: WebDavStorageServer.fromJson(json["storageServer"]));

  Map<String, dynamic> toJson() => {
        "username": username,
        "storageServerType": storageServerType,
        "storageServer": (storageServer as WebDavStorageServer).toJson()
      };
}
