// lib/core/network/supabase_client.dart
//
// Supabase client wrapper — credentials injected via --dart-define at build time.
// Never hard-code real values here.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  SupabaseClientService._();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient   get auth   => Supabase.instance.client.auth;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url:      const String.fromEnvironment('SUPABASE_URL'),
      anonKey:  const String.fromEnvironment('SUPABASE_ANON_KEY'),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      debug: kDebugMode,
    );
  }

  // ── Table names ─────────────────────────────────────────────────────────────
  static const String tableUsers         = 'users';
  static const String tableHoroscopes    = 'horoscopes';
  static const String tableCoffeeReadings = 'coffee_readings';
  static const String tableTarotReadings = 'tarot_readings';
  static const String tableEnergyScores  = 'energy_scores';
  static const String tableUserReadings  = 'user_readings';

  // ── Edge function names ──────────────────────────────────────────────────────
  static const String fnGenerateHoroscope = 'generate-horoscope';
  static const String fnReadCoffee        = 'read-coffee';
  static const String fnReadTarot         = 'read-tarot';
}
