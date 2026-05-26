import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/transcription/source_fingerprint.dart';
import 'package:langgeng_clip/features/transcription/transcript_cache.dart';
import 'package:langgeng_clip/features/transcription/transcription_provider.dart';
import 'package:langgeng_clip/features/transcription/transcription_resume_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('source fingerprint returns sha256 for file bytes', () async {
    final file = File('${Directory.systemTemp.path}/langgeng_sha_test.txt');
    await file.writeAsString('langgeng');
    addTearDown(() async {
      if (file.existsSync()) {
        await file.delete();
      }
    });

    final hash = await const SourceFingerprint().sha256ForFile(file.path);

    expect(
      hash,
      '14e39e6dca15dc125f0e6f5af3fc0e8ffb0c33e23ddf97bae94c1853126cae4b',
    );
  });

  test('transcript cache stores transcript by source hash', () async {
    final cache = TranscriptCache(
      preferences: await SharedPreferences.getInstance(),
    );
    const transcript = Transcript(
      text: 'hello world',
      language: 'en',
      durationSeconds: 1.5,
      words: [
        TranscriptWord(text: 'hello', startMillis: 0, endMillis: 500),
        TranscriptWord(text: 'world', startMillis: 700, endMillis: 1500),
      ],
    );

    await cache.write('source-hash', transcript);
    final cached = cache.read('source-hash');

    expect(cached?.text, 'hello world');
    expect(cached?.language, 'en');
    expect(cached?.durationSeconds, 1.5);
    expect(cached?.words.last.text, 'world');
    expect(cached?.words.last.endMillis, 1500);
  });

  test('resume store tracks completed chunk transcripts', () async {
    final store = TranscriptionResumeStore(
      preferences: await SharedPreferences.getInstance(),
    );
    const transcript = Transcript(
      text: 'chunk text',
      words: [TranscriptWord(text: 'chunk', startMillis: 0, endMillis: 500)],
    );

    await store.markCompleted('source-hash', 2, transcript: transcript);
    await store.markCompleted('source-hash', 0);
    await store.markCompleted('source-hash', 2);
    final checkpoint = store.read('source-hash');

    expect(checkpoint?.sourceSha256, 'source-hash');
    expect(checkpoint?.completedChunkIndexes, {0, 2});
    expect(checkpoint?.chunkTranscripts[2]?.text, 'chunk text');
    expect(checkpoint?.chunkTranscripts[2]?.words.single.endMillis, 500);
    expect(checkpoint?.toJson()['completedChunkIndexes'], [0, 2]);
  });
}
