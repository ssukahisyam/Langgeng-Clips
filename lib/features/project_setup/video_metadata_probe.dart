import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'video_metadata.dart';

final videoMetadataProbeProvider = Provider<VideoMetadataProbe>(
  (ref) => const VideoMetadataProbe(),
);

final videoMetadataProvider = FutureProvider.family<VideoMetadata, String>(
  (ref, path) => ref.watch(videoMetadataProbeProvider).probe(path),
);

class VideoMetadataProbe {
  const VideoMetadataProbe();

  static const _channel = MethodChannel('com.langgeng.clip/video_probe');

  Future<VideoMetadata> probe(String path) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>('probe', {
      'path': path,
    });

    if (result == null) {
      throw const VideoMetadataProbeException('Metadata video tidak tersedia.');
    }

    return VideoMetadata.fromMap(result);
  }
}

class VideoMetadataProbeException implements Exception {
  const VideoMetadataProbeException(this.message);

  final String message;

  @override
  String toString() => message;
}
