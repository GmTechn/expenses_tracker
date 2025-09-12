import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Mytextfield extends StatelessWidget {
  const Mytextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.leadingIcon,
    this.trailingIcon,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget leadingIcon;
  final Widget? trailingIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final whiteColor = Colors.white24;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        style: TextStyle(
          color: Colors.white,
        ),
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        cursorColor: whiteColor,
        decoration: InputDecoration(
          fillColor: Color.fromARGB(255, 40, 43, 50),
          filled: true,
          prefixIcon: leadingIcon,
          prefixIconColor: whiteColor,
          suffixIcon: trailingIcon,
          suffixIconColor: whiteColor,
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 40, 43, 50),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: whiteColor,
            ),
          ),
        ),
      ),
    );
  }
}
