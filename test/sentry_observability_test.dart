import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/core/observability/sentry_observability.dart';

void main() {
  test('sanitizeTelemetry redacts secrets and local paths', () {
    final sanitized = sanitizeTelemetry(
      'gsk_abc123 api_key=plain-key bearer: secret-token '
      'content://media/external/video/1 '
      'file:///storage/emulated/0/DCIM/input.mp4 '
      '/data/user/0/com.langgeng.clip/cache/output.mp4',
    );

    expect(sanitized, isNot(contains('gsk_abc123')));
    expect(sanitized, isNot(contains('secret-token')));
    expect(sanitized, isNot(contains('content://media')));
    expect(sanitized, isNot(contains('/storage/emulated')));
    expect(sanitized, isNot(contains('/data/user')));
    expect(sanitized, contains('[REDACTED_GROQ_KEY]'));
    expect(sanitized, contains('[REDACTED_SECRET]'));
    expect(sanitized, contains('[REDACTED_CONTENT_URI]'));
    expect(sanitized, contains('[REDACTED_FILE_URI]'));
    expect(sanitized, contains('[REDACTED_PATH]'));
  });
}
