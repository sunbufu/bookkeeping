import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:date_format/date_format.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 数字键盘
class NumberKeyBoard extends StatefulWidget {
  
  final int _amount;
  final DateTime _dateTime;
  final String _remark;
  final Function(int, DateTime, String) _callback;

  NumberKeyBoard({int amount, DateTime dateTime, String remark, Function(int, DateTime, String) callback})
      : this._amount = amount,
        this._dateTime = dateTime ?? DateTime.now(),
        this._remark = remark,
        this._callback = callback;
  
  @override
  State<StatefulWidget> createState() => NumberKeyBoardState(_amount, _dateTime, _remark);
}

class NumberKeyBoardState extends State<NumberKeyBoard> {
  String _value0Str = '0';
  String _valueStr = '0';

  /// 是否可以保存
  bool _canSave = true;

  DateTime _dateTime = DateTime.now();

  /// 备注
  String _remark = '';

  TextEditingController _remarkController;

  NumberKeyBoardState(int amount, DateTime dateTime, String remark) {
    _valueStr = (Decimal.fromInt(amount) / Decimal.fromInt(100)).toString();
    _dateTime = dateTime;
    _remark = remark;

    _remarkController = TextEditingController();
    _remarkController.text = _remark;
  }

  /// 边框颜色
  Color _borderColor;
  
  void _onSaveRemark() {
    _remark = _remarkController.text;
    setState(() {});
  }

  void _changeDate(DateTime date) {
    _dateTime = DateTime(date.year, date.month, date.day, _dateTime.hour, _dateTime.minute, _dateTime.second);
    setState(() {});
  }

