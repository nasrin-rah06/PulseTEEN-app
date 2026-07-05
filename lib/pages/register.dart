import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final teenEmailController = TextEditingController();
  final AuthService _auth = AuthService();
  String errorMessage = '';
  String selectedRole = 'teen';

  void handleRegister() async {
    if (nameController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Please enter your name.');
      return;
    }

    // If caretaker, look up teen by email first
    String teenUid = '';
    if (selectedRole == 'caretaker') {
      if (teenEmailController.text.trim().isEmpty) {
        setState(() => errorMessage = 'Please enter the teen\'s email.');
        return;
      }

      final teenSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: teenEmailController.text.trim())
          .where('role', isEqualTo: 'teen')
          .get();

      if (teenSnap.docs.isEmpty) {
        setState(() => errorMessage = 'Teen email not found. Make sure the teen registered first.');
        return;
      }

      teenUid = teenSnap.docs.first.id;
    }

    String? error = await _auth.register(
      emailController.text.trim(),
      passwordController.text.trim(),
      selectedRole,
      nameController.text.trim(),
      teenUid,
    );

    if (error == null) {
      Navigator.pop(context);
    } else {
      setState(() => errorMessage = 'Registration failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text('Create Account',
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: const InputDecoration(labelText: 'I am a'),
              items: const [
                DropdownMenuItem(value: 'teen', child: Text('Teen')),
                DropdownMenuItem(
                    value: 'caretaker', child: Text('Caretaker')),
              ],
              onChanged: (val) => setState(() => selectedRole = val!),
            ),
            if (selectedRole == 'caretaker') ...[
              const SizedBox(height: 16),
              TextField(
                controller: teenEmailController,
                decoration: const InputDecoration(
                  labelText: 'Teen\'s Email',
                  hintText: 'Enter the email of the teen you care for',
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (errorMessage.isNotEmpty)
              Text(errorMessage,
                  style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleRegister,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white),
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}