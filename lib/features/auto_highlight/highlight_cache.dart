import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'highlight_candidate.dart';

class HighlightCache {
  const HighlightCache({required SharedPreferences preferences})
    : _preferences = preferences;

  static const _prefix = 'highlight_cache_v1';

  final SharedPreferences _preferences;

  HighlightResult? read({
    required String sourceSha256,
    required String configHash,
  }) {
    final raw = _preferences.getString(_key(sourceSha256, configHash));
    if (raw == null) {
      return null;
    }

    try {
      return HighlightResult.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      delete(sourceSha256: sourceSha256, configHash: configHash);
      return null;
    }
  }

  Future<void> write({
    required String sourceSha256,
    required String configHash,
    required HighlightResult result,
  }) {
    return _preferences.setString(
      _key(sourceSha256, configHash),
      jsonEncode(result.toJson()),
    );
  }

  Future<void> delete({
    required String sourceSha256,
    required String configHash,
  }) {
    return _preferences.remove(_key(sourceSha256, configHash));
  }

  String _key(String sourceSha256, String configHash) {
    return '$_prefix:$sourceSha256:$configHash';
  }
}
