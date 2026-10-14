import 'dart:async';

/// Stream 初识演示（对应指南 2.2 节）
///
/// Stream 是异步的事件序列（0 到多个值随时间到达），
/// Future 可以看作"一次性的 Stream"。
/// 使用 `await for` 消费一个流。
Future<void> main() async {
  // 每秒产生一个递增整数，取前 3 个
  final stream = Stream.periodic(const Duration(seconds: 1), (i) => i).take(3);

  print('开始消费 Stream...');
  await for (final i in stream) {
    print('tick $i');
  }
  print('Stream 消费完毕');
}
