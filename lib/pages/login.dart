import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mysquaretile.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/pages/forgotpass.dart';
import 'package:expenses_tracker/pages/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:expenses_tracker/models/users.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseManager _dbManager = DatabaseManager();

  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in with Google')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed in with Apple: ${credential.email}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple Sign-In failed: $e')),
      );
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: Text(
          message,
          style: const TextStyle(color: Color(0xff050c20)),
        ),
      ),
    );
  }

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorMessage("Please fill all fields.");
      return;
    }

    if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(email)) {
      showErrorMessage("Please enter a valid email address.");
      return;
    }

    try {
      final user = await _dbManager.getUserByEmail(email);

      if (user == null) {
        showErrorMessage("No account found with this email.");
        return;
      }

      if (user.password != password) {
        showErrorMessage("Incorrect password. Please try again.");
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      showErrorMessage("Login failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Icon(
            CupertinoIcons.chart_bar_circle_fill,
            color: Color(0xff050c20),
            size: 60,
          ),
          const SizedBox(height: 20),
          Text(
            'B U D G E T  B U D D Y',
            style: GoogleFonts.abel(
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome back '),
              Text(
                ' !',
                style: TextStyle(color: Color(0xff050c20)),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Mytextfield(
            controller: emailController,
            hintText: 'Email',
            obscureText: false,
            leadingIcon: const Icon(Icons.email, color: Color(0xff050c20)),
          ),
          const SizedBox(height: 20),
          Mytextfield(
            controller: passwordController,
            hintText: 'Password',
            obscureText: !_isPasswordVisible,
            leadingIcon:
                const Icon(Icons.lock_outlined, color: Color(0xff050c20)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xff050c20),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage()),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xff050c20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          MyButton(
            textbutton: 'Login',
            onTap: loginUser,
            buttonHeight: 40,
            buttonWidth: 200,
          ),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: Divider(thickness: .5, color: Color(0xff050c20))),
                SizedBox(width: 10),
                Text('Or continue with',
                    style: TextStyle(color: Color(0xff050c20))),
                SizedBox(width: 10),
                Expanded(
                    child: Divider(thickness: .5, color: Color(0xff050c20))),
              ],
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MySquareTile(
                  imagePath: 'assets/images/google.png',
                  onTap: signInWithGoogle),
              MySquareTile(
                  imagePath: 'assets/images/apple.png',
                  onTap: _handleAppleSignIn),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?",
                  style: TextStyle(color: Color(0xff050c20))),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                ),
                child: const Text(
                  ' Sign up',
                  style: TextStyle(
                      color: Color(0xff050c20), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
