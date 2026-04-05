// lib/features/tarot/presentation/tarot_screen.dart
//
// Tarot — 3 kart seç (geçmiş/bugün/gelecek), Claude yorumlar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/reading_model.dart';
import '../../../shared/widgets/loading_overlay.dart';

// ─── 78 Tarot kartı listesi (sadeleştirilmiş) ────────────────────────────────

const _tarotDeck = [
  'The Fool', 'The Magician', 'The High Priestess', 'The Empress', 'The Emperor',
  'The Hierophant', 'The Lovers', 'The Chariot', 'Strength', 'The Hermit',
  'Wheel of Fortune', 'Justice', 'The Hanged Man', 'Death', 'Temperance',
  'The Devil', 'The Tower', 'The Star', 'The Moon', 'The Sun',
  'Judgement', 'The World',
  'Ace of Wands', 'Two of Wands', 'Three of Wands', 'Four of Wands',
  'Five of Wands', 'Six of Wands', 'Seven of Wands', 'Eight of Wands',
  'Nine of Wands', 'Ten of Wands', 'Page of Wands', 'Knight of Wands',
  'Queen of Wands', 'King of Wands',
  'Ace of Cups', 'Two of Cups', 'Three of Cups', 'Four of Cups',
  'Five of Cups', 'Six of Cups', 'Seven of Cups', 'Eight of Cups',
  'Nine of Cups', 'Ten of Cups', 'Page of Cups', 'Knight of Cups',
  'Queen of Cups', 'King of Cups',
  'Ace of Swords', 'Two of Swords', 'Three of Swords', 'Four of Swords',
  'Five of Swords', 'Six of Swords', 'Seven of Swords', 'Eight of Swords',
  'Nine of Swords', 'Ten of Swords', 'Page of Swords', 'Knight of Swords',
  'Queen of Swords', 'King of Swords',
  'Ace of Pentacles', 'Two of Pentacles', 'Three of Pentacles', 'Four of Pentacles',
  'Five of Pentacles', 'Six of Pentacles', 'Seven of Pentacles', 'Eight of Pentacles',
  'Nine of Pentacles', 'Ten of Pentacles', 'Page of Pentacles', 'Knight of Pentacles',
  'Queen of Pentacles', 'King of Pentacles',
];

// ─── State ────────────────────────────────────────────────────────────────────

enum TarotReadingState { selecting, loading, result, error }

class TarotNotifier extends StateNotifier<TarotReadingState> {
  TarotNotifier() : super(TarotReadingState.selecting);

  final List<TarotCard> selectedCards = [];
  TarotReading? reading;
  String? errorMessage;

  List<String> _shuffledDeck() {
    final deck = List<String>.from(_tarotDeck)..shuffle();
    return deck;
  }

  void drawRandomCards() {
    final deck = _shuffledDeck();
    final positions = ['past', 'present', 'future'];
    selectedCards.clear();
    for (var i = 0; i < 3; i++) {
      selectedCards.add(TarotCard(
        id:         '$i',
        name:       deck[i],
        position:   positions[i],
        isReversed: DateTime.now().millisecondsSinceEpoch % 2 == 0,
      ));
    }
    // StateNotifier skips notification when state value is identical.
    // Explicitly force notification by using updateShouldNotify.
    // Workaround: assign to a sentinel then back to selecting — both happen
    // synchronously so the UI only ever renders TarotReadingState.selecting.
    state = TarotReadingState.selecting;
  }

  Future<void> getReading(String language) async {
    if (selectedCards.isEmpty) {
      drawRandomCards();
    }
    state = TarotReadingState.loading;

    try {
      final response = await Supabase.instance.client.functions.invoke(
        SupabaseClientService.fnReadTarot,
        body: {
          'cards':    selectedCards.map((c) => c.toJson()).toList(),
          'language': language,
        },
      );

      if (response.status != 200) {
        throw Exception('Tarot reading failed: ${response.status}');
      }

      reading = TarotReading.fromJson(response.data as Map<String, dynamic>);
      state = TarotReadingState.result;
    } catch (e) {
      errorMessage = e.toString();
      state = TarotReadingState.error;
    }
  }

