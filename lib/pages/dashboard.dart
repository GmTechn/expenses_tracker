import 'dart:io';
import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mycards.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytransaction.dart';
import 'package:expenses_tracker/services/balance_provider.dart';
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
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  final String email;
  const Dashboard({super.key, required this.email});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DatabaseManager _databaseManager = DatabaseManager();
  AppUser? _currentUser;
  CardModel? _defaultCard;
  List<TransactionModel> _recentTransactions = [];
  String? _savedPhotoPath;

  @override
  void initState() {
    super.initState();
    _loadSavedPhoto();
    _loadAllData();
  }

  Future<void> _loadSavedPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_photo_${widget.email}');
    if (path != null && path.isNotEmpty) {
      setState(() => _savedPhotoPath = path);
    }
  }

  Future<void> _loadAllData() async {
    await _databaseManager.initialisation();

    // Load user
    final user = await _databaseManager.getUserByEmail(widget.email);
    if (mounted) setState(() => _currentUser = user);

    // Load cards
    final cards = await _databaseManager.getCards(widget.email);
    final provider = context.read<BalanceProvider>();
    provider.setCards(cards);

    // Load default card
    final defaultCard = await _databaseManager.getDefaultCard(widget.email);
    if (defaultCard != null) {
      _defaultCard = defaultCard;
      provider.setDefaultCard(defaultCard.id!);

      // Load transactions for default card
      final transactions = await _databaseManager.getTransactionsByCard(
          widget.email, defaultCard.id!);
      provider.setTransactionsForCard(defaultCard.id!, transactions);

      // Keep recent transactions for UI
      if (mounted) {
        setState(() {
          _recentTransactions = transactions.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          _recentTransactions = _recentTransactions.take(5).toList();
        });
      }
    }

    // Load all transactions for all cards into provider
    for (final card in cards) {
      if (card.id != _defaultCard?.id) {
        final txs = await _databaseManager.getTransactionsByCard(
            widget.email, card.id!);
        provider.setTransactionsForCard(card.id!, txs);
      }
    }
  }

  double get totalIncome => _recentTransactions
      .where((t) => t.amount >= 0)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _recentTransactions
      .where((t) => t.amount < 0)
      .fold(0, (sum, t) => sum + t.amount.abs());

  double get currentBalance => context.watch<BalanceProvider>().currentBalance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      appBar: AppBar(
        backgroundColor: const Color(0xff181a1e),
        automaticallyImplyLeading: false,
        title: const Text('D A S H B O A R D',
            style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 35, 37, 46),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfilePage(email: widget.email)),
                        ).then((_) => _loadAllData());
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
                            ? const Icon(CupertinoIcons.person_fill,
                                color: Color(0xff050c20))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome back,',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white54)),
                          Text(
                            _currentUser != null
                                ? "${_currentUser!.fname} ${_currentUser!.lname}"
                                : "Guest",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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
                            child: const Text('7',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Default card
              if (_defaultCard != null)
                Consumer<BalanceProvider>(
                  builder: (context, provider, _) {
                    return MyCards(
                      amount:
                          "\$${provider.totalBalance(_defaultCard!.id!).toStringAsFixed(2)}",
                      cardnumber: _defaultCard!.cardnumber,
                      expirydate: _defaultCard!.expirydate,
                      colorOne: Color(_defaultCard!.colorOne),
                      colorTwo: Color(_defaultCard!.colorTwo),
                      username: _defaultCard!.username,
                    );
                  },
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
                                  MyCardsPage(email: widget.email)),
                        );
                      },
                      label: const Text('Set up default card',
                          style: TextStyle(color: Colors.white70)),
                      icon: const Icon(CupertinoIcons.creditcard_fill,
                          color: Colors.white),
                    ),
                    MyCards(
                        amount: '0.00\$',
                        cardnumber: '0000 0000 0000 0000',
                        expirydate: 'mm/yy',
                        username: 'no username',
                        colorOne: Colors.blue,
                        colorTwo: Colors.amber),
                  ],
                ),

              const SizedBox(height: 20),

              // Income & Expense
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {},
                        heroTag: "income",
                        backgroundColor: Colors.green,
                        child: const Icon(CupertinoIcons.arrow_down_circle_fill,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text('+\$${totalIncome.toStringAsFixed(2)} Income',
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {},
                        heroTag: "expense",
                        backgroundColor: Colors.red,
                        child: const Icon(CupertinoIcons.arrow_up_circle_fill,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text('-\$${totalExpense.toStringAsFixed(2)} Expense',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Recent Transactions
              const Text('Recent Transactions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18)),
              const SizedBox(height: 10),
              Consumer<BalanceProvider>(
                builder: (context, provider, _) {
                  if (_defaultCard == null) return const SizedBox();
                  final transactions =
                      provider.transactionsForCard(_defaultCard!.id!);
                  return Column(
                    children: transactions.take(5).map((t) {
                      return Mytransaction(
                        logo: t.logoPath ?? 'assets/images/apple.png',
                        title: t.place ?? "",
                        date: "${t.date.day}/${t.date.month}/${t.date.year}",
                        amount: t.amount,
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Users button
              MyButton(
                textbutton: 'Users',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListOfUsers())).then((_) {
                    _loadAllData();
                  });
                },
                buttonHeight: 40,
                buttonWidth: 80,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 0, email: widget.email),
    );
  }
}
