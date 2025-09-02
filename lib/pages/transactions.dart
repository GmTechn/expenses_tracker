import 'dart:io';

import 'package:expenses_tracker/components/mynavbar.dart';
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
  final List<Transaction> _transactions = [];

  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  final _amountController = TextEditingController();
  File? _selectedLogo;

  double get totalAmount =>
      _transactions.fold(0, (sum, item) => sum + item.amount);

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedLogo = File(picked.path);
      });
    }
  }

  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _transactions.insert(
          0,
          Transaction(
            place: _placeController.text,
            logo: _selectedLogo,
            date: DateTime.now(),
            amount: double.parse(_amountController.text),
          ),
        );
        _placeController.clear();
        _amountController.clear();
        _selectedLogo = null;
      });
      Navigator.of(context).pop();
    }
  }

  void _openAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add Transaction"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _placeController,
                    decoration: const InputDecoration(labelText: "Place"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter a place" : null,
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: "Amount"),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        value!.isEmpty ? "Enter amount" : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickLogo,
                        icon: const Icon(Icons.image),
                        label: const Text("Pick Logo"),
                      ),
                      const SizedBox(width: 10),
                      _selectedLogo != null
                          ? Image.file(
                              _selectedLogo!,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            )
                          : const Text("No logo selected"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addTransaction,
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
      ),
      body: Column(
        children: [
          Expanded(
            child: _transactions.isEmpty
                ? const Center(child: Text("No transactions yet"))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = _transactions[index];
                      return ListTile(
                        leading: tx.logo != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(tx.logo!),
                              )
                            : const CircleAvatar(child: Icon(Icons.store)),
                        title: Text(tx.place),
                        subtitle: Text(
                            "${tx.date.day}/${tx.date.month}/${tx.date.year}"),
                        trailing: Text("\$${tx.amount.toStringAsFixed(2)}"),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("\$${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _openAddTransactionDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add Transaction"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyNavBar(
        currentIndex: 0,
        email: '',
      ),
    );
  }
}
