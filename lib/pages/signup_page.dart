import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_attendence_app/components/logincomponents.dart';

class SignupPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  SignupPage({super.key});

  void signupUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'ChivoMono', // Added font family
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(hint: "Name", controller: nameController),
            const SizedBox(height: 16),
            CustomTextField(hint: "Email", controller: emailController),
            const SizedBox(height: 16),
            CustomTextField(
                hint: "Password",
                controller: passwordController,
                obscure: true),
            const SizedBox(height: 24),
            PrimaryButton(
              text: "Sign Up",
              onPressed: () => signupUser(context),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text("Already have an account? Login",
                  style: TextStyle(fontFamily: "ChivoMono")),
            ),
          ],
        ),
      ),
    );
  }
}
