import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_challenge/controllers/app_controllers.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/game/game_engine.dart';
import 'package:memory_challenge/models/game_state.dart';
import 'package:memory_challenge/models/profile_stats.dart';

class GameController extends StateNotifier<GameState> {
  GameController(this._ref) : super(const GameState()) {
    _engine = GameEngine(audio: _ref.read(audioServiceProvider));
    _engine.onChange = (s) {
      if (!mounted) return;
      final prev = state;
      state = s;
      // Timeout (and any non-tap) path into final game-over after bonus life.
      if (s.phase == GamePhase.gameOver &&
          prev.phase != GamePhase.gameOver &&
          s.adBonusLifeUsed) {
        _persistLoss(s);
      }
    };
  }

  final Ref _ref;
  late final GameEngine _engine;
  bool _runCounted = false;
  bool _lossPersisted = false;
  int _runMistakes = 0;
  int _runCorrect = 0;
  int _runResponseMs = 0;
  int _runResponseSamples = 0;
  DateTime? _lastInputAt;

  GameEngine get engine => _engine;

  void startGame() {
    final settings = _ref.read(settingsControllerProvider);

    _runCounted = false;
    _lossPersisted = false;
    _runMistakes = 0;
    _runCorrect = 0;
    _runResponseMs = 0;
    _runResponseSamples = 0;
    _lastInputAt = null;

    // Always a fresh run from Level 1 Stage 1 (not a continue/resume).
    _engine.startNewGame(
      startLevel: 1,
      startStage: 1,
      timerSeconds: settings.timerDurationSeconds,
    );
    _bumpGamesPlayed();
  }

  Future<void> _bumpGamesPlayed() async {
    if (_runCounted) return;
    _runCounted = true;
    final profile = _ref.read(activeProfileProvider);
    final stats = _ref.read(profilesControllerProvider)[profile] ??
        const ProfileStats();
    await _ref.read(profilesControllerProvider.notifier).save(
          profile,
          stats.copyWith(gamesPlayed: stats.gamesPlayed + 1),
        );
  }

  void pause() => _engine.pause();
  void resume() => _engine.resume();
  void restartStage() => _engine.restartStage();

  void onTileTapped(int index) {
    if (state.phase == GamePhase.input && !state.isPaused) {
      final now = DateTime.now();
      if (_lastInputAt != null) {
        _runResponseMs += now.difference(_lastInputAt!).inMilliseconds;
        _runResponseSamples++;
      }
      _lastInputAt = now;
    }
    final before = state;
    _engine.onTileTapped(index);
    final after = state;

    if (after.mistakesThisRun > before.mistakesThisRun) {
      _runMistakes++;
      _persistProgressOnFailure(after);
    }
    if (after.correctTapsThisRun > before.correctTapsThisRun) {
      _runCorrect++;
    }
    if (after.phase == GamePhase.stageSuccess ||
        after.phase == GamePhase.levelComplete ||
        after.phase == GamePhase.victory) {
      _persistCompletedStage(after);
    }
    if (after.phase == GamePhase.victory) {
      _persistWin(after);
    }
  }

  void continueAfterFailure() {
    _engine.continueAfterFailure();
  }

  void continueAfterLevelComplete() {
    _engine.continueAfterLevelComplete();
  }

  /// Grant one bonus life after a rewarded ad and resume the current stage.
  void continueWithAdBonusLife() {
    _engine.continueWithAdBonusLife();
  }

  void restartGame() {
    if (state.phase == GamePhase.gameOver) {
      _persistLoss(state);
    }
    final settings = _ref.read(settingsControllerProvider);
    _runCounted = false;
    _lossPersisted = false;
    _runMistakes = 0;
    _runCorrect = 0;
    _bumpGamesPlayed();
    _engine.restartGame(timerSeconds: settings.timerDurationSeconds);
  }

  /// Called when leaving mid-run (home, back, background).
  Future<void> abandonAndSave() async {
    if (state.phase == GamePhase.gameOver) {
      await _persistLoss(state);
    }
    await _persistHighestCompleted();
    _engine.abandonRun();
    if (mounted) state = const GameState();
  }

