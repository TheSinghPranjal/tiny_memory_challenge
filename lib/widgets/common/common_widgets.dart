import 'package:flutter/material.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: child,
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: color == null ? AppColors.cardGradient : null,
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PrimaryGameButton extends StatefulWidget {
  const PrimaryGameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.width,
    this.glowing = false,
    this.glowColor,
    this.depth3D = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final double? width;

  /// When true, renders an animated pulsing neon-glow ring around the
  /// button (used for the "Start Game" primary CTA on the home screen).
  final bool glowing;

  /// Color of the neon ring. Defaults to [AppColors.secondary] when
  /// [glowing] is true and no override is given.
  final Color? glowColor;

  /// When true, adds a solid darker "base" layer offset below the pill,
  /// giving a chunky 3D/beveled look (used for popup CTAs like Continue).
  /// Works best with an explicit [width] (e.g. double.infinity) since the
  /// base layer mirrors the pill's own width/constraints exactly.
  final bool depth3D;

  @override
  State<PrimaryGameButton> createState() => _PrimaryGameButtonState();
}

class _PrimaryGameButtonState extends State<PrimaryGameButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  AnimationController? _glowController;
  Animation<double>? _glow;

  @override
  void initState() {
    super.initState();
    if (widget.glowing) {
      _glowController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat(reverse: true);
      _glow = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _glowController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? AppColors.secondary;





    final button = Container(
      width: widget.width,
      constraints: const BoxConstraints(minHeight: 56, minWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        gradient: widget.color == null ? AppColors.buttonGradient : null,
        color: widget.color,
        borderRadius: BorderRadius.circular(22),
        border: widget.glowing
            ? Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.4,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: (widget.color ?? AppColors.primary).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: AppColors.textOnDark, size: 22),
            const SizedBox(width: 10),
          ],
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );

    final scaled = AnimatedScale(
      scale: _pressed ? 0.96 : 1,
      duration: const Duration(milliseconds: 100),
      child: button,
    );

    final content = widget.glowing
        ? AnimatedBuilder(
      animation: _glow!,
      builder: (context, child) {
        final t = _glow!.value;
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              // Wide soft outer halo — breathes in and out.
              BoxShadow(
                color: glowColor.withValues(alpha: 0.55 * t),
                blurRadius: 28 * t,
                spreadRadius: 4 * t,
              ),
              // Tight bright rim right at the edge of the pill.
              BoxShadow(
                color: glowColor.withValues(alpha: 0.9),
                blurRadius: 6,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: scaled,
    )
        : scaled;

    final depthWrapped = widget.depth3D
        ? Stack(
      clipBehavior: Clip.none,
      children: [
        // Solid darker "base" layer, offset down — reads as a
        // chunky 3D bevel rather than a soft blurred shadow.
        Transform.translate(
          offset: const Offset(0, 6),
          child: Container(
            width: widget.width,
            constraints:
            const BoxConstraints(minHeight: 56, minWidth: 160),
            decoration: BoxDecoration(
              color: Color.lerp(
                widget.color ?? AppColors.primary,
                Colors.black,
                0.35,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        content,
      ],
    )
        : content;

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: widget.onPressed == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.onPressed == null
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: depthWrapped,
      ),
    );
  }
}

class SecondaryGameButton extends StatelessWidget {
  const SecondaryGameButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textOnDark,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(48, 48),
          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textOnDark,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}