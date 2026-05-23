import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'transcription_provider.dart';

class TranscriptCache {
  const TranscriptCache({required SharedPreferences preferences})
    : _preferences = preferences;

  static const _prefix = 'transcript_cache_v1';

  final SharedPreferences _preferences;

  Transcript? read(String sourceSha256) {
    final value = _preferences.getString(_key(sourceSha256));
    if (value == null) {
      return null;
    }

    try {
      return Transcript.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } on FormatException {
      delete(sourceSha256);
      return null;
    }
  }

  Future<void> write(String sourceSha256, Transcript transcript) {
    return _preferences.setString(
      _key(sourceSha256),
      jsonEncode(transcript.toJson()),
    );
  }

  Future<void> delete(String sourceSha256) {
    return _preferences.remove(_key(sourceSha256));
  }

  String _key(String sourceSha256) => '$_prefix:$sourceSha256';
}
