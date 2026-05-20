import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/import/selected_video.dart';

void main() {
  test('returns uppercase extension from filename', () {
    const video = SelectedVideo(
      name: 'podcast.clip.mp4',
      path: '/tmp/podcast.clip.mp4',
      sizeBytes: 1024,
    );

    expect(video.extension, 'MP4');
  });

  test('formats file size with units', () {
    const video = SelectedVideo(
      name: 'episode.mov',
      path: '/tmp/episode.mov',
      sizeBytes: 1572864,
    );

    expect(video.formattedSize, '1.5 MB');
  });
}
