import 'dart:io';

import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mycards.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytransaction.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/models/cards.dart';
import 'package:expenses_tracker/models/transactions.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:expenses_tracker/pages/cardspage.dart';
import 'package:expenses_tracker/pages/profile.dart';
import 'package:expenses_tracker/services/listofusers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  final String email;

  const Dashboard({super.key, required this.email});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //calling the database
  final DatabaseManager _databaseManager = DatabaseManager();

//generating an app instance
  AppUser? _currentUser;

//generating a card model
  CardModel? _defaultCard;

  ///generating a transaction list of the recent
  ///transactions so we can display the 5 most recent

  List<TransactionModel> _recentTransactions = [];

  /// Generating a complete list of all transactions
  /// so we can use them to calculate our total => income and expenses

  List<TransactionModel> _allTransactions = [];

//generating a photopath string
  String? _savedPhotoPath;

//initializing states for
  ///users, default card, profile pic
  ///as well as recent transactions

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadDefaultCard();
    _loadSavedPhoto();
    _loadTransactions();
  }

  ///using sharedpreferences to display
  ///the profile picture saved in
  ///the local database

  Future<void> _loadSavedPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_photo_${widget.email}');
    if (path != null && path.isNotEmpty) {
      setState(() {
        _savedPhotoPath = path;
      });
    }
  }

  ///This function allows your widget to react and update its state
  /// or UI when its dependencies change,
  /// ensuring the UI reflects the latest data or configuration.

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUsers();
    _loadDefaultCard();
    _loadTransactions();
  }

  ///loading users from the database so the
  ///users info always appear on the dashboard
  ///such as their name and profile picture
  ///as well as the last saved state of the app

  Future<void> _loadUsers() async {
    await _databaseManager.initialisation();
    final user = await _databaseManager.getUserByEmail(widget.email);
    setState(() {
      _currentUser = user;
    });
  }

  ///loading default card so that the default selected card
  ///would always appear when the user
  ///opens their dashboard

  Future<void> _loadDefaultCard() async {
    final card = await _databaseManager.getDefaultCard(widget.email);
    setState(() {
      _defaultCard = card;
    });
  }

  ///loading recent transactions to display them
  ///on the dashboard, from the transactions page
  ///depending on the date of the transaction, meaning from oldest to newest
  ///and only displaying x number of them

  Future<void> _loadTransactions() async {
    final transactions = await _databaseManager.getTransactions(widget.email);
    transactions
        .sort((a, b) => b.date.compareTo(a.date)); // Trier par date descendante
    setState(() {
      _allTransactions = transactions;
      _recentTransactions =
          transactions.take(5).toList(); // 5 dernières transactions
    });
  }

//total transactions to sum up the total number of
//incomes and expenses to separate

  double get totalTransactionsAmount =>
      _allTransactions.fold(0, (sum, item) => sum + item.amount);

// Calcule la somme des revenus (Income)
  double get totalIncome => _allTransactions
      .where((t) => t.amount >= 0)
      .fold(0, (sum, t) => sum + t.amount);

// Calcule la somme des dépenses (Expense)
  double get totalExpense => _allTransactions
      .where((t) => t.amount < 0)
      .fold(0, (sum, t) => sum + t.amount.abs());

//solde de la carte a prendre en soustrayant
//les expenses des incomes

// Suppose _defaultCard!.amount = "$1700"
// On parse la valeur en double
  double? get initialCardAmount {
    if (_defaultCard == null) return 0.0;
    // Supprimer le $ si présent
    return _defaultCard?.amount;
  }

// Solde actuel = montant initial + totalIncome - totalExpense
  double get currentBalance {
    final income = totalIncome; // toutes les transactions positives
    final expense = totalExpense; // toutes les transactions négatives
    return initialCardAmount! + income - expense;
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
              // Header Container : Profile button
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 35, 37, 46),
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
                            builder: (_) => ProfilePage(email: widget.email),
                          ),
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
                    const SizedBox(width: 14),
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
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '7',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Card
              if (_defaultCard != null)
                MyCards(
                  amount: "${currentBalance.toStringAsFixed(2)}\$",
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
                            builder: (context) =>
                                MyCardsPage(email: widget.email),
                          ),
                        );
                      },
                      label: const Text(
                        'Set up default card',
                        style: TextStyle(color: Colors.white70),
                      ),
                      icon: const Icon(
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
                      Text(
                        '+\$${totalIncome.toStringAsFixed(2)} Income',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
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
                      Text(
                        '-\$${totalExpense.toStringAsFixed(2)} Expense',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Recent Transactions',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18),
              ),
              const SizedBox(height: 10),

              Column(
                children: _recentTransactions.map((t) {
                  return Mytransaction(
                    logo: t.logoPath ??
                        'assets/images/apple.png', // mettre une image par défaut
                    title: t.place ?? "",
                    date: "${t.date.day}/${t.date.month}/${t.date.year}",
                    amount: t.amount,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

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
      bottomNavigationBar: MyNavBar(
        currentIndex: 0,
        email: widget.email,
      ),
    );
  }
}
