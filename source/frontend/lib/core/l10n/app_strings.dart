// lib/core/l10n/app_strings.dart
//
// Nazar — Lightweight localization — no codegen required.
//
// Usage:
//   S.of(context).someKey
//   ref.watch(localeProvider)
//
// Supported: en, tr, es, de, fr, pt

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Locale Provider ──────────────────────────────────────────────────────────

const _kLangKey = 'app_language';
const _supportedLangs = ['en', 'tr', 'es', 'de', 'fr', 'pt'];

String _deviceLang() {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return _supportedLangs.contains(code) ? code : 'en';
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _load();
    return Locale(_deviceLang());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLangKey);
    if (saved != null) state = Locale(saved);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, languageCode);
  }

  bool get isTurkish    => state.languageCode == 'tr';
  bool get isSpanish    => state.languageCode == 'es';
  bool get isGerman     => state.languageCode == 'de';
  bool get isFrench     => state.languageCode == 'fr';
  bool get isPortuguese => state.languageCode == 'pt';
}

// ─── String lookup ────────────────────────────────────────────────────────────

class S {
  const S._(this._locale);
  final Locale _locale;
  String get _lang => _locale.languageCode;
  bool get _tr => _lang == 'tr';
  bool get _es => _lang == 'es';
  bool get _de => _lang == 'de';
  bool get _fr => _lang == 'fr';
  bool get _pt => _lang == 'pt';

  static S of(BuildContext context) => S._(Localizations.localeOf(context));

  // ── Common ───────────────────────────────────────────────────────────────────
  String get commonOk           => _tr ? 'Tamam'      : _es ? 'Aceptar'     : _de ? 'OK'           : _fr ? 'OK'            : _pt ? 'OK'            : 'OK';
  String get commonCancel       => _tr ? 'İptal'      : _es ? 'Cancelar'    : _de ? 'Abbrechen'    : _fr ? 'Annuler'       : _pt ? 'Cancelar'      : 'Cancel';
  String get commonSave         => _tr ? 'Kaydet'     : _es ? 'Guardar'     : _de ? 'Speichern'    : _fr ? 'Enregistrer'   : _pt ? 'Salvar'        : 'Save';
  String get commonContinue     => _tr ? 'Devam Et'   : _es ? 'Continuar'   : _de ? 'Weiter'       : _fr ? 'Continuer'     : _pt ? 'Continuar'     : 'Continue';
  String get commonBack         => _tr ? 'Geri'       : _es ? 'Atrás'       : _de ? 'Zurück'       : _fr ? 'Retour'        : _pt ? 'Voltar'        : 'Back';
  String get commonLoading      => _tr ? 'Yükleniyor' : _es ? 'Cargando'    : _de ? 'Laden...'     : _fr ? 'Chargement'    : _pt ? 'Carregando'    : 'Loading...';
  String get commonError        => _tr ? 'Hata'       : _es ? 'Error'       : _de ? 'Fehler'       : _fr ? 'Erreur'        : _pt ? 'Erro'          : 'Error';
  String get commonRetry        => _tr ? 'Tekrar Dene': _es ? 'Reintentar'  : _de ? 'Wiederholen'  : _fr ? 'Réessayer'     : _pt ? 'Tentar novamente' : 'Try Again';
  String get commonPageNotFound => _tr ? 'Sayfa Bulunamadı' : _es ? 'Página no encontrada' : _de ? 'Seite nicht gefunden' : _fr ? 'Page introuvable' : _pt ? 'Página não encontrada' : 'Page Not Found';
  String get commonGoHome       => _tr ? 'Ana Sayfaya Dön'  : _es ? 'Ir al inicio'         : _de ? 'Zur Startseite'      : _fr ? 'Aller à l\'accueil' : _pt ? 'Ir para o início' : 'Go Home';
  String get commonClose        => _tr ? 'Kapat'      : _es ? 'Cerrar'      : _de ? 'Schließen'    : _fr ? 'Fermer'        : _pt ? 'Fechar'        : 'Close';
  String get commonShare        => _tr ? 'Paylaş'     : _es ? 'Compartir'   : _de ? 'Teilen'       : _fr ? 'Partager'      : _pt ? 'Compartilhar'  : 'Share';

