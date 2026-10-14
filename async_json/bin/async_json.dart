import 'dart:convert';
import 'dart:io';

import 'package:async_json/async_json.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  try {
    // 定位数据文件：项目根目录下的 data/books.json
    final dataPath = p.join('data', 'books.json');
    final file = File(dataPath);

    // 文件存在性检查，给出友好提示
    if (!await file.exists()) {
      print('数据文件缺失，请检查 data/books.json');
      return;
    }

    // 异步读取文件内容
    final String content;
    try {
      content = await file.readAsString();
    } on FileSystemException catch (e) {
      print('文件读取出错：${e.path}（${e.message}）');
      return;
    }

    // JSON 字符串 -> List<dynamic>，捕获格式错误
    final List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(content) as List<dynamic>;
    } on FormatException catch (e) {
      print('JSON 格式错误：$e');
      return;
    } catch (e) {
      print('JSON 解析失败：$e');
      return;
    }

    // 解析为 List<Book>，逐条处理类型/缺失异常
    final books = <Book>[];
    for (var i = 0; i < jsonList.length; i++) {
      try {
        books.add(Book.fromJson(jsonList[i] as Map<String, dynamic>));
      } on TypeError catch (e) {
        print('第 ${i + 1} 条记录字段类型错误，已跳过：$e');
      } catch (e) {
        print('第 ${i + 1} 条记录解析异常，已跳过：$e');
      }
    }

    if (books.isEmpty) {
      print('没有可统计的有效图书记录。');
      return;
    }

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
  } catch (e) {
    // 兜底：任何未预料的异常都不允许裸抛崩溃
    print('程序运行出错：$e');
  }
}
