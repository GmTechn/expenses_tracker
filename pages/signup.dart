import 'package:expenses_tracker/management/sessionmanager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/components/mysquaretile.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:expenses_tracker/pages/profile.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //controllers

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

//database instance

  final DatabaseManager _dbManager = DatabaseManager();

  //google sign in var

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _dbManager.initialisation();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showMessage("Please fill in all required fields.");
      return;
    }

    if (password != confirmPassword) {
      showMessage("Passwords do not match.");
      return;
    }

    if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(email)) {
      showMessage("Please enter a valid email address.");
      return;
    }

    try {
      final existingUser = await _dbManager.getUserByEmail(email);
      if (existingUser != null) {
        showMessage("An account with this email already exists.");
        return;
      }

      final newUser = AppUser(
        fname: '',
        lname: '',
        email: email,
        password: password,
        phone: '',
        photoPath: '',
      );

      await _dbManager.insertAppUser(newUser);
      await SessionManager.saveCurrentUser(newUser.email);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(email: newUser.email),
        ),
      );
    } catch (e) {
      showMessage("Registration failed: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        showMessage('Signed in with Google');
        final existingUser = await _dbManager.getUserByEmail(account.email);
        if (existingUser == null) {
          final newUser = AppUser(
            fname: '',
            lname: '',
            email: account.email,
            password: '',
            phone: '',
            photoPath: '',
          );
          await _dbManager.insertAppUser(newUser);
          await SessionManager.saveCurrentUser(newUser.email);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage(email: account.email)),
        );
      }
    } catch (e) {
      showMessage('Google sign-in failed: $e');
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ]);
      showMessage("Signed in with Apple: ${credential.email}");
      if (credential.email != null) {
        final existingUser = await _dbManager.getUserByEmail(credential.email!);
        if (existingUser == null) {
          final newUser = AppUser(
            fname: '',
            lname: '',
            email: credential.email!,
            password: '',
            phone: '',
            photoPath: '',
          );
          await _dbManager.insertAppUser(newUser);
          await SessionManager.saveCurrentUser(newUser.email);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ProfilePage(email: credential.email!)),
        );
      }
    } catch (e) {
      showMessage('Apple Sign-In failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          CupertinoIcons.chart_bar_circle_fill,
                          size: 60,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'B U D G E T  B U D D Y',
                          style: GoogleFonts.abel(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Create your account here!',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 40),
                        MyTextFormField(
                            controller: emailController,
                            hintText: 'Email',
                            obscureText: false,
                            leadingIcon: const Icon(
                              CupertinoIcons.envelope_fill,
                            )),
                        const SizedBox(height: 20),
                        MyTextFormField(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: !_isPasswordVisible,
                          leadingIcon: const Icon(
                            CupertinoIcons.lock_fill,
                          ),
                          trailingIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? CupertinoIcons.eye_fill
                                  : CupertinoIcons.eye_slash_fill,
                            ),
                            onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                        const SizedBox(height: 20),
                        MyTextFormField(
                          controller: confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: !_isPasswordVisible,
                          leadingIcon: const Icon(
                            CupertinoIcons.lock_fill,
                          ),
                          trailingIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? CupertinoIcons.eye_fill
                                  : CupertinoIcons.eye_slash_fill,
                            ),
                            onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                        const SizedBox(height: 40),
                        MyButton(
                            textbutton: 'Sign Up',
                            onTap: registerUser,
                            buttonHeight: 40,
                            buttonWidth: 200),
                        const SizedBox(height: 40),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: .5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Or continue with',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Divider(
                                  thickness: .5,
                                  color: Colors.white,
                                ),
                              ),
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
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
