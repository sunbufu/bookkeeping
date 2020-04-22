
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class MonthPickerDialog {

  /// 展示月份选择框
  static void showDialog(BuildContext context, String month, Function(DateTime) callback, ) {
    DatePicker.showPicker(
      context,
      pickerModel: MonthPicker(currentTime: DateTimeUtil.getDateTimeByMonth(month)),
      locale: LocaleType.zh,
      onConfirm: (dateTime) {
        if (null != callback) callback(dateTime);
      },
    );
  }
}

class MonthPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  MonthPicker({DateTime currentTime, LocaleType locale}) : super(locale: locale) {
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
  List<int> layoutProportions() => [1, 1, 0];

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(this.currentLeftIndex(), this.currentMiddleIndex(), 1, 0, 0, 0)
        : DateTime(this.currentLeftIndex(), this.currentMiddleIndex(), 1, 0, 0, 0);
  }
}
