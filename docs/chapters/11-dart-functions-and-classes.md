# 11｜用函数和类建立一条有效的灵感

最后核验：2026-09-04

## 本篇结论

函数负责完成边界明确的操作，类负责把属于同一个业务对象的数据和行为组织在一起。为 `SparkIdea` 设计构造函数时，标题使用 `required` 命名参数，说明允许省略，优先级和完成状态提供默认值；构造过程同时清洗和检查输入，避免创建标题无效的灵感对象。

本篇不罗列 Dart 的所有函数和构造函数形式，而是把第 10 课的一组局部变量整理成可重复创建、始终满足当前规则的 `SparkIdea`。

## 学完你能做到

- 声明带有明确参数类型和返回类型的函数。
- 区分位置参数、命名参数、`required` 和默认值。
- 用类组合一条灵感的数据与行为。
- 用构造函数初始化非空和 `final` 字段。
- 理解 `required` 只保证调用方传参，业务内容仍需单独验证。
- 通过静态分析和实际运行验证调用边界。

## 开始前检查

先完成[第 10 课](10-dart-data-basics.md)，确认类型、空安全、`final` 和 `const` 的基本边界。本篇示例位于：

```text
examples/lesson_11_functions_and_classes.dart
```

示例只使用 Dart 标准库，不下载第三方包，也不修改 `Spark` 应用代码或依赖。

确认当前仍使用 Track A：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/dart" --version
```

本篇实际验证版本为 Dart 3.13.2。

## 01 先把标题清洗写成函数

第 10 课直接在 `main()` 中清洗并检查标题。当每次创建灵感都要遵守相同规则时，应把这项操作提取成函数：

```dart
const maxTitleLength = 80;

