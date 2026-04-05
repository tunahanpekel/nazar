// lib/shared/widgets/premium_gate.dart
//
// Wrap any feature widget to show a premium upgrade prompt.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class PremiumGate extends StatelessWidget {
  const PremiumGate({
    super.key,
    required this.isPremium,
    required this.child,
    this.featureName,
  });

  final bool isPremium;
  final Widget child;
  final String? featureName;

  @override
  Widget build(BuildContext context) {
    if (isPremium) return child;
    return _PremiumWall(featureName: featureName);
  }
}

class _PremiumWall extends StatelessWidget {
  const _PremiumWall({this.featureName});
  final String? featureName;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: AppTheme.accent, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              s.paywallTitle,
              style: AppTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              s.paywallSubtitle,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => context.push(AppRoutes.paywall),
                child: Text(s.homeUpgradePremium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daily Limit Reached Banner ───────────────────────────────────────────────

class DailyLimitBanner extends StatelessWidget {
  const DailyLimitBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1A5E), Color(0xFF1A0D3D)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('🔮', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.limitReachedTitle,
                  style: AppTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            s.limitReachedBody,
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () => context.push(AppRoutes.paywall),
              child: Text(s.homeUpgradePremium),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AdMob Banner Placeholder ─────────────────────────────────────────────────

class BannerAdPlaceholder extends StatelessWidget {
  const BannerAdPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    // Gerçek BannerAd widget'ı AdMobService üzerinden inject edilir.
    // Bu placeholder UI geliştirme sırasında kullanılır.
    return Container(
      height: 50,
      color: AppTheme.bgMid,
      alignment: Alignment.center,
      child: Text('Ad', style: AppTheme.labelSmall),
    );
  }
}