  // ── Navigation ───────────────────────────────────────────────────────────────
  String get tabHome     => _tr ? 'Ana Sayfa' : _es ? 'Inicio'   : _de ? 'Startseite'      : _fr ? 'Accueil'     : _pt ? 'Início'        : 'Home';
  String get tabSettings => _tr ? 'Ayarlar'   : _es ? 'Ajustes'  : _de ? 'Einstellungen'   : _fr ? 'Paramètres'  : _pt ? 'Configurações' : 'Settings';

  // ── Auth ─────────────────────────────────────────────────────────────────────
  String get authSignIn       => _tr ? 'Giriş Yap'  : _es ? 'Iniciar sesión'  : _de ? 'Anmelden'  : _fr ? 'Se connecter'    : _pt ? 'Entrar'        : 'Sign In';
  String get authSignOut      => _tr ? 'Çıkış Yap'  : _es ? 'Cerrar sesión'   : _de ? 'Abmelden'  : _fr ? 'Se déconnecter'  : _pt ? 'Sair'          : 'Sign Out';
  String get authSignInGoogle => _tr ? 'Google ile Giriş Yap' : _es ? 'Continuar con Google' : _de ? 'Mit Google anmelden' : _fr ? 'Connexion Google' : _pt ? 'Entrar com Google' : 'Continue with Google';
  String get authSignInApple  => _tr ? 'Apple ile Giriş Yap'  : _es ? 'Continuar con Apple'  : _de ? 'Mit Apple anmelden'  : _fr ? 'Connexion Apple'  : _pt ? 'Entrar com Apple'  : 'Continue with Apple';

  // ── Onboarding ────────────────────────────────────────────────────────────────
  String get onboardingPage1Title    => _tr ? 'Kaderine Kulak Ver'           : _es ? 'Escucha tu destino'        : _de ? 'Höre auf dein Schicksal'    : _fr ? 'Écoute ton destin'         : _pt ? 'Ouça seu destino'          : 'Listen to Your Destiny';
  String get onboardingPage1Body     => _tr ? 'Yapay zeka falcın her gün seni bekliyor. Burç, tarot, kahve falı.' : _es ? 'Tu adivino AI te espera cada día. Horóscopo, tarot, café.' : _de ? 'Dein KI-Wahrsager wartet täglich auf dich.' : _fr ? 'Ton oracle IA t\'attend chaque jour.' : _pt ? 'Seu adivinho IA espera por você todo dia.' : 'Your AI fortune teller awaits every day. Horoscope, tarot, coffee.';
  String get onboardingPage2Title    => _tr ? 'Kahve Fincanında Sırlar'       : _es ? 'Secretos en la taza'        : _de ? 'Geheimnisse in der Tasse'    : _fr ? 'Secrets dans la tasse'       : _pt ? 'Segredos na xícara'           : 'Secrets in the Cup';
  String get onboardingPage2Body     => _tr ? 'Fincana bak, fotoğraf çek. Claude görüntüyü okur, kaderinle konuşur.' : _es ? 'Mira la taza, toma foto. Claude lee la imagen y habla con tu destino.' : _de ? 'Schau in die Tasse, mach ein Foto. Claude liest das Bild.' : _fr ? 'Regarde la tasse, prends une photo. Claude lit l\'image.' : _pt ? 'Olhe para a xícara, tire foto. Claude lê a imagem.' : 'Look into the cup, take a photo. Claude reads the image and speaks your destiny.';
  String get onboardingPage3Title    => _tr ? 'Tarot Kartların Konuşuyor'     : _es ? 'Las cartas del tarot hablan' : _de ? 'Die Tarotkarten sprechen'    : _fr ? 'Les cartes de tarot parlent'  : _pt ? 'As cartas de tarô falam'       : 'Tarot Cards Speak';
  String get onboardingPage3Body     => _tr ? '3 kart çek, geçmişin, bugünün ve geleceğin açıklanıyor.' : _es ? 'Saca 3 cartas, tu pasado, presente y futuro se revelan.' : _de ? 'Ziehe 3 Karten, deine Vergangenheit, Gegenwart und Zukunft.' : _fr ? 'Tire 3 cartes, ton passé, présent et futur se révèlent.' : _pt ? 'Tire 3 cartas, seu passado, presente e futuro se revelam.' : 'Draw 3 cards, your past, present, and future are revealed.';
  String get onboardingGetStarted    => _tr ? 'Falımı Bak'    : _es ? 'Ver mi destino'  : _de ? 'Mein Schicksal' : _fr ? 'Voir mon destin'  : _pt ? 'Ver meu destino' : 'See My Fortune';
  String get onboardingSkip          => _tr ? 'Geç'           : _es ? 'Omitir'          : _de ? 'Überspringen'  : _fr ? 'Passer'          : _pt ? 'Pular'           : 'Skip';

