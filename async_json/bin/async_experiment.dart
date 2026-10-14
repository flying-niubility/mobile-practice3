import 'dart:async';

/// 异步模型实验：串行 await  vs  Future.wait 并行
///
/// 三个 1 秒延时任务：
/// - 连续 await：约 3 秒（串行等待）
/// - Future.wait：约 1 秒（并行执行）
Future<void> main() async {
  // 模拟一个耗时 1 秒的异步任务
  Future<String> fetch(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'result-$id';
  }

  // ---- 串行 await ----
  final sw1 = Stopwatch()..start();
  final r1 = await fetch(1);
  final r2 = await fetch(2);
  final r3 = await fetch(3);
  sw1.stop();
  print('串行 await 结果: $r1, $r2, $r3');
  print('串行 await 耗时: ${sw1.elapsedMilliseconds} ms');

  // ---- Future.wait 并行 ----
  final sw2 = Stopwatch()..start();
  final results = await Future.wait([fetch(1), fetch(2), fetch(3)]);
  sw2.stop();
  print('Future.wait 结果: $results');
  print('Future.wait 耗时: ${sw2.elapsedMilliseconds} ms');
}
