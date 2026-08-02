import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/core/utils/sequence_generator.dart';
import 'package:memory_challenge/models/game_state.dart';
import 'package:memory_challenge/services/audio_service.dart';
import 'package:memory_challenge/services/timer_service.dart';

typedef GameStateListener = void Function(GameState state);

/// Pure game engine — no Flutter widgets. Controllers subscribe via [onChange].
class GameEngine {
  GameEngine({
    required AudioService audio,
    Random? random,
  })  : _audio = audio,
        _random = random ?? Random();

  final AudioService _audio;
  final Random _random;
  final TimerService _timer = TimerService();

  GameState _state = const GameState();
  GameStateListener? onChange;

  Timer? _phaseTimer;
  DateTime? _phaseDeadline;
  int _phaseRemainingMs = 0;
  bool _disposed = false;
  bool _tapLocked = false;
  DateTime? _runStartedAt;
  DateTime? _inputStartedAt;

  /// Highest fully completed level/stage this run (for persistence on exit).
  int completedLevel = 0;
  int completedStage = 0;

  GameState get state => _state;

  void _emit(GameState next) {
    _state = next;
    onChange?.call(_state);
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  void startNewGame({
    required int startLevel,
    required int startStage,
    required int timerSeconds,
  }) {
    _cancelPhaseTimer();
    _timer.cancel();
    _tapLocked = false;
    completedLevel = startStage > 1
        ? startLevel
        : (startLevel > 1 ? startLevel - 1 : 0);
    completedStage = startStage > 1
        ? startStage - 1
        : (startLevel > 1
            ? LevelConfig.stageCountFor(startLevel - 1)
            : 0);
    _runStartedAt = DateTime.now();
    final showIntro = startStage == 1;
    _emit(GameState(
      phase: showIntro ? GamePhase.levelIntroReady : GamePhase.blinking,
      level: startLevel,
      stage: startStage,
      lives: AppConstants.maxLives,
      timerTotalMs: timerSeconds * 1000,
      remainingMs: timerSeconds * 1000,
    ));
    if (showIntro) {
      _beginOverlay(GamePhase.levelIntroReady, AppConstants.readyDuration);
    } else {
      _startStageBlink(showLevelIntro: false);
    }
  }

  void dispose() {
    _disposed = true;
    _cancelPhaseTimer();
    _timer.dispose();
    onChange = null;
  }

  // ─── Pause / Resume ──────────────────────────────────────────────────────

  void pause() {
    if (_disposed || _state.isPaused) return;
    if (!_state.isGameActive) return;
    if (_state.phase == GamePhase.wrongPopup ||
        _state.phase == GamePhase.timerExpiredPopup ||
        _state.phase == GamePhase.levelComplete ||
        _state.phase == GamePhase.stageSuccess ||
        _state.phase == GamePhase.gameOver ||
        _state.phase == GamePhase.victory) {
      return;
    }

    _timer.pause();
    final remaining = _freezePhaseTimer();
    _emit(_state.copyWith(
      isPaused: true,
      phaseBeforePause: _state.phase,
      phase: GamePhase.paused,
      overlayRemainingMs: remaining,
      blinkRemainingMs: remaining,
    ));
  }

  void resume() {
    if (_disposed || !_state.isPaused) return;
    final restore = _state.phaseBeforePause ?? GamePhase.input;
    final remaining = _state.overlayRemainingMs;
    _emit(_state.copyWith(
      isPaused: false,
      phase: restore,
      clearPhaseBeforePause: true,
    ));

    if (restore == GamePhase.input) {
      _timer.resume();
      return;
    }

    if (restore == GamePhase.blinking) {
      _resumeBlinking(remaining > 0 ? remaining : null);
      return;
    }

    // Overlay phases: Ready / Set / Observe / Go
    final duration = Duration(milliseconds: remaining > 0 ? remaining : 1000);
    _beginOverlay(restore, duration, resumeExisting: true);
  }

  void restartStage() {
    if (_disposed) return;
    _cancelPhaseTimer();
    _timer.cancel();
    _tapLocked = false;
    _emit(_state.copyWith(
      isPaused: false,
      clearPhaseBeforePause: true,
      playerIndex: 0,
      clearBlinkingTile: true,
      tileStates: const {},
      sequence: const [],
      blinkProgressIndex: 0,
    ));
    _startStageBlink(showLevelIntro: false);
  }

  /// Ends the current run without marking game-over UI (home / background).
  void abandonRun() {
    _cancelPhaseTimer();
    _timer.cancel();
    _tapLocked = false;
    _emit(const GameState());
  }

  // ─── Player input ────────────────────────────────────────────────────────

  void onTileTapped(int tileIndex) {
    if (_disposed || _tapLocked) return;
    if (!_state.isAcceptingInput) return;

    final expected = _state.sequence[_state.playerIndex];
    if (tileIndex != expected) {
      _handleWrongTap(tileIndex);
      return;
    }

    _handleCorrectTap(tileIndex);
  }

  // ─── Popup actions ───────────────────────────────────────────────────────

  void continueAfterFailure() {
    if (_disposed) return;
    if (_state.lives <= 0) return;
    _cancelPhaseTimer();
    _timer.cancel();
    _tapLocked = false;
    _emit(_state.copyWith(
      playerIndex: 0,
      clearBlinkingTile: true,
      tileStates: const {},
      sequence: const [],
      clearFailureReason: true,
      lastFailedSequence: const [],
    ));
    // Give the player Ready → Set → Observe before the next blink sequence.
    _beginOverlay(GamePhase.levelIntroReady, AppConstants.readyDuration);
  }

  /// After a rewarded ad: grant one life and resume the current stage.
  /// Can only be used once per run ([GameState.adBonusLifeUsed]).
  void continueWithAdBonusLife() {
    if (_disposed) return;
    if (_state.phase != GamePhase.gameOver) return;
    if (_state.adBonusLifeUsed) return;
    _cancelPhaseTimer();
    _timer.cancel();
    _tapLocked = false;
    // Leave game-over in the same emit as granting the life to avoid a
    // one-frame "Continue" flash on the popup.
    _emit(_state.copyWith(
      lives: 1,
      adBonusLifeUsed: true,
      playerIndex: 0,
      clearBlinkingTile: true,
      tileStates: const {},
      sequence: const [],
      clearFailureReason: true,
      lastFailedSequence: const [],
      phase: GamePhase.levelIntroReady,
      overlayRemainingMs: AppConstants.readyDuration.inMilliseconds,
    ));
    _beginOverlay(
      GamePhase.levelIntroReady,
      AppConstants.readyDuration,
      resumeExisting: true,
    );
  }

  void continueAfterLevelComplete() {
    if (_disposed) return;
    final nextLevel = _state.level + 1;
    if (nextLevel > AppConstants.maxLevel) {
      _emit(_state.copyWith(phase: GamePhase.victory));
      return;
    }
    _emit(_state.copyWith(
      level: nextLevel,
      stage: 1,
      playerIndex: 0,
      clearBlinkingTile: true,
      tileStates: const {},
      sequence: const [],
    ));
    _emit(_state.copyWith(phase: GamePhase.levelIntroReady));
    _beginOverlay(GamePhase.levelIntroReady, AppConstants.readyDuration);
  }

  void restartGame({required int timerSeconds}) {
    startNewGame(startLevel: 1, startStage: 1, timerSeconds: timerSeconds);
  }

  // ─── Internal: overlays ──────────────────────────────────────────────────

  void _beginOverlay(
    GamePhase phase,
    Duration duration, {
    bool resumeExisting = false,
  }) {
    if (!resumeExisting) {
      _emit(_state.copyWith(phase: phase, overlayRemainingMs: duration.inMilliseconds));
    }
    _phaseDeadline = DateTime.now().add(duration);
    _phaseRemainingMs = duration.inMilliseconds;
    _phaseTimer?.cancel();
    _phaseTimer = Timer(duration, () {
      if (_disposed || _state.isPaused) return;
      _onOverlayFinished(phase);
    });
  }

  void _onOverlayFinished(GamePhase phase) {
    switch (phase) {
      case GamePhase.levelIntroReady:
        _beginOverlay(GamePhase.levelIntroSet, AppConstants.setDuration);
      case GamePhase.levelIntroSet:
        _beginOverlay(GamePhase.levelIntroObserve, AppConstants.observeDuration);
      case GamePhase.levelIntroObserve:
        _startStageBlink(showLevelIntro: false);
      case GamePhase.go:
        _startInputPhase();
      default:
        break;
    }
  }

  // ─── Internal: blinking ──────────────────────────────────────────────────

  void _startStageBlink({required bool showLevelIntro}) {
    final active = LevelConfig.squareCountFor(_state.level);
    final length = _state.stage;
    final sequence = generateSequence(active, length, _random);
    _emit(_state.copyWith(
      phase: GamePhase.blinking,
      sequence: sequence,
      playerIndex: 0,
      blinkProgressIndex: 0,
      clearBlinkingTile: true,
      tileStates: const {},
    ));
    _playBlinkAt(0, remainingOverride: null);
  }

  Future<void> _playBlinkAt(int index, {int? remainingOverride}) async {
    if (_disposed) return;
    if (_state.isPaused) return;
    if (_state.phase != GamePhase.blinking) return;

    final sequence = _state.sequence;
    if (index >= sequence.length) {
      _emit(_state.copyWith(clearBlinkingTile: true, tileStates: const {}));
      _audio.play(GameSound.countdown);
      _beginOverlay(GamePhase.go, AppConstants.goDuration);
      return;
    }

    final tile = sequence[index];
    final durationMs =
        remainingOverride ?? AppConstants.blinkDuration.inMilliseconds;

    _emit(_state.copyWith(
      blinkProgressIndex: index,
      blinkingTileIndex: tile,
      tileStates: {tile: TileVisualState.blinking},
      blinkRemainingMs: durationMs,
    ));
    _audio.play(GameSound.blink);

    _phaseDeadline = DateTime.now().add(Duration(milliseconds: durationMs));
    _phaseRemainingMs = durationMs;
    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(milliseconds: durationMs), () async {
      if (_disposed || _state.isPaused) return;
      if (_state.phase != GamePhase.blinking) return;

      _emit(_state.copyWith(clearBlinkingTile: true, tileStates: const {}));

      // Gap between blinks (skip if this was the last).
      if (index + 1 < sequence.length) {
        _phaseDeadline =
            DateTime.now().add(AppConstants.blinkGap);
        _phaseRemainingMs = AppConstants.blinkGap.inMilliseconds;
        _phaseTimer?.cancel();
        _phaseTimer = Timer(AppConstants.blinkGap, () {
          if (_disposed || _state.isPaused) return;
          _playBlinkAt(index + 1);
        });
      } else {
        _playBlinkAt(index + 1);
      }
    });
  }

