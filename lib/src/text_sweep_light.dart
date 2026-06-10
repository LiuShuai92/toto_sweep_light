import 'package:flutter/material.dart';

/// 文字扫光动画的状态枚举
enum TotoSweepLightStatus {
  /// 闲置状态，动画未开始或已重置
  idle,

  /// 动画正在进行中
  running,

  /// 动画已暂停
  paused,

  /// 动画已完成
  completed,
}

/// 文字扫光动画的状态回调
/// - [status]：当前动画状态
/// - [progress]：当前轮次的动画进度，范围 [0.0, 1.0]
/// - [completedLoops]：已完成的循环轮次数
typedef TotoSweepLightStatusCallback = void Function(
  TotoSweepLightStatus status,
  double progress,
  int completedLoops,
);

/// 文字扫光控制器
///
/// 用于外部控制扫光动画的启动、停止和重置。
/// 使用方式：
/// ```dart
/// final controller = TotoSweepLightController();
///
/// TotoSweepLight(
///   text: 'HELLO WORLD',
///   controller: controller,
/// );
///
/// // 启动动画
/// controller.start();
///
/// // 停止动画
/// controller.stop();
///
/// // 重置到初始状态
/// controller.reset();
/// ```
class TotoSweepLightController {
  _TotoSweepLightState? _state;

  /// 当前动画状态
  TotoSweepLightStatus get status =>
      _state?._status ?? TotoSweepLightStatus.idle;

  /// 当前动画进度，范围 [0.0, 1.0]
  double get progress => _state?._progress ?? 0.0;

  /// 已完成的循环轮次数
  int get completedLoops => _state?._completedLoops ?? 0;

  /// 启动扫光动画（从头开始）
  void start() => _state?._start();

  /// 暂停扫光动画（保持当前位置）
  void pause() => _state?._pause();

  /// 从暂停位置继续扫光动画
  void resume() => _state?._resume();

  /// 停止扫光动画并回到闲置状态
  void stop() => _state?._stop();

  /// 重置扫光动画到初始闲置状态
  void reset() => _state?._reset();

  void _attach(_TotoSweepLightState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }
}

