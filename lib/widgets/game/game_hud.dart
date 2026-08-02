import 'package:flutter/material.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/models/game_state.dart';

/// Shared frosted-glass fill used across the game HUD.
const Color _kGlassFill = Color(0xCC2A1F5C);
const Color _kGlassBorder = Color(0x59FFFFFF);

class PhaseOverlay extends StatelessWidget {
  const PhaseOverlay({super.key, required this.phase});

  final GamePhase phase;

  String? get _label {
    switch (phase) {
      case GamePhase.levelIntroReady:
        return 'READY';
      case GamePhase.levelIntroSet:
        return 'SET';
      case GamePhase.levelIntroObserve:
        return 'OBSERVE';
      case GamePhase.go:
        return 'GO!';
      default:
        return null;
    }
  }

  Color get _accent {
    switch (phase) {
      case GamePhase.go:
        return AppColors.success;
      case GamePhase.levelIntroObserve:
        return AppColors.secondary;
      case GamePhase.levelIntroSet:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _label;
    if (label == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(label),
          tween: Tween(begin: 0.7, end: 1),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: scale.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: _accent,
                    fontSize: 44,
                    letterSpacing: 1.2,
                    height: 1,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Coach banner under the HUD — always reserved so the board never jumps.
class PhaseCoachBanner extends StatelessWidget {
  const PhaseCoachBanner({super.key, required this.phase});

  /// Fixed slot height (including top margin) — keep board position stable.
  static const double slotHeight = 56;

  final GamePhase phase;

  (String title, String subtitle) get _copy {
    switch (phase) {
      case GamePhase.blinking:
      case GamePhase.levelIntroObserve:
        return ('Watch the sequence', 'Memorize the order of the tiles.');
      case GamePhase.input:
        return ('Your turn!', 'Tap the tiles in the same order.');
      case GamePhase.go:
        return ('Get ready…', 'The sequence is about to start.');
      case GamePhase.levelIntroReady:
      case GamePhase.levelIntroSet:
        return ('New level!', 'Get set for a new challenge.');
      case GamePhase.stageSuccess:
        return ('Nice!', 'Get ready for the next stage.');
      case GamePhase.levelComplete:
        return ('Level complete!', 'Great memory — keep going.');
      case GamePhase.wrongPopup:
      case GamePhase.timerExpiredPopup:
        return ('Almost!', 'Check the sequence and try again.');
      case GamePhase.gameOver:
        return ('Game over', 'Tap continue when you are ready.');
      case GamePhase.adBonusReady:
        return ('Extra life!', 'Continue with your rewarded life.');
      case GamePhase.victory:
        return ('You did it!', 'You beat every level.');
      case GamePhase.paused:
        return ('Paused', 'Take a breath, then resume.');
      case GamePhase.idle:
        return ('Tiny Think', 'Follow the sequence when it starts.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy;

    return SizedBox(
      height: slotHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _kGlassFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kGlassBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/panda_logo.webp',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Column(
                    key: ValueKey(copy.$1),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        copy.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                      ),
                      Text(
                        copy.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFFD4CCF0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFFD54F),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LivesRow extends StatelessWidget {
  const LivesRow({super.key, required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$lives lives remaining',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: _kGlassFill,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kGlassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final filled = i < lives;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedScale(
                scale: filled ? 1 : 0.88,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  filled
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: filled
                      ? const Color(0xFFFF4D6D)
                      : const Color(0x99A898D8),
                  size: 22,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class LevelStageChip extends StatelessWidget {
  const LevelStageChip({
    super.key,
    required this.level,
    required this.stage,
  });

  final int level;
  final int stage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
              children: [
                TextSpan(
                  text: 'Lv ',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
                TextSpan(
                  text: '$level',
                  style: const TextStyle(color: AppColors.primary),
                ),
                TextSpan(
                  text: '  •  St ',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
                TextSpan(
                  text: '$stage',
                  style: const TextStyle(color: Color(0xFFF5A623)),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -11,
          child: Icon(
            Icons.star_rounded,
            size: 22,
            color: const Color(0xFFFFC107),
            shadows: [
              Shadow(
                color: const Color(0xFFFFB300).withValues(alpha: 0.55),
                blurRadius: 8,
              ),
              const Shadow(
                color: Color(0x66FFFFFF),
                offset: Offset(-0.8, -0.8),
                blurRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PauseChipButton extends StatelessWidget {
  const PauseChipButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Pause',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kGlassFill,
              shape: BoxShape.circle,
              border: Border.all(color: _kGlassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.pause_rounded,
              color: onPressed == null
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft timer badge — plain frosted disc with a thin progress arc.
/// No neon glow / gradient ring.
class StageTimerRing extends StatelessWidget {
  const StageTimerRing({
    super.key,
    required this.remainingMs,
    required this.totalMs,
  });

  static const double size = 58;

  final int remainingMs;
  final int totalMs;

  @override
  Widget build(BuildContext context) {
    final progress = totalMs <= 0
        ? 0.0
        : (remainingMs / totalMs).clamp(0.0, 1.0);
    final seconds = (remainingMs / 1000).ceil().clamp(0, 999);
    final urgent = progress < 0.25;
    final accent = urgent ? const Color(0xFFFF6B6B) : const Color(0xFFB8AEF0);

    return Semantics(
      label: '$seconds seconds remaining',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _kGlassFill,
          shape: BoxShape.circle,
          border: Border.all(color: _kGlassBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: SizedBox(
          width: size - 10,
          height: size - 10,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.5,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(accent),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$seconds',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          height: 1,
                        ),
                  ),
                  Text(
                    'sec',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          height: 1.1,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PauseDialog extends StatelessWidget {
  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onRestartStage,
    required this.onHome,
  });

  final VoidCallback onResume;
  final VoidCallback onRestartStage;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paused',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            _btn(context, 'Resume', onResume, AppColors.primary),
            const SizedBox(height: 12),
            _btn(context, 'Restart Stage', onRestartStage, AppColors.secondary),
            const SizedBox(height: 12),
            _btn(context, 'Home', onHome, AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _btn(
    BuildContext context,
    String label,
    VoidCallback onTap,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(48, 52),
        ),
        child: Text(label),
      ),
    );
  }
}
