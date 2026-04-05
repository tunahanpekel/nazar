// lib/features/paywall/presentation/paywall_screen.dart
//
// Nazar Premium paywall
// $2.99/ay · Reklamsız + Sınırsız fal + Öncelikli AI

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_overlay.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final paywallOfferingsProvider = FutureProvider<Offerings?>((ref) async {
  try {
    return await Purchases.getOfferings();
  } catch (_) {
    return null;
  }
});

// ─── PaywallScreen ────────────────────────────────────────────────────────────

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isPurchasing = false;
  String? _selectedPackageId;

  Future<void> _purchase(Package package) async {
    setState(() => _isPurchasing = true);
    try {
      await Purchases.purchasePackage(package);
      if (mounted) Navigator.of(context).pop();
    } on PurchasesErrorCode catch (e) {
      if (e != PurchasesErrorCode.purchaseCancelledError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${S.of(context).commonError}: ${e.name}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);
    try {
      await Purchases.restorePurchases();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).commonError}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final offeringsAsync = ref.watch(paywallOfferingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: offeringsAsync.when(
        loading: () => const LoadingView(),
        error: (_, __) => _PaywallContent(
          packages: const [],
          isPurchasing: _isPurchasing,
          selectedPackageId: _selectedPackageId,
          onPackageSelected: (id) => setState(() => _selectedPackageId = id),
          onPurchase: (_) {},
          onRestore: _restorePurchases,
        ),
        data: (offerings) {
          final packages = offerings?.current?.availablePackages ?? [];
          if (_selectedPackageId == null && packages.isNotEmpty) {
            _selectedPackageId = packages.first.identifier;
          }
          return _PaywallContent(
            packages: packages,
            isPurchasing: _isPurchasing,
            selectedPackageId: _selectedPackageId,
            onPackageSelected: (id) => setState(() => _selectedPackageId = id),
            onPurchase: (pkg) => _purchase(pkg),
            onRestore: _restorePurchases,
          );
        },
      ),
    );
  }
}

// ─── Paywall Content ──────────────────────────────────────────────────────────

class _PaywallContent extends ConsumerWidget {
  const _PaywallContent({
    required this.packages,
    required this.isPurchasing,
    required this.selectedPackageId,
    required this.onPackageSelected,
    required this.onPurchase,
    required this.onRestore,
  });

  final List<Package> packages;
  final bool isPurchasing;
  final String? selectedPackageId;
  final ValueChanged<String> onPackageSelected;
  final ValueChanged<Package> onPurchase;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    final benefits = [
      (Icons.all_inclusive, s.paywallBenefit1),
      (Icons.block, s.paywallBenefit2),
      (Icons.bolt_outlined, s.paywallBenefit3),
      (Icons.bookmark_outline, s.paywallBenefit4),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('✨', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(s.paywallTitle, style: AppTheme.displayMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(s.paywallSubtitle, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 28),

            // Benefits
            ...benefits.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(b.$1, color: AppTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(b.$2, style: AppTheme.titleMedium),
                ],
              ),
            )),
            const SizedBox(height: 24),

            // Package options
            if (packages.isNotEmpty) ...[
              ...packages.map((pkg) {
                final isSelected = pkg.identifier == selectedPackageId;
                final isAnnual = pkg.packageType == PackageType.annual;
                return GestureDetector(
                  onTap: () => onPackageSelected(pkg.identifier),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.bgMid,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.bgBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.bgBorder, width: 2),
                            color: isSelected ? AppTheme.primary : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isAnnual ? s.paywallAnnual : s.paywallMonthly,
                                    style: AppTheme.titleMedium,
                                  ),
                                  if (isAnnual) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(s.paywallMostPopular, style: AppTheme.labelSmall.copyWith(color: AppTheme.bgDeep)),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                pkg.storeProduct.priceString,
                                style: AppTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ] else
              // Fallback — RevenueCat bağlı değilse statik göster
              _StaticPricingCard(s: s),

            const SizedBox(height: 20),

            // CTA
            SizedBox(
              width: double.infinity,
              height: 56,
              child: isPurchasing
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : FilledButton(
                      onPressed: () {
                        final pkg = packages.firstWhere(
                          (p) => p.identifier == selectedPackageId,
                          orElse: () => packages.isNotEmpty ? packages.first : throw StateError('No packages'),
                        );
                        onPurchase(pkg);
                      },
                      child: Text(s.paywallStartTrial),
                    ),
            ),
            const SizedBox(height: 12),
            Text(s.paywallCancelAnytime, style: AppTheme.labelSmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),

            // Footer links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: onRestore,
                  child: Text(s.paywallRestore, style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary)),
                ),
                Text(' · ', style: AppTheme.labelSmall),
                TextButton(
                  onPressed: () => launchUrl(Uri.parse(AppConfig.termsUrl)),
                  child: Text(s.paywallTerms, style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary)),
                ),
                Text(' · ', style: AppTheme.labelSmall),
                TextButton(
                  onPressed: () => launchUrl(Uri.parse(AppConfig.privacyUrl)),
                  child: Text(s.paywallPrivacy, style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticPricingCard extends StatelessWidget {
  const _StaticPricingCard({required this.s});
  final S s;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(s.paywallMonthly, style: AppTheme.titleMedium),
          Text(s.paywallMonthlyPrice, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}
