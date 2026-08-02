import 'package:flutter/material.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/core/theme/card_themes.dart';
import 'package:memory_challenge/models/game_state.dart';
import 'package:memory_challenge/widgets/game/memory_tile.dart';

class MemoryBoard extends StatelessWidget {
  const MemoryBoard({
    super.key,
    required this.level,
    required this.stage,
    required this.tileStates,
    required this.inputEnabled,
    required this.onTileTap,
    this.sequenceBadges,
  });

  final int level;

  /// Current stage within the level — used together with [level] to pick a
  /// different card-set colour theme for every stage.
  final int stage;

  final Map<int, TileVisualState> tileStates;
  final bool inputEnabled;
  final ValueChanged<int> onTileTap;

  /// Optional map of active tile index → order badge (1-based).
  final Map<int, int>? sequenceBadges;

  @override
  Widget build(BuildContext context) {
    final active = LevelConfig.squareCountFor(level);
    final dim = LevelConfig.gridDimensionFor(level);
    final total = dim * dim;
    final theme = cardThemeForStage(level: level, stage: stage);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final spacing = AppConstants.tileSpacing + 2;
        final pad = 16.0;
        final inner = maxSide - pad * 2;
        final tileSize = (inner - spacing * (dim - 1)) / dim;

        return Container(
          width: maxSide,
          height: maxSide,
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.38),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: theme.idleDark.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: dim,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1,
            ),
            itemCount: total,
            itemBuilder: (context, gridIndex) {
              final isFiller = gridIndex >= active;
              final visual = isFiller
                  ? TileVisualState.locked
                  : (tileStates[gridIndex] ?? TileVisualState.idle);
              return SizedBox(
                width: tileSize,
                height: tileSize,
                child: MemoryTile(
                  index: gridIndex,
                  isFiller: isFiller,
                  visualState: visual,
                  enabled: inputEnabled && !isFiller,
                  badge: sequenceBadges?[gridIndex],
                  theme: theme,
                  onTap: () => onTileTap(gridIndex),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
