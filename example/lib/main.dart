import 'package:flutter/material.dart';
import 'package:toto_sweep_light/toto_sweep_light.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toto Sweep Light Example',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E2E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.tealAccent,
        ),
      ),
      home: const SweepLightDemoPage(),
    );
  }
}

class SweepLightDemoPage extends StatefulWidget {
  const SweepLightDemoPage({super.key});

  @override
  State<SweepLightDemoPage> createState() => _SweepLightDemoPageState();
}

class _SweepLightDemoPageState extends State<SweepLightDemoPage> {
  final TextSweepLightController _manualController = TextSweepLightController();

  // 动画状态相关变量
  TextSweepLightStatus _status = TextSweepLightStatus.idle;
  double _progress = 0.0;
  int _completedLoops = 0;

  // 自定义配置参数
  double _scaleRatio = 1.3;
  double _letterSpacingRatio = 1.4;
  Color _sweepColor = Colors.amberAccent;
  int _characterDurationMs = 600;
  int _sweepIntervalMs = 80;
  bool _loop = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toto Sweep Light 示例'),
        backgroundColor: const Color(0xFF181825),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 核心展示区域
              _buildSectionTitle('效果预览'),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF11111B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Center(
                  child: TextSweepLight(
                    text: 'TOTO SWEEP LIGHT',
                    controller: _manualController,
                    scaleRatio: _scaleRatio,
                    letterSpacingRatio: _letterSpacingRatio,
                    sweepColor: _sweepColor,
                    characterDuration: Duration(milliseconds: _characterDurationMs),
                    sweepInterval: Duration(milliseconds: _sweepIntervalMs),
                    loop: _loop,
                    autoStart: true,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Colors.grey,
                    ),
                    onStatusChanged: (status, progress, completedLoops) {
                      setState(() {
                        _status = status;
                        _progress = progress;
                        _completedLoops = completedLoops;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. 状态反馈区
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF181825),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusItem('当前状态', _status.name.toUpperCase()),
                    _buildStatusItem('动画进度', '${(_progress * 100).toStringAsFixed(1)}%'),
                    _buildStatusItem('循环轮次', '$_completedLoops'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. 控制面板区
              _buildSectionTitle('手动控制'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _manualController.start(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('启动 (Start)'),
                  ),
                  ElevatedButton(
                    onPressed: () => _manualController.pause(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('暂停 (Pause)'),
                  ),
                  ElevatedButton(
                    onPressed: () => _manualController.resume(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('恢复 (Resume)'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _manualController.stop(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('停止 (Stop)'),
                  ),
                  ElevatedButton(
                    onPressed: () => _manualController.reset(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('重置 (Reset)'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. 参数配置区
              _buildSectionTitle('参数微调'),
              Card(
                color: const Color(0xFF181825),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 缩放倍率
                      _buildSliderRow(
                        '缩放倍率 (${_scaleRatio.toStringAsFixed(1)})',
                        _scaleRatio,
                        1.0,
                        2.0,
                        (val) => setState(() => _scaleRatio = val),
                      ),
                      // 字间距扩展倍率
                      _buildSliderRow(
                        '字间距倍率 (${_letterSpacingRatio.toStringAsFixed(1)})',
                        _letterSpacingRatio,
                        1.0,
                        3.0,
                        (val) => setState(() => _letterSpacingRatio = val),
                      ),
                      // 每个字符变换时长
                      _buildSliderRow(
                        '单字符时长 (${_characterDurationMs}ms)',
                        _characterDurationMs.toDouble(),
                        200,
                        1500,
                        (val) => setState(() => _characterDurationMs = val.toInt()),
                      ),
                      // 扫光间隔
                      _buildSliderRow(
                        '扫光间隔 (${_sweepIntervalMs}ms)',
                        _sweepIntervalMs.toDouble(),
                        20,
                        300,
                        (val) => setState(() => _sweepIntervalMs = val.toInt()),
                      ),
                      // 扫光目标颜色
                      ListTile(
                        title: const Text('扫光目标颜色'),
                        trailing: DropdownButton<Color>(
                          value: _sweepColor,
                          dropdownColor: const Color(0xFF1E1E2E),
                          onChanged: (Color? newColor) {
                            if (newColor != null) {
                              setState(() => _sweepColor = newColor);
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: Colors.amberAccent, child: Text('琥珀黄', style: TextStyle(color: Colors.amberAccent))),
                            DropdownMenuItem(value: Colors.tealAccent, child: Text('极光绿', style: TextStyle(color: Colors.tealAccent))),
                            DropdownMenuItem(value: Colors.pinkAccent, child: Text('蔷薇粉', style: TextStyle(color: Colors.pinkAccent))),
                            DropdownMenuItem(value: Colors.cyanAccent, child: Text('天空蓝', style: TextStyle(color: Colors.cyanAccent))),
                          ],
                        ),
                      ),
                      // 是否循环
                      SwitchListTile(
                        title: const Text('是否启用循环'),
                        value: _loop,
                        onChanged: (bool val) {
                          setState(() => _loop = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
