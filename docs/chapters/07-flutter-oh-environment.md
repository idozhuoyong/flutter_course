# 07｜认识 DevEco Studio、Flutter-OH 与大陆下载环境

最后核验：2026-09-01

## 本篇结论

Flutter-OH 不是 Flutter 官方 stable 增加的一个开关，而是 CPF-Flutter 基于特定 Flutter 上游版本维护的 OpenHarmony 适配 SDK。搭建环境时必须同时锁定 Flutter-OH tag、DevEco Studio、OpenHarmony API 和 Dart 版本，不能把第 03 课安装的上游 Flutter 直接拿来构建 HAP。

本篇基于 CPF-Flutter、Flutter 与华为官方一手资料写成。当前阻塞环境暂不安装，因此正文中的下载、环境变量、检查和构建命令均为官方流程参考，没有在本机执行，也不代表 `Spark` 已经支持 OpenHarmony。

## 学完你能做到

- 解释 Flutter 上游 SDK 与 Flutter-OH 为什么必须分成两条轨道。
- 识别 DevEco Studio、OpenHarmony SDK、ohpm、Hvigor、HDC 和 Flutter-OH 的职责。
- 按稳定 tag 而不是持续变化的开发分支选择 Flutter-OH。
- 区分 GitCode 源码、Flutter／pub 镜像、HarmonyOS 包仓库和 DevEco Studio 下载源。
- 看懂 Flutter-OH 官方环境检查与 HAP 构建命令，但不把未执行步骤写成已经通过。
- 说明当前 `Spark` 为什么还不能直接切换到 Flutter-OH。

## 本篇核验边界

2026-09-01 已完成两类核验：

- 一手来源核验：CPF-Flutter 当前稳定 tag、Release Notes、环境搭建指南、应用构建指南，以及 Flutter 官方 SDK 归档。
- 现有环境只读核验：DevEco Studio、内置与独立 SDK、Hvigor、Flutter-OH SDK 和 Flutter 插件是否存在。

本篇没有进行以下操作：

- 安装或升级 DevEco Studio、Command Line Tools、JDK 或 OpenHarmony SDK。
- 克隆完整 Flutter-OH SDK 到开发目录并执行其中的 `flutter` 命令。
- 修改 Shell 配置、环境变量、签名或 `Spark` 的 Dart 约束。
- 创建模拟器、连接真机、生成 `ohos/` 目录、构建或安装 HAP。

## 开始前检查

先读完[第 05 课](05-vscode-flutter-workflow.md)和[第 06 课](06-android-toolchain-differences.md)。你需要先理解上游 Flutter 的编辑器工作流，以及“IDE 不等于完整工具链”。

本篇不要求你跟随命令操作。先建立版本与组件关系，第 08 课再处理两条 SDK 轨道的切换规则。

## 01 先锁定一整组版本

CPF-Flutter 官方仓库建议使用 tag 获取稳定版本。课程于 2026-09-01 核对后的基线如下：

| 项目 | 课程记录的基线 | 说明 |
|---|---|---|
| Flutter-OH tag | `3.41.10-ohos-1.0.1` | Release Notes 标记为 release，发布日期为 2026-08-17 |
| Flutter 上游基线 | Flutter 3.41.9 | Flutter-OH 在该上游提交基础上适配 OpenHarmony |
| Dart | 3.11.5 | 由相同上游 Flutter 提交和 Flutter 官方发布索引确认 |
| DevEco Studio | 26.0.0 Beta2，Build 26.0.0.621 | Flutter-OH Release Notes 指定的配套版本 |
| Command Line Tools | 26.0.0 Beta2，Build 26.0.0.621 | 与该 Flutter-OH release 配套 |
| 应用目标 API | OpenHarmony API 26 | Release Notes 指定 |
| 应用最低运行 API | OpenHarmony API 17 | 不等于开发时可以只安装 API 17 |

这里有两个容易误判的点：

1. tag 名显示为 `3.41.10-ohos-1.0.1`，但适配的上游基线是 Flutter 3.41.9。CPF-Flutter 说明，显示版本多出的修订号用于避免 Flutter 版本比较解析失败。
2. Flutter-OH 本身标记为 release，不代表配套工具全部都是 Release；这一版明确要求 DevEco Studio 26.0.0 Beta2。

不要混用 `dev` 分支、旧教程中的 3.7／3.22 分支和当前 release tag。开发分支会持续变化，不适合作为课程复现基线。

## 02 看懂每个组件负责什么

完整链路不是“安装 DevEco Studio，然后使用上游 Flutter”：

