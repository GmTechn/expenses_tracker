import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mysquaretile.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/pages/dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:expenses_tracker/models/users.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final DatabaseManager _dbManager = DatabaseManager();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isPasswordVisible = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    await _dbManager.initialisation();
  }

  Future<void> registerUser() async {
    final fname = fnameController.text.trim();
    final lname = lnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();

    if (fname.isEmpty || lname.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage("Please fill in all required fields.");
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
        fname: fname,
        lname: lname,
        email: email,
        password: password,
        phone: phone,
      );

      await _dbManager.insertAppUser(newUser);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Dashboard()),
      );
    } catch (e) {
      showMessage("Registration failed: $e");
    }
  }

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
          const SizedBox(height: 10),
          Text(
            'B U D G E T  B U D D Y',
            style: GoogleFonts.abel(
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create your account here!',
            style: TextStyle(
              color: Color(0xff050c20),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Mytextfield(
            controller: fnameController,
            hintText: 'First Name',
            obscureText: false,
            leadingIcon: const Icon(Icons.person, color: Color(0xff050c20)),
          ),
          const SizedBox(height: 10),
          Mytextfield(
            controller: lnameController,
            hintText: 'Last Name',
            obscureText: false,
            leadingIcon: const Icon(Icons.person, color: Color(0xff050c20)),
          ),
          const SizedBox(height: 10),
          Mytextfield(
            controller: emailController,
            hintText: 'Email',
            obscureText: false,
            leadingIcon: const Icon(Icons.email, color: Color(0xff050c20)),
          ),
          const SizedBox(height: 10),
          Mytextfield(
            controller: passwordController,
            hintText: 'Password',
            obscureText: !_isPasswordVisible,
            leadingIcon: const Icon(Icons.lock, color: Color(0xff050c20)),
            trailingIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xff050c20),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Mytextfield(
            controller: phoneController,
            hintText: 'Phone (optional)',
            obscureText: false,
            leadingIcon: const Icon(Icons.phone, color: Color(0xff050c20)),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),
          MyButton(
            textbutton: "Sign Up",
            onTap: registerUser,
            buttonHeight: 40,
            buttonWidth: 200,
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MySquareTile(
                imagePath: 'assets/images/google.png',
                onTap: signInWithGoogle,
              ),
              MySquareTile(
                imagePath: 'assets/images/apple.png',
                onTap: _handleAppleSignIn,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?",
                  style: TextStyle(color: Color(0xff050c20))),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ),
                child: const Text(
                  ' Login',
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
