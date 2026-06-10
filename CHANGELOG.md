## 0.0.4

* 修复 example 示例应用在大、小屏设备上的 Right overflow 布局溢出问题。
* 重构控制按钮布局为 Wrap，并优化文案长度。
* 修改 demo 的包名 (Bundle Identifier & Application ID) 及应用名。

## 0.0.3

* 破坏性改动 (Breaking Change)：将核心类名从 `TextSweepLight` 重命名为 `TotoSweepLight`。
* 将配套的控制器、状态枚举及状态回调重命名为 `TotoSweepLightController`、`TotoSweepLightStatus` 和 `TotoSweepLightStatusCallback`。

## 0.0.2

* 修复文件打包结构。
* 完善 example 演示子项目及说明文档。

## 0.0.1

* 初始版本发布。
* 提供 `TextSweepLight` 扫光文本组件，支持缩放、字间距拉伸和颜色过渡。
* 提供 `TextSweepLightController` 控制器，支持动画控制（start, pause, resume, stop, reset）。
* 支持自定义三阶段时长比例、单字符时长、扫光间隔及循环控制。
