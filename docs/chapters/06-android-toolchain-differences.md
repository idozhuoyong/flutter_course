# 06｜看懂 Android Studio、Android SDK、模拟器与构建流程差异

最后核验：2026-08-31

## 本篇结论

Android Studio 只是开发入口之一，不等于完整的 Android 工具链。Flutter 面向 Android 运行或构建时，还会依赖 Android SDK、JDK、Gradle、Android Gradle Plugin、设备或模拟器；这些组件与 iOS 的 Xcode、Simulator 和构建系统并不是逐项等价的替换关系。

本篇只帮助你看懂这套关系以及它与 iOS 流程的差异，不安装或修改 Android 工具，不创建模拟器，不运行 Android 应用，也不构建 APK／AAB。

## 学完你能做到

- 区分 Android Studio、Flutter 插件、Flutter SDK 和 Android SDK。
- 解释 SDK Platform、Build-Tools、Platform-Tools、Command-line Tools、Emulator 与系统镜像的职责。
- 区分 AVD 配置和 Android Emulator 运行实例。
- 说清 Flutter、Gradle、Android Gradle Plugin 和 JDK 如何参与 Android 构建。
- 区分 APK 与 AAB，不把 Google Play 的要求套用到所有中国大陆 Android 渠道。
- 遇到下载失败时，先判断失败的是 Flutter、Android SDK、Gradle 还是 Maven 依赖。

## 本篇核验边界

2026-08-31 已逐项核对 Flutter 与 Android 官方文档，并只读检查课程 `Spark` 工程中的 Android 目录结构。

以下内容没有进行实际验证：

- Android Studio 的 Flutter 插件安装与运行。
- Android SDK 组件下载和许可证接受。
- AVD 创建、启动与设备连接。
- `flutter doctor` 的 Android toolchain 结果。
- Android 调试、热重载、APK／AAB 构建与签名。

因此，本篇出现的 Android 操作入口和命令只用于说明它们在完整流程中的位置，不代表课程已经执行通过。

## 开始前检查

你需要已经读完第 05 课，并能在 iOS Simulator 中运行 `Spark`。本篇继续使用现有 `app/` 工程，不要求你打开 Android Studio。

在 VS Code Explorer 中展开 `app/android/`。只查看文件，不修改 Gradle、SDK、JDK、签名或环境变量配置。

## 01 不要把 Android Studio 当成全部工具链

Flutter 官方明确说明：只安装 Android Studio 的 Flutter 插件并不够，仍然需要 Flutter SDK；要面向 Android 运行，还需要 Android SDK 和对应工具。

各层职责如下：

| 组件 | 负责什么 | 与 iOS 学习路径的主要差异 |
|---|---|---|
| Android Studio | 编辑器，以及 SDK Manager、Device Manager、Gradle 等工具的图形入口 | Xcode 同时承担 Apple 平台 IDE 和构建工具入口；Android Studio 本身不等于 Android SDK |
| Flutter 插件 | 让 Android Studio 识别 Flutter 工程，提供 Dart 分析、运行、调试和 Inspector 入口 | 类似第 05 课的 VS Code Flutter 扩展，但不能代替 Flutter SDK |
| Flutter SDK | 提供 `flutter` 命令、Flutter Framework 和构建协调逻辑 | iOS 与 Android 共用上游 Flutter SDK |
| Android SDK | 提供 Android 平台 API、构建工具、设备通信和模拟器相关工具 | 不由 Xcode 管理，需要单独通过 Android SDK 工具管理 |
| JDK | 运行 Gradle，并参与 Java／Kotlin 构建 | iOS 构建不经过 JVM 与 Gradle |
| Gradle 与 AGP | 读取构建脚本并完成 Android 专用编译、打包和变体配置 | 对应的是 Android 构建链，不应当作 Xcode 工程文件的同名替代品 |

你仍然可以用 VS Code 编写 Flutter 代码。是否使用 Android Studio 作为日常编辑器，与 Android SDK、JDK 和 Gradle 是否齐全，是两个问题。

## 02 Android SDK 不是一个单独文件

Flutter 官方 Android 环境说明要求通过 SDK Manager 管理平台和工具。主要组件的职责不同：

| SDK 组件 | 作用 | 缺失时影响 |
|---|---|---|
| SDK Platform | 提供某个 Android API Level 的平台 API | 无法针对相应平台编译 |
| SDK Build-Tools | 包含打包、签名分析等构建工具 | Gradle 无法完成部分构建步骤 |
| SDK Command-line Tools | 提供 SDK 包管理和许可证相关命令 | 命令行管理 SDK 受阻 |
| SDK Platform-Tools | 包含 `adb` 等设备通信工具 | 无法正常识别、安装或调试设备上的应用 |
| Android Emulator | 运行虚拟 Android 设备 | 不能在本机启动 Android 虚拟设备 |
| System Image | AVD 实际启动的 Android 系统 | 只有 Emulator 程序也无法创建可启动设备 |
| CMake 与 NDK | 构建原生 C／C++ 代码 | 使用相关原生插件或工程时可能无法构建 |

