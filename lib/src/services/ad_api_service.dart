import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/ad.dart';

/// API service for AdPlatform
class AdApiService {
  String _baseUrl;
  final String _sdkKey;
  final http.Client _client = http.Client();

  AdApiService(this._baseUrl, this._sdkKey);

  void updateBaseUrl(String url) {
    _baseUrl = url;
  }

  /// Request an ad from the server
  Future<Ad?> requestAd(String adType) async {
    try {
      final deviceInfo = await _getDeviceInfo();

      final request = AdRequest(
        sdkKey: _sdkKey,
        adType: adType,
        deviceInfo: deviceInfo,
      );

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/sdk/ad'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final adResponse = AdResponse.fromJson(data);

        if (adResponse.success && adResponse.ad != null) {
          return adResponse.ad;
        }
      }

      return null;
    } catch (e) {
      debugPrint('AdPlatform: Error requesting ad: $e');
      return null;
    }
  }

  /// Track ad click
  Future<bool> trackClick(int adId, int impressionId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/sdk/click'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sdk_key': _sdkKey,
          'ad_id': adId,
          'impression_id': impressionId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('AdPlatform: Error tracking click: $e');
      return false;
    }
  }

  Future<DeviceInfo> _getDeviceInfo() async {
    String os = 'unknown';
    String osVersion = '';
    String deviceModel = '';

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        os = 'android';
        osVersion = Platform.operatingSystemVersion;
      } else if (Platform.isIOS) {
        os = 'ios';
        osVersion = Platform.operatingSystemVersion;
      }
      // Note: Getting device model requires platform channels
      // For simplicity, we'll use a generic value
      deviceModel = Platform.localHostname;
    }

    // Get screen dimensions
    final window = WidgetsBinding.instance.window;
    final screenWidth = window.physicalSize.width ~/ window.devicePixelRatio;
    final screenHeight = window.physicalSize.height ~/ window.devicePixelRatio;

    // Get locale
    final locale = PlatformDispatcher.instance.locale;

    return DeviceInfo(
      os: os,
      osVersion: osVersion,
      deviceModel: deviceModel,
      screenWidth: screenWidth.toInt(),
      screenHeight: screenHeight.toInt(),
      language: locale.languageCode,
      country: locale.countryCode ?? '',
    );
  }

  void dispose() {
    _client.close();
  }
}
