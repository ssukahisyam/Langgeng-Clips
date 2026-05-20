class VideoMetadata {
  const VideoMetadata({
    required this.durationMillis,
    required this.width,
    required this.height,
    required this.rotationDegrees,
    required this.mimeType,
  });

  factory VideoMetadata.fromMap(Map<Object?, Object?> map) {
    return VideoMetadata(
      durationMillis: (map['durationMillis'] as num?)?.toInt() ?? 0,
      width: (map['width'] as num?)?.toInt() ?? 0,
      height: (map['height'] as num?)?.toInt() ?? 0,
      rotationDegrees: (map['rotationDegrees'] as num?)?.toInt() ?? 0,
      mimeType: map['mimeType'] as String? ?? 'unknown',
    );
  }

  final int durationMillis;
  final int width;
  final int height;
  final int rotationDegrees;
  final String mimeType;

  String get formattedDuration {
    final totalSeconds = (durationMillis / 1000).round();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get resolution {
    if (width <= 0 || height <= 0) {
      return 'unknown';
    }

    return '${width}x$height';
  }
}
