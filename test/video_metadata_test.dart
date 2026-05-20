import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/project_setup/video_metadata.dart';

void main() {
  test('parses metadata map from native channel', () {
    final metadata = VideoMetadata.fromMap({
      'durationMillis': 90500,
      'width': 1920,
      'height': 1080,
      'rotationDegrees': 90,
      'mimeType': 'video/mp4',
    });

    expect(metadata.formattedDuration, '01:31');
    expect(metadata.resolution, '1920x1080');
    expect(metadata.rotationDegrees, 90);
    expect(metadata.mimeType, 'video/mp4');
  });

  test('formats hour-long duration', () {
    const metadata = VideoMetadata(
      durationMillis: 3723000,
      width: 3840,
      height: 2160,
      rotationDegrees: 0,
      mimeType: 'video/mp4',
    );

    expect(metadata.formattedDuration, '01:02:03');
  });
}
