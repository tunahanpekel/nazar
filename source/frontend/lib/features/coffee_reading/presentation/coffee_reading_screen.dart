// lib/features/coffee_reading/presentation/coffee_reading_screen.dart
//
// Kahve falı — kullanıcı fotoğraf çeker/yükler, Claude Vision analiz eder.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/reading_model.dart';
import '../../../shared/widgets/loading_overlay.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum CoffeeReadingState { initial, imageSelected, loading, result, error }

class CoffeeReadingNotifier extends StateNotifier<CoffeeReadingState> {
  CoffeeReadingNotifier() : super(CoffeeReadingState.initial);

  File? selectedImage;
  CoffeeReading? reading;
  String? errorMessage;

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (picked != null) {
        selectedImage = File(picked.path);
        state = CoffeeReadingState.imageSelected;
      }
    } catch (e) {
      errorMessage = e.toString();
      state = CoffeeReadingState.error;
    }
  }

  Future<void> analyzeImage(String language) async {
    if (selectedImage == null) return;
    state = CoffeeReadingState.loading;

    try {
      // Kimlik doğrulama kontrolü — anonim dahil tüm kullanıcıların oturum açmış olması gerekir.
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        errorMessage = 'User is not authenticated. Please sign in to continue.';
        state = CoffeeReadingState.error;
        return;
      }

      // Resmi Supabase Storage'a kullanıcıya özgü yola yükle.
      final userId = currentUser.id;
      final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await selectedImage!.readAsBytes();

      await Supabase.instance.client.storage
          .from('coffee-readings')
          .uploadBinary(filename, bytes);

      // Gizlilik için signed URL kullan (1 saat geçerli).
      final imageUrl = await Supabase.instance.client.storage
          .from('coffee-readings')
          .createSignedUrl(filename, 3600);

      // Edge function ile analiz et
      final response = await Supabase.instance.client.functions.invoke(
        SupabaseClientService.fnReadCoffee,
        body: {
          'image_url': imageUrl,
          'language':  language,
        },
      );

      if (response.status != 200) {
        throw Exception('Analysis failed: ${response.status}');
      }

      reading = CoffeeReading.fromJson(response.data as Map<String, dynamic>);
      state = CoffeeReadingState.result;
    } catch (e) {
      errorMessage = e.toString();
      state = CoffeeReadingState.error;
    }
  }

  void reset() {
    selectedImage = null;
    reading = null;
    errorMessage = null;
    state = CoffeeReadingState.initial;
  }
}

final coffeeReadingProvider =
    StateNotifierProvider.autoDispose<CoffeeReadingNotifier, CoffeeReadingState>(
  (ref) => CoffeeReadingNotifier(),
);

// ─── CoffeeReadingScreen ──────────────────────────────────────────────────────

class CoffeeReadingScreen extends ConsumerWidget {
  const CoffeeReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final state = ref.watch(coffeeReadingProvider);
    final notifier = ref.read(coffeeReadingProvider.notifier);
    final lang = ref.read(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text(s.coffeeTitle),
        backgroundColor: Colors.transparent,
      ),
      body: switch (state) {
        CoffeeReadingState.initial     => _InitialView(notifier: notifier),
        CoffeeReadingState.imageSelected => _ImageSelectedView(
            notifier: notifier,
            language: lang,
          ),
        CoffeeReadingState.loading     => MysticalLoader(message: s.coffeeAnalyzing),
        CoffeeReadingState.result      => _ResultView(notifier: notifier),
        CoffeeReadingState.error       => ErrorView(
            message: notifier.errorMessage ?? s.commonError,
            onRetry: notifier.reset,
          ),
      },
    );
  }
}

// ─── Initial View ─────────────────────────────────────────────────────────────

class _InitialView extends ConsumerWidget {
  const _InitialView({required this.notifier});
  final CoffeeReadingNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('☕', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            s.coffeeInstruction,
            style: AppTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(s.coffeeTakePhoto),
              onPressed: () => notifier.pickImage(ImageSource.camera),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(s.coffeeUploadPhoto),
              onPressed: () => notifier.pickImage(ImageSource.gallery),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Image Selected View ──────────────────────────────────────────────────────

class _ImageSelectedView extends ConsumerWidget {
  const _ImageSelectedView({
    required this.notifier,
    required this.language,
  });

  final CoffeeReadingNotifier notifier;
  final String language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                notifier.selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => notifier.analyzeImage(language),
              child: Text(s.coffeeAnalyzing.replaceAll('...', '')),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: notifier.reset,
            child: Text(s.commonBack),
          ),
        ],
      ),
    );
  }
}

// ─── Result View ──────────────────────────────────────────────────────────────

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.notifier});
  final CoffeeReadingNotifier notifier;

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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              notifier.selectedImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('☕', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(s.coffeeResult, style: AppTheme.headlineMedium),
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
