import 'package:flutter/material.dart';
import 'app/theme.dart';
import 'features/auth/screens/splash_screen.dart';

void main() {
  runApp(const CogniMeetApp());
}

class CogniMeetApp extends StatelessWidget {
  const CogniMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CogniMeetAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
