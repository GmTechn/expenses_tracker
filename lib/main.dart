import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/pages/login.dart';
import 'package:expenses_tracker/pages/signup.dart';
import 'package:expenses_tracker/services/listofusers.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/dashboard.dart';
import 'package:expenses_tracker/pages/transactions.dart';
import 'package:expenses_tracker/pages/cardspage.dart';
import 'package:expenses_tracker/pages/profile.dart';
import 'package:expenses_tracker/management/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbManager = DatabaseManager();

  // ✅ Clear database during testing
  //await dbManager.clearDatabase();

  await dbManager.initialisation();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenses Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/signup',
      routes: {
        '/': (context) => const LoginPage(),
        // You can handle navigation with email using onGenerateRoute
      },
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/signup':
            return MaterialPageRoute(
              builder: (_) => SignUpPage(),
            );
          case '/dashboard':
            return MaterialPageRoute(
              builder: (_) => Dashboard(
                email: args?['email'] ?? '',
              ),
            );

          case '/transactions':
            return MaterialPageRoute(
              builder: (_) => TransactionsPage(
                email: args?['email'] ?? '',
              ),
            );
          case '/mycards':
            return MaterialPageRoute(
              builder: (_) => MyCardsPage(
                email: args?['email'] ?? '',
              ),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => ProfilePage(
                email: args?['email'],
              ),
            );
          case '/usersList':
            return MaterialPageRoute(
              builder: (_) => ListOfUsers(),
            );

          default:
            return null;
        }
      },
    );
  }
}
