# AdNova Flutter SDK

مكتبة إعلانات لتطبيقات Flutter

## التثبيت

أضف المكتبة في `pubspec.yaml`:

```yaml
dependencies:
  adnova_flutter_sdk:
    git:
      url: https://github.com/onvvjnmng-design/adplatform-flutter-sdk.git
      ref: v1.0.1
```

ثم نفذ:

```bash
flutter pub get
```

## الاستخدام

### التهيئة

```dart
import 'package:adnova_flutter_sdk/adnova_flutter_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AdNova.initialize('YOUR_SDK_KEY');
  
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

