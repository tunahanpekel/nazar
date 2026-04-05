// lib/main.dart — Nazar
//
// Run locally:
//   flutter run \
//     --dart-define=APP_ENV=dev \
//     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=eyJ...

import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/services/admob_service.dart';
import 'core/services/revenue_cat_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // ── Orientation ──────────────────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── System UI ────────────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgDeep,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Supabase ─────────────────────────────────────────────────────────────────
  assert(
    AppConfig.supabaseUrl.isNotEmpty && !AppConfig.supabaseUrl.startsWith('YOUR'),
    'SUPABASE_URL set edilmedi. --dart-define=SUPABASE_URL=... kullan',
  );
  await Supabase.initialize(
    url:     AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    debug:   kDebugMode,
  );

  // ── RevenueCat ───────────────────────────────────────────────────────────────
  await RevenueCatService.initialize();
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId != null) {
    await RevenueCatService.identifyUser(userId);
  }

  // ── AdMob ────────────────────────────────────────────────────────────────────
  await AdMobService.initialize();

  runApp(const ProviderScope(child: NazarApp()));
}

// ─── Root widget ──────────────────────────────────────────────────────────────

class NazarApp extends ConsumerWidget {
  const NazarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Nazar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('es'),
        Locale('de'),
        Locale('fr'),
        Locale('pt'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
