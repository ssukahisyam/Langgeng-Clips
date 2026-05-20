import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'export_options.dart';

final trimExporterProvider = Provider<TrimExporter>(
  (ref) => const TrimExporter(),
);

class TrimExporter {
  const TrimExporter();

  static const _channel = MethodChannel('com.langgeng.clip/trim_export');
  static const _progressChannel = EventChannel(
    'com.langgeng.clip/trim_export_progress',
  );

  Stream<double> get progressStream {
    return _progressChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        final progress = event['progress'];
        if (progress is num) {
          return progress.toDouble().clamp(0, 1);
        }
      }

      return 0.0;
    });
  }

  Future<void> cancel() {
    return _channel.invokeMethod<void>('cancelExport');
  }

  Future<TrimExportResult> export({
    required String sourcePath,
    required int startMillis,
    required int endMillis,
    required ExportOptions options,
  }) async {
    if (sourcePath.trim().isEmpty) {
      throw const TrimExportException(
        'File sumber tidak tersedia. Pilih ulang video.',
      );
    }
    if (endMillis <= startMillis) {
      throw const TrimExportException(
        'Range clip tidak valid. Geser start/end clip.',
      );
    }

    Map<Object?, Object?>? result;
    try {
      result = await _channel.invokeMapMethod<Object?, Object?>('exportTrim', {
        'sourcePath': sourcePath,
        'startMillis': startMillis,
        'endMillis': endMillis,
        'resolution': options.resolution,
        'frameRate': options.frameRate,
        'codec': options.codec,
      });
    } on PlatformException catch (error) {
      throw TrimExportException.fromPlatformException(error);
    }

    if (result == null) {
      throw const TrimExportException('Output export tidak tersedia.');
    }

    return TrimExportResult.fromMap(result);
  }
}

class TrimExportResult {
  const TrimExportResult({
    required this.cachePath,
    this.galleryUri,
    this.resolution,
    this.frameRate,
    this.codec,
  });

  factory TrimExportResult.fromMap(Map<Object?, Object?> map) {
    final cachePath = map['cachePath'] as String?;
    if (cachePath == null || cachePath.isEmpty) {
      throw const TrimExportException('Output cache export tidak tersedia.');
    }

    return TrimExportResult(
      cachePath: cachePath,
      galleryUri: map['galleryUri'] as String?,
      resolution: map['resolution'] as String?,
      frameRate: map['frameRate'] as String?,
      codec: map['codec'] as String?,
    );
  }

  final String cachePath;
  final String? galleryUri;
  final String? resolution;
  final String? frameRate;
  final String? codec;

  bool get isSavedToGallery => galleryUri != null && galleryUri!.isNotEmpty;
}

class TrimExportException implements Exception {
  const TrimExportException(this.message);

  factory TrimExportException.fromPlatformException(PlatformException error) {
    final message = error.message;
    if (message != null && message.trim().isNotEmpty) {
      return TrimExportException(message);
    }

    return switch (error.code) {
      'invalid_source' => const TrimExportException(
        'File sumber tidak tersedia. Pilih ulang video.',
      ),
      'invalid_range' => const TrimExportException(
        'Range clip tidak valid. Geser start/end clip.',
      ),
      'export_cancelled' => const TrimExportException('Export dibatalkan.'),
      _ => const TrimExportException('Export gagal. Coba ulangi.'),
    };
  }

  final String message;

  @override
  String toString() => message;
}
