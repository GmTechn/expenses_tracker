import 'dart:io';

import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mycards.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytransaction.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/models/cards.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:expenses_tracker/pages/cardspage.dart';
import 'package:expenses_tracker/pages/login.dart';
import 'package:expenses_tracker/pages/profile.dart';
import 'package:expenses_tracker/services/listofusers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ added

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
//Generating database instance
  final DatabaseManager _databaseManager = DatabaseManager();

//creating an instance of an appuser = current user

  AppUser? _currentUser;

//Default card
  CardModel? _defaultCard;

//photo path to persit

  String? _savedPhotoPath;

//initialising state

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadDefaultCard();
    _loadSavedPhoto();
  }

  Future<void> _loadSavedPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_photo_${widget.email}');
    if (path != null && path.isNotEmpty) {
      setState(() {
        _savedPhotoPath = path;
      });
    }
  }

  //--Refreshing the page to reload the page

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUsers();
    _loadDefaultCard();
  }

//loading users to display name on dashboard

  Future<void> _loadUsers() async {
    await _databaseManager.initialisation();
    final user = await _databaseManager.getUserByEmail(widget.email);
    setState(() {
      _currentUser = user;
    });
  }

//loading cards to display

  //loading default card to display
  Future<void> _loadDefaultCard() async {
    final card = await _databaseManager.getDefaultCard(widget.email);
    setState(() {
      _defaultCard = card;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      appBar: AppBar(
        backgroundColor: const Color(0xff181a1e),
        automaticallyImplyLeading: false,
        title: const Text(
          'D A S H B O A R D',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header Container : Profile button
              /// Welcome message
              /// Username
              /// notifications bell

              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 35, 37, 46),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfilePage(
                                    email: widget.email,
                                  )),
                        ).then((_) => _loadUsers());
                      },
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            (_currentUser?.photoPath ?? '').isNotEmpty &&
                                    File(_currentUser!.photoPath!).existsSync()
                                ? FileImage(File(_currentUser!.photoPath!))
                                : (_savedPhotoPath != null &&
                                        File(_savedPhotoPath!).existsSync())
                                    ? FileImage(File(_savedPhotoPath!))
                                    : null,
                        child: (_currentUser?.photoPath ?? '').isEmpty &&
                                (_savedPhotoPath == null ||
                                    _savedPhotoPath!.isEmpty)
                            ? const Icon(
                                CupertinoIcons.person_fill,
                                color: Color(0xff050c20),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white54),
                          ),
                          Row(
                            children: [
                              Text(
                                _currentUser != null
                                    ? "${_currentUser!.fname} ${_currentUser!.lname}"
                                    : "Guest",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                          icon: const Icon(CupertinoIcons.bell_fill,
                              size: 28, color: Colors.white),
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
              ),

              const SizedBox(height: 20),

              // Card
              if (_defaultCard != null)
                MyCards(
                  amount: _defaultCard!.amount,
                  cardnumber: _defaultCard!.cardnumber,
                  expirydate: _defaultCard!.expirydate,
                  colorOne: Color(_defaultCard!.colorOne),
                  colorTwo: Color(_defaultCard!.colorTwo),
                  username: _defaultCard!.username,
                )
              else
                Column(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyCardsPage(
                              email: widget.email,
                            ),
                          ),
                        );
                      },
                      label: Text(
                        'Set up default card',
                        style: TextStyle(color: Colors.white70),
                      ),
                      icon: Icon(
                        CupertinoIcons.creditcard_fill,
                        color: Colors.white,
                      ),
                    ),
                    MyCards(
                      amount: '0.00\$',
                      cardnumber: '0000 0000 0000 0000',
                      expirydate: 'mm/yy',
                      username: 'no username',
                      colorOne: Colors.blue,
                      colorTwo: Colors.amber,
                    ),
                  ],
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
                    color: Colors.white,
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
                    _loadUsers();
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
