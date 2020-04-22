
import 'package:flutter/cupertino.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

class LoadingDialog {

  /// 在 function 运行期间展示 loading
  static runWithLoading(BuildContext context, String title, Function() function) {
    var dialog = ProgressHUD.of(context);
    dialog.showWithText(title);
    try {
      if (null != function)
        return function();
    } finally {
      dialog.dismiss();
    }
  }

  /// 在 function 运行期间展示 loading
  static runWithLoadingAsync(BuildContext context, String title, Function() function) async {
    var dialog = ProgressHUD.of(context);
    dialog.showWithText(title);
    try {
      if (null != function)
        return await function();
    } finally {
      dialog.dismiss();
    }
  }
}
