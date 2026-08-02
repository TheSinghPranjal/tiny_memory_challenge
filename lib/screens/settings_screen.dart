import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_challenge/controllers/app_controllers.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/models/animal_profile.dart';
import 'package:memory_challenge/widgets/profile/profile_avatar.dart';

/// Frosted neon glass used by settings cards (matches design mock).
const Color _kGlassFill = Color(0xB31A1048);
const Color _kNeonBorder = Color(0xFFB794F6);
const Color _kNeonGlow = Color(0x99A78BFA);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final profiles = ref.watch(profilesControllerProvider.notifier);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x33000000),
                  Color(0x66000000),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
                  child: Row(
                    children: [
                      _BackButton(onPressed: () => Navigator.pop(context)),
                      const SizedBox(width: 8),
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 30,
                              shadows: const [
                                Shadow(
                                  color: Color(0x99B794F6),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFD54F),
                        size: 22,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    children: [
                      _NeonGlassCard(
                        child: Column(
                          children: [
                            const _SectionPill(
                              icon: Icons.pets_rounded,
                              label: 'PROFILE',
                            ),
                            const SizedBox(height: 14),
                            ProfileSelectorRow(
                              selected: settings.lastActiveProfile,
                              onSelected: (p) async {
                                await ref
                                    .read(audioServiceProvider)
                                    .playButtonTap();
                                await ref
                                    .read(settingsControllerProvider.notifier)
                                    .setActiveProfile(p);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _NeonGlassCard(
                        child: Column(
                          children: [
                            const _SectionPill(
                              icon: Icons.timer_outlined,
                              label: 'STAGE TIMER',
                            ),
                            const SizedBox(height: 16),
                            _StageTimerBlock(
                              seconds: settings.timerDurationSeconds,
                              onChanged: (snapped) {
                                ref
                                    .read(settingsControllerProvider.notifier)
                                    .setTimerDuration(snapped);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _NeonGlassCard(
                        child: Column(
                          children: [
                            const _SectionPill(
                              icon: Icons.music_note_rounded,
                              label: 'PREFERENCES',
                            ),
                            const SizedBox(height: 8),
                            _PreferenceToggle(
                              icon: Icons.music_note_rounded,
                              iconColor: const Color(0xFFB794F6),
                              title: 'Music',
                              subtitle: 'Background music and melodies.',
                              value: settings.musicEnabled,
                              onChanged: (v) => ref
                                  .read(settingsControllerProvider.notifier)
                                  .setMusicEnabled(v),
                            ),
                            const _PreferenceDivider(),
                            _PreferenceToggle(
                              icon: Icons.volume_up_rounded,
                              iconColor: const Color(0xFF4FC3F7),
                              title: 'Sound',
                              subtitle: 'Sound effects and UI sounds.',
                              value: settings.soundEnabled,
                              onChanged: (v) => ref
                                  .read(settingsControllerProvider.notifier)
                                  .setSoundEnabled(v),
                            ),
                            const _PreferenceDivider(),
                            _PreferenceToggle(
                              icon: Icons.vibration_rounded,
                              iconColor: const Color(0xFF4ADE80),
                              title: 'Vibration',
                              subtitle: 'Haptic feedback on actions.',
                              value: settings.vibrationEnabled,
                              onChanged: (v) => ref
                                  .read(settingsControllerProvider.notifier)
                                  .setVibrationEnabled(v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _NeonGlassCard(
                        child: Column(
                          children: [
                            const _SectionPill(
                              icon: Icons.emoji_events_rounded,
                              label: 'LEADERBOARD',
                            ),
                            const SizedBox(height: 12),
                            ...profiles.leaderboard().map((entry) {
                              return _LeaderboardTile(
                                rank: entry.rank,
                                profile: entry.profile,
                                level: entry.stats.maxLevel,
                                stage: entry.stats.maxStage,
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _NeonGlassCard(
                        child: Column(
                          children: [
                            const _SectionPill(
                              icon: Icons.more_horiz_rounded,
                              label: 'MORE',
                            ),
                            _GlassListTile(
                              label: 'Reset Current Profile',
                              icon: Icons.restart_alt_rounded,
                              onTap: () async {
                                final ok = await _confirm(
                                  context,
                                  'Reset ${settings.lastActiveProfile.displayName}?',
                                );
                                if (ok) {
                                  await ref
                                      .read(profilesControllerProvider.notifier)
                                      .resetProfile(
                                          settings.lastActiveProfile);
                                }
                              },
                            ),
                            const _PreferenceDivider(),
                            _GlassListTile(
                              label: 'Reset All Progress',
                              icon: Icons.delete_forever_rounded,
                              onTap: () async {
                                final ok = await _confirm(
                                  context,
                                  'Reset ALL profiles?',
                                );
                                if (ok) {
                                  await ref
                                      .read(profilesControllerProvider.notifier)
                                      .resetAll();
                                }
                              },
                            ),
                            const _PreferenceDivider(),
                            _GlassListTile(
                              label: 'Privacy Policy',
                              icon: Icons.open_in_new_rounded,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Privacy Policy'),
                                    content: const Text(
                                      'Tiny Think stores all progress locally on your device. '
                                      'No personal data is collected. Banner ads may use the AdMob SDK. '
                                      'Full policy: ${AppConstants.privacyPolicyUrl}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const _PreferenceDivider(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Version ${AppConstants.version}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFFD4CCF0),
                                      ),
                                ),
                              ),
                            ),
                            const _StatsSummary(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _NeonGlassCard extends StatelessWidget {
  const _NeonGlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: _kGlassFill,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _kNeonBorder, width: 1.6),
        boxShadow: const [
          BoxShadow(
            color: _kNeonGlow,
            blurRadius: 14,
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE63D2B7A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x99C4B5FD), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66A78BFA),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, size: 13, color: Colors.green.shade300),
          const SizedBox(width: 6),
          Icon(icon, size: 15, color: const Color(0xFFE9D5FF)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.eco_rounded, size: 13, color: Colors.green.shade300),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xCC3D2B7A),
            border: Border.all(color: _kNeonBorder, width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: _kNeonGlow,
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _StageTimerBlock extends StatelessWidget {
  const _StageTimerBlock({
    required this.seconds,
    required this.onChanged,
  });

  final int seconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0x663D2B7A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x66C4B5FD)),
          ),
          child: const Icon(
            Icons.timer_rounded,
            color: Color(0xFFE9D5FF),
            size: 36,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$seconds sec',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _kNeonBorder,
                  inactiveTrackColor: const Color(0x663D2B7A),
                  thumbColor: const Color(0xFFFFD54F),
                  overlayColor: const Color(0x33FFD54F),
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 9,
                  ),
                ),
                child: Slider(
                  value: seconds.toDouble(),
                  min: AppConstants.minTimerSeconds.toDouble(),
                  max: AppConstants.maxTimerSeconds.toDouble(),
                  divisions: ((AppConstants.maxTimerSeconds -
                              AppConstants.minTimerSeconds) ~/
                          AppConstants.timerStepSeconds),
                  label: '${seconds}s',
                  onChanged: (v) {
                    final snapped = AppConstants.minTimerSeconds +
                        (((v - AppConstants.minTimerSeconds) /
                                    AppConstants.timerStepSeconds)
                                .round() *
                            AppConstants.timerStepSeconds);
                    onChanged(snapped);
                  },
                ),
              ),
              Text(
                'Choose how much time you get to complete each stage.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFD4CCF0),
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferenceToggle extends StatelessWidget {
  const _PreferenceToggle({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withValues(alpha: 0.45)),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFD4CCF0),
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: const Color(0xFFE9D5FF),
            inactiveTrackColor: const Color(0x663D2B7A),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PreferenceDivider extends StatelessWidget {
  const _PreferenceDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0x33FFFFFF),
    );
  }
}

class _GlassListTile extends StatelessWidget {
  const _GlassListTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            Icon(icon, color: const Color(0xFFE9D5FF), size: 22),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.profile,
    required this.level,
    required this.stage,
  });

  final int rank;
  final AnimalProfile profile;
  final int level;
  final int stage;

  Color get _cardColor {
    switch (rank) {
      case 1:
        return const Color(0xE6FFE082);
      case 2:
        return const Color(0xE6C5CAE9);
      case 3:
        return const Color(0xE6FFAB91);
      default:
        return const Color(0xCCB39DDB);
    }
  }

  Color get _medalColor {
    switch (rank) {
      case 1:
        return AppColors.gold;
      case 2:
        return AppColors.silver;
      case 3:
        return AppColors.bronze;
      default:
        return AppColors.rankBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _medalColor,
              boxShadow: [
                BoxShadow(
                  color: _medalColor.withValues(alpha: 0.45),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              '$rank',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          ProfileAvatar(profile: profile, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                ),
                Text(
                  stage == 0
                      ? 'Not started'
                      : 'Level $level · Stage $stage',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.star_rounded, color: _medalColor, size: 18),
          const SizedBox(width: 4),
          Text(
            stage == 0 ? '0' : '${level * 250 + stage * 40}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatsSummary extends ConsumerWidget {
  const _StatsSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(activeProfileStatsProvider);
    final accuracy = (stats.averageAccuracy * 100).toStringAsFixed(0);
    final avgMs = stats.averageResponseMs.toStringAsFixed(0);
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFD4CCF0),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
        ),
        const SizedBox(height: 8),
        Text('Games played: ${stats.gamesPlayed}', style: style),
        Text('Won / Lost: ${stats.gamesWon} / ${stats.gamesLost}',
            style: style),
        Text('Longest streak: ${stats.longestStreak}', style: style),
        Text('Total mistakes: ${stats.totalMistakes}', style: style),
        Text('Accuracy: $accuracy%', style: style),
        Text('Avg response: ${avgMs}ms', style: style),
      ],
    );
  }
}
