import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.textbutton});

  final String textbutton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 40,
        width: 200,
        decoration: BoxDecoration(
          color: const Color(0xff050c20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextButton(
            onPressed: () {},
            child: Text(
              textbutton,
              style: const TextStyle(color: Colors.white),
            )),
      ),
    );
  }
}
