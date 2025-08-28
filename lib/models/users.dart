import 'package:flutter/material.dart';

class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String confirmpassword;

  User(
      {required this.id,
      required this.username,
      required this.email,
      required this.password,
      required this.confirmpassword});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'confirmpassword': confirmpassword,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map['id'],
        username: map['username'],
        email: map['email'],
        password: map['password'],
        confirmpassword: map['confirmpassword']);
  }
}
