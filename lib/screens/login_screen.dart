import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  Future<void> _login() async {
    try {
      final res = await AuthService.signIn(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final user = res.user;
      if (user == null) throw Exception('Invalid email or password');

      final profile =
          await AuthService.getProfileByAuthId(user.id);

      if (profile == null) {
        throw Exception('Profile not found');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authId', user.id);
      await prefs.setString('userEmail', user.email ?? '');
      await prefs.setString('userName', profile['name']);
      await prefs.setBool('isGuest', false);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _guestLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);
    await prefs.setString('userName', 'Guest');
    await prefs.remove('authId');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.person_outline),
              label: const Text('Continue as Guest'),
              onPressed: _guestLogin,
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
