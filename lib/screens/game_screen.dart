import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_challenge/controllers/app_controllers.dart';
import 'package:memory_challenge/controllers/game_controller.dart';
import 'package:memory_challenge/core/extensions/extensions.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/models/game_state.dart';
import 'package:memory_challenge/widgets/common/common_widgets.dart'
    show SoftCard, PrimaryGameButton;
import 'package:memory_challenge/widgets/game/game_hud.dart';
import 'package:memory_challenge/widgets/game/memory_board.dart';
import 'package:memory_challenge/widgets/game/popups.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  late final ConfettiController _confetti;
  bool _started = false;
  bool _adLoading = false;
  /// True while a rewarded ad is on screen — skip background abandon/home.
  bool _showingRewardedAd = false;
  GamePhase? _lastPhase;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_started) {
        _started = true;
        ref.read(audioServiceProvider).stopMusic();
        ref.read(gameControllerProvider.notifier).startGame();
        // Warm rewarded inventory for a possible game-over continue.
        ref.read(adServiceProvider).preloadRewardedAd();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confetti.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(gameControllerProvider.notifier);
    final game = ref.read(gameControllerProvider);
    final audio = ref.read(audioServiceProvider);

    // Fullscreen rewarded ads briefly background the app. Do not abandon the
    // run or pop to Home — the player should return to the game screen.
    if (_showingRewardedAd) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.hidden ||
          state == AppLifecycleState.detached) {
        audio.stopMusic();
      }
      return;
    }

    if (state == AppLifecycleState.inactive) {
      if (game.isGameActive && !game.isPaused) {
        controller.pause();
      }
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      audio.stopMusic();
    }

    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      controller.abandonAndSave();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }

    if (state == AppLifecycleState.resumed &&
        mounted &&
        (ModalRoute.of(context)?.isCurrent ?? false) &&
        ref.read(gameControllerProvider).isPaused) {
      audio.startMusic();
    }
  }

  Future<void> _goHome() async {
    await ref.read(audioServiceProvider).stopMusic();
    await ref.read(gameControllerProvider.notifier).abandonAndSave();
    if (mounted) Navigator.of(context).pop();
  }

  void _pauseGame() {
    ref.read(gameControllerProvider.notifier).pause();
    ref.read(audioServiceProvider).startMusic();
  }

  void _resumeGame() {
    ref.read(audioServiceProvider).stopMusic();
    ref.read(gameControllerProvider.notifier).resume();
  }

  Future<void> _watchAdForExtraLife() async {
    if (_adLoading) return;
    setState(() {
      _adLoading = true;
      _showingRewardedAd = true;
    });

    var earned = false;
    try {
      earned = await ref.read(adServiceProvider).showRewardedAd();
    } finally {
      if (mounted) {
        setState(() => _showingRewardedAd = false);
      } else {
        _showingRewardedAd = false;
      }
    }

    if (!mounted) return;

    if (earned) {
      // Close Game Over and show the "continue with rewarded life" popup.
      ref.read(gameControllerProvider.notifier).grantAdBonusLife();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad unavailable. Try again in a moment.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(adServiceProvider).preloadRewardedAd();
    }

    if (mounted) setState(() => _adLoading = false);
  }

  void _handlePhaseSideEffects(GameState game) {
    if (_lastPhase == game.phase) return;
    _lastPhase = game.phase;
    if (game.phase == GamePhase.levelComplete ||
        game.phase == GamePhase.victory) {
      _confetti.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    _handlePhaseSideEffects(game);

    final showOverlay = game.phase == GamePhase.levelIntroReady ||
        game.phase == GamePhase.levelIntroSet ||
        game.phase == GamePhase.levelIntroObserve ||
        game.phase == GamePhase.go;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _goHome();
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/home_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x73000000),
                    Color(0x33000000),
                    Color(0x66000000),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: SizedBox(
                          height: StageTimerRing.size + 8,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              LivesRow(lives: game.lives),
                              const Spacer(),
                              LevelStageChip(
                                level: game.level,
                                stage: game.stage,
                              ),
                              const Spacer(),
                              // Reserve timer slot so the board never jumps.
                              SizedBox(
                                width: StageTimerRing.size,
                                height: StageTimerRing.size,
                                child: game.phase == GamePhase.input
                                    ? StageTimerRing(
                                        remainingMs: game.remainingMs,
                                        totalMs: game.timerTotalMs,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              const SizedBox(width: 8),
                              PauseChipButton(
                                onPressed: game.isGameActive &&
                                        !game.isPaused &&
                                        game.phase != GamePhase.wrongPopup &&
                                        game.phase !=
                                            GamePhase.timerExpiredPopup &&
                                        game.phase != GamePhase.levelComplete &&
                                        game.phase != GamePhase.gameOver &&
                                        game.phase != GamePhase.adBonusReady &&
                                        game.phase != GamePhase.victory
                                    ? _pauseGame
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      PhaseCoachBanner(phase: game.phase),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                          child: Center(
                            child: MemoryBoard(
                              level: game.level.clamp(1, 9),
                              stage: game.stage,
                              tileStates: game.tileStates,
                              inputEnabled: game.isAcceptingInput,
                              onTileTap: (i) => ref
                                  .read(gameControllerProvider.notifier)
                                  .onTileTapped(i),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (showOverlay) PhaseOverlay(phase: game.phase),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confetti,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: const [
                        AppColors.primary,
                        AppColors.secondary,
                        AppColors.accent,
                        AppColors.gold,
                        AppColors.success,
                      ],
                    ),
                  ),
                  if (game.phase == GamePhase.paused)
                    PauseDialog(
                      onResume: _resumeGame,
                      onRestartStage: () {
                        ref.read(audioServiceProvider).stopMusic();
                        ref
                            .read(gameControllerProvider.notifier)
                            .restartStage();
                      },
                      onHome: _goHome,
                    ),
                  if (game.phase == GamePhase.wrongPopup ||
                      game.phase == GamePhase.timerExpiredPopup ||
                      game.phase == GamePhase.gameOver)
                    WrongSequencePopup(
                      level: game.level,
                      sequence: game.lastFailedSequence,
                      livesRemaining: game.lives,
                      isTimeout: game.failureReason == 'timeout',
                      showWatchAd: game.canWatchAdForBonusLife,
                      adLoading: _adLoading,
                      onWatchAd: _watchAdForExtraLife,
                      onContinue: () => ref
                          .read(gameControllerProvider.notifier)
                          .continueAfterFailure(),
                      onRestart: () => ref
                          .read(gameControllerProvider.notifier)
                          .restartGame(),
                      onHome: _goHome,
                    ),
                  if (game.phase == GamePhase.adBonusReady)
                    AdBonusContinuePopup(
                      onContinue: () => ref
                          .read(gameControllerProvider.notifier)
                          .continueWithAdBonusLife(),
                      onHome: _goHome,
                    ),
                  if (game.phase == GamePhase.levelComplete)
                    LevelCompletePopup(
                      level: game.level,
                      onContinue: () => ref
                          .read(gameControllerProvider.notifier)
                          .continueAfterLevelComplete(),
                    ),
                  if (game.phase == GamePhase.victory)
                    _VictoryOverlay(game: game),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VictoryOverlay extends ConsumerWidget {
  const _VictoryOverlay({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = Duration(milliseconds: game.runElapsedMs);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SoftCard(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text(
                'Congratulations!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                'Memory Master',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 16),
              _stat(context, 'Total mistakes', '${game.mistakesThisRun}'),
              _stat(context, 'Total time', elapsed.mmss),
              _stat(context, 'Best streak', '${game.bestStreakThisRun}'),
              const SizedBox(height: 20),
              PrimaryGameButton(
                label: 'Restart',
                icon: Icons.refresh_rounded,
                width: double.infinity,
                onPressed: () =>
                    ref.read(gameControllerProvider.notifier).restartGame(),
              ),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(gameControllerProvider.notifier)
                      .abandonAndSave();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(
                  'Home',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
