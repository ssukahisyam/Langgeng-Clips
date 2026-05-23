import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/transcription/audio_chunker.dart';
import 'package:langgeng_clip/features/transcription/transcription_provider.dart';

void main() {
  test('returns no chunks for empty audio', () {
    expect(const AudioChunker().plan(0), isEmpty);
  });

  test('plans single chunk for audio shorter than ten minutes', () {
    final chunks = const AudioChunker().plan(90 * 1000);

    expect(chunks, hasLength(1));
    expect(chunks.single.index, 0);
    expect(chunks.single.startMillis, 0);
    expect(chunks.single.endMillis, 90 * 1000);
  });

  test('plans ten minute chunks with five second overlap', () {
    final chunks = const AudioChunker().plan(21 * 60 * 1000);

    expect(chunks, hasLength(3));
    expect(chunks[0].startMillis, 0);
    expect(chunks[0].endMillis, 600000);
    expect(chunks[1].startMillis, 595000);
    expect(chunks[1].endMillis, 1195000);
    expect(chunks[2].startMillis, 1190000);
    expect(chunks[2].endMillis, 1260000);
  });

  test('rejects overlap greater than chunk duration', () {
    expect(
      () => const AudioChunker(
        chunkDurationMillis: 1000,
        overlapMillis: 1000,
      ).plan(5000),
      throwsA(isA<AudioChunkerException>()),
    );
  });

  test('merges transcript words across overlapped chunks', () {
    final transcript = Transcript.mergeChunks([
      const Transcript(
        text: 'hello world',
        language: 'en',
        durationSeconds: 10,
        words: [
          TranscriptWord(text: 'hello', startMillis: 0, endMillis: 400),
          TranscriptWord(text: 'world', startMillis: 500, endMillis: 900),
        ],
      ),
      const Transcript(
        text: 'world again',
        language: 'en',
        durationSeconds: 12,
        words: [
          TranscriptWord(text: 'world', startMillis: 800, endMillis: 1100),
          TranscriptWord(text: 'again', startMillis: 1200, endMillis: 1500),
        ],
      ),
    ]);

    expect(transcript.text, 'hello world again');
    expect(transcript.words.map((word) => word.text), [
      'hello',
      'world',
      'again',
    ]);
  });
}
