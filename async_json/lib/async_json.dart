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

  /// 从 JSON Map 构造 Book。
  /// 数字字段统一用 `as num` 再 `toInt()`，
  /// 兼容 JSON 中数字可能是 int 或 double 的情况。
  factory Book.fromJson(Map<String, dynamic> j) {
    return Book(
      id: j['id'] as String,
      title: j['title'] as String,
      category: j['category'] as String,
      borrowCount: (j['borrowCount'] as num).toInt(),
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
