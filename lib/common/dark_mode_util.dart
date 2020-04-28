import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 黑暗模式工具类
class DarkModeUtil {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
