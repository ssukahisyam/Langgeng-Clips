import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/app/app.dart';

void main() {
  testWidgets('shows Langgeng Clip splash screen', (tester) async {
    await tester.pumpWidget(const LanggengClipApp());

    expect(find.text('Langgeng Clip'), findsOneWidget);
    expect(find.text('clip smarter'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
  });
}
