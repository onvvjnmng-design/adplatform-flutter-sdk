import 'dart:io';
import 'package:flutter/foundation.dart';
import 'services/ad_api_service.dart';

/// AdNova SDK main class
///
/// Initialize in your main function:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AdNova.initialize('YOUR_SDK_KEY');
///   runApp(MyApp());
/// }
/// ```
class AdNova {
  static String? _sdkKey;
  static String _baseUrl =
      'http://10.0.2.2:3000'; // Default for Android emulator
  static bool _isInitialized = false;
  static AdApiService? _apiService;

  /// SDK Key
  static String? get sdkKey => _sdkKey;

  /// Base URL for API
  static String get baseUrl => _baseUrl;

  /// API Service instance
  static AdApiService? get apiService => _apiService;

  /// Check if SDK is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize the AdNova SDK
  ///
  /// [sdkKey] - Your SDK key from the AdNova dashboard
  /// [baseUrl] - Optional custom API base URL
  static Future<void> initialize(String sdkKey, {String? baseUrl}) async {
    if (_isInitialized) {
      debugPrint('AdNova SDK already initialized');
      return;
    }

    if (sdkKey.isEmpty) {
      throw ArgumentError('SDK key cannot be empty');
    }

    _sdkKey = sdkKey;

    // Set base URL based on platform
    if (baseUrl != null) {
      _baseUrl = baseUrl;
    } else if (!kIsWeb) {
      // For mobile platforms in debug mode
      if (Platform.isAndroid) {
        _baseUrl = 'http://10.0.2.2:3000'; // Android emulator localhost
      } else if (Platform.isIOS) {
        _baseUrl = 'http://localhost:3000'; // iOS simulator localhost
      }
    }

    _apiService = AdApiService(_baseUrl, sdkKey);
    _isInitialized = true;

    debugPrint('AdNova SDK initialized successfully');
  }

  /// Set custom base URL for the API
  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    _apiService?.updateBaseUrl(_baseUrl);
  }

  /// Get SDK version
  static String get version => '1.0.0';

  /// Ensure SDK is initialized before use
  static void ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'AdNova SDK not initialized. Call AdNova.initialize() first.',
      );
    }
  }
}