  // ── Home ─────────────────────────────────────────────────────────────────────
  String get homeTitle          => _tr ? 'Nazar'                    : _es ? 'Nazar'                    : _de ? 'Nazar'                    : _fr ? 'Nazar'                    : _pt ? 'Nazar'                    : 'Nazar';
  String get homeGreeting       => _tr ? 'Günün Falı'               : _es ? 'Tu fortuna del día'        : _de ? 'Deine Tagesglück'         : _fr ? 'Ta fortune du jour'        : _pt ? 'Sua sorte do dia'          : 'Your Daily Fortune';
  String get homeHoroscope      => _tr ? 'Burç Yorumu'              : _es ? 'Horóscopo'                 : _de ? 'Horoskop'                  : _fr ? 'Horoscope'                 : _pt ? 'Horóscopo'                 : 'Horoscope';
  String get homeCoffeeReading  => _tr ? 'Kahve Falı'               : _es ? 'Lectura de café'            : _de ? 'Kaffeesatz lesen'          : _fr ? 'Lecture du café'            : _pt ? 'Leitura de café'            : 'Coffee Reading';
  String get homeTarot          => _tr ? 'Tarot'                    : _es ? 'Tarot'                     : _de ? 'Tarot'                     : _fr ? 'Tarot'                     : _pt ? 'Tarô'                      : 'Tarot';
  String get homeEnergyScore    => _tr ? 'Günlük Enerji'            : _es ? 'Energía del día'            : _de ? 'Tagesenergie'              : _fr ? 'Énergie du jour'            : _pt ? 'Energia do dia'             : 'Daily Energy';
  String get homeReadingsLeft   => _tr ? 'fal hakkın kaldı'         : _es ? 'lecturas restantes'         : _de ? 'Lesungen übrig'            : _fr ? 'lectures restantes'         : _pt ? 'leituras restantes'         : 'readings left today';
  String get homeNoReadingsLeft => _tr ? 'Bugünlük fal hakkın bitti': _es ? 'Se acabaron las lecturas de hoy' : _de ? 'Heute keine Lesungen mehr' : _fr ? 'Plus de lectures aujourd\'hui' : _pt ? 'Sem leituras hoje' : 'No readings left today';
  String get homeUpgradePremium => _tr ? 'Premium\'a Geç'           : _es ? 'Mejorar a Premium'          : _de ? 'Zu Premium wechseln'       : _fr ? 'Passer à Premium'           : _pt ? 'Ir para Premium'            : 'Go Premium';
  String get homeRefreshAt      => _tr ? 'Gece yarısı yenileniyor'  : _es ? 'Se renueva a medianoche'    : _de ? 'Erneuert sich um Mitternacht' : _fr ? 'Se renouvelle à minuit'   : _pt ? 'Renova à meia-noite'        : 'Refreshes at midnight';

  // ── Horoscope ─────────────────────────────────────────────────────────────────
  String get horoscopeTitle       => _tr ? 'Günlük Burç Yorumu'   : _es ? 'Horóscopo diario'      : _de ? 'Tageshoroskop'        : _fr ? 'Horoscope quotidien'  : _pt ? 'Horóscopo diário'      : 'Daily Horoscope';
  String get horoscopeSelectSign  => _tr ? 'Burcunu Seç'          : _es ? 'Elige tu signo'         : _de ? 'Wähle dein Zeichen'   : _fr ? 'Choisis ton signe'    : _pt ? 'Escolha seu signo'     : 'Select Your Sign';
  String get horoscopeLoading     => _tr ? 'Yıldızlar konuşuyor..': _es ? 'Las estrellas hablan..': _de ? 'Die Sterne sprechen..': _fr ? 'Les étoiles parlent..': _pt ? 'As estrelas falam...'  : 'The stars are speaking...';
  String get horoscopeReadAgain   => _tr ? 'Yeniden Bak'          : _es ? 'Ver de nuevo'           : _de ? 'Nochmal lesen'        : _fr ? 'Relire'               : _pt ? 'Ler novamente'         : 'Read Again';
  String get horoscopeTodayEnergy => _tr ? 'Bugünkü Enerji Skoru' : _es ? 'Energía de hoy'         : _de ? 'Energie heute'        : _fr ? 'Énergie d\'aujourd\'hui' : _pt ? 'Energia de hoje'    : 'Today\'s Energy Score';

