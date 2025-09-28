import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/pages/login.dart';
import 'package:expenses_tracker/pages/signup.dart';
import 'package:expenses_tracker/services/listofusers.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/dashboard.dart';
import 'package:expenses_tracker/pages/transactions.dart';
import 'package:expenses_tracker/pages/cardspage.dart';
import 'package:expenses_tracker/pages/profile.dart';
import 'package:expenses_tracker/management/sessionmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbManager = DatabaseManager();

  //clearing db
  //await dbManager.clearDatabase();

  // ✅ Initialise toujours la DB avec version:1

  await dbManager.initialisation();

  // Récupère l'utilisateur courant (email si connecté)
  final currentUserEmail = await SessionManager.getCurrentUser();

  runApp(MyApp(initialEmail: currentUserEmail));
}

class MyApp extends StatelessWidget {
  final String? initialEmail;

  const MyApp({super.key, this.initialEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenses Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),

      /// ✅ Si user existe → Dashboard
      /// ✅ Sinon → SignUp (car DB est vide au lancement)
      home: (initialEmail != null && initialEmail!.isNotEmpty)
          ? LoginPage(email: initialEmail!) // on utilise le vrai email
          : const Dashboard(email: ''), // email vide si null

      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/signup':
            return MaterialPageRoute(
                builder: (_) => const SignUpPage(
                      email: '',
                    ));
          case '/dashboard':
            return MaterialPageRoute(
              builder: (_) => Dashboard(email: args?['email'] ?? ''),
            );
          // case '/transactions':
          //   return MaterialPageRoute(
          //     builder: (_) => TransactionsPage(email: args?['email'] ?? ''),
          //   );
          case '/mycards':
            return MaterialPageRoute(
              builder: (_) => MyCardsPage(email: args?['email'] ?? ''),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => ProfilePage(email: args?['email'] ?? ''),
            );
          case '/usersList':
            return MaterialPageRoute(builder: (_) => const ListOfUsers());
          default:
            return null;
        }
      },
    );
  }
}
