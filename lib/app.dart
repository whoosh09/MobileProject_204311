
import 'package:flutter/material.dart';
import 'screens/login.dart';
// import 'screens/home.dart';

class QuackApp extends StatelessWidget {
  const QuackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quackle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      // Start at Login
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
