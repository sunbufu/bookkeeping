import 'package:bookkeeping/common/action_entry.dart';
import 'package:bookkeeping/common/checked_entry.dart';
import 'package:bookkeeping/common/date_time_util.dart';
import 'package:bookkeeping/item/category_item.dart';
import 'package:bookkeeping/item/number_key_board.dart';
import 'package:bookkeeping/model/category.dart';
import 'package:bookkeeping/model/record.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailPage extends StatefulWidget {
  final Record record;

  DetailPage(Record record) : this.record = record;

  @override
  State<StatefulWidget> createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
  List<CategoryCheckedTab> tabs = [
    CategoryCheckedTab(name: '支出', direction: 0, list: [
      CheckedEntry(entry: Category(name: '吃喝', direction: 0), checked: false),
      CheckedEntry(entry: Category(name: '生活', direction: 0), checked: false),
      CheckedEntry(entry: Category(name: '零食', direction: 0), checked: false),
      CheckedEntry(entry: Category(name: '交通', direction: 0), checked: false),
      CheckedEntry(entry: Category(name: '孩子', direction: 0), checked: false),
      CheckedEntry(entry: Category(name: '宠物', direction: 0), checked: false),
    ]),
    CategoryCheckedTab(name: '收入', direction: 1, list: [
      CheckedEntry(entry: Category(name: '工资', direction: 1), checked: false),
      CheckedEntry(entry: Category(name: '奖金', direction: 1), checked: false),
    ]),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    if (null != widget.record) {
      for (int i = 0; i < tabs.length; i++) {
        if (tabs[i].direction == widget.record.direction) {
          _tabController.index = i;
          _checkCategory(tabs[i].list, widget.record.category);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xEEEEEEEE),
      appBar: AppBar(
        centerTitle: true,
        title: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: tabs.map((categoryTab) {
            return Tab(
              child: Text(
                categoryTab.name,
                style: TextStyle(fontSize: 18),
              ),
            );
          }).toList(),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.delete), onPressed: (){
            showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text('提示'),
                  content: Text('确认删除该记录吗？'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('取消'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('确定'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pop(context, ActionEntry(oldEntry: widget.record, newEntry: null, deleted: true));
                      },
                    ),
                  ],
                );
              },
            );
          },),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: tabs.map((categoryTab) {
                  return Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: _getCategoryView(categoryTab),
                  );
                }).toList(),
              ),
            ),
            NumberKeyBoard(
                amount: null != widget.record ? widget.record.amount : 0,
                dateTime: null != widget.record ? DateTimeUtil.getDateTimeByTimestamp(widget.record.time) : null,
                remark: null != widget.record ? widget.record.remark : '',
                callback: (value, dateTime, remark) {
                  Category category = _getCheckedCategory();
                  if (null == category) {
                    Fluttertoast.showToast(msg: '请选择分类');
                    return;
                  }
                  Record newRecord;
                  if (null == widget.record)
                    newRecord = Record(amount: value);
                  else
                    newRecord = Record(id: widget.record.id, amount: value);
                  newRecord.direction = category.direction;
                  newRecord.category = category.name;
                  newRecord.remark = remark;
                  newRecord.time = DateTimeUtil.getTimestampByDateTime(dateTime);
                  newRecord.createdTime = DateTimeUtil.getTimestamp();
                  Navigator.pop(context, ActionEntry(oldEntry: widget.record, newEntry: newRecord, deleted: false));
                }),
          ],
        ),
      ),
    );
  }

  Category _getCheckedCategory() {
    Category result;
    tabs.forEach((tab) => tab.list.forEach((each) {
          if (each.checked) result = each.entry;
        }));
    return result;
  }

  Widget _getCategoryView(CategoryCheckedTab categoryTab) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        itemCount: categoryTab.list.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              color: Colors.white,
            ),
            margin: EdgeInsets.all(5),
            child: CategoryItem(categoryTab.list[index], _onSelected),
          );
        });
  }

  void _onSelected(CheckedEntry<Category> categoryChecked) {
    tabs.forEach((categoryCheckedTab) {
      if (categoryCheckedTab.direction != categoryChecked.entry.direction){
        _checkCategory(categoryCheckedTab.list, null);
      } else {
        _checkCategory(categoryCheckedTab.list, categoryChecked.entry.name);
      }
    });
    setState(() {});
  }

  void _checkCategory(List<CheckedEntry<Category>> categoryCheckedList, String category) {
    categoryCheckedList.forEach((each){
      if(each.entry.name == category) {
        each.checked = true;
      } else {
        each.checked = false;
      }
    });
  }
}

class CategoryCheckedTab {
  String name;

  /// 0 支出，1 收入
  int direction;
  List<CheckedEntry<Category>> list;

  CategoryCheckedTab({String name, int direction, List<CheckedEntry<Category>> list}) {
    this.name = name ?? '';
    this.direction = direction ?? '';
    this.list = list ?? [];
  }
}