  void _resumeBlinking(int? remainingMs) {
    final index = _state.blinkProgressIndex;
    // If we were in the gap (no blinking tile), advance to next.
    if (_state.blinkingTileIndex == null && remainingMs != null) {
      _phaseTimer?.cancel();
      _phaseTimer = Timer(Duration(milliseconds: remainingMs), () {
        if (_disposed || _state.isPaused) return;
        _playBlinkAt(index + 1);
      });
      return;
    }
    _playBlinkAt(index, remainingOverride: remainingMs);
  }

  // ─── Internal: input / timer ─────────────────────────────────────────────

  void _startInputPhase() {
    final total = _state.timerTotalMs;
    _inputStartedAt = DateTime.now();
    _emit(_state.copyWith(
      phase: GamePhase.input,
      remainingMs: total,
      clearBlinkingTile: true,
      tileStates: const {},
      playerIndex: 0,
    ));
    _timer.start(
      durationMs: total,
      onTick: (ms) {
        if (_disposed) return;
        _emit(_state.copyWith(remainingMs: ms));
      },
      onExpired: () {
        if (_disposed) return;
        _handleTimeout();
      },
    );
  }

  void _handleCorrectTap(int tileIndex) {
    _tapLocked = true;
    final nextIndex = _state.playerIndex + 1;
    final streak = _state.currentStreak + 1;
    final best = streak > _state.bestStreakThisRun
        ? streak
        : _state.bestStreakThisRun;

    if (_inputStartedAt != null) {
      // Response time tracked via run stats in controller.
    }

    _emit(_state.copyWith(
      tileStates: {tileIndex: TileVisualState.correct},
      playerIndex: nextIndex,
      correctTapsThisRun: _state.correctTapsThisRun + 1,
      currentStreak: streak,
      bestStreakThisRun: best,
    ));
    _audio.play(GameSound.correct);
    _audio.hapticLight();

    Timer(AppConstants.correctFeedback, () {
      if (_disposed) return;
      _tapLocked = false;
      _emit(_state.copyWith(tileStates: const {}));
      if (nextIndex >= _state.sequence.length) {
        _onStageSuccess();
      }
    });
  }

