/*
 * File: login.dart
 * Description: UI screen for displaying the user authentication form.
 *
 * Responsibilities:
 * - Captures user credentials (username and password)
 * - Navigates to the home screen upon successful input
 * - Create a demo login page
 *
 *
 * Author: Phutawan Fongchan
 * Course: Mobile Application Development Framework
 */
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16.0),
                const Text('Quackle'),
              ],
            ),
            const SizedBox(height: 120.0),
            TextField(
              controller: _usernameController,
              decoration:
              const InputDecoration(filled: true, labelText: 'Username'),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration:
              const InputDecoration(filled: true, labelText: 'Password'),
              obscureText: true,
            ),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                    onPressed: () {
                      _usernameController.clear();
                      _passwordController.clear();
                    },
                    child: const Text('CANCEL')),
                ElevatedButton(
                    onPressed: () {
                      if (_usernameController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty) {
                        // Navigate to home page
                        Navigator.pushReplacementNamed(context, '/');
                      } else {
                        // Show error
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please fill in username and password')),
                        );
                      }
                    },
                    child: const Text('NEXT'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
