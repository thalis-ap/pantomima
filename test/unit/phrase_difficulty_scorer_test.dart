import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/data/models/phrase_difficulty_scorer.dart';

void main() {
  group('PhraseDifficultyScorer Unit Tests', () {
    const defaultScorer = PhraseDifficultyScorer();

    test(
      'Familiar, concrete, everyday phrase yields low semantic difficulty score',
      () {
        final breakdown = defaultScorer.score('Το παιδί τρώει μήλο');
        expect(breakdown.compositeScore, lessThan(35.0));
        expect(breakdown.wordFamiliarity, greaterThanOrEqualTo(80.0));
        expect(breakdown.semanticAbstractness, lessThan(20.0));
        expect(breakdown.actionComplexity, lessThan(30.0));
      },
    );

    test(
      'Culturally specific concept increases cultural specificity signal and score',
      () {
        final universalBreakdown = defaultScorer.score('Ο άντρας χορεύει');
        final culturalBreakdown = defaultScorer.score(
          'Ο κουμπάρος χορεύει ζεϊμπέκικο',
        );

        expect(
          culturalBreakdown.culturalSpecificity,
          greaterThan(universalBreakdown.culturalSpecificity),
        );
        expect(
          culturalBreakdown.compositeScore,
          greaterThan(universalBreakdown.compositeScore),
        );
      },
    );

    test(
      'Multi-stage complex goal yields high action and scenario complexity',
      () {
        final simpleBreakdown = defaultScorer.score('Ο σερβιτόρος περπατάει');
        final complexBreakdown = defaultScorer.score(
          'Ο σερβιτόρος προσπαθεί να ισορροπήσει γεμάτους δίσκους',
        );

        expect(
          complexBreakdown.actionComplexity,
          greaterThan(simpleBreakdown.actionComplexity),
        );
        expect(
          complexBreakdown.scenarioComplexity,
          greaterThan(simpleBreakdown.scenarioComplexity),
        );
        expect(
          complexBreakdown.compositeScore,
          greaterThan(simpleBreakdown.compositeScore),
        );
      },
    );

    test('Abstract mental phrase yields high abstractness and ambiguity', () {
      final concreteBreakdown = defaultScorer.score('Η γιαγιά πλένει πιάτα');
      final abstractBreakdown = defaultScorer.score(
        'Ο καθηγητής προβληματίζεται και σκέφτεται',
      );

      expect(
        abstractBreakdown.semanticAbstractness,
        greaterThan(concreteBreakdown.semanticAbstractness),
      );
      expect(
        abstractBreakdown.ambiguity,
        greaterThan(concreteBreakdown.ambiguity),
      );
      expect(
        abstractBreakdown.compositeScore,
        greaterThan(concreteBreakdown.compositeScore),
      );
    });

    test('Configurable weights predictably alter composite ranking', () {
      const phrase = 'Ο κουμπάρος χορεύει ζεϊμπέκικο';

      // Heavy cultural weight vs zero cultural weight
      const heavyCulturalScorer = PhraseDifficultyScorer(
        weights: DifficultySignalWeights(
          culturalSpecificity: 0.80,
          wordFamiliarity: 0.04,
          semanticAbstractness: 0.04,
          actionComplexity: 0.04,
          guessability: 0.04,
          scenarioComplexity: 0.04,
        ),
      );

      const noCulturalScorer = PhraseDifficultyScorer(
        weights: DifficultySignalWeights(
          culturalSpecificity: 0.0,
          wordFamiliarity: 0.20,
          semanticAbstractness: 0.20,
          actionComplexity: 0.20,
          guessability: 0.20,
          scenarioComplexity: 0.20,
        ),
      );

      final heavyScore = heavyCulturalScorer.score(phrase).compositeScore;
      final noScore = noCulturalScorer.score(phrase).compositeScore;

      expect(heavyScore, greaterThan(noScore));
    });
  });
}
