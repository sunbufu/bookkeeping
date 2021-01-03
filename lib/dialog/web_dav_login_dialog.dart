import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/model/user.dart';
import 'package:bookkeeping/model/web_dav_storage_server_configuration.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

/// WebDav 登录弹框
class WebDavLoginDialog extends SimpleDialog {
  WebDavLoginDialog();

  bool syncOnModify = Runtime.syncOnModify;
  // var syncRadioGroup = '及时同步';

  // 保存为 user 对象
  User _save(String nickname, String url, String username, String password) {
    if ('' == nickname) {
      Fluttertoast.showToast(msg: '昵称不能为空');
      return null;
    }
    if ('' == url) {
      Fluttertoast.showToast(msg: 'WebDav url 不能为空');
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
        syncOnModify: syncOnModify ? Enables.ON : Enables.OFF,
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
        builder: (context) => StatefulBuilder(
          builder: (context, void Function(void Function()) setState) => SimpleDialog(
            title: Text("设置账号信息"),
            titlePadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            elevation: 5,
            contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
            children: <Widget>[
              TextField(autofocus: true, controller: _nickname, decoration: InputDecoration(hintText: "昵称")),
              TextField(
                controller: _url,
                decoration: InputDecoration(
                  hintText: "WebDav url",
                  suffixIcon: InkWell(
                    onTap: () => launch('https://sunbufu.github.io/2020/05/02/bookkeeping/'),
                    child: Icon(Icons.help),
                  ),
                ),
              ),
              Text('例如: https://dav.jianguoyun.com/dav/bookkeeping', style: TextStyle(fontSize: 12),),
              TextField(controller: _username, decoration: InputDecoration(hintText: "账号")),
              TextField(controller: _password, decoration: InputDecoration(hintText: "密码"), obscureText: true),
              Row(
                children: <Widget>[
                  Text('同步策略:'),
                  Radio(groupValue: syncOnModify, value: false,
                      onChanged: (v) => setState(() => syncOnModify = false)),
                  Text('退出时'),
                  Radio(groupValue: syncOnModify, value: true,
                      onChanged: (v) => setState(() => syncOnModify = true)),
                  Text('保存时'),
                ],
              ),
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
              ]),
            ],
          ),
        ));
    // builder: (context) => SimpleDialog(
    //
    // )
  }
}
