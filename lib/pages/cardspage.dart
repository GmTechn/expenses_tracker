import 'package:expenses_tracker/components/mycards.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/models/cards.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';

class MyCardsPage extends StatefulWidget {
  const MyCardsPage({super.key, required this.email});
  final String email;

  @override
  State<MyCardsPage> createState() => _MyCardsPageState();
}

class _MyCardsPageState extends State<MyCardsPage> {
  //Database
  final DatabaseManager _databaseManager = DatabaseManager();

  // list of user cards
  List<CardModel> _userCards = [];

  //initializing state

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  //loading Cards for users

  Future<void> _loadCards() async {
    final cards = await _databaseManager.getCards(widget.email);
    setState(() {
      _userCards = cards; // pas besoin de mapper
    });
  }

  ///Adding or editting a card
  ///

  void _cardAddEditDialog({CardModel? card}) {
    final TextEditingController amountController =
        TextEditingController(text: card?.amount.replaceAll('\$', ''));

    final TextEditingController cardNumberController =
        TextEditingController(text: card?.cardnumber ?? '');

    final TextEditingController expiryController =
        TextEditingController(text: card?.expirydate ?? '');
    final TextEditingController usernameController =
        TextEditingController(text: card?.username ?? '');

    Color color1 = card != null ? Color(card.colorOne) : Colors.blue;
    Color color2 = card != null ? Color(card.colorTwo) : Colors.deepPurple;
    Color color3 = card != null ? Color(card.colorThree) : Colors.orange;

    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Text(card == null ? 'Add New Card' : 'Edit Card'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Mytextfield(
                      controller: amountController,
                      hintText: 'Amount',
                      obscureText: false,
                      leadingIcon: Icon(
                        CupertinoIcons.money_dollar,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mytextfield(
                      controller: cardNumberController,
                      hintText: 'Card Number',
                      obscureText: false,
                      leadingIcon: Icon(
                        CupertinoIcons.creditcard,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        // _CardNumberFormatter(),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mytextfield(
                      controller: expiryController,
                      hintText: 'Expiry date',
                      obscureText: false,
                      leadingIcon: Icon(
                        CupertinoIcons.calendar,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mytextfield(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false,
                      leadingIcon: Icon(
                        CupertinoIcons.person,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Pick Card Colors:'),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Pick First Color'),
                                content: BlockPicker(
                                  pickerColor: color1,
                                  onColorChanged: (c) {
                                    setStateDialog(() => color1 = c);
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Ok'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: color1,
                            radius: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Pick Second Color'),
                                content: BlockPicker(
                                  pickerColor: color2,
                                  onColorChanged: (c) {
                                    setStateDialog(() => color2 = c);
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Ok'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: color2,
                            radius: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Pick Third Color'),
                                content: BlockPicker(
                                  pickerColor: color3,
                                  onColorChanged: (c) {
                                    setStateDialog(() => color3 = c);
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Ok'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: color3,
                            radius: 20,
                          ),
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
                TextButton(
                  onPressed: () async {
                    if (amountController.text.isNotEmpty &&
                        cardNumberController.text.isNotEmpty &&
                        expiryController.text.isNotEmpty &&
                        usernameController.text.isNotEmpty) {
                      final newCard = CardModel(
                        id: card?.id,
                        email: widget.email,
                        amount: "\$${amountController.text}",
                        cardnumber: cardNumberController.text,
                        expirydate: expiryController.text,
                        username: usernameController.text,
                        colorOne: color1.value,
                        colorTwo: color2.value,
                        colorThree: color3.value,
                      );

                      if (card == null) {
                        await _databaseManager.insertCard(newCard);
                      } else {
                        await _databaseManager.updateCard(newCard);
                      }

                      await _loadCards();

                      if (mounted) Navigator.of(ctx).pop();
                    }
                  },
                  child: Text(card == null ? "Add" : "Save"),
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'M Y  C A R D S',
          style: TextStyle(color: Color(0xff050c20)),
        ),
      ),
      body: _userCards.isEmpty
          ? const Center(
              child: Text(
                "No cards yet. Add one!",
                style: TextStyle(
                  color: Color(
                    0xff050c20,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _userCards.length,
              itemBuilder: (ctx, i) {
                final card = _userCards[i];
                return GestureDetector(
                  onTap: () => _cardAddEditDialog(card: card),
                  child: MyCards(
                    amount: card.amount,
                    cardnumber: card.cardnumber,
                    expirydate: card.expirydate,
                    username: card.username,
                    colorOne: Color(card.colorOne),
                    colorTwo: Color(
                      card.colorTwo,
                    ),
                    colorThree: Color(card.colorThree),
                  ),
                );
              },
              separatorBuilder: (ctx, i) => SizedBox(
                height: 16,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff050c20),
        onPressed: () => _cardAddEditDialog(),
        child: const Icon(
          CupertinoIcons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: MyNavBar(
        currentIndex: 2,
        email: widget.email,
      ),
    );
  }
}

// /// Formatter → automatically adds space every 4 digits
// class _CardNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     final text = newValue.text.replaceAll(' ', '');
//     final spaced = text.replaceAllMapped(
//         RegExp(r".{1,4}"), (match) => "${match.group(0)} ");
//     return TextEditingValue(
//       text: spaced.trim(),
//       selection: TextSelection.collapsed(offset: spaced.length),
//     );
//   }
// }
