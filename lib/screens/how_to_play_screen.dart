import 'package:flutter/material.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/widgets/common/common_widgets.dart';

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      emoji: '👀',
      title: 'Watch the Sequence',
      body:
          'Tiles light up one by one. Watch carefully — each blink lasts one second.',
    ),
    (
      emoji: '🧠',
      title: 'Remember the Order',
      body:
          'When you see GO, tap the tiles in the exact same order. You have limited time!',
    ),
    (
      emoji: '❤️',
      title: 'Beat Every Level',
      body:
          'You have 3 lives. Mistakes and timeouts cost a life. Clear all 9 levels to become a Memory Master!',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textOnDark, size: 28),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            key: ValueKey(page.title),
                            tween: Tween(begin: 0.7, end: 1),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutBack,
                            builder: (context, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                            child: Text(
                              page.emoji,
                              style: const TextStyle(fontSize: 88),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SoftCard(
                            child: Column(
                              children: [
                                Text(
                                  page.title,
                                  style:
                                      Theme.of(context).textTheme.headlineMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  page.body,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.textOnDark : Colors.white54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: PrimaryGameButton(
                  label: _page == _pages.length - 1 ? 'Got it!' : 'Next',
                  width: double.infinity,
                  onPressed: () {
                    if (_page == _pages.length - 1) {
                      Navigator.pop(context);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