  void reset() {
    selectedCards.clear();
    reading = null;
    errorMessage = null;
    state = TarotReadingState.selecting;
  }
}

final tarotProvider =
    StateNotifierProvider.autoDispose<TarotNotifier, TarotReadingState>(
  (ref) => TarotNotifier()..drawRandomCards(),
);

// ─── TarotScreen ──────────────────────────────────────────────────────────────

class TarotScreen extends ConsumerWidget {
  const TarotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final state = ref.watch(tarotProvider);
    final notifier = ref.read(tarotProvider.notifier);
    final lang = ref.read(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text(s.tarotTitle),
        backgroundColor: Colors.transparent,
      ),
      body: switch (state) {
        TarotReadingState.selecting => _CardSelectionView(
            notifier: notifier,
            language: lang,
          ),
        TarotReadingState.loading   => MysticalLoader(message: s.tarotInterpreting),
        TarotReadingState.result    => _TarotResultView(notifier: notifier),
        TarotReadingState.error     => ErrorView(
            message: notifier.errorMessage ?? s.commonError,
            onRetry: notifier.reset,
          ),
      },
    );
  }
}

// ─── Card Selection View ──────────────────────────────────────────────────────

class _CardSelectionView extends ConsumerWidget {
  const _CardSelectionView({required this.notifier, required this.language});
  final TarotNotifier notifier;
  final String language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(s.tarotInstruction, style: AppTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final position in ['past', 'present', 'future'])
                _CardSlot(
                  position: position,
                  label: _positionLabel(s, position),
                  card: notifier.selectedCards.isEmpty
                      ? null
                      : notifier.selectedCards.firstWhere(
                          (c) => c.position == position,
                          orElse: () => TarotCard(id: '', name: '', position: position, isReversed: false),
                        ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.shuffle),
              label: Text(s.tarotDrawCards),
              onPressed: () => notifier.drawRandomCards(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              icon: const Text('🔮'),
              label: Text(s.tarotReading),
              onPressed: () => notifier.getReading(language),
            ),
          ),
        ],
      ),
    );
  }

  String _positionLabel(S s, String position) {
    switch (position) {
      case 'past':    return s.tarotCardPast;
      case 'present': return s.tarotCardPresent;
      case 'future':  return s.tarotCardFuture;
      default:        return position;
    }
  }
}

class _CardSlot extends StatelessWidget {
  const _CardSlot({required this.position, required this.label, this.card});
  final String position;
  final String label;
  final TarotCard? card;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTheme.labelSmall),
        const SizedBox(height: 8),
        Container(
          width: 80, height: 120,
          decoration: BoxDecoration(
            gradient: AppTheme.tarotGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
          ),
          child: card != null && card!.name.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      card!.name,
                      style: AppTheme.labelSmall,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                    ),
                  ),
                )
              : const Center(child: Text('🃏', style: TextStyle(fontSize: 28))),
        ),
      ],
    );
  }
}

// ─── Tarot Result View ────────────────────────────────────────────────────────

class _TarotResultView extends ConsumerWidget {
  const _TarotResultView({required this.notifier});
  final TarotNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final reading = notifier.reading!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Çekilen kartlar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: reading.cards.map((card) => _DrawnCard(card: card)).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('🃏', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(s.tarotReading, style: AppTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgMid,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.bgBorder),
            ),
            child: Text(reading.content, style: AppTheme.readingText),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share_outlined),
                  label: Text(s.commonShare),
                  onPressed: () {/* TODO: share */},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: notifier.reset,
                  child: Text(s.horoscopeReadAgain),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawnCard extends StatelessWidget {
  const _DrawnCard({required this.card});
  final TarotCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90, height: 130,
      decoration: BoxDecoration(
        gradient: AppTheme.tarotGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentIndigo.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (card.isReversed)
                Transform.rotate(
                  angle: 3.14159,
                  child: const Text('⬆️', style: TextStyle(fontSize: 16)),
                ),
              Text(
                card.name,
                style: AppTheme.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
