import 'package:equatable/equatable.dart';

/// Phases of the per-stage (and level-intro) state machine.
enum GamePhase {
  idle,
  levelIntroReady,
  levelIntroSet,
  levelIntroObserve,
  blinking,
  go,
  input,
  stageSuccess,
  levelComplete,
  wrongPopup,
  timerExpiredPopup,
  gameOver,
  /// Reward earned from ad — waiting for player to confirm continue.
  adBonusReady,
  victory,
  paused,
}

enum TileVisualState {
  idle,
  blinking,
  correct,
  wrong,
  locked,
  dimmed,
}

/// Immutable snapshot of the running game — UI reads this only.
class GameState extends Equatable {
  const GameState({
    this.phase = GamePhase.idle,
    this.level = 1,
    this.stage = 1,
    this.lives = 3,
    this.sequence = const [],
    this.playerIndex = 0,
    this.blinkingTileIndex,
    this.tileStates = const {},
    this.remainingMs = 0,
    this.timerTotalMs = 20000,
    this.isPaused = false,
    this.pausedFromPhase,
    this.mistakesThisRun = 0,
    this.correctTapsThisRun = 0,
    this.currentStreak = 0,
    this.bestStreakThisRun = 0,
    this.runElapsedMs = 0,
    this.lastFailedSequence = const [],
    this.failureReason,
    this.phaseBeforePause,
    this.blinkProgressIndex = 0,
    this.blinkRemainingMs = 0,
    this.overlayRemainingMs = 0,
    this.adBonusLifeUsed = false,
  });

  final GamePhase phase;
  final int level;
  final int stage;
  final int lives;
  final List<int> sequence;
  final int playerIndex;
  final int? blinkingTileIndex;
  final Map<int, TileVisualState> tileStates;
  final int remainingMs;
  final int timerTotalMs;
  final bool isPaused;
  final GamePhase? pausedFromPhase;
  final int mistakesThisRun;
  final int correctTapsThisRun;
  final int currentStreak;
  final int bestStreakThisRun;
  final int runElapsedMs;
  final List<int> lastFailedSequence;
  final String? failureReason;

  /// True after the player already claimed a rewarded-ad extra life this run.
  final bool adBonusLifeUsed;

  /// Phase frozen when pause was entered.
  final GamePhase? phaseBeforePause;

  /// Index into [sequence] currently being blinked (for pause/resume).
  final int blinkProgressIndex;

  /// Remaining ms of the current blink / overlay when paused.
  final int blinkRemainingMs;
  final int overlayRemainingMs;

  bool get isAcceptingInput => phase == GamePhase.input && !isPaused;

  bool get isGameActive =>
      phase != GamePhase.idle &&
      phase != GamePhase.gameOver &&
      phase != GamePhase.adBonusReady &&
      phase != GamePhase.victory;

  /// Offer a rewarded ad only on the first game-over of a run.
  bool get canWatchAdForBonusLife =>
      phase == GamePhase.gameOver && !adBonusLifeUsed && lives <= 0;

  GameState copyWith({
    GamePhase? phase,
    int? level,
    int? stage,
    int? lives,
    List<int>? sequence,
    int? playerIndex,
    int? blinkingTileIndex,
    bool clearBlinkingTile = false,
    Map<int, TileVisualState>? tileStates,
    int? remainingMs,
    int? timerTotalMs,
    bool? isPaused,
    GamePhase? pausedFromPhase,
    bool clearPausedFromPhase = false,
    int? mistakesThisRun,
    int? correctTapsThisRun,
    int? currentStreak,
    int? bestStreakThisRun,
    int? runElapsedMs,
    List<int>? lastFailedSequence,
    String? failureReason,
    bool clearFailureReason = false,
    GamePhase? phaseBeforePause,
    bool clearPhaseBeforePause = false,
    int? blinkProgressIndex,
    int? blinkRemainingMs,
    int? overlayRemainingMs,
    bool? adBonusLifeUsed,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      level: level ?? this.level,
      stage: stage ?? this.stage,
      lives: lives ?? this.lives,
      sequence: sequence ?? this.sequence,
      playerIndex: playerIndex ?? this.playerIndex,
      blinkingTileIndex: clearBlinkingTile
          ? null
          : (blinkingTileIndex ?? this.blinkingTileIndex),
      tileStates: tileStates ?? this.tileStates,
      remainingMs: remainingMs ?? this.remainingMs,
      timerTotalMs: timerTotalMs ?? this.timerTotalMs,
      isPaused: isPaused ?? this.isPaused,
      pausedFromPhase: clearPausedFromPhase
          ? null
          : (pausedFromPhase ?? this.pausedFromPhase),
      mistakesThisRun: mistakesThisRun ?? this.mistakesThisRun,
      correctTapsThisRun: correctTapsThisRun ?? this.correctTapsThisRun,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreakThisRun: bestStreakThisRun ?? this.bestStreakThisRun,
      runElapsedMs: runElapsedMs ?? this.runElapsedMs,
      lastFailedSequence: lastFailedSequence ?? this.lastFailedSequence,
      failureReason: clearFailureReason
          ? null
          : (failureReason ?? this.failureReason),
      phaseBeforePause: clearPhaseBeforePause
          ? null
          : (phaseBeforePause ?? this.phaseBeforePause),
      blinkProgressIndex: blinkProgressIndex ?? this.blinkProgressIndex,
      blinkRemainingMs: blinkRemainingMs ?? this.blinkRemainingMs,
      overlayRemainingMs: overlayRemainingMs ?? this.overlayRemainingMs,
      adBonusLifeUsed: adBonusLifeUsed ?? this.adBonusLifeUsed,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        level,
        stage,
        lives,
        sequence,
        playerIndex,
        blinkingTileIndex,
        tileStates,
        remainingMs,
        timerTotalMs,
        isPaused,
        pausedFromPhase,
        mistakesThisRun,
        correctTapsThisRun,
        currentStreak,
        bestStreakThisRun,
        runElapsedMs,
        lastFailedSequence,
        failureReason,
        phaseBeforePause,
        blinkProgressIndex,
        blinkRemainingMs,
        overlayRemainingMs,
        adBonusLifeUsed,
      ];
}