  void _handleWrongTap(int tileIndex) {
    _tapLocked = true;
    _timer.cancel();
    _cancelPhaseTimer();
    _audio.play(GameSound.wrong);
    _audio.hapticHeavy();

    final newLives = (_state.lives - 1).clamp(0, AppConstants.maxLives);
    _emit(_state.copyWith(
      tileStates: {tileIndex: TileVisualState.wrong},
      lives: newLives,
      mistakesThisRun: _state.mistakesThisRun + 1,
      currentStreak: 0,
      lastFailedSequence: List<int>.from(_state.sequence),
      failureReason: 'wrong',
      phase: newLives <= 0 ? GamePhase.gameOver : GamePhase.wrongPopup,
    ));

    Timer(AppConstants.wrongFeedback, () {
      _tapLocked = false;
      if (newLives <= 0) {
        _audio.play(GameSound.gameOver);
      }
    });
  }

  void _handleTimeout() {
    if (_disposed) return;
    if (_state.phase != GamePhase.input) return;
    _tapLocked = true;
    _audio.play(GameSound.wrong);
    _audio.hapticHeavy();

    final newLives = (_state.lives - 1).clamp(0, AppConstants.maxLives);
    _emit(_state.copyWith(
      lives: newLives,
      mistakesThisRun: _state.mistakesThisRun + 1,
      currentStreak: 0,
      lastFailedSequence: List<int>.from(_state.sequence),
      failureReason: 'timeout',
      remainingMs: 0,
      phase: newLives <= 0 ? GamePhase.gameOver : GamePhase.timerExpiredPopup,
    ));
    _tapLocked = false;
    if (newLives <= 0) {
      _audio.play(GameSound.gameOver);
    }
  }

