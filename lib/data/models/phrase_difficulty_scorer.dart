import 'game_enums.dart';

/// Weights configuration for the weighted semantic difficulty model
class DifficultySignalWeights {
  final double wordFamiliarity; // Default: 25% (0.25)
  final double semanticAbstractness; // Default: 20% (0.20)
  final double actionComplexity; // Default: 20% (0.20)
  final double culturalSpecificity; // Default: 15% (0.15)
  final double guessability; // Default: 10% (0.10)
  final double scenarioComplexity; // Default: 10% (0.10)

  const DifficultySignalWeights({
    this.wordFamiliarity = 0.25,
    this.semanticAbstractness = 0.20,
    this.actionComplexity = 0.20,
    this.culturalSpecificity = 0.15,
    this.guessability = 0.10,
    this.scenarioComplexity = 0.10,
  });

  double get totalWeight =>
      wordFamiliarity +
      semanticAbstractness +
      actionComplexity +
      culturalSpecificity +
      guessability +
      scenarioComplexity;
}

/// Detailed signal breakdown for a scored phrase
class DifficultyBreakdown {
  final String text;
  final double compositeScore; // 0.0 (easiest) to 100.0 (hardest)
  final double wordFamiliarity; // 0 (unknown) to 100 (universal)
  final double semanticAbstractness; // 0 (physical/tangible) to 100 (abstract)
  final double
  actionComplexity; // 0 (simple single action) to 100 (multi-stage)
  final double culturalSpecificity; // 0 (universal) to 100 (culturally nuanced)
  final double ambiguity; // 0 (unambiguous) to 100 (vague/multiple meanings)
  final double scenarioComplexity; // 0 (simple) to 100 (intricate)

  const DifficultyBreakdown({
    required this.text,
    required this.compositeScore,
    required this.wordFamiliarity,
    required this.semanticAbstractness,
    required this.actionComplexity,
    required this.culturalSpecificity,
    required this.ambiguity,
    required this.scenarioComplexity,
  });

  @override
  String toString() =>
      'DifficultyBreakdown(score: ${compositeScore.toStringAsFixed(1)}, '
      'fam: ${wordFamiliarity.toStringAsFixed(0)}, '
      'abs: ${semanticAbstractness.toStringAsFixed(0)}, '
      'act: ${actionComplexity.toStringAsFixed(0)}, '
      'cult: ${culturalSpecificity.toStringAsFixed(0)})';
}

/// Weighted Semantic Difficulty Scorer for Greek Charades Phrases
class PhraseDifficultyScorer {
  final DifficultySignalWeights weights;

  const PhraseDifficultyScorer({
    this.weights = const DifficultySignalWeights(),
  });

  // Curated lexical dictionaries with Greek charades properties
  static const Set<String> _universalHighFamiliarity = {
    'ο',
    'η',
    'το',
    'τον',
    'την',
    'τους',
    'τις',
    'τα',
    'στο',
    'στη',
    'στον',
    'στην',
    'στα',
    'στους',
    'στις',
    'μαμά',
    'μπαμπάς',
    'παιδί',
    'μωρό',
    'παππούς',
    'γιαγιά',
    'σκύλος',
    'γάτα',
    'κόκορας',
    'φαγητό',
    'νερό',
    'γάλα',
    'ψωμί',
    'μήλο',
    'μπανάνα',
    'μπάλα',
    'πόρτα',
    'σπίτι',
    'τρέχει',
    'κοιμάται',
    'τρώει',
    'πίνει',
    'κλαίει',
    'γελάει',
    'πέφτει',
    'πηδάει',
    'πλύνει',
    'σκουπίζει',
    'χορεύει',
    'διαβάζει',
    'γράφει',
    'ανοίγει',
    'κλείνει',
  };

  static const Set<String> _culturallySpecific = {
    'κουμπάρος',
    'κουμπάρα',
    'πεθερά',
    'πεθερός',
    'μπατζανάκης',
    'συμπεθέρα',
    'ζεϊμπέκικο',
    'τσιφτετέλι',
    'καλαματιανό',
    'συρτάκι',
    'πανηγύρι',
    'γλέντι',
    'σουβλάκια',
    'μουσακάς',
    'παστίτσιο',
    'κουλουράκια',
    'τσουρέκι',
    'λουκουμάδες',
    'φραπέ',
    'ελληνικό',
    'καφενείο',
    'λαϊκή',
    'φουφού',
    'κομπολόι',
    'τάβλι',
    'παπάς',
    'καντήλι',
    'κουμπαράς',
    'φλουρί',
    'τσολιάς',
  };

  static const Set<String> _abstractActions = {
    'σκέφτεται',
    'προβληματίζεται',
    'υποπτεύεται',
    'διαμαρτύρεται',
    'απορεί',
    'ονειρεύεται',
    'ξεχνάει',
    'θυμάται',
    'σχεδιάζει',
    'συνωμοτεί',
    'μετανιώνει',
    'αμφιβάλλει',
    'ελπίζει',
    'ζηλεύει',
    'συγχωρεί',
    'συγκεντρώνεται',
    'φαντάζεται',
  };

