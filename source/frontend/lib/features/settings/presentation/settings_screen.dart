// lib/features/settings/presentation/settings_screen.dart
//
// Nazar — Ayarlar ekranı
// Dil seçimi, hesap, premium, gizlilik

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/revenue_cat_service.dart';
import '../../../core/theme/app_theme.dart';

// ─── SettingsScreen ───────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text(s.settingsTitle),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Kullanıcı bilgisi
          if (user != null) _UserTile(user: user),
          const SizedBox(height: 8),

          // Premium
          if (!isPremium)
            _SettingsTile(
              icon: Icons.workspace_premium,
              iconColor: AppTheme.accent,
              title: s.settingsPremium,
              subtitle: s.paywallSubtitle,
              onTap: () => context.push(AppRoutes.paywall),
            ),

          const SizedBox(height: 8),
          _SectionHeader(title: s.settingsLanguage),
          _LanguageSelector(),

          const SizedBox(height: 8),
          _SectionHeader(title: s.settingsAccount),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: s.settingsPrivacyPolicy,
            onTap: () => launchUrl(Uri.parse(AppConfig.privacyUrl)),
          ),
          _SettingsTile(
            icon: Icons.article_outlined,
            title: s.settingsTerms,
            onTap: () => launchUrl(Uri.parse(AppConfig.termsUrl)),
          ),
          _SettingsTile(
            icon: Icons.logout,
            title: s.authSignOut,
            onTap: () => _signOut(context, ref),
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            iconColor: AppTheme.error,
            title: s.settingsDeleteAccount,
            titleColor: AppTheme.error,
            onTap: () => _confirmDeleteAccount(context, ref, s),
          ),

          const SizedBox(height: 24),
          _VersionInfo(),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await Supabase.instance.client.auth.signOut();
    await RevenueCatService.logout();
  }

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref, S s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.settingsDeleteAccount),
        content: Text(s.settingsDeleteAccount), // TODO: add deleteAccountConfirmBody string with proper warning text
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.settingsDeleteAccount, style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await Supabase.instance.client.functions.invoke('delete-account');
      await Supabase.instance.client.auth.signOut();
    }
  }
}

// ─── User Tile ────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});
  final dynamic user; // Supabase User

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
            child: Text(
              (user.email as String? ?? '?').substring(0, 1).toUpperCase(),
              style: AppTheme.headlineMedium.copyWith(color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email as String? ?? '', style: AppTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Language Selector ────────────────────────────────────────────────────────

class _LanguageSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    const languages = [
      ('tr', '🇹🇷', 'Türkçe'),
      ('en', '🇬🇧', 'English'),
      ('es', '🇪🇸', 'Español'),
      ('de', '🇩🇪', 'Deutsch'),
      ('fr', '🇫🇷', 'Français'),
      ('pt', '🇧🇷', 'Português'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Column(
        children: [
          for (final (code, flag, name) in languages)
            ListTile(
              leading: Text(flag, style: const TextStyle(fontSize: 24)),
              title: Text(name, style: AppTheme.titleMedium),
              trailing: currentLocale.languageCode == code
                  ? const Icon(Icons.check_circle, color: AppTheme.primary)
                  : null,
              onTap: () => localeNotifier.setLocale(code),
            ),
        ],
      ),
    );
  }
}

// ─── Reusable Settings Tile ───────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: AppTheme.bgMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.textSecondary),
        title: Text(title, style: AppTheme.titleMedium.copyWith(color: titleColor)),
        subtitle: subtitle != null ? Text(subtitle!, style: AppTheme.bodyMedium) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textHint),
        onTap: onTap,
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(title, style: AppTheme.labelMedium),
    );
  }
}

// ─── Version Info ─────────────────────────────────────────────────────────────

class _VersionInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '1.0.0';
        final build = snapshot.data?.buildNumber ?? '1';
        final s = S.of(context);
        return Center(
          child: Text(
            '${s.settingsVersion} $version ($build)',
            style: AppTheme.labelSmall,
          ),
        );
      },
    );
  }
}
