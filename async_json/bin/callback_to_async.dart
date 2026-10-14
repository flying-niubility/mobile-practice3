import 'dart:async';

/// 自主实践任务1：嵌套回调版 改写为 顺序 async/await 版
///
/// 场景：依次获取用户 -> 获取订单 -> 获取订单详情，三步有依赖关系。
/// 嵌套回调版（callback hell）与 async/await 版功能等价，
/// 但后者可读性与可维护性显著更好。

// ---- 模拟异步 API ----
Future<String> fetchUser() async {
  await Future.delayed(const Duration(milliseconds: 100));
  return 'user_42';
}

Future<String> fetchOrder(String userId) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return 'order_$userId';
}

Future<String> fetchOrderDetail(String orderId) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return 'detail_$orderId';
}

// ---- 嵌套回调版（回调地狱）----
void nestedCallbackVersion() {
  fetchUser().then((userId) {
    fetchOrder(userId).then((orderId) {
      fetchOrderDetail(orderId).then((detail) {
        print('[嵌套回调] 最终结果: $detail');
      });
    });
  });
}

// ---- async/await 顺序版 ----
Future<void> asyncAwaitVersion() async {
  final userId = await fetchUser();
  final orderId = await fetchOrder(userId);
  final detail = await fetchOrderDetail(orderId);
  print('[async/await] 最终结果: $detail');
}

Future<void> main() async {
  print('--- 嵌套回调版 ---');
  nestedCallbackVersion();
  await Future.delayed(const Duration(milliseconds: 500));

  print('\n--- async/await 顺序版 ---');
  await asyncAwaitVersion();
}
