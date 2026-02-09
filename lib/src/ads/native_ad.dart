import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../AdNova.dart';
import '../models/ad.dart';
import '../listeners/ad_listener.dart';

/// Native Ad - Customizable ad component
///
/// Load native ad:
/// ```dart
/// final nativeAdLoader = NativeAdLoader(
///   onAdLoaded: (ad) => setState(() => _nativeAd = ad),
///   onAdFailed: (error) => print('Failed: $error'),
/// );
///
/// nativeAdLoader.loadAd();
/// ```
///
/// Display with NativeAdView widget:
/// ```dart
/// if (_nativeAd != null) {
///   NativeAdView(
///     ad: _nativeAd!,
///     onAdClicked: () => print('Clicked'),
///   )
/// }
/// ```
class NativeAdLoader {
  final NativeAdLoadedCallback? onAdLoaded;
  final AdFailedCallback? onAdFailed;

  bool _isLoading = false;

  NativeAdLoader({this.onAdLoaded, this.onAdFailed});

  bool get isLoading => _isLoading;

  /// Load a native ad
  Future<void> loadAd() async {
    if (_isLoading) return;

    try {
      AdNova.ensureInitialized();
    } catch (e) {
      onAdFailed?.call(e.toString());
      return;
    }

    _isLoading = true;

    try {
      final ad = await AdNova.apiService?.requestAd('native');

      if (ad != null) {
        onAdLoaded?.call(ad);
      } else {
        onAdFailed?.call('No ad available');
      }
    } catch (e) {
      onAdFailed?.call(e.toString());
    } finally {
      _isLoading = false;
    }
  }
}

/// Native Ad View Widget
///
/// A customizable widget to display native ads
class NativeAdView extends StatelessWidget {
  final Ad ad;
  final AdClickedCallback? onAdClicked;
  final NativeAdStyle style;

  const NativeAdView({
    super.key,
    required this.ad,
    this.onAdClicked,
    this.style = NativeAdStyle.medium,
  });

  Future<void> _handleClick(BuildContext context) async {
    onAdClicked?.call();

    // Track click
    if (ad.impressionId != null) {
      AdNova.apiService?.trackClick(ad.id, ad.impressionId!);
    }

    // Open URL
    final uri = Uri.tryParse(ad.targetUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case NativeAdStyle.small:
        return _buildSmallAd(context);
      case NativeAdStyle.medium:
        return _buildMediumAd(context);
      case NativeAdStyle.large:
        return _buildLargeAd(context);
    }
  }

  Widget _buildSmallAd(BuildContext context) {
    return InkWell(
      onTap: () => _handleClick(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon/Image
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: ad.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(width: 50, height: 50, color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 24),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ad.description != null)
                    Text(
                      ad.description!,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Ad label
            _buildAdLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumAd(BuildContext context) {
    return InkWell(
      onTap: () => _handleClick(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: ad.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 48),
                    ),
                  ),
                ),

                // Ad label
                Positioned(top: 8, right: 8, child: _buildAdLabel()),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (ad.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      ad.description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  if (ad.ctaText != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleClick(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(ad.ctaText!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeAd(BuildContext context) {
    return InkWell(
      onTap: () => _handleClick(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: ad.imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 64),
                    ),
                  ),
                ),

                // Ad label
                Positioned(top: 12, right: 12, child: _buildAdLabel()),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Advertiser name (if available)
                  if (ad.advertiserName != null) ...[
                    Text(
                      ad.advertiserName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (ad.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      ad.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  if (ad.ctaText != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleClick(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          ad.ctaText!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Ad',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Native Ad Display Styles
enum NativeAdStyle {
  /// Small horizontal ad (50px height)
  small,

  /// Medium card-style ad (image + text + CTA)
  medium,

  /// Large full-width ad (big image + detailed text + CTA)
  large,
}

