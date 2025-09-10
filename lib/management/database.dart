import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:expenses_tracker/models/users.dart';

class DatabaseManager {
  Database? _database;

//initializing a database

  Future<Database> get database async {
    if (_database != null) return _database!;
    await initialisation();
    return _database!;
  }

//---- Generating a database with user info to store----

  Future<void> initialisation() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'users_database.db'),
      version: 4, // ✅ bump version when schema changes
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fname TEXT,
            lname TEXT,
            email TEXT UNIQUE,
            password TEXT,
            phone TEXT,
            photoPath TEXT
          )''',
        );

        //--- generating transactions table ---
        await db.execute(
          '''CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT,
          place TEXT,
          amount REAL,
          date TEXT,
          logoPath TEXT
          
          )''',
        );
      },

      //---Updating user profile----
      onUpgrade: (db, oldVersion, newVersion) async {
        // ✅ Ensure the users table always exists
        await db.execute(
          '''CREATE TABLE IF NOT EXISTS users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fname TEXT,
            lname TEXT,
            email TEXT UNIQUE,
            password TEXT,
            phone TEXT,
            photoPath TEXT
          )''',
        );

        //Ensuring transaction exist

        await db.execute(
          '''CREATE TABLE IF NOT EXISTS transactions 
  (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT,
  place TEXT,
  amount TEXT,
  date TEXT,
  logoPath TEXT
  
  )''',
        );
      },
    );
  }

  /// ✅ Wipes the entire database (useful for testing)
  Future<void> clearDatabase() async {
    final path = join(await getDatabasesPath(), 'users_database.db');
    if (await File(path).exists()) {
      await deleteDatabase(path);
    }
    _database = null; // force re-init on next call
  }

  ///------------    USERS -------------////

  Future<List<AppUser>> getAllAppUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((map) => AppUser.fromMap(map)).toList();
  }

  Future<void> insertAppUser(AppUser user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAppUser(AppUser user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
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

  //// --------- TRANSACTIONS ----------/////

  Future<void> insertTransaction({
    required String email,
    required String place,
    required double amount,
    required DateTime date,
    String? logoPath,
  }) async {
    final db = await database;
    await db.insert(
      'transactions',
      {
        'email': email,
        'place': place,
        'amount': amount,
        'date': date.toIso8601String(),
        'logoPath': logoPath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///Geting all user's transactions
  Future<List<Map<String, dynamic>>> getTransactions(String email) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'email = ?',
      whereArgs: [email],
      orderBy: 'date DESC',
    );
  }

  ///Deleting a transaction
  ///
  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
