import 'package:flutter/material.dart';

class Mytextfield extends StatelessWidget {
  const Mytextfield(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.leadingIcon});
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: const Color(0xff050c20),
        decoration: InputDecoration(
            prefixIcon: leadingIcon,
            hintText: hintText,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xff050c20).withOpacity(.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff050c20)))),
      ),
    );
  }
}
