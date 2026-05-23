import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/transcription/retrying_transcription_provider.dart';
import 'package:langgeng_clip/features/transcription/transcription_provider.dart';

void main() {
  final chunk = TranscriptionChunk(
    bytes: Uint8List(1),
    fileName: 'chunk.wav',
    mimeType: 'audio/wav',
    startOffsetMillis: 0,
  );

  test('retries with exponential backoff before succeeding', () async {
    final delays = <Duration>[];
    final provider = RetryingTranscriptionProvider(
      delegate: _FlakyTranscriptionProvider(failuresBeforeSuccess: 2),
      initialDelay: const Duration(milliseconds: 100),
      delay: (duration) async => delays.add(duration),
    );

    final transcript = await provider.transcribeChunk(chunk);

    expect(transcript.text, 'ok');
    expect(delays, [
      const Duration(milliseconds: 100),
      const Duration(milliseconds: 200),
    ]);
  });

  test('throws final error after max attempts', () async {
    final provider = RetryingTranscriptionProvider(
      delegate: _FlakyTranscriptionProvider(failuresBeforeSuccess: 5),
      maxAttempts: 2,
      delay: (duration) async {},
    );

    await expectLater(
      provider.transcribeChunk(chunk),
      throwsA(isA<TranscriptionException>()),
    );
  });
}

class _FlakyTranscriptionProvider implements TranscriptionProvider {
  _FlakyTranscriptionProvider({required this.failuresBeforeSuccess});

  final int failuresBeforeSuccess;
  int attempts = 0;

  @override
  Future<Transcript> transcribeChunk(TranscriptionChunk chunk) async {
    attempts += 1;
    if (attempts <= failuresBeforeSuccess) {
      throw const TranscriptionException('temporary failure');
    }

    return const Transcript(text: 'ok', words: []);
  }
}
