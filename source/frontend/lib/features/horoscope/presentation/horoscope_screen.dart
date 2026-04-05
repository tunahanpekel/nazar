// lib/features/horoscope/presentation/horoscope_screen.dart
//
// Günlük burç yorumu — Claude API'den üretilir, sabah 00:00'da yenilenir.
// Burç seçimi → API çağrısı → yorum gösterimi

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/reading_model.dart';
import '../../../shared/widgets/loading_overlay.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final horoscopeProvider = FutureProvider.family<HoroscopeReading, ({ZodiacSign sign, String language})>(
  (ref, params) async {
    final response = await Supabase.instance.client.functions.invoke(
      SupabaseClientService.fnGenerateHoroscope,
      body: {
        'sign':     params.sign.apiName,
        'language': params.language,
        'date':     DateTime.now().toIso8601String().substring(0, 10),
      },
    );
    if (response.status != 200) {
      throw Exception('Horoscope generation failed: ${response.status}');
    }
    return HoroscopeReading.fromJson(response.data as Map<String, dynamic>);
  },
);

// ─── HoroscopeScreen ─────────────────────────────────────────────────────────

class HoroscopeScreen extends ConsumerStatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen> {
  ZodiacSign? _selectedSign;

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final lang = ref.read(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text(s.horoscopeTitle),
        backgroundColor: Colors.transparent,
      ),
      body: _selectedSign == null
          ? _ZodiacGrid(
              onSignSelected: (sign) => setState(() => _selectedSign = sign),
            )
          : _HoroscopeResult(
              sign: _selectedSign!,
              language: lang,
              onBack: () => setState(() => _selectedSign = null),
            ),
    );
  }
}

// ─── Zodiac Selection Grid ────────────────────────────────────────────────────

class _ZodiacGrid extends ConsumerWidget {
  const _ZodiacGrid({required this.onSignSelected});
  final ValueChanged<ZodiacSign> onSignSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    final signs = [
      (ZodiacSign.aries,       s.signAries),
      (ZodiacSign.taurus,      s.signTaurus),
      (ZodiacSign.gemini,      s.signGemini),
      (ZodiacSign.cancer,      s.signCancer),
      (ZodiacSign.leo,         s.signLeo),
      (ZodiacSign.virgo,       s.signVirgo),
      (ZodiacSign.libra,       s.signLibra),
      (ZodiacSign.scorpio,     s.signScorpio),
      (ZodiacSign.sagittarius, s.signSagittarius),
      (ZodiacSign.capricorn,   s.signCapricorn),
      (ZodiacSign.aquarius,    s.signAquarius),
      (ZodiacSign.pisces,      s.signPisces),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.horoscopeSelectSign, style: AppTheme.headlineMedium),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: signs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final (sign, name) = signs[i];
                return _ZodiacTile(
                  sign: sign,
                  name: name,
                  onTap: () => onSignSelected(sign),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ZodiacTile extends StatelessWidget {
  const _ZodiacTile({
    required this.sign,
    required this.name,
    required this.onTap,
  });

  final ZodiacSign sign;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.bgBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(sign.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(name, style: AppTheme.labelMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── Horoscope Result ─────────────────────────────────────────────────────────

class _HoroscopeResult extends ConsumerWidget {
  const _HoroscopeResult({
    required this.sign,
    required this.language,
    required this.onBack,
  });

  final ZodiacSign sign;
  final String language;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final reading = ref.watch(horoscopeProvider((sign: sign, language: language)));

    return reading.when(
      loading: () => MysticalLoader(message: s.horoscopeLoading),
      error: (e, _) => ErrorView(
        message: '${s.commonError}: $e',
        onRetry: () => ref.invalidate(horoscopeProvider((sign: sign, language: language))),
      ),
      data: (data) => _ReadingView(
        sign: sign,
        reading: data,
        onBack: onBack,
      ),
    );
  }
}

class _ReadingView extends ConsumerWidget {
  const _ReadingView({
    required this.sign,
    required this.reading,
    required this.onBack,
  });

  final ZodiacSign sign;
  final HoroscopeReading reading;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Burç başlığı
          Row(
            children: [
              Text(sign.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _signName(s, sign),
                    style: AppTheme.headlineLarge,
                  ),
                  Text(
                    '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Enerji skoru
          _EnergyBar(score: reading.energyScore, label: s.horoscopeTodayEnergy),
          const SizedBox(height: 24),

          // Yorum içeriği
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgMid,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.bgBorder),
            ),
            child: Text(
              reading.content,
              style: AppTheme.readingText,
            ),
          ),
          const SizedBox(height: 24),

          // Geri butonu
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onBack,
              child: Text(s.commonBack),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _signName(S s, ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries:       return s.signAries;
      case ZodiacSign.taurus:      return s.signTaurus;
      case ZodiacSign.gemini:      return s.signGemini;
      case ZodiacSign.cancer:      return s.signCancer;
      case ZodiacSign.leo:         return s.signLeo;
      case ZodiacSign.virgo:       return s.signVirgo;
      case ZodiacSign.libra:       return s.signLibra;
      case ZodiacSign.scorpio:     return s.signScorpio;
      case ZodiacSign.sagittarius: return s.signSagittarius;
      case ZodiacSign.capricorn:   return s.signCapricorn;
      case ZodiacSign.aquarius:    return s.signAquarius;
      case ZodiacSign.pisces:      return s.signPisces;
    }
  }
}

class _EnergyBar extends StatelessWidget {
  const _EnergyBar({required this.score, required this.label});
  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: score / 10,
                  minHeight: 8,
                  backgroundColor: AppTheme.bgBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    score >= 7 ? AppTheme.success : score >= 4 ? AppTheme.warning : AppTheme.error,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('$score/10', style: AppTheme.labelLarge),
          ],
        ),
      ],
    );
  }
}
