import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/help/error_message_catalog.dart';
import 'package:langgeng_clip/features/monetization/free_tier_limits.dart';
import 'package:langgeng_clip/features/monetization/free_tier_watermark.dart';
import 'package:langgeng_clip/features/monetization/premium_locks.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('free tier allows three exports per WIB day', () async {
    final preferences = await SharedPreferences.getInstance();
    final counter = DailyExportCounter(
      preferences: preferences,
      now: () => DateTime.utc(2026, 5, 22, 18),
    );
    const limits = FreeTierLimits();

    expect(limits.canExport(counter.readCount()), isTrue);
    await counter.increment();
    await counter.increment();
    await counter.increment();

    expect(counter.readCount(), 3);
    expect(limits.canExport(counter.readCount()), isFalse);
    expect(limits.remainingExports(counter.readCount()), 0);
  });

  test('rewarded ad grants extra export credit', () {
    expect(const RewardedExportCredit().apply(0), 1);
  });

  test('free tier watermark is applied only for non-premium users', () {
    expect(
      const FreeTierWatermark().apply(isPremium: false).text,
      'Made with Langgeng Clip',
    );
    expect(const FreeTierWatermark().apply(isPremium: true).text, isNull);
  });

  test('premium template lock gates configured templates', () {
    const lock = PremiumTemplateLock();

    expect(lock.isLocked('gaming', isPremium: false), isTrue);
    expect(lock.isLocked('gaming', isPremium: true), isFalse);
    expect(lock.isLocked('podcast', isPremium: false), isFalse);
  });

  test('error catalog exposes normalized user messages', () {
    expect(
      ErrorMessageCatalog.messages['export_failed'],
      'Export gagal. Coba ulangi.',
    );
  });
}
