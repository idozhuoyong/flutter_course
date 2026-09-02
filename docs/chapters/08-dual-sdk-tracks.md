# 08｜用绝对路径切换上游 Flutter 与 Flutter-OH

最后核验：2026-09-02

## 本篇结论

同一台 Mac 上可以并存上游 Flutter 与 Flutter-OH，但不要把两套 SDK 的 `bin` 同时永久加入 `PATH`。本课程采用“分别保存 SDK，执行命令时写明 SDK 绝对路径”的方式：iOS／Android 命令固定交给上游 Flutter，OpenHarmony 命令固定交给 Flutter-OH。

这样做不需要安装额外的版本管理工具，也不会让目录顺序决定构建结果。每次操作前先检查 Flutter 与 Dart 版本；版本不匹配时停止，不用另一套 SDK 继续碰运气。

本篇已在本机验证上游 Flutter 3.47.2 与 Dart 3.13.2 的路径和命令。Flutter-OH SDK 尚未安装，因此涉及 Flutter-OH 的同构检查命令只依据 CPF-Flutter 官方资料给出，未在本机执行，也不代表 `Spark` 已通过 OpenHarmony 构建。

## 学完你能做到

- 解释 SDK、目标平台和项目源码为什么是三个不同概念。
- 不依赖全局 `PATH`，明确指定一条 Flutter 命令来自哪套 SDK。
- 在执行分析、测试或构建前核对 Flutter 与 Dart 版本。
- 识别终端、VS Code 和自动化脚本使用了不同 SDK 的情况。
- 判断当前 `Spark` 为什么只能在上游轨道继续开发。

## 开始前检查

先读完[第 07 课](07-flutter-oh-environment.md)，确认你理解 Flutter-OH 是独立维护的 OpenHarmony 适配 SDK，不是上游 Flutter 的一个可选 target。

本篇不会执行以下操作：

- 安装或克隆 Flutter-OH。
- 修改 `~/.zshenv`、`~/.zprofile` 或 `~/.zshrc`。
- 修改 DevEco Studio、VS Code 或系统配置。
- 修改 `Spark` 的 `pubspec.yaml`、依赖或 Dart 约束。
- 生成 `ohos/`、构建 HAP 或验证 OpenHarmony 设备。

## 01 先把三件事分开

双 SDK 不是复制两份应用。需要分开理解的是：

```text
同一份课程源码
    ├── Track A：上游 Flutter SDK → iOS／Android
    └── Track B：Flutter-OH SDK   → OpenHarmony
```

| 对象 | 本课程中的含义 | 当前状态 |
|---|---|---|
| 项目源码 | `Spark` 的 Dart 代码、资源和平台工程 | 已存在于 `app/` |
| Track A SDK | Flutter 3.47.2 stable，配套 Dart 3.13.2 | 本机已安装并验证 |
| Track B SDK | Flutter-OH `3.41.10-ohos-1.0.1`，基于上游 Flutter 3.41.9，配套 Dart 3.11.5 | 本机未安装 |
| 目标平台 | 一次命令实际要运行或构建的平台 | iOS 已验证；Android 不做构建验证；OpenHarmony 尚未验证 |

`flutter` 只是命令名。Shell 最终执行哪一个文件，取决于路径解析结果；它不会根据当前目录自动理解你想构建 iOS 还是 OpenHarmony。

## 02 为什么不把两套 SDK 都塞进 PATH

假设配置文件中同时存在：

```bash
export PATH="<flutter-upstream>/bin:$PATH"
export PATH="<flutter-oh>/bin:$PATH"
```

两行都没有语法错误，但后加入的目录通常排在前面。调换行序、重新加载不同配置文件，或从不同入口启动 VS Code，都可能改变裸命令 `flutter` 的来源。

这会产生三类问题：

1. `flutter --version` 显示的 SDK 与你以为的不同。
2. `flutter pub get` 使用了另一套 SDK 自带的 Dart 和 pub，依赖解析结果随之改变。
3. `flutter build` 能看到的 target 和使用的 Engine 来自错误轨道。

Flutter 官方安装文档说明，`PATH` 用来让终端找到 Flutter 与 Dart；修改后还要重启终端和 IDE 才能完整生效。它适合配置一套默认 SDK，不适合靠两个同名目录的排序表达本课程的双轨关系。

## 03 为两套 SDK 各自命名

先在当前终端为 SDK 根目录设置容易辨认的变量。下面的路径是结构示例，必须换成你电脑上的真实路径：

```bash
export FLUTTER_UPSTREAM_HOME="$HOME/development/flutter"
export FLUTTER_OH_HOME="$HOME/development/flutter-oh"
```

这些命令只影响当前终端，不会改 Shell 配置文件。变量指向 SDK 根目录，而不是 `bin` 目录。

