import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows Langgeng Clip splash screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: LanggengClipApp()));

    expect(find.text('Langgeng Clip'), findsOneWidget);
    expect(find.text('clip smarter'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
  });
}