  // Burç isimleri
  String get signAries       => _tr ? 'Koç'     : _es ? 'Aries'     : _de ? 'Widder'     : _fr ? 'Bélier'     : _pt ? 'Áries'     : 'Aries';
  String get signTaurus      => _tr ? 'Boğa'    : _es ? 'Tauro'     : _de ? 'Stier'      : _fr ? 'Taureau'    : _pt ? 'Touro'     : 'Taurus';
  String get signGemini      => _tr ? 'İkizler' : _es ? 'Géminis'   : _de ? 'Zwillinge'  : _fr ? 'Gémeaux'    : _pt ? 'Gêmeos'    : 'Gemini';
  String get signCancer      => _tr ? 'Yengeç'  : _es ? 'Cáncer'    : _de ? 'Krebs'      : _fr ? 'Cancer'     : _pt ? 'Câncer'    : 'Cancer';
  String get signLeo         => _tr ? 'Aslan'   : _es ? 'Leo'        : _de ? 'Löwe'       : _fr ? 'Lion'       : _pt ? 'Leão'      : 'Leo';
  String get signVirgo       => _tr ? 'Başak'   : _es ? 'Virgo'      : _de ? 'Jungfrau'   : _fr ? 'Vierge'     : _pt ? 'Virgem'    : 'Virgo';
  String get signLibra       => _tr ? 'Terazi'  : _es ? 'Libra'      : _de ? 'Waage'      : _fr ? 'Balance'    : _pt ? 'Libra'     : 'Libra';
  String get signScorpio     => _tr ? 'Akrep'   : _es ? 'Escorpio'   : _de ? 'Skorpion'   : _fr ? 'Scorpion'   : _pt ? 'Escorpião' : 'Scorpio';
  String get signSagittarius => _tr ? 'Yay'     : _es ? 'Sagitario'  : _de ? 'Schütze'    : _fr ? 'Sagittaire' : _pt ? 'Sagitário' : 'Sagittarius';
  String get signCapricorn   => _tr ? 'Oğlak'   : _es ? 'Capricornio': _de ? 'Steinbock'  : _fr ? 'Capricorne' : _pt ? 'Capricórnio' : 'Capricorn';
  String get signAquarius    => _tr ? 'Kova'    : _es ? 'Acuario'    : _de ? 'Wassermann' : _fr ? 'Verseau'    : _pt ? 'Aquário'   : 'Aquarius';
  String get signPisces      => _tr ? 'Balık'   : _es ? 'Piscis'     : _de ? 'Fische'     : _fr ? 'Poissons'   : _pt ? 'Peixes'    : 'Pisces';

