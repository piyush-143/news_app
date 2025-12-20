import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  // Singleton Pattern: Ensures only one instance of the database helper exists.
  DbService._();
  static final DbService getInstance = DbService._();

  // --- Database Constants ---
  static const String tableName = "NewsApp_Table";
  static const String columnEmail = "Email";
  static const String columnPass = "Password";
  static const String columnDark = "DarkMode";
  static const String columnName = "Name";
  static const String columnImage = "Image";

  Database? _myDb;

  /// Returns the existing database instance or initializes a new one.
  Future<Database> getDb() async {
    if (_myDb != null) {
      return _myDb!;
    }
    _myDb = await _openDb();
    return _myDb!;
  }

  /// Opens the database and creates the table if it doesn't exist.
  Future<Database> _openDb() async {
    Directory dirPath = await getApplicationDocumentsDirectory();
    String dbPath = join(dirPath.path, "newsAppDb.db");

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "create table $tableName ( $columnEmail text primary key, $columnPass text, $columnDark INTEGER, $columnName text, $columnImage text)",
        );
      },
    );
  }

  // --- Authentication ---

  /// Registers a new user. Returns true if successful.
  Future<bool> saveDetails({
    required String email,
    required String pass,
    required String name,
    bool darkMode = false,
  }) async {
    var db = await getDb();
    try {
      int rowsEffected = await db.insert(tableName, {
        columnEmail: email,
        columnPass: pass,
        columnDark: darkMode ? 1 : 0,
        columnName: name,
        columnImage: "",
      });
      return rowsEffected > 0;
    } catch (e) {
      // Fails if email (Primary Key) already exists
      return false;
    }
  }

  /// Verifies credentials for login.
  Future<bool> loginUser({required String email, required String pass}) async {
    var db = await getDb();
    List<Map<String, dynamic>> data = await db.query(
      tableName,
      where: "$columnEmail = ? AND $columnPass = ?",
      whereArgs: [email, pass],
    );
    return data.isNotEmpty;
  }

  // --- User Data Retrieval ---

  /// Fetches full user profile (Name, Image, Settings).
  Future<Map<String, dynamic>?> getUserDetails(String email) async {
    var db = await getDb();
    List<Map<String, dynamic>> data = await db.query(
      tableName,
      where: "$columnEmail = ?",
      whereArgs: [email],
    );
    if (data.isNotEmpty) {
      return data.first;
    }
    return null;
  }

  /// Helper to get just the user's name.
  Future<String?> getUserName(String email) async {
    var data = await getUserDetails(email);
    return data?[columnName] as String?;
  }

  // --- Profile Management ---

  /// Updates Name and Email.
  /// Includes validation to ensure the new email isn't already taken by someone else.
  Future<bool> updateUserProfile({
    required String oldEmail,
    required String newEmail,
    required String newName,
  }) async {
    var db = await getDb();
    try {
      // VALIDATION: If the email is changing, check if the *new* email is already taken.
      if (oldEmail != newEmail) {
        var existingUser = await db.query(
          tableName,
          where: "$columnEmail = ?",
          whereArgs: [newEmail],
        );
        if (existingUser.isNotEmpty) {
          return false; // Email collision
        }
      }

      int rowsEffected = await db.update(
        tableName,
        {columnEmail: newEmail, columnName: newName},
        where: "$columnEmail = ?",
        whereArgs: [oldEmail], // Identify record by the OLD email
      );
      return rowsEffected > 0;
    } catch (e) {
      return false;
    }
  }

  /// Updates the local file path to the user's profile picture.
  Future<bool> updateProfileImage(String email, String imagePath) async {
    var db = await getDb();
    try {
      int rowsEffected = await db.update(
        tableName,
        {columnImage: imagePath},
        where: "$columnEmail = ?",
        whereArgs: [email],
      );
      return rowsEffected > 0;
    } catch (e) {
      return false;
    }
  }

  /// Resets the user's password.
  Future<bool> updatePassword(String email, String newPassword) async {
    var db = await getDb();
    try {
      int rowsEffected = await db.update(
        tableName,
        {columnPass: newPassword},
        where: "$columnEmail = ?",
        whereArgs: [email],
      );
      return rowsEffected > 0;
    } catch (e) {
      return false;
    }
  }

  // --- Settings ---

  /// Updates the Dark Mode preference.
  Future<bool> updateDbData({
    required bool darkMode,
    required String email,
  }) async {
    var db = await getDb();
    int rowsEffected = await db.update(
      tableName,
      {columnDark: darkMode ? 1 : 0},
      where: "$columnEmail = ?",
      whereArgs: [email],
    );
    return rowsEffected > 0;
  }

  /// Fetches all rows (Useful for testing database content).
  Future<List<Map<String, dynamic>>> getAllData() async {
    var db = await getDb();
    List<Map<String, dynamic>> data = await db.query(tableName);
    return data;
  }
}
