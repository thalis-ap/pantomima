import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/data/models/game_enums.dart';
import 'package:pantomima/data/models/phrase.dart';

void main() {
  group('Phrase Model Unit Tests', () {
    test('Correctly parses valid phrase JSON', () {
      final json = {
        'id': 'phrase_000001',
        'text': 'Ο παππούς χορεύει',
        'category': 'Εύκολο',
        'wordCount': 3,
        'isNonsense': false,
      };

      final phrase = Phrase.fromJson(json);

      expect(phrase.id, 'phrase_000001');
      expect(phrase.text, 'Ο παππούς χορεύει');
      expect(phrase.difficulty, DifficultyCategory.easy);
      expect(phrase.wordCount, 3);
      expect(phrase.isNonsense, false);
    });

    test('Handles missing optional and fallback fields gracefully', () {
      final json = {'id': 'phrase_999999', 'text': 'Γάτα πίνει γάλα'};

      final phrase = Phrase.fromJson(json);

      expect(phrase.id, 'phrase_999999');
      expect(phrase.text, 'Γάτα πίνει γάλα');
      expect(phrase.difficulty, DifficultyCategory.medium); // Default fallback
      expect(phrase.wordCount, 3); // Calculated from text
      expect(phrase.isNonsense, false);
    });

    test('Serializes to JSON accurately', () {
      const phrase = Phrase(
        id: 'phrase_000123',
        text: 'Ο μάγειρας καίει τηγανίτες',
        difficulty: DifficultyCategory.medium,
        wordCount: 4,
        isNonsense: false,
      );

      final json = phrase.toJson();

      expect(json['id'], 'phrase_000123');
      expect(json['text'], 'Ο μάγειρας καίει τηγανίτες');
      expect(json['category'], 'Μεσαίο');
      expect(json['wordCount'], 4);
      expect(json['isNonsense'], false);
    });

    test('Strict difficulty word count rules verification', () {
      expect(DifficultyCategory.easy.minWords, 3);
      expect(DifficultyCategory.easy.maxWords, 3);

      expect(DifficultyCategory.medium.minWords, 4);
      expect(DifficultyCategory.medium.maxWords, 4);

      expect(DifficultyCategory.hard.minWords, 5);
      expect(DifficultyCategory.hard.maxWords, 5);

      expect(DifficultyCategory.impossible.minWords, 6);
      expect(DifficultyCategory.impossible.maxWords, 8);
    });

    test('Centralized default durations match requirements', () {
      expect(DifficultyCategory.easy.defaultDurationSeconds, 60);
      expect(DifficultyCategory.medium.defaultDurationSeconds, 90);
      expect(DifficultyCategory.hard.defaultDurationSeconds, 105);
      expect(DifficultyCategory.impossible.defaultDurationSeconds, 120);
    });

    test(
      'Centralized difficulty points match exact scoring rules (Easy=1, Medium=2, Hard=3, Impossible=5)',
      () {
        expect(DifficultyCategory.easy.points, 1);
        expect(DifficultyCategory.medium.points, 2);
        expect(DifficultyCategory.hard.points, 3);
        expect(
          DifficultyCategory.impossible.points,
          5,
        ); // Specifically 5, not 4
      },
    );
  });
}
