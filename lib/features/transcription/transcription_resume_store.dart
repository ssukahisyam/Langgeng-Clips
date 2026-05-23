import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TranscriptionResumeCheckpoint {
  const TranscriptionResumeCheckpoint({
    required this.sourceSha256,
    required this.completedChunkIndexes,
  });

  factory TranscriptionResumeCheckpoint.fromJson(Map<String, dynamic> json) {
    final indexes = json['completedChunkIndexes'];
    return TranscriptionResumeCheckpoint(
      sourceSha256: json['sourceSha256'] as String? ?? '',
      completedChunkIndexes: indexes is List
          ? indexes.whereType<num>().map((index) => index.toInt()).toSet()
          : const <int>{},
    );
  }

  final String sourceSha256;
  final Set<int> completedChunkIndexes;

  TranscriptionResumeCheckpoint markCompleted(int chunkIndex) {
    return TranscriptionResumeCheckpoint(
      sourceSha256: sourceSha256,
      completedChunkIndexes: {...completedChunkIndexes, chunkIndex},
    );
  }

  Map<String, dynamic> toJson() {
    final indexes = completedChunkIndexes.toList()..sort();
    return {'sourceSha256': sourceSha256, 'completedChunkIndexes': indexes};
  }
}

class TranscriptionResumeStore {
  const TranscriptionResumeStore({required SharedPreferences preferences})
    : _preferences = preferences;

  static const _prefix = 'transcription_resume_v1';

  final SharedPreferences _preferences;

  TranscriptionResumeCheckpoint? read(String sourceSha256) {
    final value = _preferences.getString(_key(sourceSha256));
    if (value == null) {
      return null;
    }

    try {
      return TranscriptionResumeCheckpoint.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } on FormatException {
      clear(sourceSha256);
      return null;
    }
  }

  Future<void> markCompleted(String sourceSha256, int chunkIndex) async {
    final current =
        read(sourceSha256) ??
        TranscriptionResumeCheckpoint(
          sourceSha256: sourceSha256,
          completedChunkIndexes: const {},
        );
    await _preferences.setString(
      _key(sourceSha256),
      jsonEncode(current.markCompleted(chunkIndex).toJson()),
    );
  }

  Future<void> clear(String sourceSha256) {
    return _preferences.remove(_key(sourceSha256));
  }

  String _key(String sourceSha256) => '$_prefix:$sourceSha256';
}