用可执行文件检查路径是否有效：

```bash
test -x "$FLUTTER_UPSTREAM_HOME/bin/flutter"
test -x "$FLUTTER_OH_HOME/bin/flutter"
```

命令没有输出且退出码为 `0`，只说明对应文件存在并且可以执行，不说明版本正确，也不说明平台工具链完整。路径不存在时，先修正变量；不要继续运行后续命令。

当前课程机器的上游 SDK 实际位于：

```text
/Users/ido/development/flutter/flutter
```

这是本机记录，不应原样复制到其他电脑。

## 04 用绝对路径验明 SDK 身份

检查 Track A 时，不运行裸命令 `flutter`：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/flutter" --version
"$FLUTTER_UPSTREAM_HOME/bin/dart" --version
```

本机于 2026-09-02 使用真实上游路径执行后确认：

```text
Flutter 3.47.2 · channel stable
Dart 3.13.2 · stable · macos_arm64
```

版本输出还包含 Framework revision、Engine 和 DevTools 等信息；这里只保留判断轨道所需的字段。

Flutter-OH 安装完成后，应使用另一条绝对路径执行同构检查：

```bash
"$FLUTTER_OH_HOME/bin/flutter" --version
"$FLUTTER_OH_HOME/bin/dart" --version
"$FLUTTER_OH_HOME/bin/flutter" doctor -v
```

按本课程当前锁定的 CPF-Flutter release，前两条应能识别 Flutter-OH `3.41.10-ohos-1.0.1` 所对应的 Flutter／Dart 版本，`doctor -v` 还要检查 OpenHarmony toolchain。由于本机没有该 SDK，本篇不提供伪造输出，也不把预期版本当作运行结果。

## 05 在 Spark 中明确选择轨道

进入项目后，上游轨道的分析与测试命令写成：

```bash
cd app
"$FLUTTER_UPSTREAM_HOME/bin/flutter" analyze
"$FLUTTER_UPSTREAM_HOME/bin/flutter" test
```

iOS 构建仍然明确使用 Track A：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/flutter" build ios --simulator
```

Android 也属于 Track A，但按本课程验证边界，不执行 Android 运行或构建命令。课程后续只依据 Flutter 与 Android 官方一手资料说明相对 iOS 的差异。

OpenHarmony 命令必须交给 Track B，例如：

```bash
"$FLUTTER_OH_HOME/bin/flutter" doctor -v
"$FLUTTER_OH_HOME/bin/flutter" build hap --debug
```

上面两条只是轨道归属示例，当前不能在 `Spark` 中执行：本机未安装 Flutter-OH，项目没有 `ohos/`，配套 DevEco Studio／API 也不满足当前 release 要求。

## 06 PATH 检查只能检查裸命令

如果教程、终端历史或 IDE 任务仍在使用裸命令，先运行：

```bash
command -v flutter
command -v dart
flutter --version
dart --version
```

`command -v` 回答“裸命令会执行哪个文件”，绝对路径调用则绕过这次查找。因此：

- 裸命令指向 Track A，不影响你用 Flutter-OH 绝对路径执行检查。
- 裸命令指向 Track B，也不影响你用上游绝对路径执行 iOS 命令。
- `command -v flutter` 与 `flutter --version` 必须一起看；只有路径，没有版本，仍不足以确认轨道。

本机核验时，裸命令解析为：

```text
/Users/ido/development/flutter/flutter/bin/flutter
```

它属于 Track A。当前没有第二个 Flutter-OH 路径可供检查。

## 07 Dart 与依赖不会自动向下兼容

当前 `Spark` 的 `pubspec.yaml` 写着：

```yaml
environment:
  sdk: ^3.13.2
```

Dart 官方文档说明，SDK 约束定义包接受的 Dart 版本范围，pub 会用当前正在运行的 Dart SDK 判断约束能否满足。`^3.13.2` 不接受 Dart 3.11.5，因此当前 Flutter-OH 基线不能直接为 `Spark` 解析依赖。

这里不能用三种方式掩盖问题：

- 不要先把约束下调，再假设现有源码和依赖仍然兼容。
- 不要用 Track A 执行 `pub get`，再拿生成结果证明 Track B 可用。
- 不要只比较 Flutter 版本号，忽略每套 Flutter SDK 自带的 Dart 版本。

未来解除阻塞时，要先审计语言特性与依赖约束，再分别使用两套 SDK 执行依赖解析、静态分析和测试。两条轨道都通过后，才能修改约束并记录共享源码已兼容。

## 08 终端正确不等于编辑器正确

VS Code、集成终端和普通终端可能在不同时间读取环境。Flutter 官方文档要求在修改 `PATH` 后重启终端与 IDE，原因正是已启动进程不会自动获得后来修改的环境。

