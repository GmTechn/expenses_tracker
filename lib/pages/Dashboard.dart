import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mycards.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytransaction.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:expenses_tracker/pages/login.dart';
import 'package:expenses_tracker/services/listofusers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required String email,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DatabaseManager _databaseManager = DatabaseManager();

  AppUser? _currentUser; // ✅ Store logged-in user

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    await _databaseManager.initialisation();
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    // ⚡ For now, fetch the first user in DB
    final users = await _databaseManager.getAllAppUsers();
    if (users.isNotEmpty) {
      setState(() {
        _currentUser = users.first; // later you can replace with logged-in user
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage())),
            icon: Icon(Icons.arrow_back)),
        title: const Text(
          'D A S H B O A R D',
          style: TextStyle(color: Color(0xff050c20)),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                CupertinoIcons.person,
                color: Colors.white,
              ))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //top bar of the safearea
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              _currentUser != null
                                  ? "${_currentUser!.fname} ${_currentUser!.lname}"
                                  : "Guest",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(CupertinoIcons.bell,
                            size: 28, color: Color(0xff050c20)),
                      ),
                      Positioned(
                          right: 10,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: const Text(
                              '7',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          ))
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              // Card
              MyCards(
                amount: '\$542.45',
                cardnumber: "5412 7512 3412 3456",
                expirydate: '12/25',
                colorOne: const Color.fromARGB(255, 5, 77, 113),
                colorTwo: Colors.amber.withOpacity(.5),
                username: _currentUser != null
                    ? "${_currentUser!.fname} ${_currentUser!.lname}"
                    : "User",
              ),

              const SizedBox(height: 20),

              // Income & Expenses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {},
                        heroTag: "income",
                        backgroundColor: Colors.green,
                        child: const Icon(
                          CupertinoIcons.arrow_down_circle_fill,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '+\$250 Income',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {},
                        heroTag: "expense",
                        backgroundColor: Colors.red,
                        child: const Icon(
                          CupertinoIcons.arrow_up_circle_fill,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '-\$50 Expense',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Transactions title
              const Text(
                'Transactions',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff050c20),
                    fontSize: 18),
              ),
              const SizedBox(height: 10),

              // Transactions list
              const Mytransaction(
                logo: 'assets/images/apple.png',
                title: 'Apple',
                date: '22 Sept 2024',
                amount: -45,
              ),
              const Mytransaction(
                  logo: 'assets/images/google.png',
                  title: 'Google Drive',
                  date: '21 Avr 2025',
                  amount: -2),
              const Mytransaction(
                  logo: 'assets/images/interact.png',
                  title: 'Interact Transfert',
                  date: '02 Mai 2025',
                  amount: 200),

              // Inside MyButton (Users button) in Dashboard
              MyButton(
                textbutton: 'Users',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ListOfUsers()),
                  ).then((_) {
                    // 🔥 Reload user when coming back
                    _loadCurrentUser();
                  });
                },
                buttonHeight: 40,
                buttonWidth: 80,
              ),
            ],
          ),
        ),
      ),

      // ⬇️ Bottom navigation stays fixed
      bottomNavigationBar: MyNavBar(
        currentIndex: 0,
        email: '',
      ),
    );
  }
}
