# 02｜三端支持边界：不是同一条轨道

最后核验：2026-08-26

## 本篇结论

iOS、Android 是 Flutter 官方支持的移动平台；HarmonyOS NEXT／OpenHarmony 需要 Flutter-OH 适配。正确方案是共享业务源码，但使用两条 SDK 与构建轨道。

## 学完你能做到

- 区分 Flutter 官方支持与社区平台适配。
- 理解 HarmonyOS、HarmonyOS NEXT 和 OpenHarmony 在本教程里的范围。
- 看懂本课程的双 SDK 构建策略。
- 判断“支持鸿蒙”应该如何验收。

## 01 先把“鸿蒙”说清楚

日常语境中的“鸿蒙”可能指向不同环境：

- 仍能运行 Android 应用的历史 HarmonyOS 设备。
- 不再依赖 Android 应用兼容层的 HarmonyOS NEXT。
- 开源项目 OpenHarmony。

本教程所说的鸿蒙支持，特指：

> 使用 Flutter-OH 构建面向 HarmonyOS NEXT／OpenHarmony 的应用。

如果目标设备能够直接安装 Android APK，那仍属于 Android 构建结果，不算本教程要解决的 Flutter-OH 适配。

## 02 官方 Flutter 支持到哪里

Flutter 官方支持平台页面列出了 iOS 与 Android，并给出对应系统和架构范围。OpenHarmony 不在这份官方支持列表中。

这意味着：

- iOS、Android 问题可以先查 Flutter 官方文档和 Flutter 仓库。
- OpenHarmony 问题需要继续检查 Flutter-OH 的版本、文档、Issue 和插件适配。
- 上游 Flutter 新功能不能默认认为已经进入 Flutter-OH。

## 03 两条 SDK 轨道

本教程采用下面的构建关系：

```text
共享 Git 仓库
├── lib/                  Dart 业务、状态与界面
├── test/                 共享测试
├── ios/                  iOS Runner
├── android/              Android Runner
└── ohos/                 OpenHarmony 工程

Flutter upstream
└── build iOS / Android

Flutter-OH
└── build HarmonyOS NEXT / OpenHarmony
```

共享同一个仓库，不等于让同一套 Flutter SDK 构建三个平台。Flutter-OH 官方项目也建议其他平台优先使用 Flutter 上游 SDK，以获得及时的上游修复。

## 04 版本怎么选

版本选择遵循四条规则：

1. 不使用 `master` 或开发分支作为教学基线。
2. iOS、Android 固定一个 Flutter 上游稳定版本。
3. 鸿蒙固定一个 Flutter-OH 稳定 Tag。
4. Dart 语法和依赖约束以两条轨道都能接受的范围为准。

举例：如果 Flutter 上游版本比 Flutter-OH 更新，就不能因为上游已经提供某个 API，直接在共享代码里使用它。应该先确认 Flutter-OH 对应版本是否存在该 API。

## 05 插件是最大的现实差异

纯 Dart 包不包含 iOS、Android 或 OpenHarmony 的原生实现，但仍然要核对它声明的 Dart SDK 范围，并在两条 SDK 轨道分别运行测试。只有两边测试都通过，课程才把它列为共享依赖。

插件则需要逐项确认：

- 插件是否声明 `ios`、`android`、`ohos` 实现。
- Flutter-OH 适配仓库是否有对应版本。
- 适配分支是否仍在维护。
- 示例是否真正构建过，而不是只有占位目录。
- 三端行为是否一致，是否需要功能降级。

课程不会用“pub.dev 能安装”代替“鸿蒙可用”。每个原生能力都会进入插件兼容矩阵。

## 06 中国大陆环境提示

Android 能构建，不代表依赖 Google Play 服务的功能能在大陆常见设备环境中工作。本课程选择插件和云服务时，会把下面几件事分开验证：

- Flutter 插件是否支持 Android。
- 插件是否强依赖 Google Play 服务。
- 没有 Google Play 服务时，核心功能是否可用或能够降级。
- 是否需要国内厂商 SDK，以及该 SDK 是否继续支持 iOS、Android 和鸿蒙目标。
- 服务账号、控制台、短信、支付或应用商店是否对大陆开发者提供可执行的注册路径。

因此，后续的“Android 支持”表示 Android 应用本身通过验证，不等于默认接入 Google Play；“三端支持”也不会只检查 Dart 层能否编译。

## 07 什么才算支持鸿蒙

至少满足以下条件，课程才会把功能标记成“已支持”：

- Flutter-OH 能完成 HAP 构建。
- 应用能安装并启动。
- 核心页面、数据和交互在真机运行。
- 相关原生插件已经实际验证。
- 不支持的能力具有明确降级行为。

仅通过静态分析、仅有 `ohos` 目录、或只在 README 声明兼容，都不算验证完成。

## 常见问题

### Flutter-OH 是 Google Flutter 的一个官方 target 吗

不是。它是基于 Flutter SDK 和 Engine 的 OpenHarmony 兼容扩展，由独立社区维护。

### 能否只安装 Flutter-OH，然后构建三个平台

本课程不采用这种方式。按照课程命令操作时，iOS、Android 使用上游 Flutter，鸿蒙使用 Flutter-OH；每次构建前都要核对实际生效的 SDK 路径和版本。

### 三端界面是否应该完全一致

不应该把完全一致作为目标。数据与任务流程应一致，导航、返回、弹窗、权限等行为应符合平台习惯。

## 完成检查

- [ ] 我知道 OpenHarmony 不在 Flutter 官方支持平台列表中。
- [ ] 我能解释为什么课程需要两条 SDK 轨道。
- [ ] 我不会把成功安装依赖当成插件已支持鸿蒙。
- [ ] 我知道鸿蒙能力必须通过 HAP 构建和真机流程验证。

## 一手来源

- [Flutter 支持平台](https://docs.flutter.dev/reference/supported-platforms) 。
- [CPF-Flutter](https://gitcode.com/CPF-Flutter) 。
- [Flutter-OH SDK 仓库](https://gitcode.com/CPF-Flutter/flutter_flutter) 。
- [在中国网络环境下使用 Flutter](https://docs.flutter.dev/community/china) 。
