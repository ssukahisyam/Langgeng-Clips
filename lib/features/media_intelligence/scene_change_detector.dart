import 'package:flutter/services.dart';

class SceneChangeDetector {
  const SceneChangeDetector({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('com.langgeng.clip/media_intelligence');

  final MethodChannel _channel;

  Future<List<SceneChange>> detect({
    required String sourcePath,
    int intervalMillis = 1000,
    double threshold = 0.35,
  }) async {
    if (sourcePath.trim().isEmpty) {
      throw const SceneDetectionException('File sumber tidak tersedia.');
    }
    if (intervalMillis <= 0) {
      throw const SceneDetectionException(
        'Interval scene detection tidak valid.',
      );
    }

    try {
      final raw = await _channel
          .invokeMethod<List<Object?>>('detectSceneChanges', {
            'sourcePath': sourcePath,
            'intervalMillis': intervalMillis,
            'threshold': threshold,
          });

      return (raw ?? const [])
          .whereType<Map<Object?, Object?>>()
          .map(SceneChange.fromMap)
          .toList();
    } on PlatformException catch (error) {
      throw SceneDetectionException.fromPlatformException(error);
    }
  }
}

class SceneChange {
  const SceneChange({required this.timeMillis, required this.score});

  factory SceneChange.fromMap(Map<Object?, Object?> map) {
    return SceneChange(
      timeMillis: (map['timeMillis'] as num?)?.toInt() ?? 0,
      score: (map['score'] as num?)?.toDouble() ?? 0,
    );
  }

  final int timeMillis;
  final double score;
}

class SceneDetectionException implements Exception {
  const SceneDetectionException(this.message);

  factory SceneDetectionException.fromPlatformException(
    PlatformException error,
  ) {
    return switch (error.code) {
      'invalid_source' => const SceneDetectionException(
        'File sumber tidak tersedia.',
      ),
      'invalid_interval' => const SceneDetectionException(
        'Interval scene detection tidak valid.',
      ),
      _ => const SceneDetectionException('Scene detection gagal.'),
    };
  }

  final String message;

  @override
  String toString() => message;
}
