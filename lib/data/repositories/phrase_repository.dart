import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/game_enums.dart';
import '../models/phrase.dart';

/// In-memory repository for the 100,000 bundled Greek pantomime phrases
class PhraseRepository {
  final Random _random;
  bool _isInitialized = false;

  final List<Phrase> _allPhrases = [];
  final Map<DifficultyCategory, List<Phrase>> _phrasesByCategory = {
    DifficultyCategory.easy: [],
    DifficultyCategory.medium: [],
    DifficultyCategory.hard: [],
    DifficultyCategory.impossible: [],
  };

  final Set<String> _usedPhraseIds = {};

  PhraseRepository({Random? random}) : _random = random ?? Random();

  bool get isInitialized => _isInitialized;
  int get totalPhrases => _allPhrases.length;
  int get usedPhrasesCount => _usedPhraseIds.length;

  /// Loads and parses the bundled JSON asset into memory
  Future<void> initialize({
    String assetPath = 'assets/data/phrases_el.json',
    AssetBundle? bundle,
  }) async {
    if (_isInitialized && _allPhrases.isNotEmpty) return;

    final targetBundle = bundle ?? rootBundle;
    final jsonString = await targetBundle.loadString(assetPath);
    final data = json.decode(jsonString) as Map<String, dynamic>;

    final rawPhrases = data['phrases'] as List<dynamic>? ?? [];

    _allPhrases.clear();
    for (var cat in DifficultyCategory.values) {
      _phrasesByCategory[cat]!.clear();
    }
    _usedPhraseIds.clear();

    for (var item in rawPhrases) {
      if (item is Map<String, dynamic>) {
        final phrase = Phrase.fromJson(item);
        if (phrase.text.isNotEmpty) {
          _allPhrases.add(phrase);
          _phrasesByCategory[phrase.difficulty]?.add(phrase);
        }
      }
    }

    _isInitialized = true;
  }

  /// Manually loads phrases (useful for unit testing without rootBundle)
  void loadFromPhrases(List<Phrase> phrases) {
    _allPhrases.clear();
    for (var cat in DifficultyCategory.values) {
      _phrasesByCategory[cat]!.clear();
    }
    _usedPhraseIds.clear();

    for (var p in phrases) {
      _allPhrases.add(p);
      _phrasesByCategory[p.difficulty]?.add(p);
    }
    _isInitialized = true;
  }

  /// Retrieves all phrases belonging to a specific category
  List<Phrase> getPhrasesByCategory(DifficultyCategory category) {
    return List.unmodifiable(_phrasesByCategory[category] ?? []);
  }

  /// Returns a random phrase according to allowed difficulties and exclusions.
  /// Prevents repeated phrases in the session and resets history when exhausted.
  Phrase getRandomPhrase({
    Set<DifficultyCategory>? allowedDifficulties,
    Phrase? currentPhrase,
  }) {
    if (!_isInitialized || _allPhrases.isEmpty) {
      throw StateError(
        'PhraseRepository is not initialized or contains no phrases.',
      );
    }

    final allowed =
        allowedDifficulties != null && allowedDifficulties.isNotEmpty
        ? allowedDifficulties
        : DifficultyCategory.values.toSet();

    // Efficient pool resolution without unnecessary copying
    final List<Phrase> pool;
    if (allowed.length == DifficultyCategory.values.length) {
      pool = _allPhrases;
    } else if (allowed.length == 1) {
      pool = _phrasesByCategory[allowed.first] ?? _allPhrases;
    } else {
      final combined = <Phrase>[];
      for (var cat in allowed) {
        combined.addAll(_phrasesByCategory[cat] ?? []);
      }
      pool = combined.isNotEmpty ? combined : _allPhrases;
    }

    // Fast-path: sample randomly to avoid allocating large filtered lists
    if (_usedPhraseIds.length < pool.length) {
      for (int attempt = 0; attempt < 15; attempt++) {
        final candidate = pool[_random.nextInt(pool.length)];
        if (!_usedPhraseIds.contains(candidate.id) &&
            (currentPhrase == null ||
                candidate.id != currentPhrase.id ||
                pool.length <= 1)) {
          _usedPhraseIds.add(candidate.id);
          return candidate;
        }
      }
    }

    // Exhaustive fallback: filter out phrases that have already been used in this session
    List<Phrase> available = pool
        .where((p) => !_usedPhraseIds.contains(p.id))
        .toList();

    // If all eligible phrases have been used, reset session history for this pool
    if (available.isEmpty) {
      for (var p in pool) {
        _usedPhraseIds.remove(p.id);
      }
      available = List.from(pool);
    }

    // Exclude the current phrase if there are alternative options
    if (currentPhrase != null && available.length > 1) {
      available = available.where((p) => p.id != currentPhrase.id).toList();
    }

    final selected = available[_random.nextInt(available.length)];
    _usedPhraseIds.add(selected.id);
    return selected;
  }

  /// Resets the history of used phrases
  void resetHistory() {
    _usedPhraseIds.clear();
  }
}