String normalizeTitle(String value) {
  final title = value.trim();

  if (title.isEmpty || title.length > maxTitleLength) {
    throw StateError('标题长度必须在 1～$maxTitleLength 个字符之间');
  }

  return title;
}
```

函数签名已经说明输入和输出：调用方必须传入一个 `String`，正常返回时也一定得到 `String`。函数先去掉首尾空格，再检查长度；无效输入不会伪装成正常标题继续流入业务对象。

这里不用箭头语法。Dart 的 `=>` 只适合单个表达式，而当前函数包含局部变量、条件判断和抛出错误，普通函数体更直接。

说明的规则不同：它允许缺失，只有空格的说明也归一为 `null`：

```dart
String? normalizeNote(String? value) {
  final note = value?.trim();
  return note == null || note.isEmpty ? null : note;
}
```

输入与返回值都写成 `String?`，准确表达这项业务允许“没有说明”。

## 02 参数位置也是接口设计

普通位置参数按顺序传入：

```dart
normalizeTitle('  整理 Flutter 笔记  ');
```

这里只有一个必填值，函数名与参数类型足以说明含义。若一个对象同时接收标题、说明、优先级和完成状态，全部使用位置参数会得到难读的调用：

```dart
// 不采用：2 和 false 的含义需要回头查看构造函数。
// SparkIdea('整理 Flutter 笔记', null, 2, false);
```

`SparkIdea` 改用命名参数后，调用处能直接说明每个值的用途：

```dart
final idea = SparkIdea(
  title: '  整理 Flutter 笔记  ',
  note: '补充类与构造函数示例',
  priority: 2,
);
```

命名参数写在 `{}` 中，调用时使用 `参数名: 值`。它们默认是可选的；若参数不可空又没有默认值，就必须标记 `required`。

## 03 用类组织同一条灵感的数据

类是对象的定义。当前 `SparkIdea` 只保留本课真正需要的四个字段：

```dart
class SparkIdea {
  final String title;
  final String? note;
  final int priority;
  final bool isCompleted;
}
```

每次调用构造函数都会创建一个 `SparkIdea` 实例。字段使用 `final`，表示对象创建后不能把标题、说明、优先级或完成状态直接改成另一个值。

这并不表示应用以后不能编辑灵感。后续讲状态和数据模型时，可以通过创建包含新值的对象表达一次变更。本篇只建立一个小而清楚的数据边界，不提前设计完整状态方案。

## 04 用构造函数建立有效对象

只有字段还不够：非空的 `final` 字段必须在对象创建期间完成初始化。本篇构造函数如下：

```dart
SparkIdea({
  required String title,
  String? note,
  this.priority = 2,
  this.isCompleted = false,
}) : title = normalizeTitle(title),
     note = normalizeNote(note) {
  if (priority < 1 || priority > 3) {
    throw RangeError.range(priority, 1, 3, 'priority');
  }
}
```

四种写法各自表达不同约束：

| 参数 | 写法 | 调用约束 | 构造时的处理 |
|---|---|---|---|
| 标题 | `required String title` | 必须传入且不能为 `null` | 清除首尾空格并检查长度 |
| 说明 | `String? note` | 可以省略，也可以传入 `null` | 空白说明归一为 `null` |
| 优先级 | `this.priority = 2` | 可以省略 | 默认是 `2`，并检查必须位于 1～3 |
| 完成状态 | `this.isCompleted = false` | 可以省略 | 默认是 `false` |

`this.priority` 是初始化形式参数，它直接把收到的值赋给同名字段。标题和说明还要先转换，所以初始化列表在构造函数体运行前调用清洗函数，再分别赋给 `title` 和 `note`。

`required` 只检查参数有没有出现在调用处。`title: ''` 仍然满足“已经传参”，但不满足标题业务规则，因此还需要 `normalizeTitle()`。同理，静态类型只能保证优先级是 `int`，不能自动保证它位于 1～3。

默认参数值必须是编译期常量。这里的 `2` 和 `false` 都满足要求。

## 05 方法可以使用当前对象的数据

函数写在类中就是方法。实例方法可以直接访问当前对象的字段：

```dart
String describe() {
  final displayNote = note ?? '无补充说明';

  return '标题：$title\n'
      '说明：$displayNote\n'
      '优先级：$priority\n'
      '完成状态：$isCompleted';
}
```

调用方法时先写对象，再通过 `.` 访问：

```dart
print(idea.describe());
```

标题清洗仍保留为顶层函数，因为它不依赖某个已经存在的 `SparkIdea`。`describe()` 必须读取当前实例的多个字段，所以放在类中更自然。本篇不为了展示语法而把所有函数都塞进类里。

## 06 运行完整示例

打开 [lesson_11_functions_and_classes.dart](../../examples/lesson_11_functions_and_classes.dart)，先运行格式检查和静态分析：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/dart" format --output=none --set-exit-if-changed \
  examples/lesson_11_functions_and_classes.dart
"$FLUTTER_UPSTREAM_HOME/bin/dart" analyze \
  examples/lesson_11_functions_and_classes.dart
```

预期分析结果：

```text
Analyzing lesson_11_functions_and_classes.dart...
No issues found!
```

再从仓库根目录运行：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/dart" run \
  examples/lesson_11_functions_and_classes.dart
```

预期输出：

```text
标题：整理 Flutter 笔记
说明：无补充说明
优先级：2
完成状态：false
```

传入标题和说明，观察构造函数完成清洗：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/dart" run \
  examples/lesson_11_functions_and_classes.dart \
  "  学习 Dart 构造函数  " \
  "  为 Spark 建立数据模型  "
```

预期输出中的首尾空格已经移除：

```text
标题：学习 Dart 构造函数
说明：为 Spark 建立数据模型
优先级：2
完成状态：false
```

最后传入空标题：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/dart" run \
  examples/lesson_11_functions_and_classes.dart \
  ""
