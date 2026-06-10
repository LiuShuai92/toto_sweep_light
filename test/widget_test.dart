import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toto_sweep_light/toto_sweep_light.dart';

void main() {
  testWidgets('TotoSweepLight rendering test', (WidgetTester tester) async {
    // 渲染测试
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TotoSweepLight(
            text: 'HELLO',
          ),
        ),
      ),
    );

    // 验证字符是否都在 Row 里渲染出来了
    expect(find.text('H'), findsOneWidget);
    expect(find.text('E'), findsOneWidget);
    expect(find.text('L'), findsNWidgets(2));
    expect(find.text('O'), findsOneWidget);
  });
}
