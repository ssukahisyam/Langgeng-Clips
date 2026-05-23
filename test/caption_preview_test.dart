import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/subtitle/caption_document.dart';
import 'package:langgeng_clip/features/subtitle/caption_preview.dart';

void main() {
  testWidgets('caption preview renders first caption text', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: CaptionPreview(
          document: CaptionDocument(
            items: [
              CaptionItem(
                id: '1',
                text: 'Preview text',
                startMillis: 0,
                endMillis: 1000,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Preview text'), findsOneWidget);
  });
}
