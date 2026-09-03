# 10｜用 Dart 表达一条可靠的灵感数据

最后核验：2026-09-02

## 本篇结论

Dart 是类型安全的语言，但写局部变量时通常不需要重复标注显而易见的类型。会变化的状态用 `var`，初始化后不再重新赋值的变量用 `final`，编译时就确定且内容也不允许修改的值用 `const`。只有业务上确实允许“没有值”时，才把类型写成 `String?` 这样的可空类型。

本篇不罗列全部内置类型，而是完成一个可运行的小任务：把一条尚未保存的 `Spark` 灵感整理成标题、说明、优先级、预计用时、完成状态和固定标签，并让 Dart 分析器检查类型与空安全。

## 学完你能做到

- 用 `String`、`int`、`double` 和 `bool` 表达常见业务值。
- 在局部变量中正确选择 `var`、显式类型、`final` 和 `const`。
- 用 `String?` 表达“说明可以缺失”，而不是用空字符串混淆缺失状态。
- 使用 `?.`、`??` 思维和空值检查安全处理可空数据。
- 区分“变量不能重新赋值”与“对象本身不可变”。
- 通过分析和运行结果验证代码，而不是只看语法示例。

## 开始前检查

先完成[第 09 课](09-flutter-project-structure.md)，确认共享 Dart 代码与平台工程的边界。本篇示例位于：

```text
examples/lesson_10_data_basics.dart
```

示例只使用 Dart 标准库，不需要下载第三方包，也不修改 `Spark` 应用的页面和依赖。

