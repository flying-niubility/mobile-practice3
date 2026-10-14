import 'dart:convert';
import 'dart:io';

import 'package:async_json/async_json.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  // 定位数据文件：项目根目录下的 data/books.json
  final dataPath = p.join('data', 'books.json');
  final file = File(dataPath);

  // 异步读取文件内容
  final content = await file.readAsString();

  // JSON 字符串 -> List<dynamic>
  final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;

  // 解析为 List<Book>
  final books = jsonList
      .map((e) => Book.fromJson(e as Map<String, dynamic>))
      .toList();

  // 1. 输出总数
  print('图书总数: ${books.length}');

  // 2. 各类目数量统计（Map）
  final categoryCounts = <String, int>{};
  for (final b in books) {
    categoryCounts[b.category] = (categoryCounts[b.category] ?? 0) + 1;
  }
  print('各类目数量:');
  categoryCounts.forEach((k, v) => print('  $k: $v'));

  // 3. 借阅量 Top3
  final sorted = [...books]
    ..sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
  print('借阅量 Top3:');
  for (final b in sorted.take(3)) {
    print('  ${b.title}（${b.borrowCount} 次借阅）');
  }
}