```

程序应以非零状态结束，关键错误为：

```text
Bad state: 标题长度必须在 1～80 个字符之间
```

长度恰好为 1 或 80 时可以创建对象，清洗后超过 80 个字符时应失败。本例只接收本地命令行参数，不访问网络，也不需要移动设备。

## 07 用分析错误验证调用边界

不要把错误代码留在文件里。可以临时取消下面任意一行的注释，运行 `dart analyze`，观察错误后再恢复：

```dart
// SparkIdea();
// SparkIdea(title: '学习 Dart', priority: null);
```

第一行缺少 `required` 标题，第二行把 `null` 传给非空的 `int`。它们都应在静态分析阶段被发现。

还可以临时运行以下代码，理解静态约束与业务约束的差别：

```dart
SparkIdea(title: '学习 Dart', priority: 4);
```

`4` 的类型是合法的 `int`，所以静态分析不会报错；构造函数会在运行时抛出 `RangeError`，阻止无效对象建立。验证后恢复示例，不通过忽略规则或删除检查来掩盖错误。

## 三端差异

本篇只使用纯 Dart 的函数、类、构造函数和标准库，没有调用 iOS、Android 或 OpenHarmony API：

- Track A：已使用 Dart 3.13.2 实际完成格式检查、静态分析和运行，并继续验证 Flutter 工程与 iOS Simulator 构建。
- Android：共享 Dart 语义与 iOS 相同；按课程边界不执行 Android 运行或构建。
- Track B：本机尚未安装 Flutter-OH，本篇不在 Dart 3.11.5 上执行或宣称通过。示例刻意不使用 Dart 3.13 新增的主构造函数，但这不能代替实际双轨验证。

## 预期结果

完成本篇后，应得到以下结果：

- 标题与说明的清洗规则分别集中在函数中。
- `SparkIdea` 构造函数用命名参数清楚表达每个值的含义。
- 缺少标题或传错静态类型时，分析器能直接指出错误。
- 空标题和越界优先级无法创建正常业务对象。
- 示例默认参数、自定义参数和输入边界均符合预期。
- `Spark` 应用原有测试和 iOS 构建不受影响。

## 常见问题

### 所有参数都应该改成命名参数吗

不是。参数很少、顺序含义明确时，位置参数更简洁。构造对象时通常有多个含义不同的值，命名参数能让调用处更清楚；Flutter 的 Widget 构造函数也广泛使用这种形式。

### required 是否表示参数不能为 null

不是。`required` 表示调用方必须写出该命名参数；能否传入 `null` 由类型决定。`required String title` 必须传入非空字符串，`required String? title` 则必须传参但允许值为 `null`。

### 为什么 required 之后还要检查标题

类型系统知道标题是 `String`，却不知道空字符串和 81 个字符的字符串违反当前业务规则。类型约束与业务校验解决的是两类问题。

### 为什么不用 assert 检查业务输入

`assert` 用来捕获开发期间不应发生的内部错误，在生产模式中不会执行。标题和优先级可能来自用户输入，必须在所有运行模式下检查，因此示例主动抛出错误。

### 为什么不使用 Dart 3.13 的主构造函数

当前 Track A 可以使用该语法，但课程还计划让共享 Dart 代码进入配套 Dart 3.11.5 的 Flutter-OH 轨道。传统构造函数已经足够表达本课概念，也避免无必要地提高语法版本门槛；是否真正兼容仍要等 Track B 实际验证。

### 为什么字段都是 final，完成状态以后怎么修改

`final` 防止同一个对象被原地改写，不等于业务状态永远不变。后续课程会在真实状态场景中创建带有新值的对象；本篇不提前加入 `copyWith` 或状态管理代码。

## 完成检查

- [ ] 我能从函数签名看出参数类型和返回类型。
- [ ] 我知道位置参数与命名参数各自适合什么调用场景。
- [ ] 我能解释 `required`、可空参数和默认值的差异。
- [ ] 我知道构造函数负责初始化对象字段。
- [ ] 我知道 `required` 不能代替业务内容校验。
- [ ] 我能区分顶层函数与实例方法。
- [ ] 我已经让示例恢复到格式检查和静态分析均通过的状态。

## 一手来源

- [Dart 官方：函数](https://dart.dev/language/functions) 。
- [Dart 官方：类](https://dart.dev/language/classes) 。
- [Dart 官方：构造函数](https://dart.dev/language/constructors) 。
- [Dart 官方：错误处理与 assert](https://dart.dev/language/error-handling) 。
- [Effective Dart：用法](https://dart.dev/effective-dart/usage) 。
