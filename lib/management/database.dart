import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

import 'package:expenses_tracker/models/users.dart';

class DatabaseManager {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    await initialisation(); // auto-init if not ready
    return _database!;
  }

  Future<void> initialisation() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'users_database.db'),
      onCreate: (db, version) {
        return db.execute(
          '''CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fname TEXT,
            lname TEXT,
            email TEXT,
            password TEXT,
            phone TEXT,
            photoPath TEXT
          )''',
        );
      },
      version: 1,
    );
  }

  Future<List<AppUser>> getAllAppUsers() async {
    final db = await database; // ✅ instead of _database
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((map) => AppUser.fromMap(map)).toList();
  }

  Future<void> insertAppUser(AppUser user) async {
    final db = await database;
    await db.insert('users', user.toMap());
  }

  Future<void> updateAppUser(AppUser user) async {
    final db = await database;
    await db
        .update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<void> deleteAppUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await database;
    final result =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) return AppUser.fromMap(result.first);
    return null;
  }
}
