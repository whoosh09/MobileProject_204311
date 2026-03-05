import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';

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
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
