import 'dart:math' as math;

/// App-wide constants for Tiny Think - Memory Challenge.
abstract final class AppConstants {
  static const String appName = 'Tiny Think';
  static const String appSubtitle = 'Memory Challenge';
  static const String version = '1.0.0';
  static const String privacyPolicyUrl =
      'https://www.example.com/privacy-policy';

  /// AdMob test banner unit IDs (replace with production IDs before release).
  static const String androidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  static const int maxLives = 3;
  static const int maxLevel = 9;
  static const int minTimerSeconds = 20;
  static const int maxTimerSeconds = 60;
  static const int timerStepSeconds = 5;
  static const int defaultTimerSeconds = 20;

  static const Duration readyDuration = Duration(seconds: 1);
  static const Duration setDuration = Duration(seconds: 1);
  static const Duration observeDuration = Duration(seconds: 1);
  static const Duration blinkDuration = Duration(seconds: 1);
  static const Duration blinkGap = Duration(milliseconds: 200);
  static const Duration goDuration = Duration(seconds: 1);
  static const Duration stageTransition = Duration(milliseconds: 400);
  static const Duration correctFeedback = Duration(milliseconds: 280);
  static const Duration wrongFeedback = Duration(milliseconds: 450);

  static const double tileSpacing = 10;
  static const double tileBorderRadius = 16;
  static const double bannerReservedHeight = 60;
}

/// Square counts and stage counts per level (1-indexed via list index + 1).
///
/// Grid uses ceil(sqrt(n)) × ceil(sqrt(n)) with invisible filler cells so
/// every tile stays perfectly square while matching the requested counts.
abstract final class LevelConfig {
  static const List<int> squareCounts = [4, 6, 8, 10, 12, 14, 16, 18, 20];

  static int squareCountFor(int level) {
    assert(level >= 1 && level <= 9);
    return squareCounts[level - 1];
  }

  static int stageCountFor(int level) => squareCountFor(level);

  static int gridDimensionFor(int level) {
    final count = squareCountFor(level);
    return math.sqrt(count).ceil();
  }

  static int fillerCountFor(int level) {
    final dim = gridDimensionFor(level);
    return dim * dim - squareCountFor(level);
  }
}
