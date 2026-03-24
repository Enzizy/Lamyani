import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.nextScreen});

  final Widget nextScreen;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(AppMotion.route(widget.nextScreen));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryOrange, AppColors.brownAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.86, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(scale: value, child: child),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Hero(
                  tag: 'brand-logo',
                  child: BrandLogo(size: 136, showShadow: true),
                ),
                const SizedBox(height: 28),
                Text(
                  'LAMYANI',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Roasted flavor, delivered warm.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFFFF3C4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
