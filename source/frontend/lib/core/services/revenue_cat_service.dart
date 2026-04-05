// lib/core/services/revenue_cat_service.dart
//
// RevenueCat entegrasyonu — Nazar
// Entitlement: premium
// Products: com.nazar.fal_monthly, com.nazar.fal_annual

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_config.dart';

const _kEntitlementId = 'premium';

// ─── Service ──────────────────────────────────────────────────────────────────

class RevenueCatService {
  RevenueCatService._();

  static Future<void> initialize() async {
    try {
      final apiKey = Platform.isIOS
          ? AppConfig.revenueCatAppleKey
          : AppConfig.revenueCatGoogleKey;

      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.error,
      );

      final config = PurchasesConfiguration(apiKey);
      await Purchases.configure(config);
    } catch (e) {
      debugPrint('[RevenueCat] initialize error: $e');
    }
  }

  static Future<void> identifyUser(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('[RevenueCat] identifyUser error: $e');
    }
  }

  static Future<bool> checkPremiumStatus() async {
    // TODO: release öncesi kaldır
    if (kDebugMode) return false;

    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_kEntitlementId);
    } catch (_) {
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('[RevenueCat] logout error: $e');
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final subscriptionProvider = FutureProvider<bool>((ref) async {
  if (kDebugMode) return false;
  try {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey(_kEntitlementId);
  } catch (_) {
    return false;
  }
});

/// Senkron bool — false fallback ile.
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).valueOrNull ?? false;
});
