import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';

class AdService {
  AdService();

  BannerAd? _bannerAd;
  bool _ready = false;

  RewardedAd? _rewardedAd;
  bool _rewardedLoading = false;

  BannerAd? get bannerAd => _ready ? _bannerAd : null;
  bool get isReady => _ready;
  bool get isRewardedReady => _rewardedAd != null;

  String get _bannerUnitId {
    if (kIsWeb) return AppConstants.androidBannerAdUnitId;
    if (Platform.isIOS) return AppConstants.iosBannerAdUnitId;
    return AppConstants.androidBannerAdUnitId;
  }

  String get _rewardedUnitId {
    if (kIsWeb) return AppConstants.androidRewardedAdUnitId;
    if (Platform.isIOS) return AppConstants.iosRewardedAdUnitId;
    return AppConstants.androidRewardedAdUnitId;
  }

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      // Warm the rewarded inventory so Game Over can show quickly.
      unawaited(preloadRewardedAd());
    } catch (_) {}
  }

  Future<void> loadBanner({
    required AdSize size,
    void Function()? onLoaded,
  }) async {
    if (kIsWeb) return;
    await _bannerAd?.dispose();
    _ready = false;
    _bannerAd = BannerAd(
      adUnitId: _bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _ready = true;
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          _ready = false;
        },
      ),
    );
    await _bannerAd!.load();
  }

  Future<void> preloadRewardedAd() async {
    if (kIsWeb) return;
    if (_rewardedAd != null || _rewardedLoading) return;
    _rewardedLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: _rewardedUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _rewardedLoading = false;
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _rewardedLoading = false;
          },
        ),
      );
    } catch (_) {
      _rewardedAd = null;
      _rewardedLoading = false;
    }
  }

  /// Shows a rewarded ad. Returns `true` only if the user earned the reward.
  Future<bool> showRewardedAd() async {
    if (kIsWeb) return false;

    if (_rewardedAd == null) {
      await preloadRewardedAd();
      // Wait briefly for the in-flight load.
      for (var i = 0; i < 20 && _rewardedAd == null && _rewardedLoading; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }

    final ad = _rewardedAd;
    if (ad == null) {
      // Try one fresh load if preload missed.
      final loaded = Completer<RewardedAd?>();
      try {
        await RewardedAd.load(
          adUnitId: _rewardedUnitId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (fresh) => loaded.complete(fresh),
            onAdFailedToLoad: (_) => loaded.complete(null),
          ),
        );
      } catch (_) {
        return false;
      }
      final fresh = await loaded.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () => null,
      );
      if (fresh == null) return false;
      return _presentRewarded(fresh);
    }

    _rewardedAd = null;
    return _presentRewarded(ad);
  }

  Future<bool> _presentRewarded(RewardedAd ad) async {
    final completer = Completer<bool>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(preloadRewardedAd());
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        unawaited(preloadRewardedAd());
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (_, reward) {
          earned = true;
        },
      );
    } catch (_) {
      ad.dispose();
      unawaited(preloadRewardedAd());
      return false;
    }

    return completer.future;
  }

  Future<void> dispose() async {
    await _bannerAd?.dispose();
    _bannerAd = null;
    _ready = false;
    await _rewardedAd?.dispose();
    _rewardedAd = null;
    _rewardedLoading = false;
  }
}
