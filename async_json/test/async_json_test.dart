import 'package:async_json/async_json.dart';
import 'package:test/test.dart';

void main() {
  group('Book model', () {
    test('fromJson 解析完整字段', () {
      final json = {
        'id': 'B001',
        'title': 'Flutter实战',
        'category': '移动开发',
        'borrowCount': 128,
      };
      final book = Book.fromJson(json);
      expect(book.id, 'B001');
      expect(book.title, 'Flutter实战');
      expect(book.category, '移动开发');
      expect(book.borrowCount, 128);
    });

    test('toJson 与 fromJson roundtrip 一致', () {
      final original = {
        'id': 'B002',
        'title': 'Dart编程语言',
        'category': '移动开发',
        'borrowCount': 96,
      };
      final book = Book.fromJson(original);
      final roundtrip = book.toJson();
      expect(roundtrip, original);
    });

    test('缺失 borrowCount 字段时默认为 0', () {
      final json = {
        'id': 'B003',
        'title': '测试图书',
        'category': '测试',
      };
      final book = Book.fromJson(json);
      expect(book.borrowCount, 0);
    });

    test('数字字段兼容 double 输入', () {
      final json = {
        'id': 'B004',
        'title': '测试图书',
        'category': '测试',
        'borrowCount': 10.0,
      };
      final book = Book.fromJson(json);
      expect(book.borrowCount, 10);
    });
  });
}
