// lib/core/router/app_router.dart
//
// GoRouter setup — Nazar
//   - Supabase auth guard (redirect unauthenticated → /onboarding)
//   - RevenueCat identity sync on sign-in / sign-out
//   - Slide-up and fade page transitions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_strings.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/paywall/presentation/paywall_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/horoscope/presentation/horoscope_screen.dart';
import '../../features/coffee_reading/presentation/coffee_reading_screen.dart';
import '../../features/tarot/presentation/tarot_screen.dart';

part 'app_router.g.dart';

// ─── Route paths ──────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const root           = '/';
  static const onboarding     = '/onboarding';
  static const paywall        = '/paywall';
  static const home           = '/home';
  static const settings       = '/settings';
  static const horoscope      = '/horoscope';
  static const coffeeReading  = '/coffee-reading';
  static const tarot          = '/tarot';
}

// ─── Auth state stream ────────────────────────────────────────────────────────

@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

// ─── Router ───────────────────────────────────────────────────────────────────

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authNotifier = _AuthChangeNotifier(ref);
  late final GoRouter router;

  ref.listen(authStateProvider, (_, next) {
    final event = next.valueOrNull?.event;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (event == AuthChangeEvent.signedIn) {
        router.go(AppRoutes.home);
      } else if (event == AuthChangeEvent.signedOut) {
        router.go(AppRoutes.onboarding);
      }
    });
  });

  router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,

    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthenticated = session != null;
      final goingTo = state.matchedLocation;

      const publicRoutes = {
        AppRoutes.root,
        AppRoutes.onboarding,
        AppRoutes.paywall,
      };

      if (!isAuthenticated && !publicRoutes.contains(goingTo)) {
        return AppRoutes.onboarding;
      }
      if (isAuthenticated && goingTo == AppRoutes.onboarding) {
        return AppRoutes.home;
      }
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (_, __) => AppRoutes.home,
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.paywall,
        name: 'paywall',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: const PaywallScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.horoscope,
        name: 'horoscope',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: const HoroscopeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.coffeeReading,
        name: 'coffeeReading',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: const CoffeeReadingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.tarot,
        name: 'tarot',
        pageBuilder: (context, state) => _slideUpTransition(
          state: state,
          child: const TarotScreen(),
        ),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 16),
            Text(S.of(context).commonPageNotFound),
            const SizedBox(height: 8),
            Text(state.error?.message ?? state.uri.toString()),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text(S.of(context).commonGoHome),
            ),
          ],
        ),
      ),
    ),
  );

  return router;
}

// ─── Transition helpers ───────────────────────────────────────────────────────

CustomTransitionPage<void> _slideUpTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

CustomTransitionPage<void> _fadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

// ─── Auth change listenable ───────────────────────────────────────────────────

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, next) {
      notifyListeners();
      final event  = next.valueOrNull?.event;
      final userId = next.valueOrNull?.session?.user.id;
      if (event == AuthChangeEvent.signedIn && userId != null) {
        Purchases.logIn(userId).ignore();
      } else if (event == AuthChangeEvent.signedOut) {
        Purchases.logOut().ignore();
      }
    });
  }
}
