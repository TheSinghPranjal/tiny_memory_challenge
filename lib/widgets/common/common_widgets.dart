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
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final double? width;

  @override
  State<PrimaryGameButton> createState() => _PrimaryGameButtonState();
}

class _PrimaryGameButtonState extends State<PrimaryGameButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: widget.width,
            constraints: const BoxConstraints(minHeight: 56, minWidth: 160),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              gradient: widget.color == null ? AppColors.buttonGradient : null,
              color: widget.color,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: (widget.color ?? AppColors.primary)
                      .withValues(alpha: 0.4),
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
          ),
        ),
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
