// ignore_for_file: constant_identifier_names
//
// Bu dosya Nazar için kopyalanıp özelleştirilmiştir.
// Tüm değerler --dart-define ile compile-time'da inject edilir.
//
// Kullanım (local geliştirme):
//   flutter run \
//     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=eyJ... \
//     --dart-define=REVENUECAT_APPLE_KEY=appl_... \
//     --dart-define=REVENUECAT_GOOGLE_KEY=goog_... \
//     --dart-define=ADMOB_APP_ID_IOS=ca-app-pub-xxx \
//     --dart-define=ADMOB_APP_ID_ANDROID=ca-app-pub-xxx
//
// CI/CD: Bu değerler GitHub Secrets'tan otomatik inject edilir.

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  AppConfig._();

  // ── Environment ───────────────────────────────────────────────────────────
  static const String _env =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static AppEnvironment get environment {
    switch (_env) {
      case 'prod':    return AppEnvironment.prod;
      case 'staging': return AppEnvironment.staging;
      default:        return AppEnvironment.dev;
    }
  }

  static bool get isDev     => environment == AppEnvironment.dev;
  static bool get isStaging => environment == AppEnvironment.staging;
  static bool get isProd    => environment == AppEnvironment.prod;

  // ── App Identity ──────────────────────────────────────────────────────────
  static const String appName      = 'Nazar';
  static const String packageId    = 'com.nazar.fal';
  static const String privacyUrl   = 'https://nazar.app/privacy';
  static const String termsUrl     = 'https://nazar.app/terms';
  static const String supportEmail = 'support@nazar.app';

  // ── Supabase ──────────────────────────────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // ── RevenueCat ────────────────────────────────────────────────────────────
  static const String revenueCatAppleKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: 'appl_YOUR_KEY',
  );

  static const String revenueCatGoogleKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
    defaultValue: 'goog_YOUR_KEY',
  );

  /// RevenueCat entitlement ID — App Store Connect / Play Console ile eşleşmeli
  static const String entitlementId = 'premium';

  /// Product ID'leri — App Store Connect / Play Console'da tanımlanmalı
  static const String productIdMonthly = 'com.nazar.fal_monthly';
  static const String productIdAnnual  = 'com.nazar.fal_annual';

  // ── AdMob ─────────────────────────────────────────────────────────────────
  // Test ID'leri — production öncesi gerçek ID'lerle değiştir
  static const String admobAppIdIos = String.fromEnvironment(
    'ADMOB_APP_ID_IOS',
    defaultValue: 'ca-app-pub-3940256099942544~1458002511', // Test App ID
  );

  static const String admobAppIdAndroid = String.fromEnvironment(
    'ADMOB_APP_ID_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713', // Test App ID
  );

  static const String admobInterstitialIdIos = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910', // Test Interstitial
  );

  static const String admobInterstitialIdAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712', // Test Interstitial
  );

  static const String admobBannerIdIos = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716', // Test Banner
  );

  static const String admobBannerIdAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111', // Test Banner
  );

  // ── Fal Limitleri ─────────────────────────────────────────────────────────
  static const int freeDailyReadingLimit = 3;

  // ── Validation ────────────────────────────────────────────────────────────
  static void assertProductionConfig() {
    assert(
      supabaseUrl.isNotEmpty && !supabaseUrl.startsWith('YOUR'),
      'SUPABASE_URL --dart-define ile set edilmemis!',
    );
    assert(
      supabaseAnonKey.isNotEmpty && !supabaseAnonKey.startsWith('YOUR'),
      'SUPABASE_ANON_KEY --dart-define ile set edilmemis!',
    );
  }
}
