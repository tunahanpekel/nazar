// lib/features/home/presentation/home_screen.dart
//
// Nazar ana ekranı — günlük fal hub'ı
// Özellikler: Horoscope, Kahve Falı, Tarot, Günlük Enerji Skoru
// Altta sabit AdMob banner (premium hariç)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/revenue_cat_service.dart';
import '../../../core/services/admob_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/reading_model.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/premium_gate.dart';
import '../../settings/presentation/settings_screen.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

/// Supabase daily_usage tablosundan bugünkü okuma sayısını çeker.
/// Kullanıcı giriş yapmamışsa 0 döner.
final dailyUsageFetchProvider = FutureProvider<int>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return 0;

  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final response = await Supabase.instance.client
      .from('daily_usage')
      .select('count')
      .eq('user_id', user.id)
      .eq('date', dateStr)
      .maybeSingle();

  if (response == null) return 0;
  return (response['count'] as int?) ?? 0;
});

/// Kullanıcının bugünkü okuma sayısı — gerçek değer Supabase'den alınır.
final userReadingCountProvider = StateProvider<UserReadingCount>((ref) {
  // Arka planda gerçek sayıyı çek ve provider'ı güncelle.
  ref.listen<AsyncValue<int>>(dailyUsageFetchProvider, (_, next) {
    next.whenData((count) {
      ref.controller.state = UserReadingCount(
        date:  DateTime.now(),
        count: count,
        limit: 3,
      );
    });
  });

  return UserReadingCount(
    date:  DateTime.now(),
    count: 0,
    limit: 3,
  );
});

final selectedZodiacProvider = StateProvider<ZodiacSign?>((ref) => null);

// ─── HomeScreen ───────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final readingCount = ref.watch(userReadingCountProvider);
    final bannerAd = ref.watch(bannerAdProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, s),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _EnergyScoreCard(),
                        const SizedBox(height: 24),
                        _ReadingsLeftBadge(
                          readingCount: readingCount,
                          isPremium: isPremium,
                        ),
                        const SizedBox(height: 20),
                        _FeatureGrid(isPremium: isPremium),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // AdMob banner — sadece free kullanıcılara
          if (!isPremium && bannerAd != null)
            SafeArea(
              top: false,
              child: SizedBox(
                height: bannerAd.size.height.toDouble(),
                width: bannerAd.size.width.toDouble(),
                child: AdWidget(ad: bannerAd),
              ),
            )
          else if (!isPremium)
            const SafeArea(
              top: false,
              child: SizedBox(height: 50),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, S s) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      backgroundColor: AppTheme.bgDeep,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔮 ${s.homeTitle}',
                  style: AppTheme.headlineLarge,
                ),
                Text(
                  s.homeGreeting,
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daily Energy Score Card ──────────────────────────────────────────────────

class _EnergyScoreCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    // Enerji skoru burç ve tarihten hesaplanır — gerçek implementasyon horoscope provider'dan gelir
    final score = 7; // TODO: horoscopeProvider'dan al

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.homeEnergyScore, style: AppTheme.labelMedium.copyWith(color: AppTheme.textPrimary.withValues(alpha: 0.8))),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$score', style: AppTheme.displayMedium),
                  Text('/10', style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary.withValues(alpha: 0.7))),
                ],
              ),
              const SizedBox(height: 4),
              Text(s.homeRefreshAt, style: AppTheme.labelSmall.copyWith(color: AppTheme.textPrimary.withValues(alpha: 0.6))),
            ],
          ),
          const Spacer(),
          Text('✨', style: TextStyle(fontSize: 48)),
        ],
      ),
    );
  }
}

// ─── Readings Left Badge ──────────────────────────────────────────────────────

class _ReadingsLeftBadge extends StatelessWidget {
  const _ReadingsLeftBadge({
    required this.readingCount,
    required this.isPremium,
  });

  final UserReadingCount readingCount;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (isPremium) return const SizedBox.shrink();

    if (readingCount.hasReachedLimit) {
      return const DailyLimitBanner();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.accent, size: 18),
          const SizedBox(width: 8),
          Text(
            '${readingCount.remaining} ${s.homeReadingsLeft}',
            style: AppTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

// ─── Feature Grid ─────────────────────────────────────────────────────────────

class _FeatureGrid extends ConsumerWidget {
  const _FeatureGrid({required this.isPremium});
  final bool isPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    final features = [
      _FeatureItem(
        emoji: '⭐',
        title: s.homeHoroscope,
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF2E1065)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => _navigateToReading(context, ref, AppRoutes.horoscope),
      ),
      _FeatureItem(
        emoji: '☕',
        title: s.homeCoffeeReading,
        gradient: AppTheme.coffeeGradient,
        onTap: () => _navigateToReading(context, ref, AppRoutes.coffeeReading),
      ),
      _FeatureItem(
        emoji: '🃏',
        title: s.homeTarot,
        gradient: AppTheme.tarotGradient,
        onTap: () => _navigateToReading(context, ref, AppRoutes.tarot),
      ),
    ];

    return Column(
      children: features.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _FeatureCard(item: f),
      )).toList(),
    );
  }

  Future<void> _navigateToReading(
    BuildContext context,
    WidgetRef ref,
    String route,
  ) async {
    final readingCount = ref.read(userReadingCountProvider);

    if (!isPremium && readingCount.hasReachedLimit) {
      // Limit doldu, paywall'a yönlendir
      context.push(AppRoutes.paywall);
      return;
    }

    if (!isPremium) {
      // Fal öncesi interstitial göster
      await ref.read(interstitialAdProvider.notifier)
          .showIfAvailable(isPremium: false);
    }

    if (context.mounted) {
      await context.push(route);
    }

    // Fal ekranından dönerken güncel kullanım sayısını yeniden çek.
    ref.invalidate(dailyUsageFetchProvider);
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.emoji,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final LinearGradient gradient;
  final VoidCallback onTap;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});
  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: item.gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.bgBorder.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 24),
            Text(item.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 20),
            Text(item.title, style: AppTheme.headlineMedium),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
