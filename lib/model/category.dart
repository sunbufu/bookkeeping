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

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    name: json["name"],
    icon: json["icon"],
    direction: json["direction"],
  );

  Map<String, dynamic> toJson() =>
      {"name": name, "icon": icon, "direction": direction};
}