  // ── Coffee Reading ────────────────────────────────────────────────────────────
  String get coffeeTitle        => _tr ? 'Kahve Falı'                  : _es ? 'Lectura de café'             : _de ? 'Kaffeesatz'                 : _fr ? 'Marc de café'                : _pt ? 'Borra de café'               : 'Coffee Reading';
  String get coffeeInstruction  => _tr ? 'Fincanını çevir, bekle, fotoğraf çek' : _es ? 'Da vuelta a la taza, espera, toma foto' : _de ? 'Drehe die Tasse, warte, Foto machen' : _fr ? 'Retourne la tasse, attends, prends une photo' : _pt ? 'Vire a xícara, espere, tire foto' : 'Turn the cup, wait, take a photo';
  String get coffeeUploadPhoto  => _tr ? 'Fotoğraf Yükle'              : _es ? 'Subir foto'                  : _de ? 'Foto hochladen'              : _fr ? 'Télécharger photo'             : _pt ? 'Enviar foto'                 : 'Upload Photo';
  String get coffeeTakePhoto    => _tr ? 'Fotoğraf Çek'                : _es ? 'Tomar foto'                  : _de ? 'Foto aufnehmen'              : _fr ? 'Prendre une photo'             : _pt ? 'Tirar foto'                  : 'Take Photo';
  String get coffeeAnalyzing    => _tr ? 'Fincan okunuyor...'          : _es ? 'Leyendo la taza...'          : _de ? 'Tasse wird gelesen...'       : _fr ? 'Lecture de la tasse...'        : _pt ? 'Lendo a xícara...'           : 'Reading the cup...';
  String get coffeeResult       => _tr ? 'Falın Hazır!'                : _es ? '¡Tu lectura está lista!'     : _de ? 'Deine Lesung ist bereit!'    : _fr ? 'Ta lecture est prête !'         : _pt ? 'Sua leitura está pronta!'    : 'Your Reading is Ready!';

  // ── Tarot ─────────────────────────────────────────────────────────────────────
  String get tarotTitle         => _tr ? 'Tarot'                       : _es ? 'Tarot'                       : _de ? 'Tarot'                       : _fr ? 'Tarot'                        : _pt ? 'Tarô'                        : 'Tarot';
  String get tarotInstruction   => _tr ? '3 kart seç — geçmiş, bugün, gelecek' : _es ? 'Elige 3 cartas — pasado, presente, futuro' : _de ? 'Wähle 3 Karten — Vergangenheit, Gegenwart, Zukunft' : _fr ? 'Choisissez 3 cartes — passé, présent, futur' : _pt ? 'Escolha 3 cartas — passado, presente, futuro' : 'Choose 3 cards — past, present, future';
  String get tarotDrawCards     => _tr ? 'Kartları Çek'                : _es ? 'Sacar cartas'                : _de ? 'Karten ziehen'               : _fr ? 'Tirer les cartes'              : _pt ? 'Comprar cartas'              : 'Draw Cards';
  String get tarotReading       => _tr ? 'Tarot Yorumu'                : _es ? 'Interpretación del tarot'    : _de ? 'Tarot-Deutung'               : _fr ? 'Lecture du tarot'              : _pt ? 'Leitura do tarô'             : 'Tarot Reading';
  String get tarotInterpreting  => _tr ? 'Kartlar yorumlanıyor...'    : _es ? 'Interpretando las cartas...' : _de ? 'Karten werden gedeutet...'   : _fr ? 'Interprétation des cartes...'  : _pt ? 'Interpretando as cartas...'  : 'Interpreting the cards...';
  String get tarotCardPast      => _tr ? 'Geçmiş'    : _es ? 'Pasado'    : _de ? 'Vergangenheit' : _fr ? 'Passé'    : _pt ? 'Passado'    : 'Past';
  String get tarotCardPresent   => _tr ? 'Bugün'     : _es ? 'Presente'  : _de ? 'Gegenwart'    : _fr ? 'Présent'  : _pt ? 'Presente'   : 'Present';
  String get tarotCardFuture    => _tr ? 'Gelecek'   : _es ? 'Futuro'    : _de ? 'Zukunft'      : _fr ? 'Futur'    : _pt ? 'Futuro'     : 'Future';

