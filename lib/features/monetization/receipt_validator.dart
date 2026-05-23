enum ReceiptValidationStatus { valid, expired, invalidProduct, invalidPurchase }

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

class ReceiptValidationResult {
  const ReceiptValidationResult({
    required this.status,
    required this.isPremiumActive,
  });

  final ReceiptValidationStatus status;
  final bool isPremiumActive;
}

class ClientReceiptValidator {
  const ClientReceiptValidator({
    this.allowedProductIds = const {'langgeng_pro_monthly'},
  });

  final Set<String> allowedProductIds;

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
