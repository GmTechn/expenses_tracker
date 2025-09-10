import 'package:expenses_tracker/components/mycards.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:flutter/material.dart';
import 'mycards.dart';

class MyCardsPage extends StatefulWidget {
  const MyCardsPage({super.key, required this.email});
  final String email;

  @override
  State<MyCardsPage> createState() => _MyCardsPageState();
}

class _MyCardsPageState extends State<MyCardsPage> {
  // list of user cards
  final List<MyCards> _userCards = [];

  void _addCardDialog() {
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController numberCtrl = TextEditingController();
    final TextEditingController expiryCtrl = TextEditingController();
    final TextEditingController userCtrl = TextEditingController();

    Color color1 = Colors.blue;
    Color color2 = Colors.deepPurple;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add New Card"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: numberCtrl,
                  decoration: const InputDecoration(labelText: "Card Number"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: expiryCtrl,
                  decoration:
                      const InputDecoration(labelText: "Expiry Date (MM/YY)"),
                ),
                TextField(
                  controller: userCtrl,
                  decoration:
                      const InputDecoration(labelText: "Card Holder Name"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: color1),
                      onPressed: () {
                        setState(() {
                          color1 = Colors.red;
                          color2 = Colors.orange;
                        });
                      },
                      child: const Text("Color Theme 1"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: color2),
                      onPressed: () {
                        setState(() {
                          color1 = Colors.green;
                          color2 = Colors.teal;
                        });
                      },
                      child: const Text("Color Theme 2"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (amountCtrl.text.isNotEmpty &&
                    numberCtrl.text.isNotEmpty &&
                    expiryCtrl.text.isNotEmpty &&
                    userCtrl.text.isNotEmpty) {
                  setState(() {
                    _userCards.add(
                      MyCards(
                        amount: "\$${amountCtrl.text}",
                        cardnumber: numberCtrl.text,
                        expirydate: expiryCtrl.text,
                        username: userCtrl.text,
                        colorOne: color1,
                        colorTwo: color2,
                      ),
                    );
                  });
                  Navigator.of(ctx).pop();
                }
              },
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
        automaticallyImplyLeading: false,
        title: const Text(
          'MY CARDS',
          style: TextStyle(color: Color(0xff050c20)),
        ),
      ),
      body: _userCards.isEmpty
          ? const Center(
              child: Text(
                "No cards yet. Add one!",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _userCards.length,
              itemBuilder: (ctx, i) => _userCards[i],
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCardDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: MyNavBar(
        currentIndex: 2,
        email: widget.email,
      ),
    );
  }
}
