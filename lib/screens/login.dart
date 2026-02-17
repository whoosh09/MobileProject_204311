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
import 'mock_data.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // เรียกใช้ MockDatabase เพื่อตรวจสอบ
    User? user = await MockDatabase.login(username, password);

    if (user != null) {
      //login successful
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(currentUser: user)),
      );
    } else {
      //login failed
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                const SizedBox(height: 16.0),
                const Text(
                  'ใช้Mock User นี้',
                  style: TextStyle(
                    color: Colors.red, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                const Text(
                  'username/password',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4.0),
                const Text(
                  'a/a  b/b  c/c  d/d',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 90.0),
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
            const SizedBox(height: 16.0),
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
                    // onPressed: () {
                    //   if (_usernameController.text.isNotEmpty &&
                    //       _passwordController.text.isNotEmpty) {
                    //     // Navigate to home page
                    //     Navigator.pushReplacementNamed(context, '/');
                    //   } else {
                    //     // Show error
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(
                    //           content: Text(
                    //               'Please fill in username and password')),
                    //     );
                    //   }
                    // },
                    onPressed: _handleLogin, // เรียกฟังก์ชันใหม่
                    child: const Text('NEXT'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
