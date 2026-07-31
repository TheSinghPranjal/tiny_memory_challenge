import 'package:flutter_test/flutter_test.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/core/utils/sequence_generator.dart';
import 'package:memory_challenge/models/profile_stats.dart';

void main() {
  group('LevelConfig', () {
    test('square counts match spec', () {
      expect(LevelConfig.squareCounts, [4, 6, 8, 10, 12, 14, 16, 18, 20]);
    });

    test('grid dimensions are square-preserving', () {
      expect(LevelConfig.gridDimensionFor(1), 2);
      expect(LevelConfig.gridDimensionFor(2), 3);
      expect(LevelConfig.gridDimensionFor(3), 3);
      expect(LevelConfig.gridDimensionFor(4), 4);
      expect(LevelConfig.gridDimensionFor(7), 4);
      expect(LevelConfig.gridDimensionFor(8), 5);
      expect(LevelConfig.gridDimensionFor(9), 5);
    });

    test('stages equal square count', () {
      for (var level = 1; level <= 9; level++) {
        expect(
          LevelConfig.stageCountFor(level),
          LevelConfig.squareCountFor(level),
        );
      }
    });
  });

  group('sequence generator', () {
    test('no duplicates within sequence', () {
      for (var i = 0; i < 50; i++) {
        final seq = generateSequence(6, 6);
        expect(seq.toSet().length, 6);
        expect(seq.length, 6);
      }
    });

    test('subset length respected', () {
      final seq = generateSequence(10, 4);
      expect(seq.length, 4);
      expect(seq.toSet().length, 4);
      for (final i in seq) {
        expect(i >= 0 && i < 10, isTrue);
      }
    });
  });

  group('ProfileStats', () {
    test('progress never regresses', () {
      const base = ProfileStats(maxLevel: 3, maxStage: 4);
      final lower = base.withCompletedStage(level: 2, stage: 6, livesUsed: 1);
      expect(lower.maxLevel, 3);
      expect(lower.maxStage, 4);

      final higher = base.withCompletedStage(level: 3, stage: 5, livesUsed: 2);
      expect(higher.maxLevel, 3);
      expect(higher.maxStage, 5);
      expect(higher.livesUsedAtMax, 2);
    });
  });
}
