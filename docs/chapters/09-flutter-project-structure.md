# 09｜认识 Flutter 项目：共享源码、平台工程与生成文件

最后核验：2026-09-04

## 本篇结论

Flutter 项目不是只有 `lib/main.dart`，也不是四套彼此独立的应用。`lib/` 保存共享 Dart 源码，`ios/`、`android/` 和未来的 `ohos/` 分别承担平台接入，项目根目录的 `pubspec.yaml` 则声明包、SDK 约束、资源和 Flutter 配置。

判断一个文件能不能改，先看它属于源码、平台配置还是生成产物。业务功能优先写入 `lib/`；确实涉及系统能力时才进入平台目录；`.dart_tool/`、`build/` 和带有 `Generated` 标记的本地文件通常由工具维护，不应拿来承载业务修改。

本篇以当前 `Spark` 工程为准完成结构检查，并在上游 Flutter 轨道重新验证分析、测试、iOS Simulator 构建，以及 Android 模拟器运行、debug APK 和 release AAB 构建。`ohos/` 尚未生成，因此只说明官方创建入口与验证边界，不展示不存在的本机目录。

## 学完你能做到

- 从项目根目录找到共享 Dart 入口、测试、依赖和平台工程。
- 判断一个需求应该修改 `lib/`，还是进入 iOS、Android 或 OpenHarmony 适配层。
- 看懂当前 `pubspec.yaml` 中与 `Spark` 直接相关的字段。
- 区分需要提交的源码与可以重新生成的本地文件。
- 解释为什么当前没有 `ohos/`，却仍然可以继续开发共享业务代码。

## 开始前检查

先完成[第 08 课](08-dual-sdk-tracks.md)，确保当前命令来自上游 Flutter 3.47.2，而不是尚未安装的 Flutter-OH。

进入项目根目录：

```bash
cd app
```

本篇不新增业务文件、不修改原生工程，也不运行 OpenHarmony 命令。Android 验证复用第 06 课已经跑通的现有宿主工程和构建链。

## 01 先看 Spark 的真实结构

隐藏本地缓存和平台内部细节后，当前工程可以概括为：

```text
app/
├── lib/
│   └── main.dart
├── test/
│   └── widget_test.dart
├── ios/
│   ├── Flutter/
│   ├── Runner/
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   └── RunnerTests/
├── android/
│   ├── app/
│   ├── gradle/
│   └── settings.gradle.kts
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
├── .metadata
└── README.md
```

当前没有 `ohos/`。这不是目录遗漏，而是因为 `Spark` 由上游 Flutter 创建，本机也尚未具备已验证的 Flutter-OH 工具链。

先按职责归类：

| 类别 | 当前目录或文件 | 主要职责 |
|---|---|---|
| 共享源码 | `lib/` | Dart 业务逻辑与 Flutter UI |
| 测试源码 | `test/` | 单元测试和 Widget 测试 |
| 平台工程 | `ios/`、`android/` | 原生入口、构建配置、权限和平台资源 |
| OpenHarmony 平台工程 | `ohos/` | 当前不存在，未来只能由 Flutter-OH 轨道生成并验证 |
| 项目声明 | `pubspec.yaml` | 元数据、SDK 约束、依赖、资源和 Flutter 配置 |
| 依赖锁定 | `pubspec.lock` | 记录应用实际解析到的包版本 |
| 工具配置 | `analysis_options.yaml`、`.metadata` | 分析规则与 Flutter 工程元数据 |
| 本地产物 | `.dart_tool/`、`build/` 等 | 依赖映射、缓存和构建输出，不提交 |

## 02 lib 是共享代码的默认位置

当前入口位于 `lib/main.dart`：

```dart
void main() {
  runApp(const MyApp());
}
```

执行 `flutter run` 或构建应用时，Flutter 默认从这里进入 Dart 程序。`main()` 创建根 Widget，之后的页面、状态与业务逻辑沿 Widget 树和 Dart 调用关系展开。

当前 `Spark` 仍是最小计数器基线，只有应用标题改成了 `Spark`。后续课程会逐步拆分文件，但现在不需要为了“目录看起来专业”提前创建 `models/`、`services/`、`repositories/` 等空结构。

判断代码是否应该放在 `lib/`，先问它能否用 Dart 与 Flutter 表达：

- 页面布局、状态转换和数据模型优先放在 `lib/`。
- 不依赖系统 API 的校验、排序和转换逻辑放在 `lib/`。
- 必须调用 Swift、Kotlin 或 ArkTS API 的能力，才通过插件或平台适配层进入原生目录。

