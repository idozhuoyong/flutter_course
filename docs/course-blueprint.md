# 课程蓝图

最后核验：2026-08-25

## 课程目标

读者完成课程后，应能独立开发一个具有 iOS 原生体验的 Flutter 应用，并从同一份核心业务代码构建 Android 与 HarmonyOS NEXT／OpenHarmony 版本。

这里的“支持三端”有明确验收标准：

- iOS：每章运行，最终完成 Archive。
- Android：每个阶段验证核心流程，最终完成 APK／AAB 构建。
- 鸿蒙：使用 Flutter-OH 完成 HAP 构建与核心流程真机验证。
- 共享层：Dart 业务逻辑只维护一份，并在两条 SDK 轨道上通过测试。

## 课程结构

### 第一部分：先把应用跑起来

1. Flutter 是什么：一份代码能共享什么，不能共享什么
2. 三端支持现状：iOS、Android 与 Flutter-OH 的真实边界
3. Mac 开发环境：Flutter、Xcode、Simulator 和原生依赖工具
4. 第一个 iOS 应用：运行、热重载、日志与调试

### 第二部分：补齐开发环境

5. VS Code／Android Studio 的 Flutter 开发配置
6. Android SDK、模拟器与第一次 Android 构建
7. DevEco Studio 与 Flutter-OH 环境
8. 两条 SDK 轨道：上游 Flutter 与 Flutter-OH 如何切换
9. 认识 Flutter 项目：`lib`、`ios`、`android`、`ohos` 和 `pubspec.yaml`

### 第三部分：只学够用的 Dart

10. 变量、类型、空安全与不可变数据
11. 函数、类、构造函数和命名参数
12. 集合、模式匹配与数据转换
13. `Future`、`async`、`await` 与异步错误
14. `Stream`：什么时候需要，什么时候不需要
15. 用测试验证 Dart 业务逻辑

### 第四部分：理解 Flutter UI

16. Widget、Element、RenderObject：建立正确心智模型
17. 布局约束：为什么会溢出、为什么尺寸不听话
18. 列表、滚动、懒加载与 Key
19. iOS 风格页面：`CupertinoApp`、导航栏和 Tab
20. 表单、焦点、键盘和输入校验
21. 动画、转场与 Hero
22. 深色模式、动态字体、无障碍和本地化

### 第五部分：从页面拼装进入应用开发

23. 状态到底是什么：局部状态与应用状态
24. 状态管理选型：先理解问题，再选择工具
25. 路由、页面参数、返回结果和 Deep Link
26. 数据模型、Repository 与业务层
27. 本地持久化和数据迁移边界
28. 网络请求、序列化、超时和错误处理
29. 加载、空数据、失败与重试状态

### 第六部分：三端适配专题

30. 平台自适应架构：共享内容，替换外壳和交互
31. iOS 体验精修：返回手势、安全区、Tab、弹窗和触觉
32. Android 适配：系统返回、Material 行为和权限
33. 鸿蒙适配：`ohos` 工程、构建流程和 ArkTS 桥接
34. 插件兼容矩阵：纯 Dart、官方插件、社区插件和自建适配
35. Platform Channel：Swift、Kotlin、ArkTS 三端最小实现

### 第七部分：质量与工程化

36. 单元测试、Widget 测试和关键流程测试
37. 性能分析：构建、重绘、列表和图片
38. 三端构建、签名、发布前检查与故障排查

## 贯穿项目：Spark

`Spark` 是一个离线优先的灵感与任务管理应用。它提供足够完整的真实场景，又不会让后端建设抢走 Flutter 教学重点。

功能按课程推进：

1. 静态列表和详情页面。
2. 新建、编辑、删除与完成状态。
3. 标签、搜索和筛选。
4. 本地持久化。
5. 网络同步与错误恢复。
6. 图片附件、本地通知和 Deep Link。
7. iOS 体验精修及 Android、鸿蒙适配。

## 双 SDK 策略

```text
Track A：Flutter upstream
Targets：iOS + Android

Track B：Flutter-OH
Target：HarmonyOS NEXT / OpenHarmony
```

Flutter 官方支持列表包含 iOS 与 Android，不包含 OpenHarmony。Flutter-OH 由 CPF-Flutter 维护，并按独立节奏适配上游版本。因此，课程使用共享源码和两套工具链，而不是假设一套 SDK 同时负责三端。

依赖按三级管理：

- A 级：纯 Dart 包，优先使用。
- B 级：已经验证 iOS、Android、OpenHarmony 的插件。
- C 级：只支持部分平台，需要能力降级或自行适配。

## 单篇模板

每篇正文固定包含：

1. 本篇结论。
2. 学习目标。
3. 问题场景与概念解释。
4. 最小可运行步骤。
5. 预期结果。
6. 三端差异。
7. 常见问题。
8. 完成检查。
9. 一手来源和核验日期。

## 主要来源

- [Flutter 支持平台](https://docs.flutter.dev/reference/supported-platforms) 。
- [Flutter 自适应与响应式设计](https://docs.flutter.dev/ui/adaptive-responsive) 。
- [Flutter 平台自动适配](https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations) 。
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines) 。
- [CPF-Flutter](https://gitcode.com/CPF-Flutter) 。
- [参考课程组织方式](https://github.com/stormzhang/ai-coding-guide) 。
