import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mysquaretile.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/pages/dashboard.dart';
import 'package:expenses_tracker/pages/forgotpass.dart';
import 'package:expenses_tracker/pages/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required String email});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //controllers

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //bolean for password visibility
  bool _isPasswordVisible = false;

  //signing in with google
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //initializing database instance

  final DatabaseManager _dbManager = DatabaseManager();

//signin with google function
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

  //signing in with apple

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

//showing error messages

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

//login funcion to use email and password
//with local database

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Dashboard(email: email),
        ),
      );
    } catch (e) {
      showErrorMessage("Login failed: $e");
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Dashboard(email: email), // <-- ici on passe l'email
      ),
    );
  }

  //UI design and functions calling

  @override
  Widget build(BuildContext context) {
    Color whiteColor = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.chart_bar_circle_fill,
                          color: Colors.green,
                          size: 60,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'B U D G E T  B U D D Y',
                          style: GoogleFonts.abel(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: whiteColor),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome back!',
                              style: TextStyle(
                                color: whiteColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        MyTextFormField(
                          controller: emailController,
                          hintText: 'Email',
                          obscureText: false,
                          leadingIcon: Icon(CupertinoIcons.envelope_fill,
                              color: Colors.white24),
                        ),
                        const SizedBox(height: 20),
                        MyTextFormField(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: !_isPasswordVisible,
                          leadingIcon: const Icon(
                            CupertinoIcons.lock_fill,
                            color: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                _isPasswordVisible
                                    ? CupertinoIcons.eye_fill
                                    : CupertinoIcons.eye_slash_fill,
                                color: whiteColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordPage()),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: whiteColor,
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                  child: Divider(
                                      thickness: .5, color: whiteColor)),
                              SizedBox(width: 10),
                              Text('Or continue with',
                                  style: TextStyle(color: whiteColor)),
                              SizedBox(width: 10),
                              Expanded(
                                  child: Divider(
                                      thickness: .5, color: whiteColor)),
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
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?",
                                style: TextStyle(color: whiteColor)),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              ),
                              child: const Text(
                                ' Sign up',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
