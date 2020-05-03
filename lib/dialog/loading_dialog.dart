import 'package:flutter/cupertino.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

/// loading
class LoadingDialog {

  static var dialog;

  static void show(BuildContext context) {
    dismiss();
    dialog = ProgressHUD.of(context);
    dialog.show();
  }

  static void dismiss() {
    if (null != dialog)
      dialog.dismiss();
  }

  /// 在 function 运行期间展示 loading
  static runWithLoading(BuildContext context, Function() function) {
    var dialog = ProgressHUD.of(context);
    dialog.show();
    try {
      if (null != function) return function();
    } finally {
      dialog.dismiss();
    }
  }

  /// 在 function 运行期间展示 loading
  static runWithLoadingAsync(BuildContext context, Function() function) async {
    var dialog = ProgressHUD.of(context);
    dialog.show();
    try {
      if (null != function) return await function();
    } finally {
      dialog.dismiss();
    }
  }
}
