import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends Dialog {
  String text;

  LoadingDialog(this.text);

  @override
  Widget build(BuildContext context) {
    return new Material(
      type: MaterialType.transparency,
      child: new Center(
        child: new SizedBox(
          width: 120.0,
          height: 120.0,
          child: new Container(
            decoration: ShapeDecoration(
              color: Color(0xffffffff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(),
                new Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: new Text(text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 在 function 运行期间展示 loading
  static runWithLoading(BuildContext context, String title, Function() function) {
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => LoadingDialog(title));
    try {
      if (null != function) return function();
    } finally {
      Navigator.pop(context);
    }
  }

  /// 在 function 运行期间展示 loading
  static runWithLoadingAsync(BuildContext context, String title, Function() function) async {
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => LoadingDialog(title));
    try {
      if (null != function) return await function();
    } finally {
      Navigator.pop(context);
    }
  }
}
