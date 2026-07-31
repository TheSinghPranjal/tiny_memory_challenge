import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_challenge/controllers/app_controllers.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/models/animal_profile.dart';
import 'package:memory_challenge/widgets/common/common_widgets.dart';
import 'package:memory_challenge/widgets/profile/profile_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final profiles = ref.watch(profilesControllerProvider.notifier);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textOnDark),
                    ),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Profile',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
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
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stage Timer: ${settings.timerDurationSeconds}s',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Slider(
                            value: settings.timerDurationSeconds.toDouble(),
                            min: AppConstants.minTimerSeconds.toDouble(),
                            max: AppConstants.maxTimerSeconds.toDouble(),
                            divisions: ((AppConstants.maxTimerSeconds -
                                        AppConstants.minTimerSeconds) ~/
                                    AppConstants.timerStepSeconds),
                            label: '${settings.timerDurationSeconds}s',
                            activeColor: AppColors.primary,
                            onChanged: (v) {
                              final snapped = AppConstants.minTimerSeconds +
                                  (((v - AppConstants.minTimerSeconds) /
                                              AppConstants.timerStepSeconds)
                                          .round() *
                                      AppConstants.timerStepSeconds);
                              ref
                                  .read(settingsControllerProvider.notifier)
                                  .setTimerDuration(snapped);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SoftCard(
                      child: Column(
                        children: [
                          _toggle(
                            context,
                            'Music',
                            settings.musicEnabled,
                            (v) => ref
                                .read(settingsControllerProvider.notifier)
                                .setMusicEnabled(v),
                          ),
                          _toggle(
                            context,
                            'Sound',
                            settings.soundEnabled,
                            (v) => ref
                                .read(settingsControllerProvider.notifier)
                                .setSoundEnabled(v),
                          ),
                          _toggle(
                            context,
                            'Vibration',
                            settings.vibrationEnabled,
                            (v) => ref
                                .read(settingsControllerProvider.notifier)
                                .setVibrationEnabled(v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Leaderboard',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          ...profiles.leaderboard().map((entry) {
                            return _LeaderboardTile(
                              rank: entry.rank,
                              profile: entry.profile,
                              level: entry.stats.maxLevel,
                              stage: entry.stats.maxStage,
                              livesUsed: entry.stats.livesUsedAtMax,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SoftCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Reset Current Profile',
                                style: Theme.of(context).textTheme.bodyLarge),
                            trailing: const Icon(Icons.restart_alt),
                            onTap: () async {
                              final ok = await _confirm(
                                context,
                                'Reset ${settings.lastActiveProfile.displayName}?',
                              );
                              if (ok) {
                                await ref
                                    .read(profilesControllerProvider.notifier)
                                    .resetProfile(settings.lastActiveProfile);
                              }
                            },
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Reset All Progress',
                                style: Theme.of(context).textTheme.bodyLarge),
                            trailing: const Icon(Icons.delete_forever),
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
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Privacy Policy',
                                style: Theme.of(context).textTheme.bodyLarge),
                            trailing: const Icon(Icons.open_in_new),
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
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Version ${AppConstants.version}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _StatsSummary(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
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

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.profile,
    required this.level,
    required this.stage,
    required this.livesUsed,
  });

  final int rank;
  final AnimalProfile profile;
  final int level;
  final int stage;
  final int livesUsed;

  Color get _cardColor {
    switch (rank) {
      case 1:
        return AppColors.gold.withValues(alpha: 0.35);
      case 2:
        return AppColors.silver.withValues(alpha: 0.45);
      case 3:
        return AppColors.bronze.withValues(alpha: 0.35);
      default:
        return AppColors.rankBlue.withValues(alpha: 0.25);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ProfileAvatar(profile: profile, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.displayName,
                    style: Theme.of(context).textTheme.titleLarge),
                Text(
                  stage == 0
                      ? 'Not started'
                      : 'Level $level · Stage $stage · $livesUsed lives used',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSummary extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(activeProfileStatsProvider);
    final accuracy = (stats.averageAccuracy * 100).toStringAsFixed(0);
    final avgMs = stats.averageResponseMs.toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Stats', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Games played: ${stats.gamesPlayed}'),
        Text('Won / Lost: ${stats.gamesWon} / ${stats.gamesLost}'),
        Text('Longest streak: ${stats.longestStreak}'),
        Text('Total mistakes: ${stats.totalMistakes}'),
        Text('Accuracy: $accuracy%'),
        Text('Avg response: ${avgMs}ms'),
      ],
    );
  }
}
