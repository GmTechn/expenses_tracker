import 'package:expenses_tracker/components/mycards.dart';
import 'package:expenses_tracker/pages/dashboard.dart';
import 'package:expenses_tracker/pages/login.dart';
import 'package:expenses_tracker/pages/mycards.dart';
import 'package:expenses_tracker/pages/profile.dart';
import 'package:expenses_tracker/pages/signup.dart';
import 'package:expenses_tracker/pages/transactions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const Dashboard(),
        '/transactions': (context) => const TransactionsPage(),
        '/wallet': (context) => const MyCardsPage(),

        // ✅ FIX: Pass email to ProfilePage via arguments
        '/profile': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return ProfilePage(email: email);
        },
      },
    );
  }
}
