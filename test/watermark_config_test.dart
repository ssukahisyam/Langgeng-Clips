import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/watermark/watermark_config.dart';

void main() {
  test('text watermark serializes with 9-anchor position', () {
    const config = WatermarkConfig(
      text: '@langgeng',
      anchor: WatermarkAnchor.topCenter,
      opacity: 0.5,
      scale: 1.25,
    );

    final restored = WatermarkConfig.fromJson(config.toJson());

    expect(restored.text, '@langgeng');
    expect(restored.anchor, WatermarkAnchor.topCenter);
    expect(restored.opacity, 0.5);
    expect(restored.scale, 1.25);
    expect(restored.hasContent, isTrue);
  });

  test('opacity and scale are clamped to safe ranges', () {
    final config = WatermarkConfig.fromJson({
      'opacity': 5,
      'scale': 99,
      'anchor': 'bottomLeft',
    });

    expect(config.opacity, 1);
    expect(config.scale, 4);
    expect(config.anchor, WatermarkAnchor.bottomLeft);
  });
}
