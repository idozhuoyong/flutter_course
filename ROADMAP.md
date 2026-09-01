# Roadmap

最后更新：2026-08-31

## 当前阶段

第一阶段：建立课程规范、目录骨架与 iOS 入门闭环。

## 已完成

- 完成第 06 课：基于 Flutter 与 Android 官方一手资料说明 Android Studio、Android SDK、AVD、Emulator、Gradle／AGP、APK／AAB 及中国大陆下载源差异；未执行 Android 安装、运行、构建或截图验证。
- 完成第 05 课：基于现有 VS Code、Flutter 和 iOS Simulator 环境讲清工程识别、运行、断点调试、热重载与输出定位；Android 仅保留官方依据支持的差异说明，未做运行或构建验证。
- 将 Android 验证边界统一为“官方一手来源核验与差异说明”，不执行 Android 运行、构建或截图验证，也不宣称 APK／AAB 已通过。
- 将 Flutter 上游教学基线固定为 3.47.2，并在 `app/` 创建正式 `Spark` 工程；iOS 运行、热重载、静态分析、测试和 Simulator 构建均已通过。
- 补齐第 03、04 课所需的终端输出图和 iOS Simulator 截图；第 01、02 课为概念与平台边界说明，不添加无关运行截图。
- 根据人工批注完善前 4 课：移除独立的环境提示专节，将网络前提放回具体命令，区分 VS Code 的 GitHub 克隆与官方压缩包下载，并改用 Simulator 可见标题验证首次热重载。
- 建立“未验证内容不进入教程正文”的发布红线，并清理第 02 课的待确认版本占位表。
- 将中国大陆学习者确定为默认受众，并把网络、账号、服务可用性与国内分发纳入课程规范。
- 确定项目采用 MIT License，并补充标准许可文件。
- 补齐 `.gitignore`、`.gitattributes` 和空目录占位文件，建立首个版本控制基线。
- 建立项目级内容、代码和验证规范。
- 确定课程定位：iOS 主讲并逐章验证，Android 只说明差异，鸿蒙使用 Flutter-OH 独立验证。
- 完成 38 篇课程蓝图和贯穿项目定义。
- 完成前 4 篇入门教程初稿。

## 进行中

- 暂无。

## 待办

### 第一阶段：iOS 最小闭环

- 编写第 7～9 篇：Flutter-OH、双 SDK 和项目结构。
- 编写第 10～15 篇：够用的 Dart。
- 编写第 16～22 篇：Flutter UI 与 iOS 体验。

### 第二阶段：真实业务应用

- 编写第 23～29 篇：状态、路由、数据、本地存储与网络。
- 完成 `Spark` 的 iOS 功能闭环和测试。

### 第三阶段：Android 差异与鸿蒙适配

- 编写第 30～35 篇：三端适配、插件矩阵与 Platform Channel。
- 基于 Flutter、Android 与插件维护方的一手资料完成 Android 差异说明，不执行 APK／AAB 构建。
- 完成 HarmonyOS HAP 构建和真机验证。

### 第四阶段：工程化与交付

- 编写第 36～38 篇：测试、性能与发布前检查。
- 补齐最佳实践、反模式、FAQ、术语表和版本变更记录。

## 阻塞

- iOS、Android 的 Flutter 上游版本已固定为 3.47.2；Flutter-OH 版本与共享 Dart 约束仍需根据兼容矩阵单独锁定。
- 鸿蒙插件清单尚未逐项验证，相关能力只能标记为待确认。

## 最近验证

- 2026-08-31：核对 Flutter 官方 Android 环境、Android Studio、Android 构建发布与中国网络文档，以及 Android Developers 的 AVD、构建系统、AGP 兼容和工具依赖文档；只读检查 `app/android/` 目录结构，未执行任何 Android 环境或构建命令。
- 2026-08-30：确认现有 Visual Studio Code 1.133.0 arm64、Flutter 扩展 3.140.0 和 Dart 扩展 3.140.0；VS Code 图形操作入口逐项对照官方文档，本次执行环境无法控制图形界面，未将 F5、断点命中和 Debug Toolbar 点击记为本机自动化验证。
- 2026-08-30：在现有 Flutter 3.47.2、Dart 3.13.2、macOS 26.5.2 和 iOS Simulator 环境重新运行 `flutter analyze`、`flutter test` 与 `flutter build ios --simulator`，全部通过；未执行任何 Android 验证命令。
- 2026-08-29：将项目外 Flutter stable SDK 从 3.47.0 升级到 3.47.2，确认 Dart 3.13.2、Xcode 26.6、macOS 26.5.2 和 iOS 26.5 iPhone 17 Pro Simulator 生效。
- 2026-08-29：首次通过 `storage.googleapis.com` 下载 Flutter 3.47.2 iOS 构建产物时连接中断；改用 Flutter 官方中国网络文档列出的 `storage.flutter-io.cn` 后下载、构建和运行成功。
- 2026-08-29：在正式 `app/` 工程中完成默认页面运行、标题改为 `Spark` 后热重载、`flutter analyze`、`flutter test`、`flutter build ios --simulator` 和 `flutter doctor -v` 验证。
- 2026-08-28：使用 Flutter 3.47.0 在临时工程中复现第 04 课，将 `Flutter Demo Home Page` 改为 `Spark`；`flutter analyze`、`flutter test` 和 `flutter build ios --simulator` 均通过。
- 2026-08-28：核对 Flutter 官方 macOS 版本清单，确认当前 stable 为 Flutter 3.47.2、Dart 3.13.2，并验证 Apple Silicon 官方 ZIP 地址返回 `HTTP 200`。
- 2026-08-28：核对 Flutter 官方 VS Code 安装流程、中国网络镜像变量及本机 3.47.0 项目模板，确认 `Clone Flutter`、镜像配置、默认可见标题和 Widget 测试预期。
- 2026-08-26：使用 Flutter 3.47.0、Dart 3.13.0、Xcode 26.6 和 iOS 26.5 Simulator 实际验证第 04 课；项目创建、静态分析、测试、Simulator 构建、运行和热重载均通过。
- 2026-08-26：审计现有教程的推测性内容，删除未锁定 SDK 配对表，明确源码、命令和实际运行三层验证门槛。
- 2026-08-26：统一 README、课程蓝图和现有章节的中国大陆默认环境，补充 GMS、国内服务与分发边界。
- 2026-08-26：补充第 03 课的 Flutter 官方下载入口、VS Code 安装路径和中国大陆网络说明，并按当前官方文档将 macOS 手动 PATH 配置更新为 `~/.zprofile`。
- 2026-08-25：加入标准 MIT License 文本，并确认 README 许可链接有效。
- 2026-08-25：检查 Git 忽略规则、换行符规则和待提交文件范围，未发现密钥、环境文件或构建产物。
- 2026-08-25：核对 Flutter 官方支持平台页面，确认 iOS、Android 为官方支持移动平台，OpenHarmony 不在官方支持列表。
- 2026-08-25：核对 CPF-Flutter 主页，确认 Flutter-OH 使用独立适配版本和发布节奏。
- 2026-08-25：核对 Flutter iOS 安装指南和 CLI 参考，确认本教程使用的环境检查与首个应用命令。
- 2026-08-25：检查前 4 篇的必备章节、内部链接和文件路径，未发现缺失或断链。
