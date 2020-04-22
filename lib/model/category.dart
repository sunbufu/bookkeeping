/// 分类
class Category {
  String name;
  String icon;
  int direction;

  Category({String name, String icon, int direction}) {
    this.name = name ?? '';
    this.icon = icon ?? '';
    this.direction = direction ?? 0;
  }
}
