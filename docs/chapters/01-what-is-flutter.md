# 01｜Flutter 是什么：先看清它能共享什么

最后核验：2026-08-26

## 本篇结论

Flutter 的核心价值不是“所有平台完全写一次”，而是让界面、业务逻辑和数据层尽量共享，同时为平台能力保留清晰的适配出口。

本课程会先把 iOS 应用做好，再验证 Android，最后通过 Flutter-OH 接入 HarmonyOS NEXT／OpenHarmony。

## 学完你能做到

- 说清 Flutter、Dart、Flutter Engine 分别负责什么。
- 判断一段代码更可能属于共享层还是平台层。
- 理解为什么“能运行”不等于“像这个平台的应用”。
- 知道课程为什么选择 iOS 作为主讲平台。

## 中国大陆环境提示

人工批注：去除环境特别提示
人工批注结束

本教程默认你在中国大陆学习和开发。后续章节不会假设你已经具备稳定的国际网络、Google Play 服务、境外手机号或海外支付方式。

这会影响的不只是 Flutter SDK 下载，还包括：

- Dart 和原生依赖能否稳定获取。
- 地图、推送、登录、支付和统计服务能否在大陆设备正常使用。
- Android 应用是否依赖 Google Play 服务。
- iOS、Android、鸿蒙分别通过什么渠道测试和分发。

课程会优先给出大陆可执行路径，再说明海外环境差异。具体服务仍以官方文档、维护状态和实际验证为准，不会因为“国内可用”就默认选择某个厂商。

## 01 Flutter 解决的是什么问题

假设你要做一个任务管理应用。使用原生技术时，通常需要分别维护：

- iOS 的 Swift／Objective-C 代码。
- Android 的 Kotlin／Java 代码。
- HarmonyOS NEXT 的 ArkTS 代码。

三个应用都要实现列表、编辑、搜索、数据保存和网络同步。真正重复的并不是语法，而是同一套产品逻辑被实现了三次。

Flutter 的做法是：用 Dart 描述界面和业务逻辑，由 Flutter 框架和引擎把它运行在不同平台上。

```text
Dart 业务与界面
       ↓
Flutter Framework
       ↓
Flutter Engine
       ↓
iOS / Android / 适配后的 OpenHarmony
```

这让大量代码可以共享，但不会消灭平台差异。

## 02 哪些代码适合共享

通常适合共享的内容包括：

- 数据模型与校验规则。
- 排序、搜索和筛选逻辑。
- 网络请求与错误处理。
- 页面主体和大部分自定义组件。
- 状态管理。
- 单元测试。

例如，下面的标题校验不关心应用运行在哪个平台：

```dart
String? validateTitle(String value) {
  final title = value.trim();

  if (title.isEmpty) {
    return '标题不能为空';
  }

  if (title.length > 60) {
    return '标题不能超过 60 个字符';
  }

  return null;
}
```

这种代码应当只维护一份。

## 03 哪些差异不能假装不存在

以下内容经常需要平台适配：

- 页面返回手势和系统返回键。
- Tab、导航栏、弹窗和菜单样式。
- 权限申请与系统设置入口。
- 推送、通知、相机、相册和分享。
- 应用签名、构建产物和商店审核。
- 原生 SDK 或只支持单个平台的插件。

Flutter 会自动处理一部分平台行为。例如页面转场、滚动物理和文字编辑会根据 iOS、Android 做不同适配。但涉及信息架构和组件选择时，仍然需要开发者决定。

因此，本课程不会追求三个平台逐像素相同，而是追求：

> 业务一致，体验符合平台习惯，差异集中且可维护。

## 04 为什么以 iOS 为主平台

iOS 作为主线有三个实际好处：

1. 工具链边界清晰。Flutter、Xcode、Simulator 和签名流程可以串成完整闭环。
2. 平台体验要求具体。返回手势、安全区、动态字体和导航层级会迫使我们正确处理细节。
3. 在 macOS 上可以继续配置 Android 和 DevEco Studio，覆盖三端开发环境。

主平台不等于独占平台。课程里的共享业务代码从一开始就不能依赖 iOS，平台差异也不会散落在各个页面里。

## 05 课程会如何推进

我们将共同完成 `Spark`：一个灵感与任务管理应用。

第一阶段只做 iOS：

- 跑通工具链。
- 建立页面和导航。
- 做出可交互的本地应用。

第二阶段再扩展：

- Android 的系统返回、Material 行为和权限。
- Flutter-OH 的工程结构、插件兼容和 HAP 构建。

这样做不是把跨平台拖到最后，而是先用一个稳定主线解释 Flutter，再在读者已经理解应用结构后处理真实差异。

## 常见问题

### Flutter 会把界面转换成 UIKit 或 Android View 吗

不能把 Flutter 简单理解为“生成一套原生控件”。Flutter 通常由自己的框架和渲染引擎绘制界面，同时通过平台嵌入层接收输入、接入系统能力。需要原生视图时，也可以使用 Platform View 等机制进行集成。

### 会 Flutter 后是否完全不需要 Swift、Kotlin、ArkTS

普通页面和业务逻辑通常不需要。但接入尚无插件覆盖的原生能力、调试平台构建问题或编写插件时，至少要能阅读对应平台代码。

### 为什么不从三个 Hello World 同时开始

三个工具链同时出现会掩盖 Flutter 本身的学习主线。课程先用 iOS 建立反馈闭环，再在明确的阶段门引入 Android 和鸿蒙。

## 完成检查

- [ ] 我能解释 Flutter 共享的是代码和产品逻辑，而不是消灭平台差异。
- [ ] 我能举出两个适合共享的模块和两个需要平台适配的能力。
- [ ] 我知道 iOS 是课程主线，但最终验收包含 Android 和鸿蒙。

## 一手来源

- [Flutter 官方主页](https://flutter.dev/) 。
- [Flutter 平台集成概览](https://docs.flutter.dev/platform-integration) 。
- [Flutter 平台自动适配](https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations) 。
- [在中国网络环境下使用 Flutter](https://docs.flutter.dev/community/china) 。
