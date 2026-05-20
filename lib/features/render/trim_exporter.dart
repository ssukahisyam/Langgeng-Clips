import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trimExporterProvider = Provider<TrimExporter>(
  (ref) => const TrimExporter(),
);

class TrimExporter {
  const TrimExporter();

  static const _channel = MethodChannel('com.langgeng.clip/trim_export');

  Future<String> export({
    required String sourcePath,
    required int startMillis,
    required int endMillis,
  }) async {
    final result = await _channel.invokeMethod<String>('exportTrim', {
      'sourcePath': sourcePath,
      'startMillis': startMillis,
      'endMillis': endMillis,
    });

    if (result == null || result.isEmpty) {
      throw const TrimExportException('Output export tidak tersedia.');
    }

    return result;
  }
}

class TrimExportException implements Exception {
  const TrimExportException(this.message);

  final String message;

  @override
  String toString() => message;
}
