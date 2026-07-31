import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';

class AdService {
  AdService();

  BannerAd? _bannerAd;
  bool _ready = false;

  BannerAd? get bannerAd => _ready ? _bannerAd : null;
  bool get isReady => _ready;

  String get _unitId {
    if (kIsWeb) return AppConstants.androidBannerAdUnitId;
    if (Platform.isIOS) return AppConstants.iosBannerAdUnitId;
    return AppConstants.androidBannerAdUnitId;
  }

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
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
      adUnitId: _unitId,
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

  Future<void> dispose() async {
    await _bannerAd?.dispose();
    _bannerAd = null;
    _ready = false;
  }
}
