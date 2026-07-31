import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_challenge/controllers/app_controllers.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';

class HomeBannerAd extends ConsumerStatefulWidget {
  const HomeBannerAd({super.key});

  @override
  ConsumerState<HomeBannerAd> createState() => _HomeBannerAdState();
}

class _HomeBannerAdState extends ConsumerState<HomeBannerAd> {
  bool _loaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (kIsWeb) return;
    final adService = ref.read(adServiceProvider);
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (size == null || !mounted) return;
    await adService.loadBanner(
      size: size,
      onLoaded: () {
        if (mounted) setState(() => _loaded = true);
      },
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ad = ref.read(adServiceProvider).bannerAd;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: AppConstants.bannerReservedHeight,
        width: double.infinity,
        child: _loaded && ad != null && !kIsWeb
            ? AdWidget(ad: ad)
            : Container(
                alignment: Alignment.center,
                color: Colors.black.withValues(alpha: 0.12),
                child: Text(
                  kIsWeb || (!Platform.isAndroid && !Platform.isIOS)
                      ? 'Ad space'
                      : 'Loading ad…',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ),
      ),
    );
  }
}
