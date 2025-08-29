import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final DatabaseManager _dbManager = DatabaseManager();

    Future<void> resetPassword() async {
      final email = emailController.text.trim();

      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email!')),
        );
        return;
      }

      try {
        final user = await _dbManager.getUserByEmail(email);
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No account found with this email.')),
          );
          return;
        }

        // Here you would normally send a reset link via email.
        // For now, just simulate success.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset link sent to $email')),
        );
        emailController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xff050c20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.lock, size: 40, color: Color(0xff050c20)),
            const SizedBox(height: 20),
            const Text(
              'Enter your email to reset password:',
              style: TextStyle(color: Color(0xff050c20)),
            ),
            const SizedBox(height: 40),
            Mytextfield(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
              leadingIcon: const Icon(Icons.email),
            ),
            const SizedBox(height: 40),
            MyButton(
              textbutton: 'Send reset link',
              onTap: resetPassword,
              buttonHeight: 40,
              buttonWidth: 200,
            ),
          ],
        ),
      ),
    );
  }
}
