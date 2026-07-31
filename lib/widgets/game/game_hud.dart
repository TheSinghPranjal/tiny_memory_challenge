import 'package:flutter/material.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/models/game_state.dart';

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

  Color get _color {
    switch (phase) {
      case GamePhase.go:
        return AppColors.success;
      case GamePhase.levelIntroObserve:
        return AppColors.secondary;
      default:
        return AppColors.textOnDark;
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
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 350),
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
          child: Text(
            label,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: _color,
                  fontSize: 56,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final filled = i < lives;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedScale(
              scale: filled ? 1 : 0.85,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                filled ? Icons.favorite : Icons.favorite_border,
                color: filled ? AppColors.danger : Colors.white54,
                size: 28,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class StageTimerRing extends StatelessWidget {
  const StageTimerRing({
    super.key,
    required this.remainingMs,
    required this.totalMs,
  });

  static const double size = 52;

  final int remainingMs;
  final int totalMs;

  @override
  Widget build(BuildContext context) {
    final progress =
        totalMs <= 0 ? 0.0 : (remainingMs / totalMs).clamp(0.0, 1.0);
    final seconds = (remainingMs / 1000).ceil().clamp(0, 999);
    final urgent = progress < 0.25;

    return Semantics(
      label: '$seconds seconds remaining',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 5,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(
                  urgent ? AppColors.danger : AppColors.secondary,
                ),
              ),
            ),
            Text(
              '$seconds',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textOnDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1,
                  ),
            ),
          ],
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
