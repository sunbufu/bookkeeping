/// 操作实体
class ActionEntry<T> {
  T oldEntry;
  T newEntry;
  bool deleted = false;

  ActionEntry({this.oldEntry, this.newEntry, this.deleted});
}