/// 文字扫光效果组件
///
/// 从左到右逐个文字产生放大、字间距扩大、颜色变换的扫光动画。
/// 先扫到的文字先开始变换，每个文字的变换总时长相同。
///
/// 变换过程分为三个阶段（时长占比可自定义）：
/// 1. **开始变换**：文字逐渐放大、字间距扩大、颜色变为扫光色
/// 2. **维持时长**：保持变换后的状态
/// 3. **恢复初始**：恢复到初始的大小、间距 and 颜色
///
/// 示例：
/// ```dart
/// TotoSweepLight(
///   text: 'HELLO WORLD',
///   textStyle: TextStyle(fontSize: 16, color: Colors.white),
///   sweepColor: Colors.amber,
///   scaleRatio: 1.2,
///   letterSpacingRatio: 1.2,
///   characterDuration: Duration(milliseconds: 700),
///   sweepInterval: Duration(milliseconds: 80),
///   autoStart: true,
///   onStatusChanged: (status, progress, completedLoops) {
///     print('状态: $status, 进度: $progress, 轮次: $completedLoops');
///   },
/// )
/// ```
class TotoSweepLight extends StatefulWidget {
  const TotoSweepLight({
    Key? key,
    required this.text,
    this.textStyle,
    this.scaleRatio = 1.2,
    this.letterSpacingRatio = 1.2,
    this.sweepColor = Colors.amber,
    this.characterDuration = const Duration(milliseconds: 700),
    this.sweepInterval = const Duration(milliseconds: 80),
    this.durationRatio = const [1, 1, 1],
    this.loop = false,
    this.loopCount,
    this.controller,
    this.autoStart = false,
    this.onStatusChanged,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  /// 要展示的文字内容
  final String text;

  /// 文字的基础样式
  /// 如果未指定，将使用默认的 [TextStyle]
  final TextStyle? textStyle;

  /// 变换后的文字缩放倍率，默认 1.2
  final double scaleRatio;

  /// 变换后的字间距倍率（相对于初始字间距），默认 1.2
  final double letterSpacingRatio;

  /// 扫光时文字变换的目标颜色
  final Color sweepColor;

  /// 每个文字的变换总时长，默认 700ms
  final Duration characterDuration;

  /// 相邻文字开始变换的时间间隔，默认 80ms
  /// 控制扫光的速度，间隔越小扫光越快
  final Duration sweepInterval;

  /// 三个阶段的时长占比：[开始变换, 维持时长, 恢复初始]
  /// 默认 [1, 1, 1]，即三个阶段等分
  final List<int> durationRatio;

  /// 是否启用循环播放，默认 false
  final bool loop;

  /// 循环次数限制，仅在 [loop] 为 true 时生效
  /// - 为 null 时表示无限循环
  /// - 为正整数时表示循环播放的总次数（例如 3 表示总共播放 3 次）
  final int? loopCount;

  /// 外部控制器，用于控制动画的启动/停止/重置
  final TotoSweepLightController? controller;

  /// 是否在组件初始化时自动开始动画
  final bool autoStart;

  /// 动画状态变化回调
  final TotoSweepLightStatusCallback? onStatusChanged;

  /// 文字行的主轴对齐方式
  final MainAxisAlignment mainAxisAlignment;

  /// 文字行的交叉轴对齐方式
  final CrossAxisAlignment crossAxisAlignment;

  @override
  State<TotoSweepLight> createState() => _TotoSweepLightState();
}

class _TotoSweepLightState extends State<TotoSweepLight>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  TotoSweepLightStatus _status = TotoSweepLightStatus.idle;
  double _progress = 0.0;
  int _completedLoops = 0;

  /// 三个阶段在 [0, 1] 范围内的归一化分界点
  late double _phase1End;
  late double _phase2End;

  /// 缓存的字符列表和字符宽度
  List<String> _characters = [];
  List<double> _charWidths = [];
  int _charCount = 0;

  /// 缓存的样式相关值
  late TextStyle _resolvedBaseStyle;
  late Color _baseColor;
  late double _baseLetterSpacing;

  /// 字符宽度是否已测量完成
  bool _isMeasured = false;

  /// 待执行的启动请求（在测量完成前调用了 start 时挂起）
  bool _pendingStart = false;

  @override
  void initState() {
    super.initState();
    _updatePhaseBreakpoints();
    _updateCharacters();

    final totalDuration = _calculateTotalDuration();
    _animationController = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    _animationController.addListener(_onAnimationTick);
    _animationController.addStatusListener(_onAnimationStatusChanged);

    widget.controller?._attach(this);

    if (widget.autoStart) {
      _pendingStart = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // textScaler 或 DefaultTextStyle 可能变化，重新解析样式并测量
    _resolveStyleAndMeasure();
  }

  @override
  void didUpdateWidget(covariant TotoSweepLight oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 控制器变更
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }

    // 时长占比变更
    if (widget.durationRatio != oldWidget.durationRatio) {
      _updatePhaseBreakpoints();
    }

    // 文本变更
    if (widget.text != oldWidget.text) {
      _updateCharacters();
    }

    // 文本或样式变更时重新测量
    if (widget.text != oldWidget.text ||
        widget.textStyle != oldWidget.textStyle) {
      _resolveStyleAndMeasure();
    }

    // 文本或时长参数变更需要重新计算总时长
    if (widget.text != oldWidget.text ||
        widget.characterDuration != oldWidget.characterDuration ||
        widget.sweepInterval != oldWidget.sweepInterval) {
      final totalDuration = _calculateTotalDuration();
      _animationController.duration = totalDuration;

      // 如果文本变了且正在运行，重新启动
      if (widget.text != oldWidget.text &&
          _status == TotoSweepLightStatus.running) {
        _animationController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _animationController.removeListener(_onAnimationTick);
    _animationController.removeStatusListener(_onAnimationStatusChanged);
    _animationController.dispose();
    super.dispose();
  }

  /// 更新字符列表缓存
  void _updateCharacters() {
    _characters = widget.text.characters.toList();
    _charCount = _characters.length;
  }

  /// 解析样式并测量字符宽度
  ///
  /// 在 [didChangeDependencies] 和 [didUpdateWidget] 中调用，
  /// 确保在首次 build 之前完成测量。
  void _resolveStyleAndMeasure() {
    _resolvedBaseStyle = widget.textStyle ??
        DefaultTextStyle.of(context).style.copyWith(
              color: Colors.white,
              fontSize: 16,
            );
    _baseColor = _resolvedBaseStyle.color ?? Colors.white;
    _baseLetterSpacing = _resolvedBaseStyle.letterSpacing ?? 0.0;

    final textScaler = MediaQuery.textScalerOf(context);
    _charWidths = List<double>.filled(_charCount, 0.0);
    final measureStyle =
        _resolvedBaseStyle.copyWith(letterSpacing: _baseLetterSpacing);

    for (int i = 0; i < _charCount; i++) {
      final painter = TextPainter(
        text: TextSpan(text: _characters[i], style: measureStyle),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      _charWidths[i] = painter.width;
      painter.dispose();
    }

    _isMeasured = true;

    // 测量完成后，如果有挂起的启动请求，立即执行
    if (_pendingStart) {
      _pendingStart = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _start();
      });
    }
  }

  /// 更新三阶段的归一化分界点
  void _updatePhaseBreakpoints() {
    final ratioSum =
        widget.durationRatio.fold<int>(0, (sum, val) => sum + val);
    _phase1End = widget.durationRatio[0] / ratioSum;
    _phase2End = (widget.durationRatio[0] + widget.durationRatio[1]) / ratioSum;
  }

  /// 计算整个扫光动画的总时长
  Duration _calculateTotalDuration() {
    if (_charCount == 0) return Duration.zero;
    final totalMs = (_charCount - 1) * widget.sweepInterval.inMilliseconds +
        widget.characterDuration.inMilliseconds;
    return Duration(milliseconds: totalMs);
  }

  void _onAnimationTick() {
    if (!mounted) return;

    _progress = _animationController.value.clamp(0.0, 1.0);

    if (_status == TotoSweepLightStatus.running) {
      widget.onStatusChanged?.call(_status, _progress, _completedLoops);
    }

    setState(() {});
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (!mounted) return;
    switch (status) {
      case AnimationStatus.forward:
        _updateStatus(TotoSweepLightStatus.running);
        break;
      case AnimationStatus.completed:
        _completedLoops++;
        if (widget.loop &&
            (widget.loopCount == null || _completedLoops < widget.loopCount!)) {
          _animationController.forward(from: 0.0);
        } else {
          _updateStatus(TotoSweepLightStatus.completed);
        }
        break;
      case AnimationStatus.dismissed:
        break;
      default:
        break;
    }
  }

  void _updateStatus(TotoSweepLightStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      widget.onStatusChanged?.call(_status, _progress, _completedLoops);
    }
  }

  /// 启动动画（从头开始）
  ///
  /// 如果字符宽度尚未测量完成，启动请求会被挂起，
  /// 待测量完成后自动执行。
  void _start() {
    if (!_isMeasured) {
      _pendingStart = true;
      return;
    }
    _completedLoops = 0;
    _animationController.forward(from: 0.0);
  }

  /// 暂停动画（保持在当前位置）
  void _pause() {
    if (_status == TotoSweepLightStatus.running) {
      _animationController.stop();
      _updateStatus(TotoSweepLightStatus.paused);
    }
  }

  /// 从暂停位置继续动画
  void _resume() {
    if (_status == TotoSweepLightStatus.paused) {
      _animationController.forward();
    }
  }

  /// 停止动画并回到闲置状态
  void _stop() {
    _animationController.stop();
    if (_status == TotoSweepLightStatus.running ||
        _status == TotoSweepLightStatus.paused) {
      _updateStatus(TotoSweepLightStatus.idle);
    }
  }

  /// 重置动画
  void _reset() {
    _pendingStart = false;
    _animationController.reset();
    _progress = 0.0;
    _completedLoops = 0;
    _updateStatus(TotoSweepLightStatus.idle);
    setState(() {});
  }

  /// 计算单个文字在当前动画时间的变换参数
  _CharAnimValues _calculateCharValues(int charIndex) {
    final totalMs = _animationController.duration?.inMilliseconds ?? 0;
    if (totalMs <= 0) {
      return _CharAnimValues.identity;
    }

    final currentMs = _animationController.value * totalMs;
    final charStartMs = charIndex * widget.sweepInterval.inMilliseconds;
    final charEndMs = charStartMs + widget.characterDuration.inMilliseconds;

    // 还没轮到这个字 或 这个字的动画已结束
    if (currentMs < charStartMs || currentMs >= charEndMs) {
      return _CharAnimValues.identity;
    }

    // 在这个字的动画时间范围内
    final charProgress =
        (currentMs - charStartMs) / widget.characterDuration.inMilliseconds;

    double intensity;
    if (charProgress <= _phase1End) {
      intensity = charProgress / _phase1End;
    } else if (charProgress <= _phase2End) {
      intensity = 1.0;
    } else {
      intensity = 1.0 - (charProgress - _phase2End) / (1.0 - _phase2End);
    }

    intensity = intensity.clamp(0.0, 1.0);
    final curvedIntensity = Curves.easeInOut.transform(intensity);

    return _CharAnimValues(
      scale: 1.0 + (widget.scaleRatio - 1.0) * curvedIntensity,
      colorLerp: curvedIntensity,
      spacingLerp: curvedIntensity,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 预先计算所有字符的动画值
    final allValues = List<_CharAnimValues>.generate(
      _charCount,
      _calculateCharValues,
    );

    // 缓存静止字符的 TextStyle，避免重复 copyWith
    final staticStyle =
        _resolvedBaseStyle.copyWith(letterSpacing: _baseLetterSpacing);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: List.generate(_charCount, (index) {
        final values = allValues[index];
        final isLast = index == _charCount - 1;
        final isStatic = values.isIdentity;

        // 静止字符复用缓存的 style，动画中字符才做 Color.lerp
        final charStyle = isStatic
            ? staticStyle
            : _resolvedBaseStyle.copyWith(
                color: Color.lerp(
                    _baseColor, widget.sweepColor, values.colorLerp)!,
                letterSpacing: _baseLetterSpacing,
              );

        Widget charWidget = Text(
          _characters[index],
          style: charStyle,
        );

        // 缩放变换（仅动画中的字符）
        if (!isStatic) {
          charWidget = Transform.scale(
            scale: values.scale,
            child: charWidget,
          );
        }

        // 字间距计算（最后一个字符不需要右侧间距）
        if (!isLast) {
          // 1. 用户期望的字间距扩展量
          final targetExtraSpacing =
              _baseLetterSpacing * (widget.letterSpacingRatio - 1.0);
          final userExtraSpacing = targetExtraSpacing * values.spacingLerp;

          // 2. 缩放补偿量：
          //    Transform.scale 不改变布局尺寸，放大后文字视觉上向两侧溢出。
          //    当前字符右侧溢出 = charWidth * (scale - 1) / 2
          //    下一个字符左侧溢出 = nextCharWidth * (nextScale - 1) / 2
          final currentOverflow =
              _charWidths[index] * (values.scale - 1.0) / 2.0;
          final nextValues = allValues[index + 1];
          final nextOverflow =
              _charWidths[index + 1] * (nextValues.scale - 1.0) / 2.0;
          final scaleCompensation = currentOverflow + nextOverflow;

          final totalExtraSpacing = userExtraSpacing + scaleCompensation;

          if (totalExtraSpacing > 0) {
            charWidget = Padding(
              padding: EdgeInsets.only(right: totalExtraSpacing),
              child: charWidget,
            );
          }
        }

        // RepaintBoundary 隔离每个字符的重绘范围
        return RepaintBoundary(child: charWidget);
      }),
    );
  }
}

/// 单个文字的动画插值参数
class _CharAnimValues {
  /// 文字缩放值，1.0 为原始大小
  final double scale;

  /// 颜色插值因子，0.0 为原始颜色，1.0 为扫光颜色
  final double colorLerp;

  /// 字间距插值因子，0.0 为原始间距，1.0 为最大扩展间距
  final double spacingLerp;

  const _CharAnimValues({
    required this.scale,
    required this.colorLerp,
    required this.spacingLerp,
  });

  /// 无动画的初始值常量，避免每次创建新对象
  static const identity = _CharAnimValues(
    scale: 1.0,
    colorLerp: 0.0,
    spacingLerp: 0.0,
  );

  /// 是否为无动画 of 初始状态
  bool get isIdentity => scale == 1.0 && colorLerp == 0.0;
}
