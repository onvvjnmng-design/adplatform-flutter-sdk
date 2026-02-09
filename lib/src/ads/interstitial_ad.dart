import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../adplatform.dart';
import '../models/ad.dart';
import '../listeners/ad_listener.dart';

/// Interstitial Ad - Full screen ad
///
/// Usage:
/// ```dart
/// final interstitial = InterstitialAd(
///   onAdLoaded: () => print('Loaded'),
///   onAdFailed: (error) => print('Failed'),
///   onAdClosed: () => print('Closed'),
/// );
///
/// await interstitial.load();
/// if (interstitial.isLoaded) {
///   interstitial.show(context);
/// }
/// ```
class InterstitialAd {
  Ad? _ad;
  bool _isLoaded = false;
  bool _isLoading = false;

  final AdLoadedCallback? onAdLoaded;
  final AdFailedCallback? onAdFailed;
  final AdClickedCallback? onAdClicked;
  final AdClosedCallback? onAdClosed;

  InterstitialAd({
    this.onAdLoaded,
    this.onAdFailed,
    this.onAdClicked,
    this.onAdClosed,
  });

  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;

  /// Load the interstitial ad
  Future<void> load() async {
    if (_isLoading) return;

    try {
      AdPlatform.ensureInitialized();
    } catch (e) {
      onAdFailed?.call(e.toString());
      return;
    }

    _isLoading = true;

    try {
      final ad = await AdPlatform.apiService?.requestAd('interstitial');

      if (ad != null) {
        _ad = ad;
        _isLoaded = true;
        onAdLoaded?.call();
      } else {
        onAdFailed?.call('No ad available');
      }
    } catch (e) {
      onAdFailed?.call(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Show the interstitial ad
  void show(BuildContext context) {
    if (!_isLoaded || _ad == null) {
      onAdFailed?.call('Ad not loaded');
      return;
    }

    _isLoaded = false;
    final ad = _ad!;
    _ad = null;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _InterstitialAdDialog(
          ad: ad,
          onAdClicked: onAdClicked,
          onAdClosed: onAdClosed,
        );
      },
    );
  }
}

class _InterstitialAdDialog extends StatefulWidget {
  final Ad ad;
  final AdClickedCallback? onAdClicked;
  final AdClosedCallback? onAdClosed;

  const _InterstitialAdDialog({
    required this.ad,
    this.onAdClicked,
    this.onAdClosed,
  });

  @override
  State<_InterstitialAdDialog> createState() => _InterstitialAdDialogState();
}

class _InterstitialAdDialogState extends State<_InterstitialAdDialog> {
  int _countdown = 5;
  Timer? _countdownTimer;
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _canClose = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleClick() async {
    widget.onAdClicked?.call();

    // Track click
    if (widget.ad.impressionId != null) {
      AdPlatform.apiService?.trackClick(widget.ad.id, widget.ad.impressionId!);
    }

    // Open URL
    final uri = Uri.tryParse(widget.ad.targetUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _close() {
    if (!_canClose) return;
    widget.onAdClosed?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ad label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Advertisement',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),

                      // Close button
                      GestureDetector(
                        onTap: _close,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _canClose
                                ? Colors.grey[300]
                                : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _canClose
                                ? const Icon(Icons.close, size: 20)
                                : Text(
                                    '$_countdown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Ad content
                Flexible(
                  child: GestureDetector(
                    onTap: _handleClick,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: widget.ad.imageUrl,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 250,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 250,
                                color: Colors.grey[200],
                                child: const Icon(Icons.error, size: 48),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Title
                          Text(
                            widget.ad.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // Description
                          if (widget.ad.description != null)
                            Text(
                              widget.ad.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: 16),

                          // CTA Button
                          if (widget.ad.ctaText != null)
                            ElevatedButton(
                              onPressed: _handleClick,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(widget.ad.ctaText!),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
