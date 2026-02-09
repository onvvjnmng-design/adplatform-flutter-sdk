import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../adplatform.dart';
import '../models/ad.dart';
import '../listeners/ad_listener.dart';

/// Rewarded Ad - Full screen ad with reward
///
/// Usage:
/// ```dart
/// final rewarded = RewardedAd(
///   onAdLoaded: () => print('Loaded'),
///   onAdFailed: (error) => print('Failed'),
///   onRewarded: (reward) => print('Got reward: ${reward.amount} ${reward.type}'),
///   onAdClosed: () => print('Closed'),
/// );
///
/// await rewarded.load();
/// if (rewarded.isLoaded) {
///   rewarded.show(context);
/// }
/// ```
class RewardedAd {
  Ad? _ad;
  bool _isLoaded = false;
  bool _isLoading = false;

  final AdLoadedCallback? onAdLoaded;
  final AdFailedCallback? onAdFailed;
  final AdClickedCallback? onAdClicked;
  final AdClosedCallback? onAdClosed;
  final RewardedCallback? onRewarded;

  RewardedAd({
    this.onAdLoaded,
    this.onAdFailed,
    this.onAdClicked,
    this.onAdClosed,
    this.onRewarded,
  });

  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;

  /// Load the rewarded ad
  Future<void> load() async {
    if (_isLoading) return;

    try {
      AdNova.ensureInitialized();
    } catch (e) {
      onAdFailed?.call(e.toString());
      return;
    }

    _isLoading = true;

    try {
      final ad = await AdNova.apiService?.requestAd('rewarded');

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

  /// Show the rewarded ad
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
      barrierColor: Colors.black,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _RewardedAdDialog(
          ad: ad,
          onAdClicked: onAdClicked,
          onAdClosed: onAdClosed,
          onRewarded: onRewarded,
        );
      },
    );
  }
}

class _RewardedAdDialog extends StatefulWidget {
  final Ad ad;
  final AdClickedCallback? onAdClicked;
  final AdClosedCallback? onAdClosed;
  final RewardedCallback? onRewarded;

  const _RewardedAdDialog({
    required this.ad,
    this.onAdClicked,
    this.onAdClosed,
    this.onRewarded,
  });

  @override
  State<_RewardedAdDialog> createState() => _RewardedAdDialogState();
}

class _RewardedAdDialogState extends State<_RewardedAdDialog> {
  int _countdown = 30;
  Timer? _countdownTimer;
  bool _rewardEarned = false;
  bool _adComplete = false;

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
          _adComplete = true;
          _rewardEarned = true;
          timer.cancel();

          // Grant reward
          final reward = widget.ad.reward ?? Reward(type: 'coins', amount: 10);
          widget.onRewarded?.call(reward);
        }
      });
    });
  }

  Future<void> _handleClick() async {
    widget.onAdClicked?.call();

    // Track click
    if (widget.ad.impressionId != null) {
      AdNova.apiService?.trackClick(widget.ad.id, widget.ad.impressionId!);
    }

    // Open URL
    final uri = Uri.tryParse(widget.ad.targetUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _close() {
    if (!_adComplete) {
      // Show confirmation dialog if closing early
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Close Ad?'),
          content: const Text(
            'You will not receive your reward if you close now.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Watching'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onAdClosed?.call();
                Navigator.of(this.context).pop();
              },
              child: const Text('Close Anyway'),
            ),
          ],
        ),
      );
    } else {
      widget.onAdClosed?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.card_giftcard,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _rewardEarned
                                  ? 'Reward Earned!'
                                  : 'Watch to earn reward',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Timer/Close button
                  GestureDetector(
                    onTap: _close,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _adComplete ? Colors.white : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _adComplete
                            ? const Icon(Icons.close, color: Colors.black)
                            : Text(
                                '$_countdown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: (30 - _countdown) / 30,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),

            // Main content
            Expanded(
              child: GestureDetector(
                onTap: _handleClick,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: widget.ad.imageUrl,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 300,
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 300,
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.error,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          widget.ad.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Description
                        if (widget.ad.description != null)
                          Text(
                            widget.ad.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[300],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 24),

                        // CTA or Reward info
                        if (_rewardEarned)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+${widget.ad.reward?.amount ?? 10} ${widget.ad.reward?.type ?? 'coins'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (widget.ad.ctaText != null)
                          ElevatedButton(
                            onPressed: _handleClick,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                            ),
                            child: Text(widget.ad.ctaText!),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
