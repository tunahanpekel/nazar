// lib/core/theme/app_theme.dart
//
// Nazar — Mistik, koyu, mor-lacivert renk paleti.
// Fal uygulamasına uygun gizemli atmosfer.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Nazar Brand Palette — Mistik Gece ────────────────────────────────────

  // Backgrounds — derin mor-lacivert
  static const Color bgDeep        = Color(0xFF0A0A1A); // En koyu arka plan
  static const Color bgMid         = Color(0xFF12102A); // Kartlar
  static const Color bgSurface     = Color(0xFF1E1A3A); // Yükseltilmiş yüzey
  static const Color bgBorder      = Color(0xFF2D2850); // Kenarlıklar

  // Primary — mistik mor
  static const Color primary       = Color(0xFF8B5CF6); // Violet
  static const Color primaryDark   = Color(0xFF6D28D9);

  // Accent — altın/amber — fal teması
  static const Color accent        = Color(0xFFF59E0B); // Altın
  static const Color accentDark    = Color(0xFFD97706);

  // Supporting — mistik renkler
  static const Color accentTeal    = Color(0xFF14B8A6); // Turkuaz
  static const Color accentRose    = Color(0xFFEC4899); // Pembe — kahve falı
  static const Color accentIndigo  = Color(0xFF6366F1); // İndigo — tarot

  // Text
  static const Color textPrimary   = Color(0xFFF5F3FF); // Krem beyaz
  static const Color textSecondary = Color(0xFF9D8EC5); // Soluk mor
  static const Color textHint      = Color(0xFF4C4580); // Çok soluk

  // Semantic
  static const Color success       = Color(0xFF10B981);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color error         = Color(0xFFEF4444);

  // ─── Gradients ────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0B20), Color(0xFF0A0A1A)],
  );

  // Kahve falı için özel gradient
  static const LinearGradient coffeeGradient = LinearGradient(
    colors: [Color(0xFF3D1A0A), Color(0xFF1A0D05)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Tarot için özel gradient
  static const LinearGradient tarotGradient = LinearGradient(
    colors: [Color(0xFF1A0D3D), Color(0xFF0A0A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Typography ───────────────────────────────────────────────────────────

  static TextStyle get displayLarge  => GoogleFonts.cinzel(fontSize: 36, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: 1.5, height: 1.1);
  static TextStyle get displayMedium => GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 1.0, height: 1.15);
  static TextStyle get headlineLarge => GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.5, height: 1.2);
  static TextStyle get headlineMedium=> GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary, height: 1.3);
  static TextStyle get titleLarge    => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary, height: 1.35);
  static TextStyle get titleMedium   => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary, height: 1.4);
  static TextStyle get bodyLarge     => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.6);
  static TextStyle get bodyMedium    => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.6);
  static TextStyle get labelLarge    => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.2);
  static TextStyle get labelMedium   => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary, letterSpacing: 0.3);
  static TextStyle get labelSmall    => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textHint, letterSpacing: 0.5);

  // Fal yorumu için özel — italic, mistik
  static TextStyle get readingText   => GoogleFonts.lora(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary, fontStyle: FontStyle.italic, height: 1.8);

  // ─── ThemeData ────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,

      colorScheme: const ColorScheme.dark(
        primary:                  primary,
        primaryContainer:         Color(0xFF1E0A4A),
        onPrimary:                textPrimary,
        secondary:                accent,
        secondaryContainer:       Color(0xFF2A1A00),
        onSecondary:              bgDeep,
        tertiary:                 accentTeal,
        tertiaryContainer:        Color(0xFF0A2020),
        onTertiary:               bgDeep,
        surface:                  bgMid,
        surfaceContainerHighest:  bgSurface,
        onSurface:                textPrimary,
        onSurfaceVariant:         textSecondary,
        outline:                  bgBorder,
        error:                    error,
        onError:                  bgDeep,
        // ignore: deprecated_member_use
        background:               bgDeep,
      ),

      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge:   displayLarge,
        displayMedium:  displayMedium,
        headlineLarge:  headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge:     titleLarge,
        titleMedium:    titleMedium,
        bodyLarge:      bodyLarge,
        bodyMedium:     bodyMedium,
        labelLarge:     labelLarge,
        labelMedium:    labelMedium,
        labelSmall:     labelSmall,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: headlineLarge,
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      cardTheme: CardThemeData(
        color: bgMid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: bgBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: labelLarge.copyWith(fontSize: 16),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: bgDeep,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: labelLarge.copyWith(fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: bgBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:         OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: bgBorder)),
        enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: bgBorder)),
        focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 1.5)),
        labelStyle: bodyMedium,
        hintStyle:  labelMedium,
      ),

      dividerTheme: const DividerThemeData(color: bgBorder, thickness: 1, space: 1),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgMid,
        selectedItemColor: accent,
        unselectedItemColor: textHint,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgSurface,
        contentTextStyle: bodyMedium.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: bgMid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: bgBorder),
        ),
        titleTextStyle:   headlineMedium,
        contentTextStyle: bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgMid,
        modalBackgroundColor: bgMid,
        showDragHandle: true,
        dragHandleColor: bgBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: bgBorder,
        circularTrackColor: bgBorder,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
