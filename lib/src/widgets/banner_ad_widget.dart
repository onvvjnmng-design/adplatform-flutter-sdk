import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../adplatform.dart';
import '../models/ad.dart';
import '../listeners/ad_listener.dart';

/// Banner Ad Widget
///
/// Add to your layout:
/// ```dart
/// BannerAdWidget(
///   onAdLoaded: () => print('Loaded'),
///   onAdFailed: (error) => print('Failed: $error'),
///   onAdClicked: () => print('Clicked'),
/// )
/// ```
class BannerAdWidget extends StatefulWidget {
  final AdLoadedCallback? onAdLoaded;
  final AdFailedCallback? onAdFailed;
  final AdClickedCallback? onAdClicked;
  final AdShownCallback? onAdShown;
  final bool autoRefresh;
  final Duration refreshInterval;

  const BannerAdWidget({
    super.key,
    this.onAdLoaded,
    this.onAdFailed,
    this.onAdClicked,
    this.onAdShown,
    this.autoRefresh = true,
    this.refreshInterval = const Duration(seconds: 60),
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  Ad? _currentAd;
  bool _isLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAd() async {
    if (_isLoading) return;

    try {
      AdNova.ensureInitialized();
    } catch (e) {
      widget.onAdFailed?.call(e.toString());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ad = await AdNova.apiService?.requestAd('banner');

      if (mounted) {
        setState(() {
          _currentAd = ad;
          _isLoading = false;
        });

        if (ad != null) {
          widget.onAdLoaded?.call();
          widget.onAdShown?.call();
          _startAutoRefresh();
        } else {
          widget.onAdFailed?.call('No ad available');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onAdFailed?.call(e.toString());
      }
    }
  }

  void _startAutoRefresh() {
    if (!widget.autoRefresh) return;

    _refreshTimer?.cancel();
    _refreshTimer = Timer(widget.refreshInterval, _loadAd);
  }

  Future<void> _handleClick() async {
    final ad = _currentAd;
    if (ad == null) return;

    widget.onAdClicked?.call();

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
    if (_currentAd == null) {
      return const SizedBox.shrink();
    }

    final ad = _currentAd!;

    return Material(
      elevation: 4,
      child: InkWell(
        onTap: _handleClick,
        child: Container(
          padding: const EdgeInsets.all(4),
          color: Colors.white,
          child: Row(
            children: [
              // Ad Image
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: ad.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(width: 80, height: 80, color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Ad Title
              Expanded(
                child: Text(
                  ad.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Ad Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  'Ad',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
