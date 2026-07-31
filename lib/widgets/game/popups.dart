import 'package:flutter/material.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/widgets/common/common_widgets.dart';
import 'package:memory_challenge/widgets/game/memory_board.dart';

class WrongSequencePopup extends StatelessWidget {
  const WrongSequencePopup({
    super.key,
    required this.level,
    required this.sequence,
    required this.livesRemaining,
    required this.onContinue,
    required this.onRestart,
    required this.onHome,
    this.isTimeout = false,
  });

  final int level;
  final List<int> sequence;
  final int livesRemaining;
  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final bool isTimeout;

  @override
  Widget build(BuildContext context) {
    final badges = <int, int>{
      for (var i = 0; i < sequence.length; i++) sequence[i]: i + 1,
    };
    final gameOver = livesRemaining <= 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SoftCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gameOver
                  ? 'Game Over'
                  : (isTimeout ? 'Time\'s Up!' : 'Correct Sequence'),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              gameOver
                  ? 'You ran out of lives. Try again!'
                  : 'Study the order, then continue.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: MediaQuery.sizeOf(context).shortestSide * 0.42,
              child: MemoryBoard(
                level: level,
                tileStates: const {},
                inputEnabled: false,
                sequenceBadges: badges,
                onTileTap: (_) {},
              ),
            ),
            const SizedBox(height: 20),
            if (!gameOver)
              PrimaryGameButton(
                label: 'Continue',
                icon: Icons.play_arrow_rounded,
                onPressed: onContinue,
                width: double.infinity,
              )
            else ...[
              PrimaryGameButton(
                label: 'Restart Game',
                icon: Icons.refresh_rounded,
                onPressed: onRestart,
                width: double.infinity,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onHome,
                child: Text(
                  'Home',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LevelCompletePopup extends StatelessWidget {
  const LevelCompletePopup({
    super.key,
    required this.level,
    required this.onContinue,
  });

  final int level;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SoftCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            Text(
              'Level Complete!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You finished Level $level',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.star_rounded, color: AppColors.gold, size: 36),
                ),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryGameButton(
              label: 'Next Level',
              icon: Icons.arrow_forward_rounded,
              onPressed: onContinue,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
