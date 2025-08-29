import 'package:expenses_tracker/components/mycards.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytransaction.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:expenses_tracker/pages/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //username display
  String username = 'Gabrielle Mutunda';

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
                  const SizedBox(
                    width: 40,
                  ),
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
                            Text(username),
                            const Text('!'),
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

              const SizedBox(
                height: 20,
              ),

              // Card
              MyCards(
                amount: '\$542.45',
                cardnumber: "5412 7512 3412 3456",
                expirydate: '12/25',
                username: username,
                colorOne: const Color.fromARGB(255, 5, 77, 113),
                colorTwo: Colors.amber.withOpacity(.5),
              ),

              const SizedBox(
                height: 20,
              ),

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
                      const SizedBox(
                        height: 8,
                      ),
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
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        '-\$50 Expense',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              // Transactions title
              const Text(
                'Transactions',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff050c20),
                    fontSize: 18),
              ),
              const SizedBox(
                height: 10,
              ),

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
            ],
          ),
        ),
      ),

      // ⬇️ Bottom navigation stays fixed

      bottomNavigationBar: MyNavBar(
        currentIndex: 0,
      ),
    );
  }
}
