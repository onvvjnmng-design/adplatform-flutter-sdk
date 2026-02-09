import '../models/ad.dart';

/// Listener for ad events
abstract class AdListener {
  /// Called when ad is loaded successfully
  void onAdLoaded();

  /// Called when ad fails to load
  void onAdFailed(String error);

  /// Called when ad is clicked
  void onAdClicked();

  /// Called when ad is shown
  void onAdShown() {}

  /// Called when ad is closed
  void onAdClosed() {}
}

/// Listener for rewarded ad events
abstract class RewardedAdListener extends AdListener {
  /// Called when user earns reward
  void onUserEarnedReward(int amount, String type);
}

/// Listener for native ad events
abstract class NativeAdListener {
  /// Called when native ad is loaded
  void onNativeAdLoaded(Ad ad);

  /// Called when ad fails to load
  void onAdFailed(String error);
}

/// Callback type definitions for simplified usage
typedef AdLoadedCallback = void Function();
typedef AdFailedCallback = void Function(String error);
typedef AdClickedCallback = void Function();
typedef AdShownCallback = void Function();
typedef AdClosedCallback = void Function();
typedef RewardEarnedCallback = void Function(int amount, String type);
typedef NativeAdLoadedCallback = void Function(Ad ad);
