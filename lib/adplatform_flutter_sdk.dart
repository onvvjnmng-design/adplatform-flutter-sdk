/// AdPlatform Flutter SDK
///
/// Complete SDK for displaying ads in Flutter apps.
///
/// ## Getting Started
///
/// Initialize the SDK:
/// ```dart
/// import 'package:adplatform_flutter_sdk/adplatform_flutter_sdk.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AdPlatform.initialize(
///     sdkKey: 'your_sdk_key',
///     appId: 'your_app_id',
///   );
///   runApp(MyApp());
/// }
/// ```
///
/// ## Ad Types
///
/// ### Banner Ad
/// ```dart
/// BannerAdWidget(
///   onAdLoaded: () => print('Loaded'),
///   onAdClicked: () => print('Clicked'),
/// )
/// ```
///
/// ### Interstitial Ad
/// ```dart
/// final interstitial = InterstitialAd(
///   onAdLoaded: () => print('Loaded'),
///   onAdClosed: () => print('Closed'),
/// );
/// await interstitial.load();
/// interstitial.show(context);
/// ```
///
/// ### Rewarded Ad
/// ```dart
/// final rewarded = RewardedAd(
///   onRewarded: (reward) => print('Got ${reward.amount}'),
/// );
/// await rewarded.load();
/// rewarded.show(context);
/// ```
///
/// ### Native Ad
/// ```dart
/// final loader = NativeAdLoader(
///   onAdLoaded: (ad) => setState(() => _ad = ad),
/// );
/// loader.loadAd();
/// // Then display with:
/// NativeAdView(ad: _ad)
/// ```
library adplatform_flutter_sdk;

// Core
export 'src/adplatform.dart';

// Models
export 'src/models/ad.dart';

// Services
export 'src/services/ad_api_service.dart';

// Listeners
export 'src/listeners/ad_listener.dart';

// Widgets
export 'src/widgets/banner_ad_widget.dart';

// Ads
export 'src/ads/interstitial_ad.dart';
export 'src/ads/rewarded_ad.dart';
export 'src/ads/native_ad.dart';
