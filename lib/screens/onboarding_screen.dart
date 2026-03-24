import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/primary_button.dart';
import 'app_shell.dart';
import 'mock_data.dart';
import 'signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _openApp() {
    Navigator.of(context).pushReplacement(AppMotion.route(const AppShell()));
  }

  void _openSignup() {
    Navigator.of(
      context,
    ).pushReplacement(AppMotion.route(const SignupScreen()));
  }

  Future<void> _nextPage() async {
    if (_page == 1) {
      await _requestLocationFromSlide();
    }

    if (_page == MockData.onboardingSlides.length - 1) {
      _openSignup();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _requestLocationFromSlide() async {
    final status = await LocationService.requestLocationPermission();
    if (!mounted) {
      return;
    }

    String? message;
    switch (status) {
      case LocationPermissionStatus.granted:
        message = 'Location enabled. We can now show nearby Lamyani branches.';
      case LocationPermissionStatus.denied:
        message = 'Location denied for now. You can enable it later in Stores.';
      case LocationPermissionStatus.deniedForever:
        message =
            'Location is blocked in system settings. You can enable it later.';
      case LocationPermissionStatus.disabled:
        message =
            'Turn on location services to see the nearest Lamyani branches.';
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = MockData.onboardingSlides;
    final isLast = _page == slides.length - 1;
    final progressLabel = '${_page + 1} of ${slides.length}';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _openApp,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.brownAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    final slide = slides[index];

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxHeight < 620;
                        final ultraCompact = constraints.maxHeight < 540;
                        final heroHeight = math.min(
                          ultraCompact
                              ? 336.0
                              : compact
                              ? 376.0
                              : 432.0,
                          constraints.maxHeight * 0.58,
                        );

                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: ultraCompact ? 8 : 14),
                                SizedBox(
                                  height: heroHeight,
                                  child: _OnboardingHeroCard(
                                    slide: slide,
                                    compact: compact,
                                    ultraCompact: ultraCompact,
                                  ),
                                ),
                                SizedBox(height: ultraCompact ? 18 : 26),
                                Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        fontSize: compact ? 27 : 31,
                                        height: 1.08,
                                      ),
                                ),
                                SizedBox(height: compact ? 12 : 14),
                                Text(
                                  slide.subtitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppColors.mutedText,
                                        fontSize: compact ? 14 : 15,
                                        height: 1.45,
                                      ),
                                ),
                                const SizedBox(height: 14),
                                _OnboardingHint(
                                  text: _slideHint(index),
                                  compact: compact,
                                ),
                                SizedBox(height: ultraCompact ? 8 : 12),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      progressLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.brownAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(
                      slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: _page == index ? 28 : 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _page == index
                              ? AppColors.primaryOrange
                              : AppColors.peachSurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: isLast ? 'Get Started' : 'Next',
                icon: isLast
                    ? Icons.restaurant_menu_rounded
                    : Icons.arrow_forward,
                onPressed: _nextPage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _slideHint(int index) {
    switch (index) {
      case 0:
        return 'Cebu-roasted favorites, ready for fast ordering.';
      case 1:
        return 'We will ask for location permission on the next tap.';
      case 2:
        return 'Rewards begin as soon as your first completed order lands.';
      case 3:
        return 'Create your account next to unlock checkout and order history.';
      default:
        return '';
    }
  }
}

class _OnboardingStat extends StatelessWidget {
  const _OnboardingStat({
    required this.label,
    required this.value,
    required this.compact,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: compact ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.86),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
                fontSize: compact ? 13 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeroCard extends StatelessWidget {
  const _OnboardingHeroCard({
    required this.slide,
    required this.compact,
    required this.ultraCompact,
  });

  final OnboardingSlide slide;
  final bool compact;
  final bool ultraCompact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final microCompact = constraints.maxHeight < 260;
        final dense = constraints.maxHeight < 320 || compact;
        final bubbleSize = microCompact
            ? 104.0
            : ultraCompact
            ? 146.0
            : dense
            ? 176.0
            : 212.0;
        final emojiSize = microCompact
            ? 52.0
            : ultraCompact
            ? 68.0
            : dense
            ? 80.0
            : 96.0;
        final logoSize = microCompact
            ? 28.0
            : dense
            ? 38.0
            : 46.0;
        final panelPadding = microCompact
            ? 14.0
            : dense
            ? 18.0
            : 28.0;
        final bottomPadding = microCompact
            ? panelPadding
            : dense
            ? panelPadding + 10
            : panelPadding + 14;
        final showStats = !microCompact;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: const LinearGradient(
              colors: [AppColors.primaryOrange, AppColors.yellowAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: AppTheme.softShadow,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -20,
                child: CircleAvatar(
                  radius: dense ? 56 : 86,
                  backgroundColor: AppColors.white.withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                left: -10,
                bottom: -10,
                child: CircleAvatar(
                  radius: dense ? 48 : 72,
                  backgroundColor: AppColors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  panelPadding,
                  panelPadding,
                  panelPadding,
                  bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Hero(
                          tag: 'brand-logo',
                          child: BrandLogo(size: logoSize),
                        ),
                        const Spacer(),
                        if (!microCompact)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: dense ? 12 : 16,
                              vertical: dense ? 8 : 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Lamyani Experience',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: dense ? 12 : 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: bubbleSize,
                            height: bubbleSize,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                slide.emoji,
                                style: TextStyle(fontSize: emojiSize),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: microCompact
                                ? 6
                                : dense
                                ? 10
                                : 16,
                          ),
                          Text(
                            'Roasted good food, fast and warm',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontSize: microCompact
                                      ? 12
                                      : dense
                                      ? 14
                                      : 16,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: dense ? 10 : 16),
                    const Spacer(),
                    if (showStats)
                      Row(
                        children: [
                          _OnboardingStat(
                            label: 'Fast prep',
                            value: '12-20 min',
                            compact: dense,
                          ),
                          const SizedBox(width: 10),
                          _OnboardingStat(
                            label: 'Rewards',
                            value: dense ? '1 pt / order' : '1 point / order',
                            compact: dense,
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingHint extends StatelessWidget {
  const _OnboardingHint({
    required this.text,
    required this.compact,
  });

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 9 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.peachSurface.withValues(alpha: 0.92),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: AppColors.primaryOrange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.brownAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
