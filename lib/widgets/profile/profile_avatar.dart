import 'package:flutter/material.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/models/animal_profile.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.size = 64,
    this.selected = false,
    this.onTap,
    this.showName = false,
  });

  final AnimalProfile profile;
  final double size;
  final bool selected;
  final VoidCallback? onTap;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final ring = selected
        ? BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.7),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          )
        : null;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: profile.color,
        border: Border.all(
          color: selected ? AppColors.gold : Colors.white.withValues(alpha: 0.8),
          width: selected ? 3.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        profile.emoji,
        style: TextStyle(fontSize: size * 0.48),
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(decoration: ring ?? const BoxDecoration(), child: avatar),
        if (showName) ...[
          const SizedBox(height: 8),
          Text(
            profile.displayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
          ),
        ],
      ],
    );

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: '${profile.displayName} profile',
      child: GestureDetector(
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class ProfileSelectorRow extends StatelessWidget {
  const ProfileSelectorRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AnimalProfile selected;
  final ValueChanged<AnimalProfile> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: AnimalProfile.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final profile = AnimalProfile.values[index];
          return ProfileAvatar(
            profile: profile,
            size: 64,
            selected: profile == selected,
            showName: true,
            onTap: () => onSelected(profile),
          );
        },
      ),
    );
  }
}