  void _changeTime(DateTime time) {
    _dateTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day, time.hour, time.minute, time.second);
    setState(() {});
  }

  void _onNumberButtonPressed(int value) {
    // 小数点后两位
    if (_valueStr.contains('.') && _valueStr.indexOf('.') <= _valueStr.length - 3) return;
    // 初次直接赋值
    if ('0' == _valueStr) {
      _valueStr = value.toString();
      setState(() {});
      return;
    }
    String newValueStr = _valueStr + value.toString();
    num newValue = num.parse(newValueStr);
    if (0 > newValue || (1 << 31 - 1) <= newValue) {
      Fluttertoast.showToast(msg: '数值超限');
    } else {
      _valueStr = newValueStr;
      setState(() {});
    }
  }

  void _onDecimalPointButtonPressed() {
    if (_valueStr.contains('.')) return;
    _valueStr += '.';
    setState(() {});
  }

  // 1 加法， 2 减法
  int operation = 0;

  void _onBackButtonPressed() {
    if ('0' == _valueStr) {
      if (0 != operation) {
        // 待运算符的推格
        operation = 0;
        _canSave = true;
        _valueStr = _value0Str;
        _value0Str = '0';
        setState(() {});
      }
    } else {
      if (1 == _valueStr.length)
        _valueStr = '0';
      else
        _valueStr = _valueStr.substring(0, _valueStr.length - 1);
      setState(() {});
    }
  }

  void _onPlusButtonPressed() {
    if ('0' != _value0Str || 0 != operation) return;
    _value0Str = _valueStr;
    _valueStr = '0';
    operation = 1;
    _canSave = false;
    setState(() {});
  }

  void _onSubtractButtonPressed() {
    if ('0' != _value0Str || 0 != operation) return;
    _value0Str = _valueStr;
    _valueStr = '0';
    operation = 2;
    _canSave = false;
    setState(() {});
  }

  void _onEvaluationButtonPressed() {
    if (0 == operation) return;
    Decimal value0 = Decimal.parse(_value0Str);
    Decimal value = Decimal.parse(_valueStr);
    Decimal result = operation == 1 ? value0 + value : value0 - value;
    _valueStr = result.toString();
    _value0Str = '0';
    operation = 0;
    _canSave = true;
    setState(() {});
  }

  void _onSaveButtonPressed() {
    if (null != widget._callback)
      widget._callback((Decimal.parse(_valueStr) * Decimal.fromInt(100)).toInt(), _dateTime, _remark);
  }

  String _getValueShowString() {
    if ('0' == _value0Str) return _valueStr;
    return _value0Str + (operation == 1 ? '+' : '-') + _valueStr;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = DarkModeUtil.isDarkMode(context);
    _borderColor = isDarkMode ? Colors.grey : Color(0x10333333);
    DatePickerTheme dateTimeTheme  = DatePickerTheme(
      cancelStyle: isDarkMode
          ? TextStyle(color: Colors.white, fontSize: 16)
          : TextStyle(color: Colors.black54, fontSize: 16),
      itemStyle: isDarkMode
          ? TextStyle(color: Colors.white, fontSize: 18)
          : TextStyle(color: Color(0xFF000046), fontSize: 18),
      backgroundColor: isDarkMode ? Color(0xFF222222) : Colors.white,
    );
    return Container(
      height: 300,
      color: DarkModeUtil.isDarkMode(context) ? Color(0xFF222222) : Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Row(
              children: <Widget>[
                Container(height: 40),
                Expanded(
                    child: Text(_getValueShowString(),
                        textAlign: TextAlign.right, style: TextStyle(color: Colors.red, fontSize: 25))),
              ],
            ),
          ),
          Row(children: <Widget>[
            OutlineButton(
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
              borderSide: BorderSide(color: _borderColor),
              highlightedBorderColor: _borderColor,
              child: Text(DateTimeUtil.getDayByTimestamp(DateTimeUtil.getTimestampByDateTime(_dateTime))),
              onPressed: () {
                DatePicker.showDatePicker(context, theme: dateTimeTheme,
                    locale: LocaleType.zh, currentTime: _dateTime, onConfirm: _changeDate);
              },
            ),
            OutlineButton(
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
              borderSide: BorderSide(color: _borderColor),
              highlightedBorderColor: _borderColor,
              child: Text(formatDate(_dateTime, [HH, ':', nn, ':', ss])),
              onPressed: () {
                DatePicker.showTimePicker(context, theme: dateTimeTheme,
                    locale: LocaleType.zh, currentTime: _dateTime, onConfirm: _changeTime);
              },
            ),
            OutlineButton(
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
              borderSide: BorderSide(color: _borderColor),
              highlightedBorderColor: _borderColor,
              child: Container(
                constraints: BoxConstraints(maxWidth: 100),
                child: Text('' == _remark ? '备注' : _remark, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  child: AlertDialog(
                    title: Text('备注'),
                    content: TextField(controller: _remarkController, decoration: InputDecoration(hintText: '请输入备注'), autofocus: true,),
                    actions: <Widget>[
                      FlatButton(child: Text('取消'), onPressed: () => Navigator.pop(context),),
                      FlatButton(child: Text('确认'), onPressed: () {
                        _onSaveRemark();
                        Navigator.pop(context);
                      },),
                    ],
                  ),
                );
              },
            ),
          ]),
          Row(children: <Widget>[
            NumberKeyBoardButton(title: '7', onPressed: () => _onNumberButtonPressed(7)),
            NumberKeyBoardButton(title: '8', onPressed: () => _onNumberButtonPressed(8)),
            NumberKeyBoardButton(title: '9', onPressed: () => _onNumberButtonPressed(9)),
            NumberKeyBoardButton(
              icon: Icons.backspace,
              onPressed: () => _onBackButtonPressed(),
            ),
          ]),
          Row(children: <Widget>[
            NumberKeyBoardButton(title: '4', onPressed: () => _onNumberButtonPressed(4)),
            NumberKeyBoardButton(title: '5', onPressed: () => _onNumberButtonPressed(5)),
            NumberKeyBoardButton(title: '6', onPressed: () => _onNumberButtonPressed(6)),
            NumberKeyBoardButton(
              icon: Icons.add,
              onPressed: () => _onPlusButtonPressed(),
            ),
          ]),
          Row(children: <Widget>[
            NumberKeyBoardButton(title: '1', onPressed: () => _onNumberButtonPressed(1)),
            NumberKeyBoardButton(title: '2', onPressed: () => _onNumberButtonPressed(2)),
            NumberKeyBoardButton(title: '3', onPressed: () => _onNumberButtonPressed(3)),
            NumberKeyBoardButton(
              icon: Icons.remove,
              onPressed: () => _onSubtractButtonPressed(),
            ),
          ]),
          Row(children: <Widget>[
            NumberKeyBoardButton(),
            NumberKeyBoardButton(title: '0', onPressed: () => _onNumberButtonPressed(0)),
            NumberKeyBoardButton(title: '.', onPressed: () => _onDecimalPointButtonPressed()),
            NumberKeyBoardButton(title: _canSave ? '完成' : '=',
                onPressed: () => _canSave ? _onSaveButtonPressed() : _onEvaluationButtonPressed(),
            ),
          ]),
        ],
      ),
    );
  }
}

///  自定义 键盘 按钮
class NumberKeyBoardButton extends StatefulWidget {
  /// 按钮显示的文本内容
  final String title;

  /// 图标
  final IconData icon;

  /// 回调函数
  final onPressed;

  NumberKeyBoardButton({Key key, this.title: '', this.icon, this.onPressed}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NumberKeyBoardButtonState();
}

class NumberKeyBoardButtonState extends State<NumberKeyBoardButton> {
  @override
  Widget build(BuildContext context) {
    /// 获取当前屏幕的总宽度，从而得出单个按钮的宽度
    double _screenWidth = MediaQuery.of(context).size.width;

    /// 边框颜色
    Color _borderColor = Color(0x10333333);

    /// 字体样式
    TextStyle _textStyle = TextStyle(color: DarkModeUtil.isDarkMode(context) ? Colors.white : Color(0xff333333), fontSize: 20.0);

    return new Container(
        height: 50.0,
        width: _screenWidth / 4,
        child: new OutlineButton(
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
          borderSide: BorderSide(color: _borderColor),
          highlightedBorderColor: _borderColor,
          child: null != widget.icon ? Icon(widget.icon) : Text(widget.title, style: _textStyle),
          onPressed: () {
            if (null != widget.onPressed) widget.onPressed();
          },
        ));
  }
}
