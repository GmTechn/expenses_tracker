import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyNavBar(
        currentIndex: 1,
      ),
    );
  }
}
