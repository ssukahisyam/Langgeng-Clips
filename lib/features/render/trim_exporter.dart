import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/pigeon/render_api.g.dart' as pigeon;
import 'export_options.dart';

final trimExporterProvider = Provider<TrimExporter>(
  (ref) => const TrimExporter(),
);

abstract class NativeRenderGateway {
  Future<pigeon.RenderResult> exportTrim(pigeon.RenderRequest request);

  Future<void> cancelExport();
}

class PigeonNativeRenderGateway implements NativeRenderGateway {
  PigeonNativeRenderGateway({pigeon.NativeRenderApi? api})
    : _api = api ?? pigeon.NativeRenderApi();

  final pigeon.NativeRenderApi _api;

  @override
  Future<pigeon.RenderResult> exportTrim(pigeon.RenderRequest request) {
    return _api.exportTrim(request);
  }

  @override
  Future<void> cancelExport() => _api.cancelExport();
}

class TrimExporter {
  const TrimExporter({NativeRenderGateway? nativeRenderGateway})
    : _nativeRenderGateway = nativeRenderGateway;

  static const _progressChannel = EventChannel(
    'com.langgeng.clip/trim_export_progress',
  );

  final NativeRenderGateway? _nativeRenderGateway;

  NativeRenderGateway get _gateway {
    return _nativeRenderGateway ?? PigeonNativeRenderGateway();
  }

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
    return _gateway.cancelExport();
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

    try {
      final result = await _gateway.exportTrim(
        pigeon.RenderRequest(
          sourcePath: sourcePath,
          startMillis: startMillis,
          endMillis: endMillis,
          resolution: options.resolution,
          frameRate: options.frameRate,
          codec: options.codec,
          targetWidth: options.targetWidth,
          targetHeight: options.targetHeight,
          cropToPortrait: options.cropToPortrait,
          requiresReencode: options.requiresReencode,
        ),
      );
      return TrimExportResult.fromPigeon(result);
    } on PlatformException catch (error) {
      throw TrimExportException.fromPlatformException(error);
    }
  }
}

class TrimExportResult {
  const TrimExportResult({
    required this.cachePath,
    this.galleryUri,
    this.resolution,
    this.frameRate,
    this.codec,
    this.targetWidth,
    this.targetHeight,
    this.cropToPortrait,
    this.requiresReencode,
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
      targetWidth: (map['targetWidth'] as num?)?.toInt(),
      targetHeight: (map['targetHeight'] as num?)?.toInt(),
      cropToPortrait: map['cropToPortrait'] as bool?,
      requiresReencode: map['requiresReencode'] as bool?,
    );
  }

  factory TrimExportResult.fromPigeon(pigeon.RenderResult result) {
    if (result.cachePath.isEmpty) {
      throw const TrimExportException('Output cache export tidak tersedia.');
    }

    return TrimExportResult(
      cachePath: result.cachePath,
      galleryUri: result.galleryUri,
      resolution: result.resolution,
      frameRate: result.frameRate,
      codec: result.codec,
      targetWidth: result.targetWidth,
      targetHeight: result.targetHeight,
      cropToPortrait: result.cropToPortrait,
      requiresReencode: result.requiresReencode,
    );
  }

  final String cachePath;
  final String? galleryUri;
  final String? resolution;
  final String? frameRate;
  final String? codec;
  final int? targetWidth;
  final int? targetHeight;
  final bool? cropToPortrait;
  final bool? requiresReencode;

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
