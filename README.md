# Flutter 跨平台实战教程

这是一套以 iOS 为主平台，同时覆盖 Android 与 HarmonyOS NEXT／OpenHarmony 的中文 Flutter 教程。

教程不会把三端包装成完全等价的一键构建：iOS、Android 使用 Flutter 上游稳定版，鸿蒙使用独立维护的 Flutter-OH。课程围绕同一个实战应用，讲清楚共享代码、平台差异、插件兼容和验证边界；iOS 逐章实际验证，Android 只做官方一手来源核验和差异说明。

## 默认读者

教程默认读者位于中国大陆，使用中文操作系统和大陆常见网络环境。课程不会默认你拥有稳定的国际网络、Google Play 服务、境外手机号、境外支付方式或海外开发者账号。

遇到 Flutter 下载、依赖、地图、推送、登录、支付、统计和应用分发时，教程会优先给出中国大陆可执行路径，并明确海外方案的适用条件。镜像与第三方替代服务只采用可信来源，并标注维护方和最后核验日期。

## 当前状态

项目处于第一阶段：课程规范与入门章节建设。真实进度见 [ROADMAP.md](ROADMAP.md) 。

## 开始阅读

1. [Flutter 是什么：先看清它能共享什么](docs/chapters/01-what-is-flutter.md)
2. [三端支持边界：iOS、Android 与鸿蒙不是同一条轨道](docs/chapters/02-platform-boundaries.md)
3. [搭建 macOS 与 iOS 开发环境](docs/chapters/03-macos-ios-setup.md)
4. [运行第一个 iOS 应用](docs/chapters/04-first-ios-app.md)
5. [用 VS Code 运行、调试和热重载 Flutter 应用](docs/chapters/05-vscode-flutter-workflow.md)
6. [看懂 Android Studio、Android SDK、模拟器与构建流程差异](docs/chapters/06-android-toolchain-differences.md)
7. [认识 DevEco Studio、Flutter-OH 与大陆下载环境](docs/chapters/07-flutter-oh-environment.md)
8. [用绝对路径切换上游 Flutter 与 Flutter-OH](docs/chapters/08-dual-sdk-tracks.md)
9. [认识 Flutter 项目：共享源码、平台工程与生成文件](docs/chapters/09-flutter-project-structure.md)
10. [用 Dart 表达一条可靠的灵感数据](docs/chapters/10-dart-data-basics.md)

完整课程设计见 [课程蓝图](docs/course-blueprint.md) 。

## 贯穿项目

课程将逐步完成一个名为 `Spark` 的灵感与任务管理应用，覆盖：

- 列表、编辑、标签、搜索与筛选。
- 本地持久化与简单网络同步。
- 深色模式、动态字体与无障碍。
- 图片附件、通知和 Deep Link。
- iOS 体验精修、Android 适配和 Flutter-OH 适配。

首个可运行基线位于 [`app/`](app/) ，当前使用 Flutter 3.47.2 stable。

## 事实来源

涉及平台支持、工具链和命令时，优先使用以下一手资料：

- [Flutter 官方文档](https://docs.flutter.dev/) 。
- [Flutter 中文开发者文档](https://docs.flutter.cn/) 。
- [Apple Developer Documentation](https://developer.apple.com/documentation/) 。
- [CPF-Flutter](https://gitcode.com/CPF-Flutter) 。

每篇教程会单独列出实际使用的来源和最后核验日期。

## 许可

本项目采用 [MIT License](LICENSE) 开源。
