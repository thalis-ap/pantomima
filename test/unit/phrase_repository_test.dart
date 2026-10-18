import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/data/models/game_enums.dart';
import 'package:pantomima/data/models/phrase.dart';
import 'package:pantomima/data/repositories/phrase_repository.dart';

void main() {
  group('PhraseRepository Unit Tests', () {
    late PhraseRepository repository;
    final testPhrases = [
      const Phrase(
        id: 'p1',
        text: 'Ο παππούς χορεύει',
        difficulty: DifficultyCategory.easy,
        wordCount: 3,
        isNonsense: false,
      ),
      const Phrase(
        id: 'p2',
        text: 'Η γιαγιά γελάει',
        difficulty: DifficultyCategory.easy,
        wordCount: 3,
        isNonsense: false,
      ),
      const Phrase(
        id: 'p3',
        text: 'Ο μάγειρας καίει τηγανίτες',
        difficulty: DifficultyCategory.medium,
        wordCount: 4,
        isNonsense: false,
      ),
      const Phrase(
        id: 'p4',
        text: 'Ο σκύλος κρύβει κόκαλο',
        difficulty: DifficultyCategory.medium,
        wordCount: 4,
        isNonsense: false,
      ),
      const Phrase(
        id: 'p5',
        text: 'Ο παππούς χορεύει στο τραπέζι',
        difficulty: DifficultyCategory.hard,
        wordCount: 5,
        isNonsense: false,
      ),
    ];

    setUp(() {
      repository = PhraseRepository(random: Random(42));
      repository.loadFromPhrases(testPhrases);
    });

    test('Initializes and reports total phrases correctly', () {
      expect(repository.isInitialized, isTrue);
      expect(repository.totalPhrases, 5);
      expect(
        repository.getPhrasesByCategory(DifficultyCategory.easy).length,
        2,
      );
      expect(
        repository.getPhrasesByCategory(DifficultyCategory.medium).length,
        2,
      );
      expect(
        repository.getPhrasesByCategory(DifficultyCategory.hard).length,
        1,
      );
      expect(
        repository.getPhrasesByCategory(DifficultyCategory.impossible).length,
        0,
      );
    });

    test('Filters random phrase by allowed difficulties', () {
      final phrase = repository.getRandomPhrase(
        allowedDifficulties: {DifficultyCategory.hard},
      );
      expect(phrase.difficulty, DifficultyCategory.hard);
      expect(phrase.id, 'p5');
    });

    test('Excludes current phrase when alternatives exist', () {
      final first = repository.getRandomPhrase(
        allowedDifficulties: {DifficultyCategory.easy},
      );
      final second = repository.getRandomPhrase(
        allowedDifficulties: {DifficultyCategory.easy},
        currentPhrase: first,
      );
      expect(second.id, isNot(equals(first.id)));
    });

    test('Tracks used phrases and resets history upon exhaustion', () {
      expect(repository.usedPhrasesCount, 0);

      // Fetch hard phrase (only 1 available in test dataset)
      final p1 = repository.getRandomPhrase(
        allowedDifficulties: {DifficultyCategory.hard},
      );
      expect(p1.id, 'p5');
      expect(repository.usedPhrasesCount, 1);

      // Fetching again automatically resets history so a phrase is still returned
      final p2 = repository.getRandomPhrase(
        allowedDifficulties: {DifficultyCategory.hard},
      );
      expect(p2.id, 'p5');
    });

    test('Reset history clears used phrases count', () {
      repository.getRandomPhrase();
      repository.getRandomPhrase();
      expect(repository.usedPhrasesCount, greaterThan(0));

      repository.resetHistory();
      expect(repository.usedPhrasesCount, 0);
    });
  });
}
