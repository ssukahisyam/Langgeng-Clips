import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/monetization/ad_placements.dart';

void main() {
  test('interstitial policy enforces three minute cooldown', () {
    const policy = AdPlacementPolicy();
    final now = DateTime(2026, 5, 23, 10);

    expect(policy.canShowInterstitial(null, now), isTrue);
    expect(
      policy.canShowInterstitial(now.subtract(const Duration(minutes: 2)), now),
      isFalse,
    );
    expect(
      policy.canShowInterstitial(now.subtract(const Duration(minutes: 3)), now),
      isTrue,
    );
  });

  test('debug ad unit IDs are configured', () {
    expect(DebugAdUnits.banner, contains('ca-app-pub-3940256099942544'));
    expect(DebugAdUnits.interstitial, contains('ca-app-pub-3940256099942544'));
    expect(DebugAdUnits.rewarded, contains('ca-app-pub-3940256099942544'));
  });
}
