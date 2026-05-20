import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trimExporterProvider = Provider<TrimExporter>(
  (ref) => const TrimExporter(),
);

class TrimExporter {
  const TrimExporter();

  static const _channel = MethodChannel('com.langgeng.clip/trim_export');

  Future<TrimExportResult> export({
    required String sourcePath,
    required int startMillis,
    required int endMillis,
  }) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'exportTrim',
      {
        'sourcePath': sourcePath,
        'startMillis': startMillis,
        'endMillis': endMillis,
      },
    );

    if (result == null) {
      throw const TrimExportException('Output export tidak tersedia.');
    }

    return TrimExportResult.fromMap(result);
  }
}

class TrimExportResult {
  const TrimExportResult({required this.cachePath, this.galleryUri});

  factory TrimExportResult.fromMap(Map<Object?, Object?> map) {
    final cachePath = map['cachePath'] as String?;
    if (cachePath == null || cachePath.isEmpty) {
      throw const TrimExportException('Output cache export tidak tersedia.');
    }

    return TrimExportResult(
      cachePath: cachePath,
      galleryUri: map['galleryUri'] as String?,
    );
  }

  final String cachePath;
  final String? galleryUri;

  bool get isSavedToGallery => galleryUri != null && galleryUri!.isNotEmpty;
}

class TrimExportException implements Exception {
  const TrimExportException(this.message);

  final String message;

  @override
  String toString() => message;
}
