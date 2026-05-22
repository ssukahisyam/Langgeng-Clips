import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/editor/editor_project.dart';
import 'package:langgeng_clip/features/render/export_options.dart';

void main() {
  const clip = EditorClip(
    id: 'clip-1',
    name: 'Clip 1',
    startMillis: 0,
    endMillis: 10000,
  );

  test('estimates larger files for higher resolution', () {
    final small = const ExportOptions(
      resolution: '720p',
      frameRate: '30',
      codec: 'H.264',
    ).estimateSizeBytes(clip);
    final large = const ExportOptions(
      resolution: '4K',
      frameRate: '30',
      codec: 'H.264',
    ).estimateSizeBytes(clip);

    expect(large, greaterThan(small));
  });

  test('formats estimate size label', () {
    const options = ExportOptions(
      resolution: '1080p',
      frameRate: '30',
      codec: 'H.264',
    );

    expect(options.estimateSizeLabel(clip), endsWith('MB'));
  });

  test('maps export resolution to portrait target dimensions', () {
    const options = ExportOptions(
      resolution: '1080p',
      frameRate: '30',
      codec: 'H.264',
    );

    expect(options.targetWidth, 1080);
    expect(options.targetHeight, 1920);
    expect(options.cropToPortrait, isTrue);
    expect(options.requiresReencode, isTrue);
  });
}
