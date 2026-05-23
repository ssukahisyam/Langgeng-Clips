import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/subtitle/caption_segmenter.dart';
import 'package:langgeng_clip/features/transcription/transcription_provider.dart';

void main() {
  test('creates word-aware caption segments', () {
    final segments =
        const CaptionSegmenter(
          maxCharactersPerLine: 16,
          maxWordsPerSegment: 4,
        ).segment(
          const Transcript(
            text: 'hello world this is clipped',
            words: [
              TranscriptWord(text: 'hello', startMillis: 0, endMillis: 200),
              TranscriptWord(text: 'world', startMillis: 250, endMillis: 500),
              TranscriptWord(text: 'this', startMillis: 550, endMillis: 700),
              TranscriptWord(text: 'is', startMillis: 750, endMillis: 850),
              TranscriptWord(
                text: 'clipped',
                startMillis: 900,
                endMillis: 1200,
              ),
            ],
          ),
        );

    expect(segments, hasLength(2));
    expect(segments.first.text, 'hello world this');
    expect(segments.first.startMillis, 0);
    expect(segments.first.endMillis, 700);
    expect(segments.last.text, 'is clipped');
  });

  test('handles emoji Indonesian and English mix', () {
    final segments = const CaptionSegmenter(maxCharactersPerLine: 24).segment(
      const Transcript(
        text: 'aku suka this clip 🔥 banget',
        words: [
          TranscriptWord(text: 'aku', startMillis: 0, endMillis: 100),
          TranscriptWord(text: 'suka', startMillis: 120, endMillis: 220),
          TranscriptWord(text: 'this', startMillis: 240, endMillis: 340),
          TranscriptWord(text: 'clip', startMillis: 360, endMillis: 460),
          TranscriptWord(text: '🔥', startMillis: 480, endMillis: 520),
          TranscriptWord(text: 'banget', startMillis: 540, endMillis: 700),
        ],
      ),
    );

    expect(
      segments.map((segment) => segment.text).join(' '),
      'aku suka this clip 🔥 banget',
    );
  });
}
