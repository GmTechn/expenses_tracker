import 'package:flutter/material.dart';

class MySquareTile extends StatelessWidget {
  const MySquareTile({
    super.key,
    this.onTap,
    required this.imagePath,
  });

  final Function()? onTap;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white54,
            border: Border.all(color: const Color(0xff050c20)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(imagePath)),
    );
  }
}
