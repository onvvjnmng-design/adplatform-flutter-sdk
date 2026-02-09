/// Ad model class
class Ad {
  final int id;
  final int campaignId;
  final String title;
  final String? description;
  final String imageUrl;
  final String targetUrl;
  final String? callToAction;
  final String adType;
  final int? impressionId;

  Ad({
    required this.id,
    required this.campaignId,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.targetUrl,
    this.callToAction,
    required this.adType,
    this.impressionId,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'] as int,
      campaignId: json['campaign_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String,
      targetUrl: json['target_url'] as String,
      callToAction: json['call_to_action'] as String?,
      adType: json['ad_type'] as String,
      impressionId: json['impression_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'target_url': targetUrl,
      'call_to_action': callToAction,
      'ad_type': adType,
      'impression_id': impressionId,
    };
  }
}

/// Ad request model
class AdRequest {
  final String sdkKey;
  final String adType;
  final DeviceInfo deviceInfo;

  AdRequest({
    required this.sdkKey,
    required this.adType,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'sdk_key': sdkKey,
      'ad_type': adType,
      'device_info': deviceInfo.toJson(),
    };
  }
}

/// Device info model
class DeviceInfo {
  final String os;
  final String osVersion;
  final String deviceModel;
  final int screenWidth;
  final int screenHeight;
  final String language;
  final String country;

  DeviceInfo({
    required this.os,
    required this.osVersion,
    required this.deviceModel,
    required this.screenWidth,
    required this.screenHeight,
    required this.language,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'os': os,
      'os_version': osVersion,
      'device_model': deviceModel,
      'screen_width': screenWidth,
      'screen_height': screenHeight,
      'language': language,
      'country': country,
    };
  }
}

/// Ad response model
class AdResponse {
  final bool success;
  final Ad? ad;
  final String? message;

  AdResponse({required this.success, this.ad, this.message});

  factory AdResponse.fromJson(Map<String, dynamic> json) {
    return AdResponse(
      success: json['success'] as bool,
      ad: json['ad'] != null
          ? Ad.fromJson(json['ad'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}

/// Reward model
class Reward {
  final int amount;
  final String type;

  Reward({required this.amount, required this.type});
}