  // ── Paywall ───────────────────────────────────────────────────────────────────
  String get paywallTitle       => _tr ? 'Nazar Premium'               : _es ? 'Nazar Premium'               : _de ? 'Nazar Premium'               : _fr ? 'Nazar Premium'                : _pt ? 'Nazar Premium'               : 'Nazar Premium';
  String get paywallSubtitle    => _tr ? 'Sınırsız fal, sıfır reklam'  : _es ? 'Lecturas ilimitadas, sin anuncios' : _de ? 'Unbegrenzte Lesungen, keine Werbung' : _fr ? 'Lectures illimitées, sans pub' : _pt ? 'Leituras ilimitadas, sem anúncios' : 'Unlimited readings, zero ads';
  String get paywallBenefit1    => _tr ? 'Sınırsız günlük fal'         : _es ? 'Lecturas diarias ilimitadas'  : _de ? 'Unbegrenzte Tageslesungen'   : _fr ? 'Lectures quotidiennes illimitées' : _pt ? 'Leituras diárias ilimitadas' : 'Unlimited daily readings';
  String get paywallBenefit2    => _tr ? 'Reklamsız deneyim'           : _es ? 'Experiencia sin anuncios'     : _de ? 'Werbefreies Erlebnis'        : _fr ? 'Expérience sans publicité'     : _pt ? 'Experiência sem anúncios'    : 'Ad-free experience';
  String get paywallBenefit3    => _tr ? 'Öncelikli AI yorumu'         : _es ? 'Interpretación AI prioritaria': _de ? 'Bevorzugte KI-Deutung'       : _fr ? 'Interprétation IA prioritaire' : _pt ? 'Interpretação IA prioritária' : 'Priority AI reading';
  String get paywallBenefit4    => _tr ? 'Yorumları kaydet ve paylaş'  : _es ? 'Guardar y compartir lecturas' : _de ? 'Lesungen speichern und teilen': _fr ? 'Sauvegarder et partager'        : _pt ? 'Salvar e compartilhar'       : 'Save and share readings';
  String get paywallMonthly     => _tr ? 'Aylık'   : _es ? 'Mensual'  : _de ? 'Monatlich' : _fr ? 'Mensuel'  : _pt ? 'Mensal'   : 'Monthly';
  String get paywallAnnual      => _tr ? 'Yıllık'  : _es ? 'Anual'    : _de ? 'Jährlich'  : _fr ? 'Annuel'   : _pt ? 'Anual'    : 'Annual';
  String get paywallMostPopular => _tr ? 'En Popüler' : _es ? 'Más popular' : _de ? 'Beliebteste' : _fr ? 'Plus populaire' : _pt ? 'Mais popular' : 'Most Popular';
  String get paywallSavePercent => _tr ? '%40 tasarruf' : _es ? 'Ahorra un 40%' : _de ? '40% sparen' : _fr ? 'Économisez 40%' : _pt ? 'Economize 40%' : 'Save 40%';
  String get paywallFreeTrial   => _tr ? '7 gün ücretsiz dene' : _es ? 'Prueba gratuita 7 días' : _de ? '7 Tage kostenlos testen' : _fr ? 'Essai gratuit 7 jours' : _pt ? 'Teste grátis 7 dias' : '7-day free trial';
  String get paywallStartTrial  => _tr ? 'Ücretsiz Başla'      : _es ? 'Comenzar gratis'         : _de ? 'Kostenlos starten'       : _fr ? 'Commencer gratuitement' : _pt ? 'Começar grátis'       : 'Start Free Trial';
  String get paywallRestore     => _tr ? 'Satın Alımları Geri Yükle' : _es ? 'Restaurar compras' : _de ? 'Käufe wiederherstellen' : _fr ? 'Restaurer les achats' : _pt ? 'Restaurar compras' : 'Restore Purchases';
  String get paywallTerms       => _tr ? 'Kullanım Koşulları'  : _es ? 'Términos de uso'         : _de ? 'Nutzungsbedingungen'    : _fr ? 'Conditions d\'utilisation' : _pt ? 'Termos de uso'    : 'Terms of Use';
  String get paywallPrivacy     => _tr ? 'Gizlilik Politikası' : _es ? 'Política de privacidad'  : _de ? 'Datenschutzrichtlinie' : _fr ? 'Politique de confidentialité' : _pt ? 'Política de privacidade' : 'Privacy Policy';
  String get paywallCancelAnytime => _tr ? 'İstediğin zaman iptal et' : _es ? 'Cancela cuando quieras' : _de ? 'Jederzeit kündbar' : _fr ? 'Annulez à tout moment' : _pt ? 'Cancele quando quiser' : 'Cancel anytime';

