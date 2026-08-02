import 'package:flutter/material.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/widgets/common/common_widgets.dart';

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
    this.showWatchAd = false,
    this.adLoading = false,
    this.onWatchAd,
  });

  final int level;
  final List<int> sequence;
  final int livesRemaining;
  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final bool isTimeout;

  /// First game-over only: offer a rewarded ad for one bonus life.
  final bool showWatchAd;
  final bool adLoading;
  final VoidCallback? onWatchAd;

  @override
  Widget build(BuildContext context) {
    final badges = <int, int>{
      for (var i = 0; i < sequence.length; i++) sequence[i]: i + 1,
    };
    final gameOver = livesRemaining <= 0;

    final String emoji;
    final String title;
    if (gameOver) {
      emoji = '💔';
      title = 'Game Over';
    } else if (isTimeout) {
      emoji = '⏰';
      title = "Time's Up!";
    } else {
      emoji = '❌';
      title = 'Not Quite!';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SoftCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 8),
            Text(
              title,
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
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.sizeOf(context).shortestSide * 0.42,
              child: _RecapGrid(level: level, badges: badges),
            ),
            const SizedBox(height: 24),
            if (!gameOver)
              PrimaryGameButton(
                label: 'Continue',
                icon: Icons.play_arrow_rounded,
                onPressed: onContinue,
                width: double.infinity,
                depth3D: true,
              )
            else ...[
              if (showWatchAd) ...[
                PrimaryGameButton(
                  label: adLoading
                      ? 'Loading Ad…'
                      : 'Watch Ad for 1 Extra Life',
                  icon: adLoading
                      ? Icons.hourglass_top_rounded
                      : Icons.ondemand_video_rounded,
                  color: AppColors.accent,
                  onPressed: adLoading ? null : onWatchAd,
                  width: double.infinity,
                  depth3D: true,
                ),
                const SizedBox(height: 12),
              ],
              PrimaryGameButton(
                label: 'Restart Game',
                icon: Icons.refresh_rounded,
                onPressed: adLoading ? null : onRestart,
                width: double.infinity,
                depth3D: true,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: adLoading ? null : onHome,
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

/// Flat "study card" grid used inside the mistake/timeout popup to recap
/// the correct blink order. Deliberately simpler than the live [MemoryBoard]
/// tiles — no glow/float animation, just a soft card + numbered badge +
/// decorative sparkle accents, matching the reference design.
class _RecapGrid extends StatelessWidget {
  const _RecapGrid({required this.level, required this.badges});

  final int level;
  final Map<int, int> badges;

  static const _sparkleColors = [
    AppColors.gold,
    AppColors.danger,
    AppColors.secondary,
    AppColors.success,
  ];

  @override
  Widget build(BuildContext context) {
    final active = LevelConfig.squareCountFor(level);
    final dim = LevelConfig.gridDimensionFor(level);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        const spacing = 14.0;
        final tileSize = (maxSide - spacing * (dim - 1)) / dim;

        return SizedBox(
          width: maxSide,
          height: maxSide,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: dim,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1,
            ),
            itemCount: active,
            itemBuilder: (context, index) {
              return SizedBox(
                width: tileSize,
                height: tileSize,
                child: _RecapTile(
                  order: badges[index],
                  sparkleColor: _sparkleColors[index % _sparkleColors.length],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RecapTile extends StatelessWidget {
  const _RecapTile({required this.order, required this.sparkleColor});

  final int? order;
  final Color sparkleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: sparkleColor.withValues(alpha: 0.85),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 11,
              color: sparkleColor.withValues(alpha: 0.55),
            ),
          ),
          if (order != null)
            Center(
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '$order',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown after a rewarded ad completes — player must confirm to use the life.
class AdBonusContinuePopup extends StatelessWidget {
  const AdBonusContinuePopup({
    super.key,
    required this.onContinue,
    required this.onHome,
  });

  final VoidCallback onContinue;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SoftCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('❤️', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 8),
            Text(
              'Extra Life!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Continue with your rewarded extra life?',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryGameButton(
              label: 'Continue with Extra Life',
              icon: Icons.favorite_rounded,
              color: AppColors.accent,
              onPressed: onContinue,
              width: double.infinity,
              depth3D: true,
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