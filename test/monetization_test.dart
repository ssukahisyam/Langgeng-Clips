import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/help/error_message_catalog.dart';
import 'package:langgeng_clip/features/monetization/free_tier_limits.dart';
import 'package:langgeng_clip/features/monetization/free_tier_watermark.dart';
import 'package:langgeng_clip/features/monetization/premium_locks.dart';
import 'package:langgeng_clip/features/monetization/receipt_validator.dart';
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

  test('first-week promo grants unlimited messaging window', () {
    const promo = FirstWeekUnlimitedPromo();
    final firstSeenAt = DateTime.utc(2026, 5, 1, 12);

    expect(
      promo.isActive(
        firstSeenAt: firstSeenAt,
        now: DateTime.utc(2026, 5, 8, 11, 59),
      ),
      isTrue,
    );
    expect(
      promo.isActive(
        firstSeenAt: firstSeenAt,
        now: DateTime.utc(2026, 5, 8, 12),
      ),
      isFalse,
    );
    expect(
      promo.exportLimitLabel(isActive: true),
      'Unlimited export minggu pertama',
    );
    expect(promo.exportLimitLabel(isActive: false), '3 export per hari');
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

  test('client receipt validator accepts active subscription receipt', () {
    const validator = ClientReceiptValidator();
    final result = validator.validate(
      PlayReceipt(
        productId: 'langgeng_pro_monthly',
        purchaseToken: 'token-123',
        purchasedAt: DateTime.utc(2026, 5),
        expiresAt: DateTime.utc(2026, 6),
        isAcknowledged: true,
        isAutoRenewing: true,
      ),
      now: DateTime.utc(2026, 5, 23),
    );

    expect(result.status, ReceiptValidationStatus.valid);
    expect(result.isPremiumActive, isTrue);
  });

  test('client receipt validator rejects expired and invalid receipts', () {
    const validator = ClientReceiptValidator();

    expect(
      validator
          .validate(
            PlayReceipt(
              productId: 'langgeng_pro_monthly',
              purchaseToken: 'token-123',
              purchasedAt: DateTime.utc(2026, 5),
              expiresAt: DateTime.utc(2026, 5, 2),
            ),
            now: DateTime.utc(2026, 5, 3),
          )
          .status,
      ReceiptValidationStatus.expired,
    );
    expect(
      validator
          .validate(
            PlayReceipt(
              productId: 'unknown_product',
              purchaseToken: 'token-123',
              purchasedAt: DateTime.utc(2026, 5),
              expiresAt: DateTime.utc(2026, 6),
            ),
            now: DateTime.utc(2026, 5, 3),
          )
          .status,
      ReceiptValidationStatus.invalidProduct,
    );
    expect(
      validator
          .validate(
            PlayReceipt(
              productId: 'langgeng_pro_monthly',
              purchaseToken: ' ',
              purchasedAt: DateTime.utc(2026, 5),
              expiresAt: DateTime.utc(2026, 6),
            ),
            now: DateTime.utc(2026, 5, 3),
          )
          .status,
      ReceiptValidationStatus.invalidPurchase,
    );
  });

  test('error catalog exposes normalized user messages', () {
    expect(
      ErrorMessageCatalog.messages['export_failed'],
      'Export gagal. Coba ulangi.',
    );
  });
}
