import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'app_shell.dart';
import 'onboarding_screen.dart';

class LaunchGate extends StatelessWidget {
  const LaunchGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.expand(
            child: ColoredBox(color: Colors.white),
          );
        }

        if (snapshot.data != null) {
          return const AppShell();
        }

        return const OnboardingScreen();
      },
    );
  }
}
