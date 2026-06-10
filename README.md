# toto_sweep_light

一个用于实现高品质“文字扫光”动画效果的 Flutter 插件。支持逐字放大、字间距拉伸、颜色渐变等多维度的扫光动效，并提供高度可定制的动画控制器。

## 特性

* 🌟 **多重变换**：支持大小缩放（Scale）、字间距扩展（Letter Spacing）和颜色渐变（Color Lerp）的三维立体扫光动效。
* ⚡ **高流畅度**：内部采用 `RepaintBoundary` 进行视图重绘隔离，确保每个字符独立动画时的渲染性能。
* 🎛️ **外部控制器**：通过 `TotoSweepLightController` 支持外部启动、暂停、继续、停止和重置动画。
* 🛠️ **高度可定制**：
  * 支持自定义扫光颜色、字符时长、扫光间隔。
  * 可配置三阶段动画时长占比（开始变换、维持状态、恢复初始）。
  * 灵活的循环播放机制（无限循环或指定循环次数）。

## 效果预览

文字扫光效果会从左到右依次对文本中的字符进行放大、间距扩大和色彩变化：

| 效果演示 |
| :---: |
| *(运行 Example 项目以体验交互式微调)* |

## 快速开始

在您的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  toto_sweep_light: ^0.0.5
```

导入包：

```dart
import 'package:toto_sweep_light/toto_sweep_light.dart';
```

### 基础用法

```dart
TotoSweepLight(
  text: 'HELLO WORLD',
  textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
  sweepColor: Colors.amber,
  autoStart: true,
)
```

### 循环播放

```dart
TotoSweepLight(
  text: 'LOADING...',
  loop: true,
  loopCount: 3, // 播放 3 次后停止，如果不设置或设为 null 则无限循环
  sweepColor: Colors.tealAccent,
  autoStart: true,
)
```

### 使用控制器进行手动控制

```dart
// 1. 初始化控制器
final controller = TotoSweepLightController();

// 2. 绑定组件
TotoSweepLight(
  text: 'SWEEPING EFFECT',
  controller: controller,
)

// 3. 在需要的地方控制动画
controller.start();  // 启动
controller.pause();  // 暂停
controller.resume(); // 继续
controller.stop();   // 停止
controller.reset();  // 重置
```

## 属性说明

| 参数 | 类型 | 默认值 | 说明 |
| :--- | :--- | :--- | :--- |
| **text** | `String` | *必填* | 要展示的文本内容。 |
| **textStyle** | `TextStyle?` | `null` | 文本的基础样式。若为 `null`，则使用默认的文本样式。 |
| **scaleRatio** | `double` | `1.2` | 扫光时字符放大的倍率。 |
| **letterSpacingRatio** | `double` | `1.2` | 扫光时字间距的扩展倍率（相对于初始字间距）。 |
| **sweepColor** | `Color` | `Colors.amber` | 扫光时的目标变换颜色。 |
| **characterDuration** | `Duration` | `Duration(milliseconds: 700)` | 单个字符从开始变换到恢复初始的总时长。 |
| **sweepInterval** | `Duration` | `Duration(milliseconds: 80)` | 相邻字符开始变换的时间间隔。越小则扫光速度越快。 |
| **durationRatio** | `List<int>` | `[1, 1, 1]` | 动画三阶段的时长占比：`[开始变换, 维持状态, 恢复初始]`。 |
| **loop** | `bool` | `false` | 是否开启循环播放。 |
| **loopCount** | `int?` | `null` | 循环播放的次数限制。为 `null` 且 `loop` 为 `true` 时代表无限循环。 |
| **controller** | `TotoSweepLightController?` | `null` | 动画的外部控制器。 |
| **autoStart** | `bool` | `false` | 初始化时是否自动开始播放动画。 |
| **onStatusChanged** | `TotoSweepLightStatusCallback?` | `null` | 动画状态变化时的回调函数。可获取状态、进度和已完成轮次。 |

## 动画状态枚举 (`TotoSweepLightStatus`)

* `idle`：闲置状态，动画未开始或已重置。
* `running`：动画正在播放。
* `paused`：动画已暂停。
* `completed`：动画播放完成（当不循环或达到最大循环次数时触发）。
