/// Client-side subscription receipt state.
enum ReceiptValidationStatus { valid, expired, invalidProduct, invalidPurchase }

/// Minimal Play Billing receipt fields needed for local premium gating.
class PlayReceipt {
  const PlayReceipt({
    required this.productId,
    required this.purchaseToken,
    required this.purchasedAt,
    required this.expiresAt,
    this.isAcknowledged = false,
    this.isAutoRenewing = false,
  });

  final String productId;
  final String purchaseToken;
  final DateTime purchasedAt;
  final DateTime expiresAt;
  final bool isAcknowledged;
  final bool isAutoRenewing;
}

/// Result of validating a purchase receipt on-device.
class ReceiptValidationResult {
  const ReceiptValidationResult({
    required this.status,
    required this.isPremiumActive,
  });

  final ReceiptValidationStatus status;
  final bool isPremiumActive;
}

/// Performs local receipt sanity checks before premium features are enabled.
class ClientReceiptValidator {
  const ClientReceiptValidator({
    this.allowedProductIds = const {'langgeng_pro_monthly'},
  });

  final Set<String> allowedProductIds;

  /// Returns whether [receipt] is structurally valid and currently active.
  ReceiptValidationResult validate(
    PlayReceipt receipt, {
    required DateTime now,
  }) {
    if (!allowedProductIds.contains(receipt.productId)) {
      return const ReceiptValidationResult(
        status: ReceiptValidationStatus.invalidProduct,
        isPremiumActive: false,
      );
    }

    if (receipt.purchaseToken.trim().isEmpty ||
        receipt.expiresAt.isBefore(receipt.purchasedAt)) {
      return const ReceiptValidationResult(
        status: ReceiptValidationStatus.invalidPurchase,
        isPremiumActive: false,
      );
    }

    if (!receipt.expiresAt.isAfter(now)) {
      return const ReceiptValidationResult(
        status: ReceiptValidationStatus.expired,
        isPremiumActive: false,
      );
    }

    return const ReceiptValidationResult(
      status: ReceiptValidationStatus.valid,
      isPremiumActive: true,
    );
  }
}
