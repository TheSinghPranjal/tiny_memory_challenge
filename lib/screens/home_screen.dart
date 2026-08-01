import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_challenge/controllers/app_controllers.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/screens/game_screen.dart';
import 'package:memory_challenge/screens/how_to_play_screen.dart';
import 'package:memory_challenge/screens/settings_screen.dart';
import 'package:memory_challenge/widgets/common/banner_ad_widget.dart';
import 'package:memory_challenge/widgets/common/common_widgets.dart';
import 'package:memory_challenge/widgets/profile/profile_avatar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).startMusic();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider);
    final stats = ref.watch(activeProfileStatsProvider);
    final progressLabel = stats.maxStage == 0
        ? 'Ready to begin'
        : 'Level ${stats.maxLevel} · Stage ${stats.maxStage}';

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
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ProfileAvatar(profile: profile, size: 52),
                        ),
                        const Spacer(flex: 2),
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            final t = Curves.easeInOut
                                .transform(_logoController.value);
                            return Transform.translate(
                              offset: Offset(0, -6 + t * 12),
                              child: child,
                            );
                          },
                          child: Image.asset(
                            'assets/images/panda_logo.webp',
                            height: 180,
                            fit: BoxFit.contain,
                            semanticLabel: AppConstants.appName,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SoftCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              ProfileAvatar(profile: profile, size: 44),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.displayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Text(
                                      'Highest: $progressLabel',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        PrimaryGameButton(
                          label: 'Start Game',
                          icon: Icons.play_arrow_rounded,
                          width: double.infinity,
                          onPressed: () async {
                            await ref
                                .read(audioServiceProvider)
                                .playButtonTap();
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GameScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryGameButton(
                                label: 'Settings',
                                icon: Icons.settings_rounded,
                                color: AppColors.secondary,
                                onPressed: () async {
                                  await ref
                                      .read(audioServiceProvider)
                                      .playButtonTap();
                                  if (!context.mounted) return;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PrimaryGameButton(
                                label: 'How To',
                                icon: Icons.help_outline_rounded,
                                color: AppColors.accent,
                                onPressed: () async {
                                  await ref
                                      .read(audioServiceProvider)
                                      .playButtonTap();
                                  if (!context.mounted) return;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const HowToPlayScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
                const HomeBannerAd(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
