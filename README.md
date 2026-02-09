# AdPlatform Flutter SDK

مكتبة إعلانات لتطبيقات Flutter

## التثبيت

أضف المكتبة في `pubspec.yaml`:

```yaml
dependencies:
  adplatform_flutter_sdk: ^1.0.0
```

أو من Git:

```yaml
dependencies:
  adplatform_flutter_sdk:
    git:
      url: https://github.com/adplatform/flutter-sdk.git
      ref: v1.0.0
```

ثم نفذ:

```bash
flutter pub get
```

## الاستخدام

### التهيئة

```dart
import 'package:adplatform_flutter_sdk/adplatform_flutter_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AdPlatform.initialize('YOUR_SDK_KEY');
  
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

## الترخيص

MIT License
