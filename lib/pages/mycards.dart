import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyCardsPage extends StatelessWidget {
  const MyCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyNavBar(currentIndex: 2),
    );
  }
}