  Future<void> _persistHighestCompleted() async {
    if (_engine.completedLevel <= 0 || _engine.completedStage <= 0) return;
    final profile = _ref.read(activeProfileProvider);
    final stats = _ref.read(profilesControllerProvider)[profile] ??
        const ProfileStats();
    final livesUsed = AppConstants.maxLives - state.lives;
    final updated = stats.withCompletedStage(
      level: _engine.completedLevel,
      stage: _engine.completedStage,
      livesUsed: livesUsed.clamp(0, AppConstants.maxLives),
    );
    final withMistakes = updated.copyWith(
      totalMistakes: updated.totalMistakes + _runMistakes,
      totalCorrectTaps: updated.totalCorrectTaps + _runCorrect,
      totalResponseMs: updated.totalResponseMs + _runResponseMs,
      responseSamples: updated.responseSamples + _runResponseSamples,
      longestStreak: state.bestStreakThisRun > updated.longestStreak
          ? state.bestStreakThisRun
          : updated.longestStreak,
    );
    await _ref.read(profilesControllerProvider.notifier).save(profile, withMistakes);
  }

  Future<void> _persistCompletedStage(GameState s) async {
    final profile = _ref.read(activeProfileProvider);
    final stats = _ref.read(profilesControllerProvider)[profile] ??
        const ProfileStats();
    final livesUsed = AppConstants.maxLives - s.lives;
    final updated = stats.withCompletedStage(
      level: s.level,
      stage: s.stage,
      livesUsed: livesUsed.clamp(0, AppConstants.maxLives),
    ).copyWith(
      longestStreak: s.bestStreakThisRun > stats.longestStreak
          ? s.bestStreakThisRun
          : stats.longestStreak,
    );
    await _ref.read(profilesControllerProvider.notifier).save(profile, updated);
  }

  Future<void> _persistProgressOnFailure(GameState s) async {
    final profile = _ref.read(activeProfileProvider);
    final stats = _ref.read(profilesControllerProvider)[profile] ??
        const ProfileStats();
    await _ref.read(profilesControllerProvider.notifier).save(
          profile,
          stats.copyWith(totalMistakes: stats.totalMistakes + 1),
        );
  }

  Future<void> _persistWin(GameState s) async {
    final profile = _ref.read(activeProfileProvider);
    final stats = _ref.read(profilesControllerProvider)[profile] ??
        const ProfileStats();
    final updated = stats
        .withCompletedStage(
          level: AppConstants.maxLevel,
          stage: LevelConfig.stageCountFor(AppConstants.maxLevel),
          livesUsed: (AppConstants.maxLives - s.lives)
              .clamp(0, AppConstants.maxLives),
        )
        .copyWith(
          gamesWon: stats.gamesWon + 1,
          totalMistakes: stats.totalMistakes + _runMistakes,
          totalCorrectTaps: stats.totalCorrectTaps + _runCorrect,
          totalResponseMs: stats.totalResponseMs + _runResponseMs,
          responseSamples: stats.responseSamples + _runResponseSamples,
          longestStreak: s.bestStreakThisRun > stats.longestStreak
              ? s.bestStreakThisRun
              : stats.longestStreak,
        );
    await _ref.read(profilesControllerProvider.notifier).save(profile, updated);
  }

  Future<void> _persistLoss(GameState s) async {
    if (_lossPersisted) return;
    _lossPersisted = true;
    final profile = _ref.read(activeProfileProvider);
    final stats = _ref.read(profilesControllerProvider)[profile] ??
        const ProfileStats();
    await _persistHighestCompleted();
    final latest = _ref.read(profilesControllerProvider)[profile] ?? stats;
    await _ref.read(profilesControllerProvider.notifier).save(
          profile,
          latest.copyWith(gamesLost: latest.gamesLost + 1),
        );
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}

final gameControllerProvider =
    StateNotifierProvider.autoDispose<GameController, GameState>((ref) {
  return GameController(ref);
});
