import 'dart:io';

import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mycards.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytransaction.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:expenses_tracker/pages/login.dart';
import 'package:expenses_tracker/pages/profile.dart';
import 'package:expenses_tracker/services/listofusers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final String email; // ✅ keep the email passed from signup

  const Dashboard({
    super.key,
    required this.email,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
//creating an instance of an appuser = current user

  final DatabaseManager _databaseManager = DatabaseManager();
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await _databaseManager.initialisation();
    final user = await _databaseManager.getUserByEmail(widget.email);
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage())),
            icon: const Icon(Icons.arrow_back)),
        title: const Text(
          'D A S H B O A R D',
          style: TextStyle(color: Color(0xff050c20)),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(email: widget.email),
                ),
              );
            },
            icon: FutureBuilder<AppUser?>(
              future: _databaseManager.getUserByEmail(widget.email),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (snapshot.hasData && snapshot.data!.photoPath.isNotEmpty) {
                  final file = File(snapshot.data!.photoPath);
                  if (file.existsSync()) {
                    return CircleAvatar(
                      radius: 18,
                      backgroundImage: FileImage(file),
                    );
                  }
                }
                // Default icon if no photo
                return const Icon(
                  CupertinoIcons.person,
                  color: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(fontWeight: FontWeight.bold),
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

              const Text(
                'Transactions',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff050c20),
                    fontSize: 18),
              ),
              const SizedBox(height: 10),

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

              MyButton(
                textbutton: 'Users',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ListOfUsers()),
                  ).then((_) {
                    _loadUser();
                  });
                },
                buttonHeight: 40,
                buttonWidth: 80,
              ),
            ],
          ),
        ),
      ),

      // ✅ Pass the actual email here!
      bottomNavigationBar: MyNavBar(
        currentIndex: 0,
        email: widget.email,
      ),
    );
  }
}
