import 'package:flutter/material.dart' hide CardTheme;
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/core/theme/card_themes.dart';
import 'package:memory_challenge/models/game_state.dart';

class MemoryTile extends StatefulWidget {
  const MemoryTile({
    super.key,
    required this.index,
    required this.visualState,
    required this.enabled,
    required this.onTap,
    required this.theme,
    this.badge,
    this.isFiller = false,
  });

  final int index;
  final TileVisualState visualState;
  final bool enabled;
  final VoidCallback onTap;

  /// The colour theme for the current stage's card set.
  final CardTheme theme;

  final int? badge;
  final bool isFiller;

  @override
  State<MemoryTile> createState() => _MemoryTileState();
}

class _MemoryTileState extends State<MemoryTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800 + (widget.index % 5) * 120),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -2.5, end: 2.5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  bool get _showStar =>
      widget.visualState == TileVisualState.idle ||
      widget.visualState == TileVisualState.dimmed;

  List<Color> get _gradientColors {
    final t = widget.theme;
    switch (widget.visualState) {
      case TileVisualState.blinking:
        // Always the theme's complementary colour — guaranteed to read as
        // different from the idle card colour, whichever theme is active.
        return [t.blinkLight, t.blinkDark];
      case TileVisualState.correct:
        return const [Color(0xFF8FF0B0), Color(0xFF4ADE80)];
      case TileVisualState.wrong:
        return const [Color(0xFFFF9B9B), Color(0xFFFF6B6B)];
      case TileVisualState.locked:
        return const [Color(0xFFD4CEE8), Color(0xFFB8B0D0)];
      case TileVisualState.dimmed:
        return [
          Color.lerp(t.idleLight, Colors.black, 0.12)!,
          Color.lerp(t.idleDark, Colors.black, 0.12)!,
        ];
      case TileVisualState.idle:
        return [t.idleLight, t.idleDark];
    }
  }

  Color get _accentShadow {
    final t = widget.theme;
    switch (widget.visualState) {
      case TileVisualState.blinking:
        return t.blinkGlow;
      case TileVisualState.correct:
        return AppColors.tileCorrect;
      case TileVisualState.wrong:
        return AppColors.tileWrong;
      case TileVisualState.locked:
        return AppColors.primary;
      case TileVisualState.idle:
      case TileVisualState.dimmed:
        return t.idleDark;
    }
  }

  Color get _borderColor {
    if (_showStar) {
      return widget.theme.idleBorder.withValues(alpha: 0.9);
    }
    final isBlink = widget.visualState == TileVisualState.blinking;
    return Colors.white.withValues(alpha: isBlink ? 0.95 : 0.8);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFiller) {
      return const SizedBox.expand();
    }

    final isBlink = widget.visualState == TileVisualState.blinking;
    final isWrong = widget.visualState == TileVisualState.wrong;
    final isCorrect = widget.visualState == TileVisualState.correct;
    final radius = BorderRadius.circular(AppConstants.tileBorderRadius + 4);
    final t = widget.theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = constraints.biggest.shortestSide.isFinite
            ? constraints.biggest.shortestSide
            : 72.0;
        final starSize = tileSize * 0.46;

        return Semantics(
          button: widget.enabled,
          label: 'Tile ${widget.index + 1}',
          child: AnimatedBuilder(
            animation: _float,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  widget.visualState == TileVisualState.idle
                      ? _float.value
                      : 0,
                ),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: widget.enabled ? widget.onTap : null,
              child: TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 1,
                  end: isBlink
                      ? 1.07
                      : (isWrong ? 0.94 : (isCorrect ? 1.05 : 1)),
                ),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _gradientColors,
                    ),
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: _accentShadow.withValues(
                          alpha: isBlink
                              ? 0.45
                              : (isCorrect || isWrong ? 0.35 : 0.18),
                        ),
                        blurRadius: isBlink ? 18 : 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: _borderColor,
                      width: isBlink ? 2.5 : 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Soft top sheen for the "candy" card look.
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: tileSize * 0.38,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: radius.topLeft,
                              topRight: radius.topRight,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.48),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Soft bottom depth for a puffy 3D card.
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: tileSize * 0.28,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: radius.bottomLeft,
                              bottomRight: radius.bottomRight,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.12),
                                Colors.black.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Embossed star — face-down motif on resting tiles.
                      if (_showStar)
                        Center(
                          child: Icon(
                            Icons.star_rounded,
                            size: starSize,
                            color: t.starColor.withValues(
                              alpha: widget.visualState ==
                                      TileVisualState.dimmed
                                  ? 0.5
                                  : 0.82,
                            ),
                            shadows: [
                              Shadow(
                                color: t.starHighlight,
                                offset: const Offset(-1.6, -1.6),
                                blurRadius: 1.8,
                              ),
                              Shadow(
                                color: t.starShadow,
                                offset: const Offset(1.8, 2.0),
                                blurRadius: 2.2,
                              ),
                            ],
                          ),
                        ),
                      if (widget.badge != null)
                        Center(
                          child: Container(
                            width: tileSize * 0.42,
                            height: tileSize * 0.42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.buttonGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              '${widget.badge}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: tileSize * 0.19,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
