import 'dart:async';

import 'package:expenses_tracker/models/users.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

class DataBaseManager {
  late Database _database;

  Future<void> initialisation() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'users_database.db'),
      onCreate: (db, version) {
        return db.execute('''
CREATE TABLES users(
id INTEGER PRIMARY KEY AUTOINCREMENT,
username TEXT,
email TEXT,
password TEXT,
confirmpassword TEXT,
);

''');
      },
      version: 1,
    );
  }
  //get all the user from the database

  Future<List<User>> getAllUsers() async {
    final List<Map<String, dynamic>> maps = await _database.query('users');
    return List.generate(maps.length, (index) {
      return User(
          id: maps[index]['id'],
          username: maps[index]['username'],
          email: maps[index]['email'],
          password: maps[index]['password'],
          confirmpassword: maps[index]['confirmpassword']);
    });
  }

  //insert a new user into the database

  Future<void> insertUser(User user) async {
    await _database.insert('users', user.toMap());
  }

  //update user's information into the database

  Future<void> updateUser(User user) async {
    await _database
        .update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  //Delete user's information from the database

  Future<void> deleteUser(int id) async {
    await _database.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
