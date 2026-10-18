import 'package:flutter/material.dart';

/// Represents a team in the pantomime game
class Team {
  final String id;
  final String name;
  final int score;
  final Color color;
  final int streak;

  const Team({
    required this.id,
    required this.name,
    this.score = 0,
    required this.color,
    this.streak = 0,
  });

  Team copyWith({
    String? id,
    String? name,
    int? score,
    Color? color,
    int? streak,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      color: color ?? this.color,
      streak: streak ?? this.streak,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          score == other.score &&
          streak == other.streak;

  @override
  int get hashCode => Object.hash(id, name, score, streak);

  @override
  String toString() => 'Team($name: $score pts)';
}