共享代码不等于三端行为自动一致。它只表示源码可以复用；能否构建和运行，还取决于当前 SDK、平台工程和插件支持。

## 03 test 验证共享行为

当前 `test/widget_test.dart` 会创建 `MyApp`，点击加号并检查计数从 `0` 变成 `1`。测试通过上游 Flutter 的测试运行器执行：

```bash
"$FLUTTER_UPSTREAM_HOME/bin/flutter" test
```

`test/` 与 `lib/` 一样属于需要提交的源码。测试不是构建产物，也不应该放进 `build/`。

本课程后续会把纯 Dart 逻辑和 Widget 行为分别验证。当前测试只能证明默认计数器流程仍然工作；Android 是否运行还要由第 06 课的设备结果证明，OpenHarmony 则仍未运行。不同证据不能互相替代。

## 04 pubspec.yaml 是项目声明，不是下载结果

Flutter 官方说明，每个 Flutter 项目都有根目录 `pubspec.yaml`。当前 `Spark` 的关键内容可以缩减为：

```yaml
name: spark
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.13.2

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

这些字段各自回答不同问题：

| 字段 | 当前含义 |
|---|---|
| `name` | Dart 包名，也是 `package:spark/...` 导入路径的起点 |
| `publish_to: 'none'` | 阻止把这个应用误发布到 `pub.dev` |
| `version` | 应用版本名与构建号的来源之一 |
| `environment.sdk` | 当前项目接受的 Dart SDK 范围 |
| `dependencies` | 应用运行时直接依赖的包 |
| `dev_dependencies` | 分析、测试等开发阶段使用的包 |
| `flutter` | Flutter 专用配置，例如资源、字体和 Material 图标 |

`dependencies` 不是“已经下载到项目里的文件列表”。执行 `flutter pub get` 后，pub 会解析版本，把包放进缓存，并在 `.dart_tool/` 中生成本机依赖映射。

当前没有正式使用图片、字体或业务数据文件，因此不要提前添加空的 `assets:` 声明。需要资源时，再创建真实目录、写入声明并通过构建验证。

## 05 pubspec.lock 让应用复用同一组依赖版本

`pubspec.yaml` 可以声明版本范围，`pubspec.lock` 则记录一次依赖解析选中的具体版本。Dart 官方项目布局说明：应用项目应把 lockfile 提交到版本控制，以便后续构建继续使用同一组已解析版本。

因此当前处理方式是：

- 修改依赖声明时编辑 `pubspec.yaml`。
- 使用正确 SDK 执行 `flutter pub get`，让工具更新 `pubspec.lock`。
- 审查两个文件的实际差异后一起提交。
- 不手工编造 `pubspec.lock` 内容。

双 SDK 项目还要额外注意：Track A 生成的 lockfile 不能单独证明 Track B 兼容。当前 Dart 约束已经阻止 Flutter-OH 3.41.9 基线解析 `Spark`，所以本篇不使用 Flutter-OH 更新依赖。

## 06 ios 是 iOS 宿主工程

当前 `ios/` 是需要提交的 iOS 原生工程，不是可以整目录删除的缓存。重点位置包括：

| 路径 | 当前职责 |
|---|---|
| `ios/Runner/AppDelegate.swift` | iOS 应用委托和 Flutter Engine 接入入口 |
| `ios/Runner/SceneDelegate.swift` | 当前模板的 Scene 生命周期入口 |
| `ios/Runner/Info.plist` | iOS 应用元数据与权限描述入口 |
| `ios/Runner/Assets.xcassets/` | App Icon、Launch Image 等 iOS 资源 |
| `ios/Runner.xcodeproj/` | Xcode 项目配置 |
| `ios/Runner.xcworkspace/` | Xcode 工作区入口 |
| `ios/RunnerTests/` | iOS 原生测试目录 |
| `ios/Flutter/` | Flutter 与 Xcode 构建配置的连接层 |

当前 `AppDelegate.swift` 继承 `FlutterAppDelegate`，并在 Flutter Engine 初始化后注册插件。这说明 `ios/` 负责把 Flutter 内容接入 iOS 应用生命周期，但页面业务仍然从 `lib/main.dart` 开始。

`ios/Flutter/Generated.xcconfig` 和 `GeneratedPluginRegistrant.*` 等文件会由工具生成，并已被平台 `.gitignore` 排除。需要改变权限、Bundle 配置或原生能力时，应编辑对应源码和项目配置，不要把长期修改写进生成文件。

本篇没有修改任何 iOS 工程文件。

## 07 android 是 Android 宿主工程

当前 `android/` 同样是需要提交的平台工程。重点位置包括：

| 路径 | 当前职责 |
|---|---|
| `android/app/src/main/AndroidManifest.xml` | 应用组件、权限和 Android 元数据入口 |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Android Activity 入口 |
| `android/app/build.gradle.kts` | App 模块的 Android、Kotlin 与 Flutter 构建配置 |
| `android/settings.gradle.kts` | Gradle 插件管理、模块和 Flutter SDK 接入 |
| `android/gradle/wrapper/` | 项目使用的 Gradle Wrapper 配置 |

当前 `android/app/build.gradle.kts` 从 Flutter 工具读取 `compileSdk`、`minSdk`、`targetSdk` 和应用版本，并通过 `flutter { source = "../.." }` 指回项目根目录。这说明 Android 工程是 Flutter 应用的宿主，不是另一份业务源码。

`android/local.properties` 保存当前机器的 SDK 路径，已经被 `android/.gitignore` 排除。它是本地连接信息，不应复制给读者或提交到仓库。

本篇没有修改这些文件。当前宿主工程已通过 Android 16 模拟器安装与运行、debug APK 和 release AAB 构建，说明这套 Gradle 配置能接入共享 Flutter 应用；当前 AAB 使用模板调试密钥，不能据此宣称正式发布配置已经完成。

## 08 ohos 当前不存在，不能假装已经生成

CPF-Flutter 的 Flutter-OH 工具支持通过以下命令创建带 OpenHarmony 平台的项目：

```bash
flutter create --platforms ohos <project_name>
```

这条命令属于 Flutter-OH 轨道，不是上游 Flutter 3.47.2 的课程操作。本机尚未安装当前基线 Flutter-OH，也没有执行该命令，因此当前结构只能写成：

```text
app/
└── ohos/    # 当前不存在
```

未来生成并验证后，`ohos/` 才能作为 OpenHarmony 宿主工程进入课程，用于平台配置、签名、ArkTS 接入和 HAP 构建。生成前不列出未经当前版本核验的内部文件名，也不把旧版本示例结构复制进正文。

`ohos/` 不存在并不妨碍今天编写纯 Dart 业务逻辑，但它意味着以下结论都还不能成立：

- `Spark` 已具备 OpenHarmony 原生工程。
- 当前 Dart 约束和依赖可以被 Flutter-OH 解析。
- 插件、签名、HAP 构建或设备运行已经通过。

## 09 哪些文件应该提交

当前仓库已经用 `.gitignore` 区分源码与本地产物：

| 应提交 | 不应提交 |
|---|---|
| `lib/`、`test/` | `.dart_tool/` |
| `ios/`、`android/` 中未被忽略的源码和配置 | `build/` |
| `pubspec.yaml`、应用的 `pubspec.lock` | `android/local.properties` |
| `analysis_options.yaml`、`.metadata` | `ios/Flutter/Generated.xcconfig` |
| 项目说明文档 | IDE 工作区和本机构建缓存 |

`.metadata` 由 Flutter 工具记录项目类型和迁移基线，模板明确说明应纳入版本控制且不要手工编辑。`analysis_options.yaml` 则控制 Dart 分析规则，当前工程通过 `flutter_lints` 提供基础 lint。

判断一个陌生文件时，不要只凭文件名删除。先用 Git 检查它是否已跟踪或被哪条规则忽略：

```bash
git ls-files .
git check-ignore -v .dart_tool/package_config.json
```

第一条从当前 `app/` 目录列出仓库实际管理的文件；第二条会显示 `.dart_tool/package_config.json` 被哪条 `.gitignore` 规则排除。这两条命令只读取版本控制状态。

## 10 从需求反推修改位置

遇到修改任务时，可以按下面的顺序判断：

| 需求 | 优先位置 | 原因 |
|---|---|---|
| 新增列表页面 | `lib/` | 属于共享 Flutter UI |
| 新增纯 Dart 数据转换 | `lib/`，测试放 `test/` | 不依赖平台 API |
| 添加图片资源 | 真实资源目录和 `pubspec.yaml` | Flutter 需要显式打包资源 |
| 修改 iOS 权限说明 | `ios/Runner/Info.plist` | 属于 iOS 宿主配置 |
| 修改 Android 权限 | `android/app/src/main/AndroidManifest.xml` | 属于 Android 宿主配置 |
| 接入 OpenHarmony 原生能力 | 未来的 `ohos/` 与平台适配层 | 必须先完成 Flutter-OH 环境和工程验证 |
| 修复依赖版本 | `pubspec.yaml`，由工具更新 `pubspec.lock` | 声明与解析结果职责不同 |

平台目录不是禁区，但也不是业务代码的默认归宿。先共享，确有平台差异时再进入对应适配层，可以避免在 `lib/` 到处散布平台判断。

## 预期结果

完成本篇后，你应该能从当前工程得到以下可核对结果：

- `lib/main.dart` 是 `Spark` 当前共享 Dart 入口。
- `test/widget_test.dart` 是当前 Widget 测试。
- `pubspec.yaml` 声明项目与依赖，`pubspec.lock` 锁定应用解析结果。
- `ios/` 与 `android/` 是已生成并纳入版本控制的平台宿主工程。
- 当前 `android/` 已实际进入模拟器运行、debug APK 和 release AAB 构建链，不只是一个未验证目录。
- `.dart_tool/`、`build/` 和本机路径文件已被忽略。
- `ohos/` 当前不存在，不能宣称已完成 OpenHarmony 工程接入。

本篇不应产生新的业务页面、依赖、原生配置或 `ohos/` 目录。

## 常见问题

### 所有 Dart 文件都必须写在 main.dart 吗

不需要。`main.dart` 是当前默认入口，不是全部代码的永久容器。功能增加后可以在 `lib/` 下按清晰职责拆分，但不要在实际需求出现前创建空架构。

### ios 和 android 可以重新生成，所以不用提交吗

不能这样处理。应用的平台目录包含 Bundle、权限、签名入口、原生代码和构建配置，后续会产生项目专属修改，必须纳入版本控制。只有明确标记并已被忽略的生成文件不提交。

### pubspec.lock 应不应该提交

`Spark` 是应用项目，应该提交。Dart 官方建议应用提交 lockfile，以复用依赖解析得到的具体版本；可复用库包的规则不同。

### build 目录里的 Runner.app 是源码吗

不是。它是 iOS Simulator 构建产物，删除后可以重新构建，已经被 `.gitignore` 排除。

### 为什么当前项目没有 Podfile

当前 Flutter 3.47.2 模板的 `Spark` 工程使用现有 `ios/` 配置完成了 Simulator 构建，不能拿旧教程的目录列表要求它必须存在 `Podfile`。是否出现额外依赖管理文件，要以当前模板、依赖和实际构建结果为准。

### 能否用上游 Flutter 给现有项目补一个 ohos 目录

不能按本课程路径这样做。`ohos` target 来自 Flutter-OH 适配工具链，必须使用锁定版本的 Flutter-OH，并在配套 DevEco／API 环境中验证。

## 完成检查

- [ ] 我能解释 `lib/`、`test/`、平台目录和 `pubspec.yaml` 的职责。
- [ ] 我知道业务逻辑为什么优先放在共享 Dart 层。
- [ ] 我不会手工修改 `.dart_tool/`、`build/` 或本机路径文件。
- [ ] 我知道应用项目的 `pubspec.lock` 应该提交。
- [ ] 我不会把 iOS／Android 平台目录整体当作可丢弃缓存。
- [ ] 我知道当前 `ohos/` 不存在，Flutter-OH 仍未完成工程验证。
- [ ] 我能根据需求判断首先应该修改哪个位置。

## 一手来源

- [Flutter 官方：Flutter pubspec 配置](https://docs.flutter.dev/tools/pubspec) 。
- [Dart 官方：包目录约定](https://dart.dev/tools/pub/package-layout) 。
- [Dart 官方：pubspec 文件](https://dart.dev/tools/pub/pubspec) 。
- [Flutter 官方：iOS 项目中的 Flutter 应用结构](https://docs.flutter.dev/add-to-app/ios/project-setup) 。
- [CPF-Flutter：Flutter-OH SDK 官方仓库](https://gitcode.com/CPF-Flutter/flutter_flutter) 。
- [CPF-Flutter：Flutter-OH 环境搭建指导](https://gitcode.com/CPF-Flutter/flutter_samples/blob/master/docs/ohos/getting-started/flutter-oh-env-setup.md) 。
