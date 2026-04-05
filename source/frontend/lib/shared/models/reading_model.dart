// lib/shared/models/reading_model.dart
//
// Veri modelleri — Nazar
// Horoscope, CoffeeReading, TarotReading, EnergyScore, UserReading

import 'package:flutter/foundation.dart';

// ─── ZodiacSign ───────────────────────────────────────────────────────────────

enum ZodiacSign {
  aries, taurus, gemini, cancer, leo, virgo,
  libra, scorpio, sagittarius, capricorn, aquarius, pisces;

  String get emoji {
    switch (this) {
      case ZodiacSign.aries:       return '♈';
      case ZodiacSign.taurus:      return '♉';
      case ZodiacSign.gemini:      return '♊';
      case ZodiacSign.cancer:      return '♋';
      case ZodiacSign.leo:         return '♌';
      case ZodiacSign.virgo:       return '♍';
      case ZodiacSign.libra:       return '♎';
      case ZodiacSign.scorpio:     return '♏';
      case ZodiacSign.sagittarius: return '♐';
      case ZodiacSign.capricorn:   return '♑';
      case ZodiacSign.aquarius:    return '♒';
      case ZodiacSign.pisces:      return '♓';
    }
  }

  String get apiName => name; // aries, taurus, etc.
}

// ─── ReadingType ──────────────────────────────────────────────────────────────

enum ReadingType { horoscope, coffee, tarot }

// ─── HoroscopeReading ─────────────────────────────────────────────────────────

@immutable
class HoroscopeReading {
  const HoroscopeReading({
    required this.id,
    required this.sign,
    required this.content,
    required this.energyScore,
    required this.date,
    required this.language,
  });

  final String id;
  final ZodiacSign sign;
  final String content;
  final int energyScore; // 1-10
  final DateTime date;
  final String language;

  factory HoroscopeReading.fromJson(Map<String, dynamic> json) {
    return HoroscopeReading(
      id:           json['id'] as String,
      sign:         ZodiacSign.values.firstWhere((s) => s.name == json['sign']),
      content:      json['content'] as String,
      energyScore:  json['energy_score'] as int,
      date:         DateTime.parse(json['date'] as String),
      language:     json['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'sign':         sign.name,
    'content':      content,
    'energy_score': energyScore,
    'date':         date.toIso8601String(),
    'language':     language,
  };
}

// ─── CoffeeReading ────────────────────────────────────────────────────────────

@immutable
class CoffeeReading {
  const CoffeeReading({
    required this.id,
    required this.imageUrl,
    required this.content,
    required this.createdAt,
    required this.language,
  });

  final String id;
  final String imageUrl;
  final String content;
  final DateTime createdAt;
  final String language;

  factory CoffeeReading.fromJson(Map<String, dynamic> json) {
    return CoffeeReading(
      id:        json['id'] as String,
      imageUrl:  json['image_url'] as String,
      content:   json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      language:  json['language'] as String? ?? 'en',
    );
  }
}

// ─── TarotCard ────────────────────────────────────────────────────────────────

@immutable
class TarotCard {
  const TarotCard({
    required this.id,
    required this.name,
    required this.position, // 'past', 'present', 'future'
    required this.isReversed,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String position;
  final bool isReversed;
  final String? imageAsset;

  Map<String, dynamic> toJson() => {
    'id':          id,
    'name':        name,
    'position':    position,
    'is_reversed': isReversed,
  };
}

// ─── TarotReading ─────────────────────────────────────────────────────────────

@immutable
class TarotReading {
  const TarotReading({
    required this.id,
    required this.cards,
    required this.content,
    required this.createdAt,
    required this.language,
  });

  final String id;
  final List<TarotCard> cards;
  final String content;
  final DateTime createdAt;
  final String language;

  factory TarotReading.fromJson(Map<String, dynamic> json) {
    return TarotReading(
      id:        json['id'] as String,
      cards:     (json['cards'] as List)
          .map((c) => TarotCard(
                id:         c['id'] as String,
                name:       c['name'] as String,
                position:   c['position'] as String,
                isReversed: c['is_reversed'] as bool? ?? false,
              ))
          .toList(),
      content:   json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      language:  json['language'] as String? ?? 'en',
    );
  }
}

// ─── UserReadingCount ─────────────────────────────────────────────────────────

@immutable
class UserReadingCount {
  const UserReadingCount({
    required this.date,
    required this.count,
    required this.limit,
  });

  final DateTime date;
  final int count;
  final int limit;

  bool get hasReachedLimit => count >= limit;
  int get remaining => (limit - count).clamp(0, limit);
}
