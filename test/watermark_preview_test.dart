import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/watermark/watermark_config.dart';
import 'package:langgeng_clip/features/watermark/watermark_preview.dart';

void main() {
  testWidgets('watermark preview renders text watermark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WatermarkPreview(config: WatermarkConfig(text: '@langgeng')),
        ),
      ),
    );

    expect(find.text('@langgeng'), findsOneWidget);
  });
}
