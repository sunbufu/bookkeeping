import 'package:bookkeeping/model/user.dart';
import 'package:bookkeeping/model/web_dav_storage_server_configuration.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

/// webdav 登录弹框
class WebDavLoginDialog extends SimpleDialog {
  WebDavLoginDialog();

  // 保存为 user 对象
  User _save(String nickname, String url, String username, String password) {
    if ('' == nickname) {
      Fluttertoast.showToast(msg: '昵称不能为空');
      return null;
    }
    if ('' == url) {
      Fluttertoast.showToast(msg: 'webdav url 不能为空');
      return null;
    }
    if ('' == username) {
      Fluttertoast.showToast(msg: '账号不能为空');
      return null;
    }
    if ('' == password) {
      Fluttertoast.showToast(msg: '密码不能为空');
      return null;
    }
    return User(
        username: nickname,
        storageServerType: 1,
        storageServer: WebDavStorageServerConfiguration(url: url, username: username, password: password));
  }

  void show(BuildContext context, User user, Function(User) callback) {
    TextEditingController _nickname = TextEditingController();
    TextEditingController _url = TextEditingController();
    TextEditingController _username = TextEditingController();
    TextEditingController _password = TextEditingController();
    if (null != user) {
      _nickname.text = user.username;
      _url.text = (user.storageServer as WebDavStorageServerConfiguration).url;
      _username.text = (user.storageServer as WebDavStorageServerConfiguration).username;
      _password.text = (user.storageServer as WebDavStorageServerConfiguration).password;
    }
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => SimpleDialog(
              title: Text("设置账号信息"),
              titlePadding: EdgeInsets.all(10),
              elevation: 5,
              contentPadding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
              children: <Widget>[
                TextField(autofocus: true, controller: _nickname, decoration: InputDecoration(hintText: "昵称")),
                TextField(
                  controller: _url,
                  decoration: InputDecoration(
                    hintText: "webdav url",
                    suffixIcon: InkWell(
                      onTap: () => launch('http://help.jianguoyun.com/?p=2064'),
                      child: Icon(Icons.help),
                    ),
                  ),
                ),
                TextField(controller: _username, decoration: InputDecoration(hintText: "账号")),
                TextField(controller: _password, decoration: InputDecoration(hintText: "密码"), obscureText: true),
                Container(padding: EdgeInsets.all(10)),
                Row(children: <Widget>[
                  Expanded(child: FlatButton(child: Text('取消'), onPressed: () => Navigator.pop(context))),
                  Expanded(
                      child: FlatButton(
                          child: Text('确定'),
                          onPressed: () {
                            User user = _save(_nickname.text, _url.text, _username.text, _password.text);
                            if (null != user && null != callback) {
                              callback(user);
                              Navigator.pop(context);
                            }
                          })),
                ])
              ],
            ));
  }
}
