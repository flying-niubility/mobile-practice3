# 进度报告4（第6周·Dart语言基础三：异步、异常与包管理）

## 一、任务理解

本次作业是 Dart 语言基础的收官实践，围绕**异步模型、异常处理、包管理与 JSON 编解码**四个主题展开。核心任务是复现 `async_json` 命令行小工具：异步读取本地 `data/books.json`，解析为 `Book` 模型列表，输出图书总数、各类目数量统计、借阅量 Top3。

验收标准：
- 正常路径：统计输出正确（总数、类目分布、借阅量 Top3）。
- 异常路径：文件缺失、字段缺失、类型错误三类异常均给出可读提示，不崩溃。
- 模型类：`fromJson`/`toJson` 完整，roundtrip 一致。
- 包管理：依赖使用 `^` 约束，`pubspec.lock` 已提交。
- Git：3 次以上规范提交。
- 报告：按十节模板填写。

## 二、环境与工具

- 操作系统：Windows 11
- Dart SDK：3.13.4（stable）
- 开发工具：Trae IDE
- 运行目标：命令行（Console）
- AI 工具：Trae AI（辅助代码生成与调试）
- 包管理：Dart pub（使用 `path: ^1.9.1`）

## 三、过程记录

1. `dart create async_json` 创建命令行项目，自动生成 `pubspec.yaml`、`bin/`、`lib/`、`test/` 等结构。
2. `dart pub add path` 添加 `path` 依赖（用于跨平台路径拼接），确认 `pubspec.yaml` 使用 `^1.9.1` 约束。
3. 创建 `data/books.json`，写入 20 条图书记录（5 个类目，每类 4 本），字段为 `id`、`title`、`category`、`borrowCount`。
4. 第一次提交：`feat: dataset & deps ready`。
5. 在 `lib/async_json.dart` 实现 `Book` 模型类，含 `fromJson`（`as num` → `toInt()`）与 `toJson`。
6. 在 `bin/async_json.dart` 实现 `main`：`await File.readAsString()` → `jsonDecode` → `List<Book>` → 统计输出。
7. 运行验证正常路径，输出正确。第二次提交：`feat: parse & stats from books.json`。
8. 增强鲁棒性：`fromJson` 字段缺失用默认值（`borrowCount` 默认 0）；`main` 增加文件存在性检查、`FileSystemException`/`FormatException`/`TypeError` 分层捕获。
9. 测试文件缺失、字段缺失、类型错误三条异常路径，均友好输出。第三次提交：`feat: robust missing-field & file handling`。
10. 补充异步计时实验（串行 await vs `Future.wait`）、嵌套回调改写、Stream 演示三个脚本并运行验证。第四次提交。
11. 补充单元测试（`fromJson`、roundtrip、缺失字段、double 兼容），`dart test` 全部通过，`dart analyze` 无问题。

## 四、关键代码

### 代码段 1：Book.fromJson（鲁棒版）

```dart
factory Book.fromJson(Map<String, dynamic> j) {
  return Book(
    id: (j['id'] as String?) ?? '未知ID',
    title: (j['title'] as String?) ?? '未知标题',
    category: (j['category'] as String?) ?? '未分类',
    borrowCount: (j['borrowCount'] as num?)?.toInt() ?? 0,
  );
}
```

逐行解释：
- `as String?`：允许字段为 null，缺失时不抛 `TypeError`。
- `?? '未知ID'`：null 时回退到默认占位文本。
- `(j['borrowCount'] as num?)?.toInt() ?? 0`：数字统一用 `num` 兼容 int/double，`?.` 防止 null 调用，`?? 0` 缺失时默认 0。
- 验证方式：单元测试覆盖完整字段、缺失字段、double 输入三种情况，均通过。

### 代码段 2：异步读取与解析（含异常分层捕获）

```dart
final file = File(dataPath);
if (!await file.exists()) {
  print('数据文件缺失，请检查 data/books.json');
  return;
}
final content = await file.readAsString();
final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
final books = jsonList.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
```

逐行解释：
- `await file.exists()`：异步检查文件是否存在，不存在直接友好返回。
- `await file.readAsString()`：异步读取文件，不阻塞事件循环。
- `jsonDecode`：将 JSON 字符串转为 `List<dynamic>`。
- `Book.fromJson`：逐条解析为模型对象。
- 验证方式：正常路径输出正确统计；改名 `books.json` 后运行输出"数据文件缺失"提示。

### 代码段 3：统计输出

```dart
final categoryCounts = <String, int>{};
for (final b in books) {
  categoryCounts[b.category] = (categoryCounts[b.category] ?? 0) + 1;
}
final sorted = [...books]..sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
for (final b in sorted.take(3)) {
  print('  ${b.title}（${b.borrowCount} 次借阅）');
}
```

