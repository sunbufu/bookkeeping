import 'category.dart';

/// 分类tab数据
class CategoryTab {
  /// tab 名称
  String name;

  /// 0 支出，1 收入
  int direction;

  /// 分类列表
  List<Category> list;

  CategoryTab({String name, int direction, List<Category> list}) {
    this.name = name ?? '';
    this.direction = direction ?? '';
    this.list = list ?? [];
  }

  factory CategoryTab.fromJson(Map<String, dynamic> json) => CategoryTab(
    name: json["name"],
    direction: json["direction"],
    list: List<Category>.from(json["list"].map((e) => Category.fromJson(e))),
  );

  Map<String, dynamic> toJson() =>
      {"name": name, "direction": direction, "list": List<dynamic>.from(list.map((e) => e.toJson()))};

}