  void _onStageSuccess() {
    _timer.cancel();
    _cancelPhaseTimer();
    completedLevel = _state.level;
    completedStage = _state.stage;
    _audio.play(GameSound.stageClear);

    final stageCount = LevelConfig.stageCountFor(_state.level);
    if (_state.stage >= stageCount) {
      // Level complete.
      if (_state.level >= AppConstants.maxLevel) {
        _audio.play(GameSound.levelClear);
        _audio.hapticSuccess();
        final elapsed = _runStartedAt == null
            ? 0
            : DateTime.now().difference(_runStartedAt!).inMilliseconds;
        _emit(_state.copyWith(
          phase: GamePhase.victory,
          runElapsedMs: elapsed,
        ));
        return;
      }
      _audio.play(GameSound.levelClear);
      _audio.hapticSuccess();
      _emit(_state.copyWith(phase: GamePhase.levelComplete));
      return;
    }

    // Next stage immediately after brief beat.
    _emit(_state.copyWith(phase: GamePhase.stageSuccess));
    _phaseTimer?.cancel();
    _phaseTimer = Timer(AppConstants.stageTransition, () {
      if (_disposed) return;
      _emit(_state.copyWith(
        stage: _state.stage + 1,
        playerIndex: 0,
        clearBlinkingTile: true,
        tileStates: const {},
        sequence: const [],
      ));
      _startStageBlink(showLevelIntro: false);
    });
  }

  // ─── Phase timer helpers ─────────────────────────────────────────────────

  int _freezePhaseTimer() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    if (_phaseDeadline != null) {
      _phaseRemainingMs = _phaseDeadline!
          .difference(DateTime.now())
          .inMilliseconds
          .clamp(0, 1 << 30);
    }
    return _phaseRemainingMs;
  }

  void _cancelPhaseTimer() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _phaseDeadline = null;
    _phaseRemainingMs = 0;
  }

  @visibleForTesting
  void debugForceState(GameState state) => _emit(state);
}
