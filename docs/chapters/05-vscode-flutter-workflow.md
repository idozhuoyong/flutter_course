# 05｜用 VS Code 运行、调试和热重载 Flutter 应用

最后核验：2026-09-04

## 本篇结论

VS Code 配好 Flutter 与 Dart 扩展后，可以完成设备选择、运行、断点调试、热重载和问题定位。本篇以 iOS 作为主操作平台；同一套 Flutter 运行与热重载链路也已在 Android 模拟器通过命令行实际验证，不引入新的项目依赖。

## 学完你能做到

- 确认 VS Code 已经识别 Flutter SDK、Dart 扩展和 Flutter 工程。
- 在状态栏选择指定的 iOS Simulator。
- 区分不带断点运行与断点调试。
- 使用 Debug Toolbar 完成热重载。
- 知道 Problems、Debug Console 和 Terminal 分别看什么。

## 本篇核验范围

2026-08-30 实际核对了以下现有安装环境，没有安装或升级任何工具：

- macOS 26.5.2。
- Flutter 3.47.2 stable。
- Dart 3.13.2。
- Visual Studio Code 1.133.0 arm64。
- Flutter 扩展 3.140.0。
- Dart 扩展 3.140.0。
- iOS 26.5 iPhone 17 Pro Simulator。

`Spark` 已在上述 iOS 环境完成运行、热重载、静态分析、测试和 Simulator 构建。VS Code 的设备选择、运行、调试及热重载入口逐项对照 Flutter 与 VS Code 官方文档；本次执行环境无法代替读者操作图形界面，因此不把 F5、断点命中和 Debug Toolbar 点击写成本机自动化验证结果，读者需要按文末清单自行确认。

2026-09-04 又使用同一 Flutter 3.47.2 SDK，在 Android 16（API 36）ARM64 模拟器完成 `Spark` 安装、启动、计数交互和真实源码热重载。标题从 `Spark` 临时改为 `Spark Android` 后，Flutter 报告重新载入 1 个 library；恢复标题后再次热重载成功。这里验证的是 Flutter 命令行与 Android 设备链路，不冒充 VS Code 图形界面的按钮和断点已经自动操作。Android 工具链与构建细节放在[第 06 课](06-android-toolchain-differences.md)。

## 开始前检查

你需要已经完成第 03、04 课，并满足以下条件：

- `app/pubspec.yaml` 存在。
- `flutter doctor -v` 能识别 Flutter 与 Xcode。
- iOS Simulator 已经启动。
- VS Code 已安装 Flutter 与 Dart 扩展。

Flutter 官方说明，安装 Flutter 扩展时会同时安装 Dart 扩展。如果扩展尚未安装，需要连接扩展市场；网络不可用时不要反复卸载 VS Code，应先区分是扩展市场不可达，还是 Flutter SDK 路径未识别。

## 01 打开正确的工程目录

启动 VS Code，选择 `File > Open Folder...`，打开课程仓库中的 `app/`，不要打开 `lib/` 或单独打开 `main.dart`。

Flutter 扩展通过工程根目录的 `pubspec.yaml` 识别项目。打开正确后，检查：

- Explorer 顶层能看到 `lib`、`ios`、`android` 和 `pubspec.yaml`。
- VS Code 底部状态栏显示 Flutter 版本和设备名称。
- 打开 `lib/main.dart` 后，代码没有大面积无法解析的红色波浪线。

如果状态栏没有 Flutter 信息，先确认当前窗口打开的是 `app/`，再执行 `Developer: Reload Window`，不要直接重建工程。

## 02 在 VS Code 中检查 Flutter 环境

按 `Command + Shift + P` 打开 Command Palette，输入并选择：

```text
Flutter: Run Flutter Doctor
```

VS Code 会打开 Output 面板，并在输出通道中显示 Flutter Doctor 结果。完成本篇的 iOS 主线时至少要求：

- Flutter 3.47.2 可用。
- Xcode 工具链通过。
- 能识别 iOS Simulator。

继续完成第 06 课的 Android 阶段门时，`Android toolchain` 也必须通过，并且 `flutter devices` 能看到明确标记为 `android` 的运行设备。不要为了消除警告盲目升级 AGP、Gradle 或 SDK，先按第 06 课定位缺失层级。

## 03 选择 iOS Simulator

查看 VS Code 状态栏中的设备名称。显示 `No Devices` 时，先启动 Simulator：

```bash
open -a Simulator
```

Simulator 完成开机后，点击状态栏设备名称，在设备列表中选择目标 iOS Simulator。本篇验证使用 `iPhone 17 Pro`，你的机型可以不同。

当多台真机、Simulator、macOS 和 Chrome 同时在线时，不要依赖自动选择。每次运行前都确认状态栏显示的是目标 iOS Simulator。

## 04 不带断点运行应用

打开 `lib/main.dart`，选择 `Run > Run Without Debugging`，或者按：

```text
Control + F5
```

预期结果：

- VS Code 启动 Flutter 构建任务。
- iOS Simulator 显示标题为 `Spark` 的默认计数器页面。
- 底部面板出现应用运行日志。

不带断点运行适合只检查页面和交互是否正常。如果要查看变量、调用栈或让代码暂停，应使用下一节的断点调试。

## 05 完成第一次断点调试

