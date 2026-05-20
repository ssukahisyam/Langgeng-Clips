import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/library/export_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.langgeng.clip/export_actions');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('share calls native share method', () async {
    var called = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'share');
          expect(call.arguments, {
            'uri': 'content://media/video/1',
            'title': 'Clip 1',
          });
          called = true;
          return null;
        });

    await const ExportActions().share(
      uri: 'content://media/video/1',
      title: 'Clip 1',
    );

    expect(called, isTrue);
  });
}