确认当前仍使用 Track A：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/dart" --version
```

本篇实际验证版本为 Dart 3.13.2。

## 01 从一条 Spark 灵感需要哪些值开始

假设用户刚输入一条灵感：标题前后可能有空格，补充说明可以不填，完成状态以后会变化，而标题最大长度属于不会随单条数据改变的规则。

先只为这些事实选择类型：

| 业务值 | Dart 类型 | 示例 | 为什么这样选 |
|---|---|---|---|
| 标题 | `String` | `'整理 Flutter 笔记'` | 保存文本，而且最终不能为空 |
| 说明 | `String?` | `null` | 业务允许没有说明 |
| 优先级 | `int` | `2` | 使用整数等级 |
| 预计用时 | `double` | `1.5` | 允许小数小时 |
| 完成状态 | `bool` | `false` | 只有完成与未完成两种状态 |
| 标题上限 | `int` 常量 | `80` | 编译时已经确定的规则 |

Dart 的数字、字符串和布尔值都是对象。这里先掌握能直接服务业务的四种类型；集合转换留到第 12 课，类与构造函数留到第 11 课。

## 02 var 是类型推断，不是放弃类型

示例中的草稿标题这样声明：

```dart
var draftTitle = '  整理 Flutter 笔记  ';
```

Dart 会从右侧字符串推断 `draftTitle` 的静态类型为 `String`。后面可以赋另一个字符串：

```dart
draftTitle = draftTitle.trim();
```

但不能改成整数：

```dart
draftTitle = 42; // 分析错误：int 不能赋给 String
```

`var` 只省略了可以推断的类型名，不等于 JavaScript 式的“变量可以随时变成任何类型”。Dart 官方风格建议局部变量在类型明显时优先使用 `var`。

当右侧不足以表达业务约束时，再显式写类型。例如说明允许缺失：

```dart
final String? draftNote = arguments.length > 1 ? arguments[1] : null;
```

这里的 `String?` 比推断结果更重要，因为它明确告诉读者：`null` 是允许出现的业务状态。

## 03 不要用 dynamic 绕过类型问题

下面的代码虽然灵活，却把错误推迟到了运行时：

```dart
dynamic priority = 2;
priority = '高';
```

如果优先级规则就是整数，应直接让它保持 `int`：

```dart
final priority = 2;
```

此时 Dart 推断出 `int`，后续错误赋值会被分析器拦住。Dart 官方类型系统文档建议在值需要容纳多种类型时优先考虑 `Object` 或 `Object?`，只有确实需要动态成员调用时才使用 `dynamic`。

本课程不会为了少写一个转换就使用 `dynamic`。来自网络、文件或平台通道的未知数据，后续必须先检查和转换，再进入明确类型的业务代码。

## 04 var、final 与 const 解决不同问题

示例中有三类变量：

```dart
var isCompleted = false;
final priority = 2;
const maxTitleLength = 80;
```

它们的差异不是“哪一个更高级”：

| 写法 | 能否重新赋值 | 值何时确定 | 当前用途 |
|---|---|---|---|
| `var` | 可以，但新值必须符合推断类型 | 运行时 | 完成状态会从 `false` 变成 `true` |
| `final` | 只能赋值一次 | 可以到运行时才确定 | 优先级、清洗后的标题等结果 |
| `const` | 不能重新赋值 | 编译时必须确定 | 标题上限、固定标签等常量 |

因此示例可以更新状态：

```dart
isCompleted = true;
```

但下面两行都是错误：

```dart
priority = 3; // final 变量只能赋值一次
maxTitleLength = 100; // const 变量不能重新赋值
```

默认倾向很简单：确定不会重新赋值就用 `final`；业务过程确实需要变化才用 `var`；只有编译时常量才用 `const`。

## 05 final 不等于对象不可变

`final` 固定的是变量与对象之间的绑定。下面的变量不能指向另一份列表，但列表内容仍然可以改变：

```dart
final tags = <String>['Flutter'];
tags.add('iOS'); // 允许
```

真正的常量列表要创建成 `const`：

```dart
const tags = <String>['Flutter', 'iOS'];
```

此时既不能让 `tags` 指向别的对象，也不能增加、删除或替换列表元素。示例用它表示本课固定展示的标签。

这仍然只是最小认知：如果不可变集合来自运行时数据，需要采用不同的复制与封装方式，并确保元素本身也不可变。第 12 课讲集合时再完成这部分，不在本篇提前扩展。

## 06 非空是默认，可空必须明确写出来

Dart 的可靠空安全以“默认不可空”为基础：

```dart
String title = '整理 Flutter 笔记';
```

`title` 不能接收 `null`。如果说明确实可以缺失，类型必须写成：

```dart
String? note;
```

`String` 与 `String?` 是不同的静态类型。可空值不能直接调用只属于字符串的成员：

```dart
note.trim(); // 分析错误：note 可能为 null
```

这不是 Dart 故意增加麻烦，而是在代码运行到用户设备前暴露缺失值处理漏洞。

不要把所有字段都写成可空来消除初始化错误。标题在业务上必填，就应该保持 `String`；说明允许缺失，才使用 `String?`。类型应表达真实业务状态。

## 07 安全处理可空说明

示例先使用空感知调用：

```dart
final note = draftNote?.trim();
```

如果 `draftNote` 是字符串，就执行 `trim()`；如果是 `null`，整个表达式得到 `null`。因此 `note` 的推断类型仍然是 `String?`。

接着同时处理“没有说明”和“只有空格”两种情况：

```dart
final displayNote = note == null || note.isEmpty ? '无补充说明' : note;
```

当程序执行到 `note.isEmpty` 时，左侧 `note == null` 已经为假。Dart 的流程分析会把这个位置的 `note` 提升为非空 `String`，因此可以安全访问 `isEmpty`。

如果只需要为空值提供默认值，可以使用 `??`：

```dart
final displayNote = note ?? '无补充说明';
```

但这一写法不会把空字符串视为缺失。本例需要同时处理空字符串，所以保留显式判断。

## 08 不要用感叹号掩盖没有证明的非空

后缀 `!` 会告诉 Dart：“我保证这里不是 `null`。”如果保证错误，程序会在运行时失败：

```dart
final length = draftNote!.length;
```

本篇示例不需要 `!`。我们用 `?.` 跳过空值，用显式判断完成类型提升，再提供业务默认文案。

只有调用方已经建立了分析器无法看见、但可以严格证明的约束时，才考虑非空断言。把 `!` 当成消除红线的快捷键，会把本可在编辑阶段发现的问题推迟到用户设备上。

## 09 运行完整示例

打开 [lesson_10_data_basics.dart](../../examples/lesson_10_data_basics.dart)，先运行静态分析：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/dart" analyze examples/lesson_10_data_basics.dart
```

预期结果：

```text
Analyzing lesson_10_data_basics.dart...
No issues found!
```

再从项目仓库根目录运行：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/dart" run examples/lesson_10_data_basics.dart
```

预期输出：

```text
标题：整理 Flutter 笔记
说明：无补充说明
优先级：2
预计用时：1.5 小时
完成状态：false
标签：Flutter、iOS
更新后完成状态：true
```

还可以传入标题和说明，观察可空说明变成真实字符串：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/dart" run \
  examples/lesson_10_data_basics.dart \
  "整理空安全示例" \
  "补充一段可选说明"
```

这一步只传递本地命令行参数，不访问网络，也不需要 iOS、Android 或 OpenHarmony 设备。

最后传入空标题，验证输入边界：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/dart" run \
  examples/lesson_10_data_basics.dart \
  ""
