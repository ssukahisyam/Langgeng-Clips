import 'dart:io';

import 'package:file_picker/file_picker.dart';

class SelectedVideo {
  const SelectedVideo({
    required this.name,
    required this.path,
    required this.sizeBytes,
  });

  factory SelectedVideo.fromPlatformFile(PlatformFile file) {
    return SelectedVideo(
      name: file.name,
      path: file.path ?? '',
      sizeBytes: file.size,
    );
  }

  factory SelectedVideo.fromJson(Map<String, dynamic> json) {
    return SelectedVideo(
      name: json['name'] as String,
      path: json['path'] as String,
      sizeBytes: json['sizeBytes'] as int,
    );
  }

  final String name;
  final String path;
  final int sizeBytes;

  String get extension {
    final index = name.lastIndexOf('.');
    if (index == -1 || index == name.length - 1) {
      return 'unknown';
    }

    return name.substring(index + 1).toUpperCase();
  }

  String get formattedSize {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = sizeBytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    final decimals = unitIndex == 0 ? 0 : 1;
    return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }

  bool get existsOnDevice {
    if (path.isEmpty) {
      return false;
    }

    return File(path).existsSync();
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'path': path, 'sizeBytes': sizeBytes};
  }
}
