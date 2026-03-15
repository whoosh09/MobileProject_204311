/*
 * File: app.dart
 * Description: Defines the root QuackApp widget, which configures the
 * global MaterialApp, theme, and named route table for the application.
 *
 * Responsibilities:
 * - Sets global font family (DINNextRounded) and background color
 * - Configures smooth page transition animations per platform
 * - Declares initial route (/splash) and all named routes
 *
 * Author: Quackle Team
 * Course: 204311-Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';

/// The root widget of the Quackle application.
///
/// Configures [MaterialApp] with the app title, global theme, platform-aware
/// page transitions, and the named route table. Navigation always starts at
/// `/splash`, which decides whether to forward to `/welcome` or directly to
/// [HomePage] based on saved login state.
class QuackApp extends StatelessWidget {
  const QuackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quackle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'DINNextRounded',
        // Smooth page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // Always start at splash — it handles its own timer & navigation
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
