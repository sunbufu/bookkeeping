/// 存储适配器
abstract class StorageAdapter {

  /// 查看目录内容
  Future<List<String>> list();

  /// 文件是否存在
  Future<bool> exist(String fileName);

  /// 读取文件内容
  Future<String> read(String fileName);

  /// 写入文件内容
  Future<bool> write(String fileName, String content);

  /// 删除文件
  Future<bool> delete(String fileName);
}