```text
Flutter-OH SDK
    ├── Dart 与 Flutter Framework
    ├── OpenHarmony 适配后的 Flutter Tools
    └── OpenHarmony Engine 产物获取逻辑
              ↓
DevEco Studio 配套工具
    ├── OpenHarmony SDK
    ├── Node.js
    ├── ohpm
    ├── Hvigor
    └── HDC
              ↓
创建 ohos 工程、签名、构建 HAP、连接设备
```

| 组件 | 主要职责 | 不能代替什么 |
|---|---|---|
| DevEco Studio | 管理 HarmonyOS／OpenHarmony 工程、SDK、签名、设备和原生代码 | 不能代替 Flutter-OH SDK |
| Flutter-OH | 提供适配 OpenHarmony 的 Flutter Framework、Engine 与命令 | 不能用上游 Flutter 3.47.2 直接替换 |
| OpenHarmony SDK | 提供目标 API、编译和设备工具 | 不能只看“目录存在”，还要匹配 API 版本 |
| ohpm | 管理 OpenHarmony 工程依赖 | 不管理 Dart／Flutter 包 |
| Hvigor | 执行 OpenHarmony 工程构建任务 | 不代替 Flutter 的 Dart 编译流程 |
| HDC | 发现设备、安装 HAP 和执行设备调试命令 | 不创建 Flutter 工程 |
| pub | 获取 Dart／Flutter 包 | 不下载 DevEco Studio 或 OpenHarmony SDK |

DevEco Studio 可以打开 `ohos/` 原生模块，但 Flutter SDK 的选择仍由终端、`PATH` 或版本管理工具决定。不能因为 IDE 能打开工程，就认为当前 Shell 使用的是 Flutter-OH。

## 03 使用官方入口获取工具

当前课程只记录入口，不执行下载。

### DevEco Studio 与配套 SDK

