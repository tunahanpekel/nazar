// lib/features/onboarding/presentation/onboarding_screen.dart
//
// Nazar onboarding — 3 sayfa + Google/Apple ile giriş
// Deep link: com.nazar.fal://login-callback

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _isSigningIn = false;

  static const _deepLinkScheme = 'com.nazar.fal://login-callback';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _deepLinkScheme,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // Router auth state listener otomatik home'a yönlendirir
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${S.of(context).commonError}: $e'),
          backgroundColor: AppTheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _continueWithApple() async {
    setState(() => _isSigningIn = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: _deepLinkScheme,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${S.of(context).commonError}: $e'),
          backgroundColor: AppTheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);

    final pages = [
      _OnboardingPage(
        emoji: '🔮',
        title: s.onboardingPage1Title,
        body: s.onboardingPage1Body,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0A3D), Color(0xFF0A0A1A)],
        ),
      ),
      _OnboardingPage(
        emoji: '☕',
        title: s.onboardingPage2Title,
        body: s.onboardingPage2Body,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A0D05), Color(0xFF0A0A1A)],
        ),
      ),
      _OnboardingPage(
        emoji: '🃏',
        title: s.onboardingPage3Title,
        body: s.onboardingPage3Body,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D0A2A), Color(0xFF0A0A1A)],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: pages.length,
            itemBuilder: (_, i) => pages[i],
          ),
          Positioned.fill(
            child: Column(
              children: [
                const Spacer(),
                _buildBottomSection(context, s, pages.length),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, S s, int pageCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pageCount,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? AppTheme.primary : AppTheme.bgBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            if (_page < pageCount - 1) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  ),
                  child: Text(s.commonContinue),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _pageController.animateToPage(
                  pageCount - 1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                ),
                child: Text(s.onboardingSkip, style: AppTheme.bodyMedium),
              ),
            ] else ...[
              // Son sayfa — giriş butonları
              if (_isSigningIn)
                const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                    onPressed: _continueWithGoogle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4285F4))),
                        const SizedBox(width: 12),
                        Text(s.authSignInGoogle, style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                    onPressed: _continueWithApple,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.apple, size: 22),
                        const SizedBox(width: 12),
                        Text(s.authSignInApple),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  s.onboardingLegalConsent,
                  style: AppTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.gradient,
  });

  final String emoji;
  final String title;
  final String body;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 100, 32, 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 32),
            Text(
              title,
              style: AppTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              body,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
