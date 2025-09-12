import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Transaction {
  final String place;
  final DateTime date;
  final double amount;

  Transaction({
    required this.place,
    required this.date,
    required this.amount,
  });
}

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, required this.email});

  final String email;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final List<Transaction> _transactions = [];
  final dbManager = DatabaseManager();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await dbManager.getTransactions(widget.email);
    setState(() {
      _transactions.clear();
      _transactions.addAll(
        data.map(
          (t) => Transaction(
            place: t['place'],
            date: DateTime.parse(t['date']),
            amount: t['amount'],
          ),
        ),
      );
    });
  }

  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  final _amountController = TextEditingController();

  double get totalTransactionsAmount =>
      _transactions.fold(0, (sum, item) => sum + item.amount);

  // Mapping of brands to internet logos
  final Map<String, String> brandLogos = {
    'Apple':
        'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg',
    'Google':
        'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
    'Zara': 'https://logos-world.net/wp-content/uploads/2020/05/Zara-Logo.png',
    'H&M': 'https://upload.wikimedia.org/wikipedia/commons/5/53/H%26M-Logo.svg',
    'Shein': 'https://1000logos.net/wp-content/uploads/2021/05/Shein-logo.png',
  };

  void _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      final newTransaction = Transaction(
        place: _placeController.text,
        date: DateTime.now(),
        amount: double.parse(_amountController.text),
      );

      await dbManager.insertTransaction(
        email: widget.email,
        place: newTransaction.place,
        amount: newTransaction.amount,
        date: newTransaction.date,
        logoPath: null, // On ne sauvegarde plus de logo local
      );

      setState(() {
        _transactions.insert(0, newTransaction);
        _placeController.clear();
        _amountController.clear();
      });

      Navigator.pop(context);
    }
  }

  void _openAddTransactionDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xff181a1e),
            title: const Text(
              textAlign: TextAlign.center,
              'Add Transaction',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyTextFormField(
                      leadingIcon: const Icon(CupertinoIcons.placemark),
                      controller: _placeController,
                      hintText: 'Place',
                      obscureText: false,
                      validator: (value) =>
                          value!.isEmpty ? "Enter a place" : null,
                    ),
                    const SizedBox(height: 10),
                    MyTextFormField(
                      leadingIcon: const Icon(CupertinoIcons.money_dollar),
                      controller: _amountController,
                      hintText: "Amount",
                      obscureText: false,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                          value!.isEmpty ? "Enter amount" : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _addTransaction,
                    child: const Text(
                      "Add",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      appBar: AppBar(
        title: const Text(
          'T R A N S A C T I O N S',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff181a1e),
      ),
      body: Column(
        children: [
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Text(
                      "No transactions yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, index) {
                      final transacIndex = _transactions[index];
                      return ListTile(
                        leading: brandLogos.containsKey(transacIndex.place)
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                    brandLogos[transacIndex.place]!),
                              )
                            : const CircleAvatar(
                                child: Icon(
                                  CupertinoIcons.shopping_cart,
                                  color: Colors.white,
                                ),
                              ),
                        title: Text(
                          transacIndex.place,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${transacIndex.date.day}/${transacIndex.date.month}/${transacIndex.date.year}",
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Text(
                          '\$${transacIndex.amount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: .5,
                  color: Colors.white54,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '\$${totalTransactionsAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _openAddTransactionDialog,
        child: const Icon(
          CupertinoIcons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 1, email: widget.email),
    );
  }
}