先停止当前运行会话，再在 `lib/main.dart` 的下面一行左侧单击，添加断点：

```dart
runApp(const MyApp());
```

红色圆点表示断点已经设置。然后选择 `Run > Start Debugging`，或者按：

```text
F5
```

应用启动后会在 `runApp` 这一行暂停。此时检查：

- Debug 侧边栏能看到 Variables 和 Call Stack。
- Debug Console 能看到调试输出。
- Debug Toolbar 中可以继续、单步和停止。

点击 Continue 后，应用继续启动并显示在 Simulator 中。完成练习后再次单击红点，移除这个断点，避免以后每次启动都停在入口。

## 06 使用 VS Code 热重载

保持 Debug 会话运行，把首页标题临时改为：

```dart
home: const MyHomePage(title: 'Spark VS Code'),
```

保存文件，然后点击 Debug Toolbar 中的 `Hot Reload`。预期结果：

- Debug Console 出现热重载完成信息。
- Simulator 标题变为 `Spark VS Code`。
- 计数器状态仍然保留。

确认后撤销修改，让代码恢复为：

```dart
home: const MyHomePage(title: 'Spark'),
```

再次保存并热重载，确保正式工程仍保持 `Spark` 基线。

如果 Debug Toolbar 没有 `Hot Reload`，先确认当前是 Flutter Debug 会话，而不是普通 Dart 文件或已经结束的运行会话。

## 07 看懂三个输出位置

三个面板用途不同：

| 位置 | 主要内容 | 什么时候先看 |
|---|---|---|
| Problems | Dart 分析器发现的错误和警告 | 代码尚未运行就有红线时 |
| Debug Console | 当前 Debug 会话的日志、异常和表达式结果 | 断点调试和运行时异常时 |
| Terminal | 手动执行的 Flutter 命令及完整构建输出 | `flutter analyze`、测试和构建失败时 |

不要只看 Simulator 上的红屏摘要。构建失败先保留 Terminal 完整输出；断点没有命中则检查 Debug 会话、断点位置和当前运行文件。

## 08 退出前做命令行验证

停止 Debug 会话，在 VS Code 集成终端中执行：

```bash
flutter analyze
flutter test
```

预期结果：

```text
No issues found!
All tests passed!
```

编辑器没有红线不等于项目验证完成。命令行结果可以避免编辑器缓存或面板过滤造成误判。

## Android 的差异

Flutter 官方的 VS Code 操作入口不因目标设备改为 Android 而改变，差别主要在状态栏中选择的设备以及背后的 Android 工具链。本课程已经验证 Android 模拟器可被 Flutter 识别、`Spark` 能运行、计数交互有效且源码热重载生效；VS Code 状态栏选择、F5 断点和 Debug Toolbar 仍需读者在图形界面自行确认，不能用命令行结果替代。

## 常见问题

### 状态栏没有 Flutter 版本和设备

确认打开的是包含 `pubspec.yaml` 的 `app/`。然后运行 `Developer: Reload Window`。仍然没有时，检查 Flutter 与 Dart 扩展是否处于 Enabled 状态，以及 `flutter --version` 是否能在终端运行。

### 按 F5 后没有出现 Flutter 调试

先打开 `lib/main.dart`，确认当前工作区是 Flutter 工程，并检查状态栏是否已经选择 iOS Simulator。不要在只打开单个 Dart 文件的空窗口中启动调试。

### 断点显示为空心或没有命中

先确认使用的是 `Run > Start Debugging`，而不是 `Run Without Debugging`。入口断点应设置在会实际执行的 `runApp(const MyApp());`，修改断点后重新启动 Debug 会话。

### 保存后 Simulator 没有变化

确认 Debug 会话仍在运行，然后主动点击 Debug Toolbar 的 `Hot Reload`。如果修改涉及原生工程、依赖或初始化流程，停止会话后重新运行。

### Output 中出现 Android 警告

如果正在完成本篇的 iOS 主线，可以先记录 Android 警告，再到第 06 课集中处理。如果已经进入 Android 阶段门，就不能忽略：运行 `flutter doctor -v`，按 Android toolchain 的具体提示检查 SDK、JDK、许可证或设备，不要把所有警告统一归因于 Flutter。

## 完成检查

- [ ] VS Code 打开的是 `app/`，状态栏显示 Flutter 版本。
- [ ] 我能明确选择目标 iOS Simulator。
- [ ] `Control + F5` 能不带断点运行 `Spark`。
- [ ] `F5` 能在 `runApp` 断点暂停，并显示 Variables 与 Call Stack。
- [ ] 我能用 Debug Toolbar 热重载，并恢复 `Spark` 标题。
- [ ] 我能区分 Problems、Debug Console 和 Terminal。
- [ ] `flutter analyze` 与 `flutter test` 通过。
- [ ] 进入 Android 阶段门后，我能选择 Android 设备，并理解命令行验证与 VS Code 图形操作不是同一份证据。

## 一手来源

- [Flutter 官方 VS Code 使用指南](https://docs.flutter.dev/tools/vs-code) 。
- [Visual Studio Marketplace：Flutter 扩展](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) 。
- [Flutter 热重载说明](https://docs.flutter.dev/tools/hot-reload) 。
- [VS Code 官方调试文档](https://code.visualstudio.com/docs/debugtest/debugging) 。
