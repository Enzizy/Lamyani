import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/launch_gate.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const LamyaniApp());
}

Future<void> _initializeFirebase() async {
  if (kIsWeb) {
    return;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      await Firebase.initializeApp();
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      break;
  }
}

class LamyaniApp extends StatelessWidget {
  const LamyaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lamyani',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(nextScreen: LaunchGate()),
    );
  }
}
