import 'dart:async';

import 'transcription_provider.dart';

typedef Delay = Future<void> Function(Duration duration);

class RetryingTranscriptionProvider implements TranscriptionProvider {
  const RetryingTranscriptionProvider({
    required TranscriptionProvider delegate,
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.delay = Future<void>.delayed,
  }) : _delegate = delegate;

  final TranscriptionProvider _delegate;
  final int maxAttempts;
  final Duration initialDelay;
  final Delay delay;

  @override
  Future<Transcript> transcribeChunk(TranscriptionChunk chunk) async {
    if (maxAttempts <= 0) {
      throw const TranscriptionException('Jumlah retry tidak valid.');
    }

    var attempt = 0;
    while (true) {
      attempt += 1;
      try {
        return await _delegate.transcribeChunk(chunk);
      } on TranscriptionException {
        if (attempt >= maxAttempts) {
          rethrow;
        }
        await delay(initialDelay * (1 << (attempt - 1)));
      }
    }
  }
}
