// lib/core/services/admob_service.dart
//
// AdMob entegrasyonu — Nazar
// - Her fal öncesi interstitial reklam
// - Alt sabit banner (premium kullanıcılarda gizlenir)
//
// Test ID'leri kullanılıyor — production öncesi gerçek ID'lerle değiştir.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';
import 'revenue_cat_service.dart';

// ─── Ad ID Helpers ────────────────────────────────────────────────────────────

String get _interstitialAdUnitId =>
    Platform.isIOS
        ? AppConfig.admobInterstitialIdIos
        : AppConfig.admobInterstitialIdAndroid;

String get _bannerAdUnitId =>
    Platform.isIOS
        ? AppConfig.admobBannerIdIos
        : AppConfig.admobBannerIdAndroid;

// ─── AdMob Service ────────────────────────────────────────────────────────────

class AdMobService {
  AdMobService._();

  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('[AdMob] initialized');
    } catch (e) {
      debugPrint('[AdMob] initialize error: $e');
    }
  }
}

// ─── Interstitial Ad Provider ─────────────────────────────────────────────────

class InterstitialAdNotifier extends StateNotifier<InterstitialAd?> {
  InterstitialAdNotifier() : super(null) {
    _load();
  }

  void _load() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          state = ad;
          debugPrint('[AdMob] Interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdMob] Interstitial failed: ${error.message}');
          state = null;
        },
      ),
    );
  }

  /// Reklamı göster. Gösterdikten sonra otomatik yeniden yükle.
  /// [isPremium] true ise reklam gösterilmez.
  Future<void> showIfAvailable({required bool isPremium}) async {
    if (isPremium) return;

    final ad = state;
    if (ad == null) {
      debugPrint('[AdMob] No interstitial ready, skipping');
      _load(); // Yeniden yükle
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        state = null;
        _load(); // Sonraki fal için hazır ol
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        state = null;
        _load();
      },
    );

    await ad.show();
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

final interstitialAdProvider =
    StateNotifierProvider<InterstitialAdNotifier, InterstitialAd?>((ref) {
  return InterstitialAdNotifier();
});

// ─── Banner Ad Provider ───────────────────────────────────────────────────────

class BannerAdNotifier extends StateNotifier<BannerAd?> {
  BannerAdNotifier() : super(null) {
    _load();
  }

  void _load() {
    final banner = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          state = ad as BannerAd;
          debugPrint('[AdMob] Banner loaded');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          state = null;
          debugPrint('[AdMob] Banner failed: ${error.message}');
        },
      ),
    )..load();
    // Not: state'i hemen set etme, onAdLoaded'da set edilir
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

final bannerAdProvider =
    StateNotifierProvider<BannerAdNotifier, BannerAd?>((ref) {
  return BannerAdNotifier();
});
