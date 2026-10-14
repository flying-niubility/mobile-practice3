/// 图书模型类
///
/// 对应 data/books.json 中的每一条记录。
/// 包含 fromJson（JSON -> 对象）与 toJson（对象 -> JSON），
/// 用于验证 JSON 编解码的 roundtrip 一致性。
class Book {
  final String id;
  final String title;
  final String category;
  final int borrowCount;

  Book({
    required this.id,
    required this.title,
    required this.category,
    required this.borrowCount,
  });

  /// 从 JSON Map 构造 Book（鲁棒版）。
  ///
  /// - 字段缺失时使用默认值（borrowCount 默认 0，字符串字段默认占位文本）；
  /// - 数字字段统一用 `as num?` 再 `toInt()`，兼容 JSON 数字为 int/double；
  /// - 类型断言失败会抛出 TypeError，由调用方 try-catch 兜底。
  factory Book.fromJson(Map<String, dynamic> j) {
    return Book(
      id: (j['id'] as String?) ?? '未知ID',
      title: (j['title'] as String?) ?? '未知标题',
      category: (j['category'] as String?) ?? '未分类',
      borrowCount: (j['borrowCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// 序列化为 JSON Map。
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'borrowCount': borrowCount,
      };
}