```

程序应以非零状态结束，关键错误为：

```text
Bad state: 标题长度必须在 1～80 个字符之间
```

同样地，清理后超过 80 个字符的标题也应该失败；长度恰好为 1 或 80 时可以继续运行。

## 10 用分析错误验证边界

不要把错误代码留在文件里。可以临时取消下面任意一行的注释，运行 `dart analyze`，观察分析器指出问题后再恢复：

```dart
// draftTitle = 42;
// priority = 3;
// const invalidValue = DateTime.now();
// final invalidLength = draftNote.length;
```

四行分别验证：

1. 推断为 `String` 的变量不能接收 `int`。
2. `final` 变量不能再次赋值。
3. 运行时结果不能赋给 `const`。
4. `String?` 不能在未处理 `null` 前直接访问字符串成员。

恢复注释后重新运行分析，必须回到 `No issues found!`。教学中的“错误示例”用于理解边界，不能以关闭 lint、加入忽略标记或保留坏代码的方式通过验证。

## 三端差异

本篇示例只使用纯 Dart 类型、控制流和标准库，没有调用 iOS、Android 或 OpenHarmony API。源码设计上适合放在共享层，但“纯 Dart”不自动等于已经完成双 SDK 验证：

- Track A：已使用 Dart 3.13.2 实际分析和运行，并继续通过 Flutter 分析、测试与 iOS Simulator 构建。
- Android：共享 Dart 语义与 iOS 相同；按课程边界不执行 Android 运行或构建。
- Track B：当前 Flutter-OH 配套 Dart 3.11.5，而 `Spark` 要求 `^3.13.2`；本篇不在 Flutter-OH 上执行或宣称通过。

示例使用的语法没有被当作 OpenHarmony 兼容性证据。只有未来在 Flutter-OH 轨道实际分析和测试后，才能记录双轨通过。

## 预期结果

完成本篇后，应得到以下结果：

- 能根据业务是否变化选择 `var`、`final` 或 `const`。
- 知道 `var` 仍然具有推断出的静态类型。
- 能用 `String?` 表达可缺失说明，并在使用前处理 `null`。
- 知道 `final` 列表仍可能变化，`const` 列表才是常量值。
- 示例静态分析通过，默认参数与自定义参数均能运行。
- `Spark` 应用原有测试和 iOS 构建不受影响。

## 常见问题

### 局部变量应该总是显式写类型吗

不需要。右侧已经清楚表达类型时使用 `var` 或 `final` 更简洁；当显式类型能补充业务约束，例如 `String?` 表示允许缺失时，就应该写出来。

### var 和 dynamic 是一回事吗

不是。`var title = 'Spark'` 会把 `title` 推断为 `String`；`dynamic` 会关闭大部分静态成员检查，把错误推迟到运行时。

### final 和 const 应该选哪一个

运行时才能得到、但之后不再重新赋值的结果用 `final`。编译时已经确定的常量值用 `const`。不要为了追求 `const` 把运行时数据硬编码。

### 可选文本用 null 还是空字符串

如果业务需要区分“没有填写”和“填写了内容”，用 `String?` 表达缺失，并在输入边界决定空字符串是否也归一为缺失。不要让调用方各自猜测空字符串的含义。

### late 能解决所有初始化问题吗

不能。`late` 把部分初始化检查推迟到运行时，读取未初始化值会失败。本篇数据在声明或控制流中就能初始化，不需要 `late`；后续遇到真实生命周期约束时再使用。

### 为什么不用感叹号直接得到 String

因为 `!` 是运行时断言，不会为缺失值提供处理方案。本例有明确的默认文案，使用空感知操作和显式判断更安全。

## 完成检查

- [ ] 我知道 `var` 会进行类型推断，不是动态类型。
- [ ] 我会把真正变化的状态与只赋值一次的结果区分开。
- [ ] 我能解释 `final` 与 `const` 的差异。
- [ ] 我知道 `final` 不会自动冻结可变对象。
- [ ] 我只在业务允许缺失时使用可空类型。
- [ ] 我能用 `?.`、`??` 或显式检查处理可空值。
- [ ] 我不会用 `dynamic` 或 `!` 隐藏尚未解决的类型问题。
- [ ] 我已经让示例恢复到静态分析无错误的状态。

## 一手来源

- [Dart 官方：变量](https://dart.dev/language/variables) 。
- [Dart 官方：内置类型](https://dart.dev/language/built-in-types) 。
- [Dart 官方：类型系统](https://dart.dev/language/type-system) 。
- [Dart 官方：可靠空安全](https://dart.dev/null-safety) 。
- [Dart 官方：深入理解空安全](https://dart.dev/null-safety/understanding-null-safety) 。
- [Dart 官方：集合](https://dart.dev/language/collections) 。