  // ── Settings ──────────────────────────────────────────────────────────────────
  String get settingsTitle         => _tr ? 'Ayarlar'       : _es ? 'Ajustes'          : _de ? 'Einstellungen'    : _fr ? 'Paramètres'         : _pt ? 'Configurações'     : 'Settings';
  String get settingsLanguage      => _tr ? 'Dil'           : _es ? 'Idioma'            : _de ? 'Sprache'          : _fr ? 'Langue'             : _pt ? 'Idioma'            : 'Language';
  String get settingsAccount       => _tr ? 'Hesap'         : _es ? 'Cuenta'            : _de ? 'Konto'            : _fr ? 'Compte'             : _pt ? 'Conta'             : 'Account';
  String get settingsPremium       => _tr ? 'Premium'       : _es ? 'Premium'           : _de ? 'Premium'          : _fr ? 'Premium'            : _pt ? 'Premium'           : 'Premium';
  String get settingsDeleteAccount => _tr ? 'Hesabı Sil'   : _es ? 'Eliminar cuenta'    : _de ? 'Konto löschen'    : _fr ? 'Supprimer le compte': _pt ? 'Excluir conta'     : 'Delete Account';
  String get settingsPrivacyPolicy => _tr ? 'Gizlilik'     : _es ? 'Privacidad'         : _de ? 'Datenschutz'      : _fr ? 'Confidentialité'    : _pt ? 'Privacidade'       : 'Privacy Policy';
  String get settingsTerms         => _tr ? 'Kullanım Koşulları' : _es ? 'Términos'     : _de ? 'Nutzungsbedingungen' : _fr ? 'Conditions'      : _pt ? 'Termos'            : 'Terms of Use';
  String get settingsVersion       => _tr ? 'Sürüm'        : _es ? 'Versión'            : _de ? 'Version'          : _fr ? 'Version'            : _pt ? 'Versão'            : 'Version';

  // ── Ad / Premium Gate ─────────────────────────────────────────────────────────
  String get adLoadingMessage    => _tr ? 'Kısa bir reklam...'        : _es ? 'Un breve anuncio...'         : _de ? 'Kurze Werbung...'           : _fr ? 'Une brève publicité...'       : _pt ? 'Um breve anúncio...'          : 'Brief ad loading...';
  String get premiumGateMessage  => _tr ? 'Premium üyeler bu özelliği sınırsız kullanabilir' : _es ? 'Los miembros premium pueden usar esto ilimitado' : _de ? 'Premium-Mitglieder können dies unbegrenzt nutzen' : _fr ? 'Les membres premium peuvent l\'utiliser sans limite' : _pt ? 'Membros premium podem usar isso sem limite' : 'Premium members can use this unlimited';
  String get limitReachedTitle   => _tr ? 'Günlük Limit Doldu'        : _es ? 'Límite diario alcanzado'     : _de ? 'Tageslimit erreicht'         : _fr ? 'Limite quotidienne atteinte'  : _pt ? 'Limite diário atingido'        : 'Daily Limit Reached';
  String get limitReachedBody    => _tr ? 'Bugün 3 fal hakkını kullandın. Premium\'a geç veya yarın tekrar dene.' : _es ? 'Usaste tus 3 lecturas de hoy. Mejora a Premium o vuelve mañana.' : _de ? 'Du hast heute 3 Lesungen verwendet. Wechsle zu Premium oder komm morgen wieder.' : _fr ? 'Tu as utilisé tes 3 lectures d\'aujourd\'hui. Passe Premium ou reviens demain.' : _pt ? 'Você usou suas 3 leituras de hoje. Vá para Premium ou volte amanhã.' : 'You used your 3 readings today. Go Premium or come back tomorrow.';

  // ── Legal / Consent ───────────────────────────────────────────────────────────
  String get onboardingLegalConsent => _tr ? 'Devam ederek Kullanım Koşulları ve Gizlilik Politikamızı kabul etmiş olursunuz.' : _es ? 'Al continuar, aceptas nuestros Términos y Política de privacidad.' : _de ? 'Mit dem Fortfahren stimmst du unseren Nutzungsbedingungen und Datenschutzrichtlinien zu.' : _fr ? 'En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.' : _pt ? 'Ao continuar, você concorda com nossos Termos e Política de Privacidade.' : 'By continuing, you agree to our Terms & Privacy Policy.';
  String get paywallMonthlyPrice    => _tr ? '\$2,99 / ay' : _es ? '\$2,99 / mes' : _de ? '\$2,99 / Monat' : _fr ? '\$2,99 / mois' : _pt ? '\$2,99 / mês' : '\$2.99 / month';
}