逐行解释：
- `categoryCounts` Map 统计每个类目的图书数量，`?? 0` 处理首次出现的类目。
- `[...books]` 创建副本再排序，避免修改原列表。
- `sort` 按 `borrowCount` 降序，`take(3)` 取前三名。
- 验证方式：20 本书 5 个类目各 4 本，Top3 为机器学习(245)、深度学习(220)、深入理解计算机系统(210)，与数据一致。

## 五、检查点结果

### 正常路径

运行 `dart run`，输出：
```
图书总数: 20
各类目数量:
  移动开发: 4
  计算机基础: 4
  软件工程: 4
  人工智能: 4
  数据库: 4
借阅量 Top3:
  机器学习（245 次借阅）
  深度学习（220 次借阅）
  深入理解计算机系统（210 次借阅）
```
统计与 `books.json` 数据完全一致。

### 异常路径

1. **文件缺失**：将 `books.json` 临时改名后运行，输出 `数据文件缺失，请检查 data/books.json`，无崩溃堆栈。
2. **字段缺失**：删除首条记录的 `borrowCount` 字段后运行，程序正常输出（该书借阅量按 0 处理，不影响 Top3）。
3. **类型错误**：将首条记录 `borrowCount` 改为字符串后运行，输出 `第 1 条记录字段类型错误，已跳过`，其余 19 条正常统计。

检查点全部通过。

## 六、问题与调试

**问题：JSON 数字类型断言失败。**

- 现象：最初 `fromJson` 使用 `j['borrowCount'] as int`，当 JSON 中数字为 `10.0`（double）时抛出 `TypeError`。
- 定位：Dart 的 `jsonDecode` 对不带小数点的数字解析为 `int`，带小数点的解析为 `double`，直接 `as int` 在 double 情况下失败。
- 解决：改为 `(j['borrowCount'] as num).toInt()`，用 `num` 同时兼容 int 和 double，再统一转 `int`。鲁棒版进一步加 `?` 和 `?? 0` 处理缺失。
- 验证：单元测试"数字字段兼容 double 输入"通过。

**问题：异步函数中忘了 await。**

- 现象：初次写 `main` 时漏写 `await file.readAsString()`，拿到的是 `Future<String>` 而非 `String`，`jsonDecode` 报错。
- 定位：这是指南提到的本课最高频错误——"忘了写 await 导致拿到 Future 而不是值"。
- 解决：在所有异步调用前加 `await`，并确保 `main` 标记为 `async`。
- 验证：加上 `await` 后正常解析。

## 七、AI 使用记录

| 用途 | 指令摘要 | 输出 | 本人验证方式 |
|------|----------|------|--------------|
| 生成 Book 模型类 | 实现 fromJson/toJson，处理数字类型 | 模型类代码 | `dart test` 单元测试通过 |
| 生成 main 异步读取逻辑 | 异步读取 JSON 并统计 | main 函数代码 | `dart run` 输出正确 |
| 异常处理增强 | 文件缺失、字段缺失、类型错误兜底 | try-catch 分层代码 | 三条异常路径手动测试 |
| 异步计时实验 | 串行 await vs Future.wait 计时 | 实验脚本 | 实际运行：串行 3035ms，并行 1009ms |
| 单元测试编写 | fromJson/roundtrip/缺失字段/double 兼容 | 4 个测试用例 | `dart test` 全部通过 |

## 八、证据截图

（按要求本次不附截图，运行结果与 Git 提交记录见上文文字描述及仓库提交历史。）

## 九、自评

| 要求 | 完成情况 |
|------|----------|
| async_json 完整复现 | 已完成，正常路径统计正确 |
| 检查点（正常/异常两路） | 已完成，三条异常路径均友好提示 |
| async/await 改写嵌套回调 | 已完成，`callback_to_async.dart` 两版输出一致 |
| 异常兜底（文件/字段/类型） | 已完成，分层 try-catch |
| JSON 解析为类 + toJson roundtrip | 已完成，单元测试验证一致 |
| pubspec 规范（^ 约束 + lock 文件） | 已完成，`path: ^1.9.1`，lock 已提交 |
| Git 规范（3 次以上提交） | 已完成，共 4 次提交 |
| 报告记录 | 已完成 |

## 十、一句话收获与下一步计划

**一句话收获**：Dart 的异步本质是单线程事件循环，`await` 让出执行权而非阻塞线程；`Future.wait` 是并行利器，异常处理要做到"不裸抛、有兜底"。

**下一步计划**：
- 预习第 11 课网络请求，本课的异步 + JSON + 包管理将直接复用。
- 深入学习 `Stream` 的更多操作符（map、where、transform）和 `Isolate` 的使用场景。
