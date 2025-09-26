import 'package:expenses_tracker/models/transactions.dart';
import 'package:expenses_tracker/services/balance_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:provider/provider.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, required this.email});
  final String email;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final dbManager = DatabaseManager();
  final List<TransactionModel> _transactions = [];

  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedBrand;

  final Map<String, String> brandLogos = {
    'Apple':
        'https://w7.pngwing.com/pngs/589/546/png-transparent-apple-logo-new-york-city-brand-computer-apple-company-computer-logo.png',
    'Google':
        'https://4kwallpapers.com/images/wallpapers/google-logo-5k-8k-7680x4320-11298.png',
    'Zara': 'https://logos-world.net/wp-content/uploads/2020/05/Zara-Logo.png',
    'H&M':
        'https://e7.pngegg.com/pngimages/43/204/png-clipart-logo-h-m-brand-clothing-logo-hm.png',
    'Shein': 'https://1000logos.net/wp-content/uploads/2021/05/Shein-logo.png',
    'Walmart':
        'https://www.per-accurate.com/wp-content/uploads/2023/08/walmart-logo-24.jpg',
    'Loblaws':
        'https://cdn.freebiesupply.com/logos/large/2x/loblaws-logo-png-transparent.png',
    'Nike':
        'https://www.muraldecal.com/en/img/asfs364-jpg/folder/products-listado-merchanthover/stickers-nike-on-your-logo.jpg',
    'Amazon': 'https://wallpapercave.com/wp/wp7771222.png',
    'Samsung': 'https://www.pc-canada.com/dd2/img/item/B-500x500/-/Samsung.jpg',
    'Microsoft':
        'https://static.vecteezy.com/system/resources/previews/014/018/578/non_2x/microsoft-logo-on-transparent-background-free-vector.jpg',
    'Facebook':
        'https://www.citypng.com/public/uploads/preview/round-blue-circle-contains-f-letter-facebook-logo-701751695134712lb9coc4kea.png',
    'Twitter':
        'https://upload.wikimedia.org/wikipedia/commons/7/71/Twitter_Logo_Blue_%282%29.png',
    'Instagram':
        'https://img.freepik.com/free-vector/instagram-icon_1057-2227.jpg?semt=ais_hybrid&w=740&q=80',
    'TikTok': 'https://purepng.com/public/uploads/large/tik-tok-logo-6fh.png',
    'Spotify':
        'https://www.freepnglogos.com/uploads/spotify-logo-png/spotify-logo-spotify-symbol-3.png',
    'Netflix': 'https://images3.alphacoders.com/115/1152293.png',
    'Paypal': 'https://static.cdnlogo.com/logos/p/9/paypal.png',
    'Interact': 'https://download.logo.wine/logo/Interac/Interac-Logo.wine.png',
    'Wise':
        'https://d21buns5ku92am.cloudfront.net/69645/images/470455-Frame%2039263-cdfad6-medium-1677657684.png',
    'Direct Deposit':
        'https://www.shutterstock.com/image-vector/building-vector-icon-column-bank-600nw-1930635143.jpg',
    'MoneyGram':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/MoneyGram_Logo.svg/2560px-MoneyGram_Logo.svg.png',
  };

  List<String> get sortedBrands => brandLogos.keys.toList()..sort();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await dbManager.getTransactions(widget.email);
    data.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _transactions.clear();
      _transactions.addAll(data);
    });
  }

  double get totalTransactionsAmount {
    double total = 0;
    for (var t in _transactions) {
      total += t.type.toLowerCase() == 'income' ? t.amount : -t.amount;
    }
    return total;
  }

  void _openTransactionDialog({TransactionModel? transaction}) {
    String? _selectedType = transaction != null
        ? (transaction.type.toLowerCase() == 'income' ? 'Income' : 'Expense')
        : null;

    if (transaction != null) {
      _placeController.text = transaction.place;
      _amountController.text = transaction.amount.toString();
      _selectedBrand = brandLogos.entries
          .firstWhere((entry) => entry.value == transaction.logoPath,
              orElse: () => const MapEntry('', ''))
          .key;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xff181a1e),
          title: Text(
            transaction == null ? 'Add Transaction' : 'Edit Transaction',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
                    hintText: 'Merchant',
                    obscureText: false,
                    validator: (value) =>
                        value!.isEmpty ? "Enter a place" : null,
                  ),
                  const SizedBox(height: 10),
                  MyTextFormField(
                    leadingIcon: const Icon(CupertinoIcons.money_dollar),
                    controller: _amountController,
                    hintText: 'Amount',
                    obscureText: false,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        value!.isEmpty ? "Enter amount" : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedBrand,
                    items: sortedBrands
                        .map((brand) => DropdownMenuItem(
                              value: brand,
                              child: Text(brand,
                                  style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedBrand = value),
                    validator: (value) =>
                        value == null ? 'Select a brand' : null,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xff282b32),
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 40, 43, 50),
                      filled: true,
                      prefixIcon: Icon(CupertinoIcons.tag),
                      // iconColor: Colors.,
                      prefixIconColor: Colors.white,
                      hintText: 'Select Brand',
                      hintStyle: const TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 40, 43, 50),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(
                        value: 'Income',
                        child: Text(
                          'Income',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Expense',
                        child: Text(
                          'Expense',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _selectedType = value),
                    validator: (value) =>
                        value == null ? 'Select a type' : null,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xff282b32),
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 40, 43, 50),
                      filled: true,
                      prefixIcon: Icon(CupertinoIcons.arrow_2_circlepath),
                      // iconColor: Colors.,
                      prefixIconColor: Colors.white,
                      hintText: 'Select type',
                      hintStyle: const TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 40, 43, 50),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final place = _placeController.text;
                      final amountValue = double.parse(_amountController.text);
                      final isIncome = _selectedType?.toLowerCase() == 'income';
                      final logoPath = _selectedBrand != null
                          ? brandLogos[_selectedBrand!]
                          : null;

                      TransactionModel transactionModel;
                      if (transaction != null) {
                        transactionModel = transaction.copyWith(
                          place: place,
                          amount: amountValue,
                          logoPath: logoPath,
                          type: isIncome ? 'income' : 'expense',
                        );
                        await dbManager.updateTransaction(transactionModel);
                        final index = _transactions
                            .indexWhere((t) => t.id == transaction.id);
                        setState(() => _transactions[index] = transactionModel);
                      } else {
                        transactionModel = TransactionModel(
                          email: widget.email,
                          place: place,
                          amount: amountValue,
                          date: DateTime.now(),
                          logoPath: logoPath,
                          cardId: 0,
                          type: isIncome ? 'income' : 'expense',
                        );
                        await dbManager.insertTransaction(transactionModel);
                        _loadTransactions();
                      }

                      Navigator.pop(context);
                      _placeController.clear();
                      _amountController.clear();
                      _selectedBrand = null;
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      appBar: AppBar(
        title: const Text('T R A N S A C T I O N S',
            style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff181a1e),
      ),
      body: Column(
        children: [
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Text("No transactions yet",
                        style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, index) {
                      final t = _transactions[index];
                      final isIncome = t.type.toLowerCase() == 'income';
                      return Dismissible(
                        key: ValueKey(t.id),
                        background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white)),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          await dbManager.deleteTransaction(t.id!);
                          _loadTransactions();
                        },
                        child: ListTile(
                          onTap: () => _openTransactionDialog(transaction: t),
                          leading: t.logoPath != null && t.logoPath!.isNotEmpty
                              ? CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                      child: Image.network(t.logoPath!,
                                          fit: BoxFit.fill)),
                                )
                              : const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(CupertinoIcons.cart_fill,
                                      color: Color(0xff181a1e)),
                                ),
                          title: Text(t.place,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              "${t.date.day}/${t.date.month}/${t.date.year}",
                              style: const TextStyle(color: Colors.white54)),
                          trailing: Text(
                              '${isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isIncome ? Colors.green : Colors.red,
                                fontWeight: FontWeight.normal,
                              )),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(width: .5, color: Colors.white54))),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white70)),
                Text('\$${totalTransactionsAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _openTransactionDialog(),
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 1, email: widget.email),
    );
  }
}
