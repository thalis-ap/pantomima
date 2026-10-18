import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/data/models/game_enums.dart';
import 'package:pantomima/data/models/phrase.dart';
import 'package:pantomima/data/repositories/phrase_repository.dart';

void main() {
  group('100,000 Phrase Dataset & Processing Tests', () {
    test('DifficultyCategory word count contracts', () {
      expect(DifficultyCategory.easy.minWords, 3);
      expect(DifficultyCategory.easy.maxWords, 3);

      expect(DifficultyCategory.medium.minWords, 4);
      expect(DifficultyCategory.medium.maxWords, 4);

      expect(DifficultyCategory.hard.minWords, 5);
      expect(DifficultyCategory.hard.maxWords, 5);

      expect(DifficultyCategory.impossible.minWords, 6);
      expect(DifficultyCategory.impossible.maxWords, 8);
    });

    test(
      'Phrase model correctly parses entries from the 100k dataset schema',
      () {
        final sampleJson = {
          'id': 'p_000001',
          'text': 'Τοναετό καιτη φωτιά',
          'category': 'Εύκολο',
          'wordCount': 3,
          'difficultyScore': 29.1,
          'isNonsense': false,
        };

        final phrase = Phrase.fromJson(sampleJson);
        expect(phrase.id, 'p_000001');
        expect(phrase.text, 'Τοναετό καιτη φωτιά');
        expect(phrase.difficulty, DifficultyCategory.easy);
        expect(phrase.wordCount, 3);
        expect(phrase.difficultyScore, 29.1);
        expect(phrase.isNonsense, false);
      },
    );

    test(
      'Production JSON asset exists and metadata matches 100,000 phrases',
      () {
        final file = File('assets/data/phrases_el.json');
        expect(
          file.existsSync(),
          isTrue,
          reason: 'assets/data/phrases_el.json must exist',
        );

        final raw = file.readAsStringSync();
        final data = json.decode(raw) as Map<String, dynamic>;

        expect(data['totalPhrases'], 100000);
        expect(data['sourceFile'], 'frases100000.txt');

        final categories = data['categories'] as Map<String, dynamic>;
        expect(categories['Εύκολο'], 25000);
        expect(categories['Μεσαίο'], 25000);
        expect(categories['Δύσκολο'], 25000);
        expect(categories['Ακατόρθωτο'], 25000);

        final wordCounts = data['wordCounts'] as Map<String, dynamic>;
        expect(wordCounts['3'], 25000);
        expect(wordCounts['4'], 25000);
        expect(wordCounts['5'], 25000);
        expect(wordCounts['6'], 7566);
        expect(wordCounts['7'], 8550);
        expect(wordCounts['8'], 8884);

        final phrases = data['phrases'] as List<dynamic>;
        expect(phrases.length, 100000);

        // Verify first and last entries
        final first = phrases.first as Map<String, dynamic>;
        expect(first['id'], 'p_000001');
        expect(first['wordCount'], 3);
        expect(first['category'], 'Εύκολο');

        final last = phrases.last as Map<String, dynamic>;
        expect(last['id'], 'p_100000');
        expect(last['wordCount'], 8);
        expect(last['category'], 'Ακατόρθωτο');
      },
    );

    test(
      'PhraseRepository efficiently loads phrases and performs repeat-free draws',
      () {
        final repo = PhraseRepository();

        final phrases = [
          const Phrase(
            id: 'p_001',
            text: 'Ο παππούς χορεύει',
            difficulty: DifficultyCategory.easy,
            wordCount: 3,
            isNonsense: false,
          ),
          const Phrase(
            id: 'p_002',
            text: 'Η γιαγιά γελάει',
            difficulty: DifficultyCategory.easy,
            wordCount: 3,
            isNonsense: false,
          ),
          const Phrase(
            id: 'p_003',
            text: 'Ο μάγειρας ψήνει μπριζόλες',
            difficulty: DifficultyCategory.medium,
            wordCount: 4,
            isNonsense: false,
          ),
        ];

        repo.loadFromPhrases(phrases);
        expect(repo.totalPhrases, 3);
        expect(repo.getPhrasesByCategory(DifficultyCategory.easy).length, 2);
        expect(repo.getPhrasesByCategory(DifficultyCategory.medium).length, 1);

        // Draw phrases and ensure no immediate repeats
        final p1 = repo.getRandomPhrase(
          allowedDifficulties: {DifficultyCategory.easy},
        );
        final p2 = repo.getRandomPhrase(
          allowedDifficulties: {DifficultyCategory.easy},
          currentPhrase: p1,
        );
        expect(p1.id, isNot(equals(p2.id)));
      },
    );
  });
}
