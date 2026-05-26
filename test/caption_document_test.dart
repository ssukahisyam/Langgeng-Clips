import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/subtitle/caption_document.dart';
import 'package:langgeng_clip/features/transcription/transcription_provider.dart';

void main() {
  test('updates caption text without changing timing', () {
    const document = CaptionDocument(
      items: [
        CaptionItem(id: '1', text: 'old', startMillis: 100, endMillis: 900),
      ],
    );

    final updated = document.updateText(id: '1', text: 'new');

    expect(updated.items.single.text, 'new');
    expect(updated.items.single.startMillis, 100);
    expect(updated.items.single.endMillis, 900);
  });

  test('updates timing only when range is valid', () {
    const document = CaptionDocument(
      items: [
        CaptionItem(id: '1', text: 'caption', startMillis: 100, endMillis: 900),
      ],
    );

    final updated = document.updateTiming(
      id: '1',
      startMillis: 200,
      endMillis: 1000,
    );
    final unchanged = updated.updateTiming(
      id: '1',
      startMillis: 1200,
      endMillis: 1100,
    );

    expect(updated.items.single.startMillis, 200);
    expect(updated.items.single.endMillis, 1000);
    expect(unchanged.items.single.startMillis, 200);
    expect(unchanged.items.single.endMillis, 1000);
  });

  test('style clamps caption size', () {
    final style = const CaptionStyleConfig().copyWith(size: 200);

    expect(style.size, 96);
  });

  test('builds caption document from transcript words', () {
    const transcript = Transcript(
      text: 'hello world from clip',
      words: [
        TranscriptWord(text: 'hello', startMillis: 0, endMillis: 400),
        TranscriptWord(text: 'world', startMillis: 500, endMillis: 900),
        TranscriptWord(text: 'from', startMillis: 1000, endMillis: 1300),
        TranscriptWord(text: 'clip', startMillis: 1400, endMillis: 1800),
      ],
    );

    final document = CaptionDocument.fromTranscript(transcript);

    expect(document.items, hasLength(1));
    expect(document.items.first.id, 'caption-1');
    expect(document.items.first.text, 'hello world from clip');
    expect(document.items.first.startMillis, 0);
    expect(document.items.first.endMillis, 1800);
  });

  test('round-trips caption document as json', () {
    const document = CaptionDocument(
      items: [
        CaptionItem(id: '1', text: 'caption', startMillis: 100, endMillis: 900),
      ],
      style: CaptionStyleConfig(
        fontFamily: 'Inter',
        size: 52,
        highlightColor: 0xFFF97316,
        position: CaptionPosition.topCenter,
        animation: CaptionAnimation.karaoke,
      ),
    );

    final restored = CaptionDocument.fromJson(document.toJson());

    expect(restored.items.single.text, 'caption');
    expect(restored.items.single.startMillis, 100);
    expect(restored.style.fontFamily, 'Inter');
    expect(restored.style.size, 52);
    expect(restored.style.highlightColor, 0xFFF97316);
    expect(restored.style.position, CaptionPosition.topCenter);
    expect(restored.style.animation, CaptionAnimation.karaoke);
  });
}
