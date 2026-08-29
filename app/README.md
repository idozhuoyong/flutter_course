# Spark

`Spark` 是本教程的贯穿应用，后续章节会在这个工程中逐步实现灵感与任务管理功能。

## 当前基线

- Flutter 3.47.2 stable。
- Dart 3.13.2。
- 已生成 iOS 与 Android 平台工程。
- iOS 26.5 Simulator 已通过运行、热重载、静态分析、测试和构建验证。

## 验证命令

```bash
flutter analyze
flutter test
flutter build ios --simulator
flutter run -d <device-id>
```

当前只保留 Flutter 默认计数器页面，并将应用标题改为 `Spark`。不要在教程对应章节之前提前加入业务功能或第三方依赖。
