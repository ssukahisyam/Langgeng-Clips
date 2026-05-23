import 'dart:io';

import 'package:crypto/crypto.dart';

class SourceFingerprint {
  const SourceFingerprint();

  Future<String> sha256ForFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw const SourceFingerprintException('File sumber tidak tersedia.');
    }

    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }
}

class SourceFingerprintException implements Exception {
  const SourceFingerprintException(this.message);

  final String message;

  @override
  String toString() => message;
}
