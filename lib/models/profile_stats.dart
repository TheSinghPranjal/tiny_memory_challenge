import 'package:equatable/equatable.dart';

/// Per-profile statistics and high-water progress.
class ProfileStats extends Equatable {
  const ProfileStats({
    this.maxLevel = 1,
    this.maxStage = 0,
    this.livesUsedAtMax = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.longestStreak = 0,
    this.totalMistakes = 0,
    this.totalCorrectTaps = 0,
    this.totalResponseMs = 0,
    this.responseSamples = 0,
  });

  /// Highest completed level (1–9). Stage 0 means no stage completed yet.
  final int maxLevel;

  /// Highest completed stage within [maxLevel]. 0 = none completed.
  final int maxStage;

  /// Lives consumed when that high-water mark was reached.
  final int livesUsedAtMax;

  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final int longestStreak;
  final int totalMistakes;
  final int totalCorrectTaps;
  final int totalResponseMs;
  final int responseSamples;

  double get averageAccuracy {
    final total = totalCorrectTaps + totalMistakes;
    if (total == 0) return 1.0;
    return totalCorrectTaps / total;
  }

  double get averageResponseMs {
    if (responseSamples == 0) return 0;
    return totalResponseMs / responseSamples;
  }

  /// Resume level: if nothing completed, start at level 1 stage 1.
  int get resumeLevel => maxStage == 0 && maxLevel == 1 ? 1 : maxLevel;

  /// Next stage to play after highest completed.
  int get resumeStage {
    if (maxStage == 0) return 1;
    // If finished all stages of maxLevel, next is level+1 stage 1 — handled by game.
    return maxStage + 1;
  }

  ProfileStats copyWith({
    int? maxLevel,
    int? maxStage,
    int? livesUsedAtMax,
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? longestStreak,
    int? totalMistakes,
    int? totalCorrectTaps,
    int? totalResponseMs,
    int? responseSamples,
  }) {
    return ProfileStats(
      maxLevel: maxLevel ?? this.maxLevel,
      maxStage: maxStage ?? this.maxStage,
      livesUsedAtMax: livesUsedAtMax ?? this.livesUsedAtMax,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      longestStreak: longestStreak ?? this.longestStreak,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      totalCorrectTaps: totalCorrectTaps ?? this.totalCorrectTaps,
      totalResponseMs: totalResponseMs ?? this.totalResponseMs,
      responseSamples: responseSamples ?? this.responseSamples,
    );
  }

  Map<String, dynamic> toMap() => {
        'maxLevel': maxLevel,
        'maxStage': maxStage,
        'livesUsedAtMax': livesUsedAtMax,
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'gamesLost': gamesLost,
        'longestStreak': longestStreak,
        'totalMistakes': totalMistakes,
        'totalCorrectTaps': totalCorrectTaps,
        'totalResponseMs': totalResponseMs,
        'responseSamples': responseSamples,
      };

  factory ProfileStats.fromMap(Map<dynamic, dynamic> map) {
    return ProfileStats(
      maxLevel: (map['maxLevel'] as num?)?.toInt() ?? 1,
      maxStage: (map['maxStage'] as num?)?.toInt() ?? 0,
      livesUsedAtMax: (map['livesUsedAtMax'] as num?)?.toInt() ?? 0,
      gamesPlayed: (map['gamesPlayed'] as num?)?.toInt() ?? 0,
      gamesWon: (map['gamesWon'] as num?)?.toInt() ?? 0,
      gamesLost: (map['gamesLost'] as num?)?.toInt() ?? 0,
      longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
      totalMistakes: (map['totalMistakes'] as num?)?.toInt() ?? 0,
      totalCorrectTaps: (map['totalCorrectTaps'] as num?)?.toInt() ?? 0,
      totalResponseMs: (map['totalResponseMs'] as num?)?.toInt() ?? 0,
      responseSamples: (map['responseSamples'] as num?)?.toInt() ?? 0,
    );
  }

  /// Updates high-water mark only if [level]/[stage] is strictly greater.
  ProfileStats withCompletedStage({
    required int level,
    required int stage,
    required int livesUsed,
  }) {
    final better = level > maxLevel ||
        (level == maxLevel && stage > maxStage);
    if (!better) return this;
    return copyWith(
      maxLevel: level,
      maxStage: stage,
      livesUsedAtMax: livesUsed,
    );
  }

  @override
  List<Object?> get props => [
        maxLevel,
        maxStage,
        livesUsedAtMax,
        gamesPlayed,
        gamesWon,
        gamesLost,
        longestStreak,
        totalMistakes,
        totalCorrectTaps,
        totalResponseMs,
        responseSamples,
      ];
}