因此切换项目时至少检查：

1. 普通终端里的 `command -v flutter` 和版本。
2. VS Code 集成终端里的相同命令。
3. 实际运行任务输出中的 Flutter 与 Dart 版本。

如果三处结果不一致，先停止构建并统一 SDK 来源。不要用“终端已经正确”推断编辑器任务也正确。本课程当前只用 Track A 打开并运行 `Spark`；Flutter-OH 编辑器工作流要等环境实际安装后再验证。

## 预期结果

完成本篇后，上游轨道应能得到明确结果：

- SDK 路径真实存在。
- 绝对路径输出 Flutter 3.47.2 和 Dart 3.13.2。
- `Spark` 的分析、测试与 iOS 构建命令明确来自 Track A。

Flutter-OH 轨道当前只能得到边界结论：

- 已记录独立 SDK 路径约定和身份检查命令。
- 本机没有可执行的 Flutter-OH SDK，不能进行版本、doctor、依赖或构建验证。
- 当前 `Spark` 的 Dart 约束不接受 Flutter-OH 配套的 Dart 3.11.5。

## 常见问题

### 可以为两套 SDK 分别设置 alias 吗

可以，但 alias 属于 Shell 配置，容易在终端、IDE 和自动化脚本之间产生差异。本课程先使用可直接审计的绝对路径；等两套 SDK 都安装并验证后，再考虑是否增加项目级快捷命令。

### 为什么不直接使用 Flutter 版本管理工具

当前只需要区分两套固定 SDK，绝对路径已经能解决问题。引入新的版本管理工具会增加安装、网络、配置和维护成本，而且不能消除 Flutter-OH 与 Dart 约束的真实兼容问题。

### 设置 FLUTTER_UPSTREAM_HOME 算切换 PATH 吗

不算。变量只是保存一个目录字符串；只有运行 `export PATH=...` 才会改变裸命令的搜索顺序。本篇通过 `"$FLUTTER_UPSTREAM_HOME/bin/flutter"` 直接选择可执行文件。

### 两套 SDK 可以共用 pub 缓存吗

不能因为都是 Flutter 就默认安全。两套 SDK 的 Dart 版本、平台补丁和依赖来源可能不同。本课程会在 Flutter-OH 环境可用后验证缓存与依赖策略；本篇不配置或迁移 `PUB_CACHE`。

### 为什么不先下调 Spark 的 Dart 约束

SDK 约束是兼容性声明，不是消除错误提示的开关。没有在 Dart 3.11.5 上完成依赖解析、分析和测试，就没有证据证明下调后的声明成立。

### command -v 显示正确，为什么 VS Code 仍可能用错

`command -v` 只检查当前 Shell。VS Code 可能在 `PATH` 修改前已经启动，也可能使用自己的 SDK 配置。需要在集成终端和实际任务输出中再次核对。

## 完成检查

- [ ] 我能区分项目源码、Flutter SDK 和目标平台。
- [ ] 我没有把上游 Flutter 与 Flutter-OH 的 `bin` 同时永久加入 `PATH`。
- [ ] 我会同时检查 Flutter 路径、Flutter 版本和 Dart 版本。
- [ ] 我知道 iOS／Android 使用 Track A，OpenHarmony 使用 Track B。
- [ ] 我知道当前 `Spark` 只能在 Track A 中继续验证。
- [ ] 我没有把未执行的 Flutter-OH 命令写成已经通过。
- [ ] 我不会在双轨验证前下调 `Spark` 的 Dart 约束。

## 一手来源

- [Flutter 官方：将 Flutter 添加到 PATH](https://docs.flutter.dev/install/add-to-path) 。
- [Flutter 官方：中国网络环境下使用 Flutter](https://docs.flutter.dev/community/china) 。
- [Dart 官方：pubspec 与 SDK 约束](https://dart.dev/tools/pub/pubspec#sdk-constraints) 。
- [CPF-Flutter：Flutter-OH SDK 与 Engine 官方仓库](https://gitcode.com/CPF-Flutter/flutter_flutter) 。
- [CPF-Flutter：3.41.10-ohos-1.0.1 稳定 tag](https://gitcode.com/CPF-Flutter/flutter_flutter/tree/3.41.10-ohos-1.0.1) 。
- [CPF-Flutter：3.41.9-ohos-1.0.1 Release Notes](https://gitcode.com/CPF-Flutter/flutter_flutter/blob/3.41.10-ohos-1.0.1/release-notes/Flutter%203.41.9-ohos%201.0.1%20ReleaseNote.md) 。
- [CPF-Flutter：Flutter-OH 环境搭建指导](https://gitcode.com/CPF-Flutter/flutter_samples/blob/master/docs/ohos/getting-started/flutter-oh-env-setup.md) 。