  static const Set<String> _complexIndicators = {
    'προσπαθεί',
    'ισορροπήσει',
    'εξαφανίσει',
    'ξεκλειδώσει',
    'ξεμπερδέψει',
    'αντιγράψει',
    'αποφύγει',
    'συναρμολογήσει',
    'εξερευνήσει',
    'μεταμφιεστεί',
    'χωρίς',
    'ενώ',
    'ώστε',
    'ξαφνικά',
    'αδέξια',
    'πανικόβλητος',
  };

  /// Computes composite semantic difficulty score (0.0 to 100.0)
  DifficultyBreakdown score(String phraseText) {
    final tokens = phraseText
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^\w\s\u0370-\u03ff\u1f00-\u1fff]', unicode: true),
          '',
        )
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return DifficultyBreakdown(
        text: phraseText,
        compositeScore: 0,
        wordFamiliarity: 100,
        semanticAbstractness: 0,
        actionComplexity: 0,
        culturalSpecificity: 0,
        ambiguity: 0,
        scenarioComplexity: 0,
      );
    }

    // 1. Word Familiarity (0 to 100)
    int familiarCount = 0;
    int specializedCount = 0;
    for (var token in tokens) {
      if (_universalHighFamiliarity.contains(token)) {
        familiarCount++;
      } else if (token.length > 9) {
        specializedCount++;
      }
    }
    double familiarity =
        (familiarCount / tokens.length) * 100.0 - (specializedCount * 10.0);
    familiarity = familiarity.clamp(20.0, 100.0);

    // 2. Semantic Abstractness (0 to 100)
    int abstractCount = 0;
    for (var token in tokens) {
      if (_abstractActions.contains(token)) abstractCount++;
    }
    double abstractness = (abstractCount * 45.0).clamp(5.0, 100.0);

    // 3. Action Complexity (0 to 100)
    int complexCount = 0;
    for (var token in tokens) {
      if (_complexIndicators.contains(token)) complexCount++;
    }
    double actionComplexity = 15.0 + (complexCount * 35.0);
    if (phraseText.contains('προσπαθεί να')) {
      actionComplexity += 25.0;
    }
    actionComplexity = actionComplexity.clamp(10.0, 100.0);

    // 4. Cultural Specificity (0 to 100)
    int culturalCount = 0;
    for (var token in tokens) {
      if (_culturallySpecific.contains(token)) culturalCount++;
    }
    double culturalSpecificity = (culturalCount * 40.0).clamp(0.0, 100.0);

    // 5. Guessability & Ambiguity (0 to 100, where 100 = hard to guess/ambiguous)
    double ambiguity = 15.0;
    if (abstractCount > 0) ambiguity += 35.0;
    if (culturalCount > 0) ambiguity += 15.0;
    ambiguity = ambiguity.clamp(5.0, 100.0);

    // 6. Scenario Complexity (0 to 100)
    double scenarioComplexity = (tokens.length * 12.0) + (complexCount * 15.0);
    scenarioComplexity = scenarioComplexity.clamp(10.0, 100.0);

    // Weighted composite calculation
    // Note: higher familiarity reduces difficulty, so we use (100 - familiarity)
    final w = weights;
    final unfamiliarity = 100.0 - familiarity;

    final composite =
        (unfamiliarity * w.wordFamiliarity +
            abstractness * w.semanticAbstractness +
            actionComplexity * w.actionComplexity +
            culturalSpecificity * w.culturalSpecificity +
            ambiguity * w.guessability +
            scenarioComplexity * w.scenarioComplexity) /
        (w.totalWeight > 0 ? w.totalWeight : 1.0);

    return DifficultyBreakdown(
      text: phraseText,
      compositeScore: composite.clamp(0.0, 100.0),
      wordFamiliarity: familiarity,
      semanticAbstractness: abstractness,
      actionComplexity: actionComplexity,
      culturalSpecificity: culturalSpecificity,
      ambiguity: ambiguity,
      scenarioComplexity: scenarioComplexity,
    );
  }

  /// Categorizes phrase according to semantic difficulty and word count contract
  DifficultyCategory estimateCategory(String phraseText, int wordCount) {
    // Word count contract is primary constraint:
    // 3 words -> Easy
    // 4 words -> Medium
    // 5 words -> Hard
    // 6-8 words -> Impossible
    if (wordCount <= 3) {
      return DifficultyCategory.easy;
    } else if (wordCount == 4) {
      return DifficultyCategory.medium;
    } else if (wordCount == 5) {
      return DifficultyCategory.hard;
    } else {
      return DifficultyCategory.impossible;
    }
  }
}
