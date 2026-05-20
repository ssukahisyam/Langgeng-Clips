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

  int get targetWidth {
    return switch (resolution) {
      '720p' => 720,
      '4K' => 2160,
      _ => 1080,
    };
  }

  int get targetHeight {
    return switch (resolution) {
      '720p' => 1280,
      '4K' => 3840,
      _ => 1920,
    };
  }

  bool get cropToPortrait => true;

  bool get requiresReencode => cropToPortrait || codec != 'copy';

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
