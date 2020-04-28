
import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class MonthTimePickerDialog {

  /// 展示月份选择框
  static void showDialog(BuildContext context, DateTime dateTime, Function(DateTime) callback) {
    bool isDarkMode = DarkModeUtil.isDarkMode(context);
    DatePicker.showPicker(
      context,
      theme: DatePickerTheme(
        cancelStyle: isDarkMode
            ? TextStyle(color: Colors.white, fontSize: 16)
            : TextStyle(color: Colors.black54, fontSize: 16),
        itemStyle: isDarkMode
            ? TextStyle(color: Colors.white, fontSize: 18)
            : TextStyle(color: Color(0xFF000046), fontSize: 18),
        backgroundColor: isDarkMode ? Color(0xFF222222) : Colors.white,
      ),
      pickerModel: MonthTimePicker(currentTime: dateTime),
      locale: LocaleType.zh,
      onConfirm: (dateTime) {
        if (null != callback) callback(dateTime);
      },
    );
  }
}

class MonthTimePicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  MonthTimePicker({DateTime currentTime, LocaleType locale}) : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.setLeftIndex(this.currentTime.year);
    this.setMiddleIndex(this.currentTime.month);
    this.setRightIndex(1);
  }

  @override
  String leftStringAtIndex(int index) {
    if (index >= 1970 && index < 3000) {
      return this.digits(index, 2) + ' 年';
    } else {
      return null;
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 1 && index <= 12) {
      return this.digits(index, 2) + ' 月';
    } else {
      return null;
    }
  }

  @override
  String rightStringAtIndex(int index) {
    if (index >= 1 && index <= 1) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() => "|";

  @override
  String rightDivider() => "";

  @override
  List<int> layoutProportions() => [4, 1, 1];

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(this.currentLeftIndex(), this.currentMiddleIndex(), 1, 0, 0, 0)
        : DateTime(this.currentLeftIndex(), this.currentMiddleIndex(), 1, 0, 0, 0);
  }
}
