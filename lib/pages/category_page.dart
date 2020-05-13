import 'package:bookkeeping/common/dark_mode_util.dart';
import 'package:bookkeeping/common/runtime.dart';
import 'package:bookkeeping/dialog/loading_dialog.dart';
import 'package:bookkeeping/model/category.dart';
import 'package:bookkeeping/model/category_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CategoryPage extends StatefulWidget {
  final int defaultTabIndex;

  CategoryPage({int defaultTabIndex}) : this.defaultTabIndex = defaultTabIndex ?? 0;

  @override
  State<StatefulWidget> createState() {
    return CategoryPageState();
  }
}

class CategoryPageState extends State<CategoryPage> with SingleTickerProviderStateMixin {
  /// 是否修改数据
  bool changed = false;

  TabController _tabController;

  List<CategoryTab> _categoryTabList = [];

  CategoryPageState() {
    // 拷贝用户修改
    for (CategoryTab categoryTab in Runtime.categoryService.categoryTabList) {
      List<Category> list = [];
      for (Category each in categoryTab.list) {
        list.add(Category(name: each.name, icon: each.icon, direction: each.direction));
      }
      _categoryTabList.add(CategoryTab(name: categoryTab.name, direction: categoryTab.direction, list: list));
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categoryTabList.length, vsync: this);
    _tabController.index = widget.defaultTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: DarkModeUtil.isDarkMode(context) ? Colors.black : Color(0xFFEEEEEE),
        appBar: AppBar(
          centerTitle: true,
          title: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: _categoryTabList.map((tab) => Tab(child: Text(tab.name, style: TextStyle(fontSize: 18)))).toList(),
          ),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.add), onPressed: () => _showAddCategory()),
            IconButton(icon: Icon(Icons.save), onPressed: () => _saveChange()),
          ],
        ),
        body: Container(child: TabBarView(
          controller: _tabController,
          children: _categoryTabList.map((categoryTab) {
            return Container(alignment: Alignment.center, child: _getCategoryItemList(categoryTab));
          }).toList(),
        )),
      ),
    );
  }

  /// 分类列表
  Widget _getCategoryItemList(CategoryTab categoryTab) {
    return ReorderableListView(
      children: categoryTab.list.map((category) {
        return Container(
          key: ObjectKey(category),
          margin: EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
            color: DarkModeUtil.isDarkMode(context) ? Color(0xFF222222) : Colors.white,
          ),
          child: Container(
            height: 60,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(children: <Widget>[
                      CircleAvatar(
                        child: Text(category.name.substring(0, 1)),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      Container(width: 10),
                      Text(category.name, style: TextStyle(fontSize: 17)),
                    ]),
                  ),
                ),
                IconButton(icon: Icon(Icons.edit), onPressed: () => _showUpdateCategory(category)),
                IconButton(icon: Icon(Icons.delete), color: Colors.red, onPressed: () => _showDeletedCategory(category)),
                IconButton(icon: Icon(Icons.drag_handle), onPressed: () {}),
              ]),
          ),
        );
//        return ListTile(key: ObjectKey(checkedEntry), title: Text(checkedEntry.entry.name),);
      }).toList(),
      onReorder: (oldIndex, newIndex) => _onReorder(categoryTab, oldIndex, newIndex),
    );
  }

  /// 返回之前
  Future<bool> _onWillPop() async {
    if (!changed) return true;
    bool result = false;
    await showDialog(context: context,
        child: AlertDialog(title: Text('是否保存更改?'), actions: <Widget>[
          FlatButton(child: Text('丢弃'), onPressed: () {
            Navigator.pop(context);
            result = true;
          }),
          FlatButton(child: Text('保存'), onPressed: () {
            Navigator.pop(context);
            _saveChange();
            result = true;
          })
        ]));
    return result;
  }

  /// 删除确认框
  void _showDeletedCategory(Category category) {
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text('确定删除分类 ${category.name} ?'),
          actions: <Widget>[
            FlatButton(child: Text('取消'), onPressed: () => Navigator.pop(context)),
            FlatButton(
              child: Text('确定'),
              onPressed: () {
                _deleteCategory(category);
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ));
  }

  /// 分类修改框
  void _showUpdateCategory(Category category) {
    TextEditingController _categoryNameController = TextEditingController(text: category.name);
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text('修改分类'),
          content: TextField(
            decoration: InputDecoration(hintText: '名称'),
            autofocus: true,
            controller: _categoryNameController,
          ),
          actions: <Widget>[
            FlatButton(child: Text('取消'), onPressed: () => Navigator.pop(context)),
            FlatButton(
              child: Text('修改'),
              onPressed: () {
                _updateCategory(category, _categoryNameController.text);
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ));
  }

  /// 添加分类框
  void _showAddCategory() {
    TextEditingController _categoryNameController = TextEditingController();
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text('新建分类'),
          content: TextField(
            decoration: InputDecoration(hintText: '名称'),
            autofocus: true,
            controller: _categoryNameController,
          ),
          actions: <Widget>[
            FlatButton(child: Text('取消'), onPressed: () => Navigator.pop(context)),
            FlatButton(child: Text('新增'),
              onPressed: () {
                _addCategory(_categoryNameController.text);
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ));
  }

  /// 修改分类
  void _updateCategory(Category category, String name) {
    if (_contains(_categoryTabList[_tabController.index].list, name)) {
      Fluttertoast.showToast(msg: '$name 分类已经存在');
      return;
    }
    category.name = name;
    changed = true;
  }

  /// 删除分类
  void _deleteCategory(Category category) {
    _categoryTabList[_tabController.index].list.remove(category);
    changed = true;
  }

  /// 添加分类
  void _addCategory(String name) {
    if (_contains(_categoryTabList[_tabController.index].list, name)) {
      Fluttertoast.showToast(msg: '$name 分类已经存在');
      return;
    }
    _categoryTabList[_tabController.index]
        .list
        .add(Category(name: name, direction: _categoryTabList[_tabController.index].direction));
    changed = true;
    setState(() {});
  }

  /// 是否包含指定名字到分类
  bool _contains(List<Category> list, String name) {
    for (Category each in list) {
      if (each.name == name) return true;
    }
    return false;
  }

  /// 顺序变更
  void _onReorder(CategoryTab categoryTab, int oldIndex, int newIndex) {
    changed = true;
    setState(() {
      if (newIndex == categoryTab.list.length) newIndex = categoryTab.list.length - 1;
      categoryTab.list.insert(newIndex, categoryTab.list.removeAt(oldIndex));
    });
  }

  /// 保存
  Future<void> _saveChange() async {
    changed = false;
    LoadingDialog.runWithLoading(context, () {
      Runtime.categoryService.categoryTabList = _categoryTabList;
    });
    Fluttertoast.showToast(msg: '保存成功');
  }
}
