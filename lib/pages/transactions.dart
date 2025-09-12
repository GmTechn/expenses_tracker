import 'dart:io';

import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class Transaction {
  final String place;
  final File? logo;
  final DateTime date;
  final double amount;

  Transaction({
    required this.place,
    required this.logo,
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
//generating a list of transactions

  final List<Transaction> _transactions = [];

//calling the database

  final dbManager = DatabaseManager();

//initializing state

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

//loading transa from db

  Future<void> _loadTransactions() async {
    final data = await dbManager.getTransactions(widget.email);

    setState(() {
      _transactions.clear();
      _transactions.addAll(
        data.map(
          (t) => Transaction(
            place: t['place'],
            logo: t['logoPath'] != null ? File(t['logoPath']) : null,
            date: DateTime.parse(t['date']),
            amount: t['amount'],
          ),
        ),
      );
    });
  }

//determining the controller that would take the values
//to use to manipulate for place, amount, logo etc...

  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  final _amountController = TextEditingController();
  File? _selectedLogo;

//calculating the total amount of all transactions

  double get totalTransactionsAmount =>
      _transactions.fold(0, (sum, item) => sum + item.amount);

//generating the picking up of a logo to add to a transaction

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedLogo = File(picked.path);
      });
    }
  }

//function to add a transaction to the page

  void _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      //inserting into transactions var , the transactions values
      //that come from the text editting controllers
      //parsing the amount from double to string

      final newTransaction = Transaction(
        place: _placeController.text,
        logo: _selectedLogo,
        date: DateTime.now(),
        amount: double.parse(_amountController.text),
      );

      //save in DB

      await dbManager.insertTransaction(
        email: widget.email,
        place: newTransaction.place,
        amount: newTransaction.amount,
        date: newTransaction.date,
        logoPath: newTransaction.logo?.path,
      );

      setState(() {
        _transactions.insert(0, newTransaction);

        //clearing the controllers after registering the data
        //into the transaction instance

        _placeController.clear();
        _amountController.clear();
        _selectedLogo = null;
      });

      //getting rid of the context = alerdialog

      Navigator.pop(context);
    }
  }

//creating the showdialog that adds a transaction

  void _openAddTransactionDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text(
              'Add Transaction',
              style: TextStyle(
                color: Color(
                  0xff050c20,
                ),
              ),
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _placeController,
                      decoration: InputDecoration(labelText: "Place"),
                      validator: (value) =>
                          value!.isEmpty ? "Enter a place" : null,
                    ),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: "Amount"),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                          value!.isEmpty ? "Enter amount" : null,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          icon: Icon(
                            CupertinoIcons.photo,
                            color: Color(0xff050c20),
                          ),
                          onPressed: _pickLogo,
                          label: Text(
                            "Pick a logo",
                            style: TextStyle(
                              color: Color(0xff050c20),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        _selectedLogo != null
                            ? Image.file(
                                _selectedLogo!,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              )
                            : Text('No logo selected'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: _addTransaction,
                child: Text("Add"),
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
        title: Text(
          'T R A N S A C T I O N S',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff181a1e),
      ),
      body: Column(
        children: [
          Expanded(
            child: _transactions.isEmpty
                ? Center(
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
                        leading: transacIndex.logo != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(
                                  transacIndex.logo!,
                                ),
                              )
                            : CircleAvatar(
                                child: Icon(CupertinoIcons.shopping_cart),
                              ),
                        title: Text(
                          transacIndex.place,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${transacIndex.date.day}/${transacIndex.date.month}/${transacIndex.date.year}",
                          style: TextStyle(color: Colors.white54),
                        ),
                        trailing: Text(
                          '\$${transacIndex.amount.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: .5,
                  color: Colors.white54,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 80,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _openAddTransactionDialog(),
        child: const Icon(
          CupertinoIcons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 1, email: widget.email),
    );
  }
}
