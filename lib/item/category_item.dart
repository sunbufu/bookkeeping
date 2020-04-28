import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/model/category.dart';
import 'package:bookkeeping/common/checked_entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final Color _disableColor = Colors.grey;
  final Color _enableColor = Colors.blueAccent;

  final bool _checked;

  final CheckedEntry<Category> _category;

  final Function(CheckedEntry<Category>) _onPressed;

  CategoryItem(CheckedEntry<Category> category, Function(CheckedEntry<Category>) onPressed)
      : this._category = category,
        this._onPressed = onPressed,
        this._checked = category.checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        color: DarkModeUtil.isDarkMode(context) ? Color(0xFF222222) : Colors.white,
      ),
      child: FlatButton(
          onPressed: () => _onPressed(_category),
          child: Column(
            children: <Widget>[
              Container(height: 5),
              CircleAvatar(
                child: Text(_category.entry.name.substring(0, 1)),
                backgroundColor: _checked ? _enableColor : _disableColor,
                foregroundColor: Colors.white,
              ),
              Text(_category.entry.name,
                style: TextStyle(fontSize: 12, color: _checked ? _enableColor : _disableColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            ],
          )),
    );
  }
}
