import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/core/observability/analytics_events.dart';

void main() {
  test('analytics event names are unique', () {
    final names = AnalyticsEvents.all.map((event) => event.name).toSet();

    expect(names.length, AnalyticsEvents.all.length);
  });

  test('analytics schema excludes known PII and secret fields', () {
    const forbiddenFragments = {
      'api_key',
      'key_prefix',
      'authorization',
      'bearer',
      'path',
      'uri',
      'transcript',
      'content',
    };

    for (final event in AnalyticsEvents.all) {
      for (final property in event.requiredProperties) {
        for (final forbidden in forbiddenFragments) {
          expect(
            property,
            isNot(contains(forbidden)),
            reason: '${event.name} must not expose $forbidden',
          );
        }
      }
    }
  });
}