不要看到一个“Android SDK 已安装”提示，就默认所有平台、工具和系统镜像都齐全。SDK Platform、Build-Tools、Emulator 和 System Image 是不同下载项。

本课程也不在正文固定某个 API Level。实际项目需要同时考虑 Flutter 模板、Android Gradle Plugin 兼容范围，以及 `compileSdk`、`targetSdk`、`minSdk` 的用途；只追求数字最大并不能证明工具链兼容。

## 03 AVD 与 Emulator 不是同一个概念

Android 官方将 AVD 定义为虚拟设备配置，其中包含硬件规格、系统镜像、存储和其他属性。Android Emulator 则读取这份配置，启动一个可交互的虚拟设备实例。

对应关系可以这样理解：

```text
Device Manager 创建和管理 AVD
              ↓
AVD 指定硬件配置与 System Image
              ↓
Android Emulator 启动这个虚拟设备
              ↓
adb 与 Flutter 工具识别运行中的设备
```

iOS Simulator 通常由 Xcode 统一提供运行时与设备管理入口；Android 需要分别关注 Emulator 程序、AVD 配置和 System Image。删除其中一层，另外两层仍可能存在。

带 Google Play 标识的 AVD 系统镜像可以包含 Play Store 和 Google Play 服务，但这不代表中国大陆常见真机默认具备同样环境。课程后续说明 Android 差异时，不会用一台带 GMS 的模拟器代表所有大陆设备。

## 04 Android 构建多了一条 Gradle 链路

Flutter 的 Android 构建不是 Android Studio 直接把 Dart 文件变成 APK。整体关系是：

```text
Dart 与 Flutter 资源
        ↓
Flutter 构建工具
        ↓
项目中的 Gradle Wrapper
        ↓
Gradle + Android Gradle Plugin + JDK
        ↓
Android SDK Build-Tools
        ↓
APK 或 AAB
```

Gradle、Android Gradle Plugin、JDK 和 Android SDK 之间存在版本兼容关系。更新 Android Studio 后出现同步提示，不代表应该把每个项目的 AGP 或 Gradle 一并升级到最高版本；应先核对 Flutter 模板和 Android 官方兼容表，再决定是否修改工程。

与第 04 课的 iOS 路径对比：

| 阶段 | iOS | Android |
|---|---|---|
| 原生工程入口 | `ios/Runner.xcworkspace` 或 Xcode 工程 | `android/` Gradle 工程 |
| 构建系统 | Xcode Build System | Gradle + AGP |
| 本机虚拟设备 | iOS Simulator | AVD + Android Emulator |
| 调试安装包 | Simulator 中的 `.app` | 可安装的 debug APK |
| 发布准备 | Archive、签名与 App Store 流程 | release 签名，以及 APK 或 AAB |

## 05 APK 与 AAB 解决的问题不同

APK 是可以安装到 Android 设备上的应用包。AAB 是发布包，商店或配套工具会根据设备配置生成要交付的 APK。

Flutter 官方发布文档给出两条构建入口：

| 目的 | Flutter 命令 | 产物含义 |
|---|---|---|
| 构建 App Bundle | `flutter build appbundle` | 生成 `.aab` 发布包 |
| 构建拆分 APK | `flutter build apk --split-per-abi` | 按 ABI 生成多个可安装 APK |

这些命令本篇不执行。Google Play 偏好 AAB，但这不是所有 Android 分发渠道的统一规则。面向中国大陆发布时，需要逐个核对目标应用商店当时的官方包格式、签名和上架要求，不能默认 Google Play 流程等于国内渠道流程。

调试签名也不等于发布签名。Android 构建系统可以用默认调试密钥生成 debug 包；发布包需要单独配置并保护签名材料，密钥和密码不得进入 Git。

## 06 只读认识 `app/android/`

现在在 Explorer 中依次找到这些文件：

| 路径 | 当前课程中先记住什么 |
|---|---|
| `android/settings.gradle.kts` | 声明插件、插件仓库和 `:app` 模块 |
| `android/build.gradle.kts` | Android 工程级仓库与公共构建配置 |
| `android/app/build.gradle.kts` | 应用 ID、SDK 范围、构建类型和 Flutter Gradle 插件入口 |
| `android/gradle/wrapper/gradle-wrapper.properties` | 固定项目使用的 Gradle 发行版 |
| `android/app/src/main/AndroidManifest.xml` | 声明应用组件、权限和平台元数据 |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Android 原生入口 |
| `android/app/src/main/res/` | 图标、启动背景和 Android 原生资源 |

你可能还会在本机看到 `android/local.properties`。它记录本机 SDK 路径等局部信息，不应作为团队通用配置提交。课程不会要求你手工复制别人的 `local.properties` 来“修复”路径。

这一步只确认每类文件负责什么，不修改版本号，也不触发 Gradle Sync。

## 07 看懂官方验证命令的位置

完整 Android 环境通常会用以下命令检查不同层级：

