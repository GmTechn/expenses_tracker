import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mysquaretile.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite, // Occupy full width
        height: double.maxFinite,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.bottomCenter,
                colors: [
              Color.fromARGB(255, 209, 253, 211),
              Color.fromARGB(255, 229, 253, 230),
            ])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            const Icon(
              Icons.add_chart_sharp,
              color: Color(0xff050c20),
              size: 40,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'B U D G E T  B U D D Y',
              style: GoogleFonts.abel(
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text('Welcome back Gabrielle!'),
            const SizedBox(
              height: 60,
            ),
            Mytextfield(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
                leadingIcon: const Icon(
                  Icons.email,
                  color: Color(0xff050c20),
                )),
            const SizedBox(
              height: 20,
            ),
            Mytextfield(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
                leadingIcon: const Icon(
                  Icons.lock_outlined,
                  color: Color(0xff050c20),
                )),
            const SizedBox(
              height: 20,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.remove_red_eye_sharp,
                  color: Color(0xff050c20),
                ),
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                      color: Color(0xff050c20), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            const MyButton(textbutton: 'Login'),
            const SizedBox(
              height: 40,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Divider(
                      thickness: .5,
                      color: Color(0xff050c20),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Or continue with',
                    style: TextStyle(color: Color(0xff050c20)),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Divider(
                    thickness: .5,
                    color: Color(0xff050c20),
                  ))
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MySquareTile(imagePath: 'lib/images/google.png'),
                MySquareTile(imagePath: 'lib/images/apple.png')
              ],
            ),
            const SizedBox(
              height: 60,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Don\'t have an account?',
                  style: TextStyle(color: Color(0xff050c20)),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpPage())),
                  child: const Text(
                    ' Sign up',
                    style: TextStyle(
                        color: Color(0xff050c20), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
