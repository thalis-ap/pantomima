import 'game_enums.dart';

/// Represents a single Greek pantomime phrase
class Phrase {
  final String id;
  final String text;
  final DifficultyCategory difficulty;
  final int wordCount;
  final bool isNonsense;
  final double? difficultyScore;

  const Phrase({
    required this.id,
    required this.text,
    required this.difficulty,
    required this.wordCount,
    required this.isNonsense,
    this.difficultyScore,
  });

  factory Phrase.fromJson(Map<String, dynamic> json, {String? id}) {
    final text = json['text'] as String? ?? '';
    final resolvedId = id ?? (json['id'] as String?) ?? text;
    final wordCount =
        json['wordCount'] as int? ??
        (text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length);
    final catName = json['category'] as String?;
    final difficulty = (catName != null && catName.isNotEmpty)
        ? DifficultyCategory.fromGreekName(catName)
        : DifficultyCategory.fromWordCount(wordCount);

    return Phrase(
      id: resolvedId,
      text: text,
      difficulty: difficulty,
      wordCount: wordCount,
      isNonsense: json['isNonsense'] as bool? ?? false,
      difficultyScore: (json['difficultyScore'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'text': text,
      'category': difficulty.nameEl,
      'wordCount': wordCount,
      'isNonsense': isNonsense,
    };
    if (difficultyScore != null) {
      map['difficultyScore'] = difficultyScore;
    }
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Phrase && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Phrase($id: "$text", ${difficulty.nameEl}, $wordCount words)';
}
