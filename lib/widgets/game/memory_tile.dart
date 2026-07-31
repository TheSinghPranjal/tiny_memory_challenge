import 'package:flutter/material.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/models/game_state.dart';

class MemoryTile extends StatefulWidget {
  const MemoryTile({
    super.key,
    required this.index,
    required this.visualState,
    required this.enabled,
    required this.onTap,
    this.badge,
    this.isFiller = false,
  });

  final int index;
  final TileVisualState visualState;
  final bool enabled;
  final VoidCallback onTap;
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
    _float = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.visualState) {
      case TileVisualState.blinking:
        return AppColors.tileBlink;
      case TileVisualState.correct:
        return AppColors.tileCorrect;
      case TileVisualState.wrong:
        return AppColors.tileWrong;
      case TileVisualState.locked:
      case TileVisualState.dimmed:
        return AppColors.tileLocked;
      case TileVisualState.idle:
        return AppColors.tileIdle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFiller) {
      return const SizedBox.expand();
    }

    final isBlink = widget.visualState == TileVisualState.blinking;
    final isWrong = widget.visualState == TileVisualState.wrong;
    final isCorrect = widget.visualState == TileVisualState.correct;

    return Semantics(
      button: widget.enabled,
      label: 'Tile ${widget.index + 1}',
      child: AnimatedBuilder(
        animation: _float,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.visualState == TileVisualState.idle
                ? _float.value
                : 0),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 1,
              end: isBlink ? 1.08 : (isWrong ? 0.94 : (isCorrect ? 1.06 : 1)),
            ),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: _color,
                borderRadius:
                    BorderRadius.circular(AppConstants.tileBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: (isBlink ? AppColors.tileBlink : Colors.black)
                        .withValues(alpha: isBlink ? 0.55 : 0.18),
                    blurRadius: isBlink ? 22 : 10,
                    spreadRadius: isBlink ? 2 : 0,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  if (isBlink)
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppConstants.tileBorderRadius),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x66FFFFFF),
                              Color(0x00FFFFFF),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget.badge != null)
                    Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${widget.badge}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
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
  }
}
