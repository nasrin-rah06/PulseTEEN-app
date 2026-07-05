import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'caretaker_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  String errorMessage = '';

  void handleLogin() async {
  String? error = await _auth.login(
    emailController.text.trim(),
    passwordController.text.trim(),
  );
  if (error == null) {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final role = doc.data()?['role'];
    if (role == 'caretaker') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CaretakerDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
  } else {
    setState(() => errorMessage = 'Invalid email or password');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('PulseTEEN',
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 8),
            if (errorMessage.isNotEmpty)
              Text(errorMessage,
                  style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleLogin,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: const Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}