从[华为 DevEco Studio 资源页](https://developer.huawei.com/consumer/cn/deveco-studio/resources/)或[官方历史版本页](https://developer.huawei.com/consumer/cn/deveco-studio/archive/)进入下载，不使用来源不明的打包站。下载前先回到 Flutter-OH 对应 Release Notes，确认要求的是 26.0.0 Beta2，而不是只按页面上的“最新版本”选择。

CPF-Flutter 当前环境指南说明，DevEco Studio 套件会提供 SDK、ohpm、Hvigor 和 Node.js 等工具。具体是否齐全仍要在安装后逐项检查，不能仅凭 IDE 图标判断。

### Flutter-OH SDK

稳定基线应指向 CPF-Flutter 官方仓库和明确 tag：

```bash
git clone --branch 3.41.10-ohos-1.0.1 --depth 1 \
  https://gitcode.com/CPF-Flutter/flutter_flutter.git
```

这条命令本篇未执行。无法使用 Git 时，可以在同一官方 tag 页面下载 ZIP；ZIP 不包含 Git 历史，后续不能用 `git pull` 更新。

不要继续使用旧的 `openharmony-tpc` 或 `openharmony-sig` 地址作为新课程入口。CPF-Flutter 仓库已经发布迁移公告，新依赖和文档应指向 `CPF-Flutter` 组织。

## 04 环境变量分别连接哪一层

CPF-Flutter 官方 macOS 指南使用以下变量连接 DevEco Studio、OpenHarmony 工具和 Flutter-OH。下面只展示结构，不要求现在写入 `~/.zshrc`、`~/.zprofile` 或其他 Shell 文件：

```bash
export JAVA_HOME=<JDK 17 path>
export PATH=$JAVA_HOME/bin:$PATH

export TOOL_HOME=/Applications/DevEco-Studio.app/Contents
export DEVECO_SDK_HOME=$TOOL_HOME/sdk
export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH
export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH
export PATH=$TOOL_HOME/tools/node/bin:$PATH
export HDC_HOME=$TOOL_HOME/sdk/default/openharmony/toolchains

export PUB_CACHE=<pub cache path>
export PATH=<flutter-oh path>/bin:$PATH
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export FLUTTER_GIT_URL=https://gitcode.com/CPF-Flutter/flutter_flutter.git
```

这些变量解决的问题不同：

| 变量 | 指向或影响什么 |
|---|---|
| `JAVA_HOME` | OpenHarmony 构建使用的 JDK |
| `TOOL_HOME` | DevEco Studio 安装目录 |
| `DEVECO_SDK_HOME` | DevEco Studio 配套 SDK |
| `HDC_HOME` | 可选的 HDC 工具目录 |
| `PATH=<flutter-oh>/bin` | 当前 Shell 使用哪套 Flutter SDK |
| `PUB_CACHE` | Dart／Flutter 包缓存位置 |
| `PUB_HOSTED_URL` | pub 包下载源 |
| `FLUTTER_STORAGE_BASE_URL` | Flutter 构建产物下载源 |
| `FLUTTER_GIT_URL` | Flutter-OH 创建工程时使用的框架仓库地址 |

最危险的错误是把上游 Flutter 与 Flutter-OH 的 `bin` 同时塞进 `PATH`，然后依赖顺序碰运气。第 08 课会单独设计显式切换方案，本篇不修改全局 `PATH`。

## 05 官方环境检查链路

完成实际安装后，CPF-Flutter 指南要求依次检查：

```bash
java -version
hdc -v
ohpm -v
hvigor -v
flutter doctor -v
```

每个命令对应一个独立层级：

- `java -version`：确认 JDK。
- `hdc -v`：确认设备通信工具。
- `ohpm -v`：确认 OpenHarmony 包管理工具。
- `hvigor -v`：确认 OpenHarmony 构建工具。
- `flutter doctor -v`：确认当前生效的是 Flutter-OH，并检查 OpenHarmony toolchain。

本机尚未安装当前配套 Flutter-OH，因此本篇不提供这些命令的预期版本号或伪造输出。未来实际验证时，必须保留完整 `flutter doctor -v` 结果，并核对命令来自哪一个 Flutter SDK 路径。

## 06 HAP 构建处在什么位置

Flutter-OH 官方指南提供以下创建与构建入口：

```bash
flutter create --platforms ohos <project_name>
flutter build hap --debug
flutter build hap --release
```

签名完成后，官方指南给出的 HAP 产物目录是：

```text
<project_name>/build/ohos/hap/
```

这些命令本篇没有执行。当前 `Spark` 也没有 `ohos/` 目录，不能把官方文档里的示例产物路径写成课程已经生成的文件。

真机运行还涉及签名、开发者账号、设备授权和 HDC 连接。模拟器则需要受支持的主机架构；CPF-Flutter 当前指南还要求使用完成实名认证的华为账号。课程不默认读者已经具备这些账号条件。

## 07 中国大陆网络问题要按来源拆开

Flutter-OH 首次准备可能同时访问多套服务：

| 下载内容 | 默认或课程采用的入口 | 出错时先检查什么 |
|---|---|---|
| DevEco Studio | 华为开发者联盟 | 账号区域、登录状态、下载页面和文件完整性 |
| Flutter-OH 源码 | GitCode 的 CPF-Flutter 仓库 | 仓库地址、tag、GitCode 连接 |
| Dart／Flutter 包 | `pub.flutter-io.cn` | `PUB_HOSTED_URL` 与包是否真实存在 |
| Flutter-OH 构建产物 | `storage.flutter-io.cn` 或 CPF-Flutter 文档指定源 | `FLUTTER_STORAGE_BASE_URL` 与 SDK 缓存是否属于同一版本 |
| OpenHarmony 包 | HarmonyOS ohpm 仓库 | ohpm 配置、包名与版本 |
| DevEco SDK／模拟器镜像 | DevEco Studio 的 SDK／Device Manager | 华为账号、目标 API 和工具版本 |

`PUB_HOSTED_URL` 只能改变 pub 包来源，不能解决 DevEco Studio 登录、SDK 镜像或 GitCode 克隆问题。反过来，GitCode 能访问也不代表 Flutter Engine 产物和 ohpm 包都能下载。

不要把所有失败统一归因于“网络不好”，也不要默认关闭 TLS 校验。先记录失败命令、实际 URL、HTTP 状态或工具错误，再处理对应下载层。

## 08 当前课程环境为什么仍然阻塞

只读检查得到的本机状态如下：

| 项目 | 本机现有状态 | 与课程基线的关系 |
|---|---|---|
| DevEco Studio | 6.0.1.251 | 不等于 Release Notes 要求的 26.0.0 Beta2 |
| DevEco 内置 HarmonyOS SDK | 6.0.1.112，API 21 | 低于课程记录的目标 API 26 |
| 独立 OpenHarmony SDK | 5.0.1.111，API 13 | 不是当前 Flutter-OH release 的目标 SDK |
| Hvigor | 6.21.1 | 只确认已存在，未用当前 Flutter-OH 构建验证 |
| Flutter-OH SDK | 未发现 | 无法执行 Flutter-OH doctor、创建或构建 |
| DevEco Flutter 插件 | 未发现 | 不影响本篇资料核验，但不能声称 IDE 已具备 Flutter 集成 |

此外，当前 `Spark` 的 `pubspec.yaml` 使用：

```yaml
environment:
  sdk: ^3.13.2
```

而本篇锁定的 Flutter-OH 基线配套 Dart 3.11.5。现有约束不接受 Dart 3.11.5，因此不能直接复用当前工程。课程不会为了消除版本错误就盲目下调约束；必须等 Flutter-OH 环境可用后，在两套 SDK 上共同验证依赖、静态分析和测试。

## 预期结果

本篇完成后，不应出现 HAP、模拟器截图或“鸿蒙运行成功”的结论。正确结果是：

- 能准确说出当前记录的 Flutter-OH tag 与配套 DevEco／API 基线。
- 知道上游 Flutter 3.47.2 和 Flutter-OH 3.41.9 不能共用同一个全局 SDK 路径。
- 能区分 GitCode、pub 镜像、Flutter 构建产物、ohpm 和 DevEco SDK 下载源。
- 能解释官方环境检查与 HAP 构建命令分别验证什么。
- 明确当前 `Spark` 仍受 Dart 版本和未安装环境阻塞。

## 常见问题

### Flutter 3.47.2 能直接构建 OpenHarmony 吗

不能按本课程资料这样判断。Flutter 官方支持列表不包含 OpenHarmony；本课程使用 CPF-Flutter 的独立适配 SDK，当前稳定基线基于上游 Flutter 3.41.9。

### 为什么不用 Flutter-OH 的 `dev` 分支

`dev` 会持续更新，今天核对的提交以后可能变化。教程需要可复现版本，因此选择带 Release Notes 的稳定 tag。

### 安装 DevEco Studio 后就有 Flutter-OH 吗

没有。DevEco Studio 提供 OpenHarmony 原生开发工具链，Flutter-OH SDK 仍需从 CPF-Flutter 官方仓库单独获取。

### 为什么不直接使用本机 DevEco Studio 6.0.1

因为当前 Flutter-OH Release Notes 指定 DevEco Studio 26.0.0 Beta2 和 API 26。本机版本可以证明 DevEco Studio 已存在，但不能证明与这一 Flutter-OH tag 兼容。

### Flutter 中国镜像能覆盖全部鸿蒙下载吗

不能。Flutter／pub 镜像、GitCode、DevEco SDK、模拟器镜像和 ohpm 是不同来源，需要分别诊断。

### 能否现在把 `Spark` 的 Dart 约束改成 3.11.5

不能只改一行就宣称兼容。下调约束可能影响语言特性、依赖解析和上游 Flutter 轨道，必须在 Flutter-OH 与上游 Flutter 两边完成测试后再决定。

## 完成检查

- [ ] 我知道 Flutter-OH 不是 Flutter 官方支持的 OpenHarmony target。
- [ ] 我能说出当前稳定 tag、上游 Flutter、Dart、DevEco Studio 和目标 API 的配套关系。
- [ ] 我能解释 DevEco Studio、Flutter-OH、ohpm、Hvigor 和 HDC 的职责。
- [ ] 我不会把上游 Flutter 与 Flutter-OH 的 `bin` 同时加入 `PATH` 后依赖顺序切换。
- [ ] 我能区分 Flutter、GitCode、ohpm 和 DevEco Studio 的下载问题。
- [ ] 我知道本篇命令没有在本机执行，`Spark` 仍未完成 OpenHarmony 构建验证。

## 一手来源

- [CPF-Flutter：Flutter-OH SDK 与 Engine 官方仓库](https://gitcode.com/CPF-Flutter/flutter_flutter) 。
- [CPF-Flutter：3.41.10-ohos-1.0.1 稳定 tag](https://gitcode.com/CPF-Flutter/flutter_flutter/tree/3.41.10-ohos-1.0.1) 。
- [CPF-Flutter：3.41.9-ohos-1.0.1 Release Notes](https://gitcode.com/CPF-Flutter/flutter_flutter/blob/3.41.10-ohos-1.0.1/release-notes/Flutter%203.41.9-ohos%201.0.1%20ReleaseNote.md) 。
- [CPF-Flutter：Flutter-OH 环境搭建指导](https://gitcode.com/CPF-Flutter/flutter_samples/blob/master/docs/ohos/getting-started/flutter-oh-env-setup.md) 。
- [CPF-Flutter：Flutter-OH 应用构建指导](https://gitcode.com/CPF-Flutter/flutter_samples/blob/master/docs/ohos/app-development/flutter-oh-app-build-guide.md) 。
- [Flutter 官方 SDK 归档](https://docs.flutter.dev/install/archive) 。
- [Flutter 官方支持平台列表](https://docs.flutter.dev/reference/supported-platforms) 。
- [华为 DevEco Studio 资源页](https://developer.huawei.com/consumer/cn/deveco-studio/resources/) 。
- [华为 HarmonyOS API 26 平台变更说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-releases/changelogs-600) 。
