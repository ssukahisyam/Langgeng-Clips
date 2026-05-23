import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/subtitle/caption_document.dart';

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
}