| 命令 | 检查对象 |
|---|---|
| `flutter doctor` | Flutter 所见的 Android toolchain 与 Android Studio 状态 |
| `flutter doctor --android-licenses` | 阅读并接受已安装 Android SDK 的许可证 |
| `flutter emulators` | Flutter 能发现的模拟器配置 |
| `flutter devices` | Flutter 能发现的已运行模拟器或已连接设备 |
| `flutter run -d <device_id>` | 在明确设备上运行应用 |
| `flutter build apk` | 进入 APK 构建流程 |
| `flutter build appbundle` | 进入 AAB 构建流程 |

本篇不执行这些 Android 命令，也不提供伪造的成功输出。它们的意义是帮助你定位失败层级，而不是把所有问题都归为“Flutter 没装好”。

## 08 中国大陆网络环境要分清下载源

Android 首次配置可能同时访问多个来源：

- Android Studio 安装包与插件市场。
- Android SDK Platform、Build-Tools、Emulator 和 System Image。
- Gradle 发行包。
- Google Maven、Maven Central 等依赖仓库。
- Flutter SDK 构建产物与 pub 包。

Flutter 官方中国网络文档列出的镜像覆盖 Flutter SDK、Flutter 构建产物和 pub 包。它没有把 Android SDK、系统镜像、Gradle 发行包或全部 Maven 依赖声明为同一镜像的覆盖范围。

因此，设置 `PUB_HOSTED_URL` 或 `FLUTTER_STORAGE_BASE_URL` 后 Android SDK 仍下载失败，并不矛盾。应先从失败日志确认具体 URL 和组件，再使用对应维护方的官方渠道或组织批准的网络方案；不要从来源不明的下载站拼装 SDK、Gradle 或系统镜像。

## 预期结果

完成本篇后，你不需要得到 Android 运行画面或构建产物。正确结果是：

- 能画出 Android Studio、Flutter SDK、Android SDK、Gradle／AGP 与设备之间的关系。
- 能指出 AVD 是配置，Emulator 是运行程序，System Image 是虚拟系统。
- 能在 `app/android/` 中找到主要构建文件，并解释各自职责。
- 能根据失败发生的位置区分 Flutter 镜像、SDK 下载、Gradle 下载和 Maven 依赖问题。
- 不会把 Android 官方资料中的操作写成课程已经实际验证通过。

## 常见问题

### 安装 Android Studio 后，Android 环境就完整了吗

不一定。还要看 Android SDK 的平台与工具组件、JDK、许可证，以及设备或 AVD 是否齐全。Flutter 插件和 Flutter SDK 也需要分别确认。

### 只用 VS Code，可以开发 Flutter Android 吗

可以把 VS Code 作为编辑器，但底层仍需要 Android SDK、JDK、Gradle 和设备工具。更换编辑器不会消除 Android 工具链依赖。

### AVD 已经创建，为什么还没有设备

AVD 只是配置。只有 Android Emulator 使用该配置成功启动后，Flutter 和 `adb` 才可能把它识别为运行中的设备。

### 为什么不能直接升级 AGP 和 Gradle

两者与 Android Studio、JDK、SDK 以及 Flutter 模板存在兼容关系。只按更新提示追到最高版本，可能让原本可构建的工程失去兼容性。

### Flutter 镜像能解决 Android SDK 下载失败吗

不能直接这样推断。Flutter 官方镜像文档明确覆盖 Flutter SDK、构建产物和 pub 包，没有承诺覆盖 Android SDK、系统镜像、Gradle 与所有 Maven 仓库。

### APK 和 AAB 应该选哪个

取决于分发目标。APK 可以直接安装；AAB 用于交给支持 App Bundle 的分发渠道生成设备 APK。Google Play 偏好 AAB，中国大陆渠道需要逐个查看其当前官方要求。

## 完成检查

- [ ] 我能区分 Android Studio、Flutter 插件、Flutter SDK 和 Android SDK。
- [ ] 我知道 Android SDK 各组件不是一次下载得到的单一文件。
- [ ] 我能解释 AVD、Emulator 和 System Image 的关系。
- [ ] 我能说清 Gradle、AGP、JDK 和 SDK Build-Tools 在构建链中的位置。
- [ ] 我能区分 APK 与 AAB。
- [ ] 我已经只读查看 `app/android/`，没有修改或运行 Android 配置。
- [ ] 我知道本篇没有完成任何 Android 实际验证。

## 一手来源

- [Flutter 官方 Android 开发环境说明](https://docs.flutter.dev/platform-integration/android/setup) 。
- [Flutter 官方 Android Studio 与 IntelliJ 使用指南](https://docs.flutter.dev/tools/android-studio) 。
- [Android Developers：创建和管理虚拟设备](https://developer.android.com/studio/run/managing-avds) 。
- [Android Developers：Android 构建配置](https://developer.android.com/build) 。
- [Android Developers：Android Gradle Plugin 说明与兼容关系](https://developer.android.com/build/releases/about-agp) 。
- [Android Developers：构建工具与依赖关系](https://developer.android.com/build/tool-and-library-dependencies) 。
- [Flutter 官方 Android 构建与发布说明](https://docs.flutter.dev/deployment/android) 。
- [Flutter 官方中国网络环境说明](https://docs.flutter.dev/community/china) 。
