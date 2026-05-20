import '../editor/editor_project.dart';

class ExportOptions {
  const ExportOptions({
    required this.resolution,
    required this.frameRate,
    required this.codec,
  });

  final String resolution;
  final String frameRate;
  final String codec;

  int estimateSizeBytes(EditorClip clip) {
    final bitrateMbps = switch (resolution) {
      '720p' => 5,
      '4K' => 35,
      _ => 10,
    };
    final seconds = clip.durationMillis / 1000;
    return ((bitrateMbps * 1000000 / 8) * seconds).round();
  }

  String estimateSizeLabel(EditorClip clip) {
    final bytes = estimateSizeBytes(clip);
    final mb = bytes / (1024 * 1024);
    if (mb < 1024) {
      return '${mb.toStringAsFixed(1)} MB';
    }

    return '${(mb / 1024).toStringAsFixed(1)} GB';
  }
}
