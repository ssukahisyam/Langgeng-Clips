import 'package:flutter/services.dart';

class AudioExtractor {
  const AudioExtractor({MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel('com.langgeng.clip/audio_tools');

  final MethodChannel _channel;

  Future<String> extractWav16kMono({
    required String sourcePath,
    required int startMillis,
    required int endMillis,
  }) async {
    if (sourcePath.trim().isEmpty) {
      throw const AudioExtractionException(
        'File sumber tidak tersedia. Pilih ulang video.',
      );
    }
    if (endMillis <= startMillis) {
      throw const AudioExtractionException('Range audio tidak valid.');
    }

    try {
      final path = await _channel.invokeMethod<String>('extractWav16kMono', {
        'sourcePath': sourcePath,
        'startMillis': startMillis,
        'endMillis': endMillis,
      });
      if (path == null || path.isEmpty) {
        throw const AudioExtractionException('Output audio tidak tersedia.');
      }

      return path;
    } on PlatformException catch (error) {
      throw AudioExtractionException.fromPlatformException(error);
    }
  }
}

class AudioExtractionException implements Exception {
  const AudioExtractionException(this.message);

  factory AudioExtractionException.fromPlatformException(
    PlatformException error,
  ) {
    return switch (error.code) {
      'invalid_source' => const AudioExtractionException(
        'File sumber tidak tersedia. Pilih ulang video.',
      ),
      'invalid_range' => const AudioExtractionException(
        'Range audio tidak valid.',
      ),
      _ => const AudioExtractionException('Gagal mengekstrak audio WAV.'),
    };
  }

  final String message;

  @override
  String toString() => message;
}
