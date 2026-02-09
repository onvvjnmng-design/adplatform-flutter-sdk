# AdNova Flutter SDK

[![pub package](https://img.shields.io/pub/v/adnova_flutter_sdk.svg)](https://pub.dev/packages/adnova_flutter_sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

مكتبة إعلانات لتطبيقات Flutter - تدعم Banner, Interstitial, Rewarded و Native Ads

## التثبيت

### من pub.dev (الطريقة الموصى بها)

```yaml
dependencies:
  adnova_flutter_sdk: ^1.0.2
```

### أو من Git

```yaml
dependencies:
  adnova_flutter_sdk:
    git:
      url: https://github.com/onvvjnmng-design/adplatform-flutter-sdk.git
      ref: v1.0.2
```

ثم نفذ:

```bash
flutter pub get
```

## الإعلانات التجريبية (Test Ads)

استخدم هذه المعرفات أثناء التطوير:

| النوع | Test Ad Unit ID |
|-------|-----------------|
| **SDK Key** | `test-sdk-key-adnova-000` |
| Banner | `test-banner-adnova-000` |
| Interstitial | `test-interstitial-adnova-000` |
| Rewarded | `test-rewarded-adnova-000` |
| Native | `test-native-adnova-000` |

> ⚠️ استبدل Test IDs بمعرفات حقيقية من لوحة التحكم قبل النشر!

## الاستخدام

### التهيئة

```dart
import 'package:adnova_flutter_sdk/adnova_flutter_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // للاختبار
  await AdNova.initialize('test-sdk-key-adnova-000');
  
  // للإنتاج
  // await AdNova.initialize('YOUR_REAL_SDK_KEY');
  
  runApp(MyApp());
}
```

### إعلان البانر

```dart
BannerAdWidget(
  onAdLoaded: () => print('Banner loaded'),
  onAdFailed: (error) => print('Failed: $error'),
  onAdClicked: () => print('Clicked'),
)
```

### الإعلان البيني

```dart
final interstitialAd = InterstitialAd();
await interstitialAd.load();
interstitialAd.show();
```

### إعلان المكافأة

```dart
final rewardedAd = RewardedAd();
await rewardedAd.load();
rewardedAd.onUserEarnedReward = (amount, type) {
  // Give reward
};
rewardedAd.show();
```

## الدعم

- الموقع: [adnova.bbs.tr](https://adnova.bbs.tr)
- البريد: support@adnova.bbs.tr

## الترخيص

MIT License

