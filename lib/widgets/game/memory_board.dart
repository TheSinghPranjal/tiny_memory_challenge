import 'package:flutter/material.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/models/game_state.dart';
import 'package:memory_challenge/widgets/game/memory_tile.dart';

class MemoryBoard extends StatelessWidget {
  const MemoryBoard({
    super.key,
    required this.level,
    required this.tileStates,
    required this.inputEnabled,
    required this.onTileTap,
    this.sequenceBadges,
  });

  final int level;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final spacing = AppConstants.tileSpacing;
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
