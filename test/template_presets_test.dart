import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/templates/clip_template.dart';
import 'package:langgeng_clip/features/templates/template_presets.dart';

void main() {
  test('template definition round-trips as JSON', () {
    final json = TemplatePresets.podcast.toJson();
    final template = ClipTemplate.fromJson(json);

    expect(template.id, 'podcast');
    expect(template.captionStyle.size, 'large');
    expect(template.layout.cropMode, 'center_crop_9_16');
  });

  test('presets contain Phase 2 template set', () {
    expect(
      TemplatePresets.all.map((template) => template.id),
      containsAll(['podcast', 'gaming', 'talking_head', 'tutorial']),
    );
  });

  test('tutorial enables watermark by default', () {
    expect(TemplatePresets.tutorial.watermarkEnabledByDefault, isTrue);
  });
}
