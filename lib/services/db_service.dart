import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  DbService._();
  static final DbService getInstance = DbService._();

  static const String tableName = "NewsApp_Table";
  static const String columnEmail = "Email";
  static const String columnPass = "Password";
  static const String columnDark = "DarkMode";
  static const String columnName = "Name";
  static const String columnImage = "Image";

  Database? _myDb;

  Future<Database> getDb() async {
    if (_myDb != null) {
      return _myDb!;
    }
    _myDb = await openDb();
    return _myDb!;
  }

  Future<Database> openDb() async {
    Directory dirPath = await getApplicationDocumentsDirectory();
    String dbPath = join(dirPath.path, "newsAppDb.db");

    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        db.execute(
          "create table $tableName ( $columnEmail text primary key, $columnPass text, $columnDark INTEGER, $columnName text, $columnImage text)",
        );
      },
      version: 1,
    );
  }

  // --- Insert Data (Sign Up) ---
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
      return false;
    }
  }

  // --- Login Check ---
  Future<bool> loginUser({required String email, required String pass}) async {
    var db = await getDb();
    List<Map<String, dynamic>> data = await db.query(
      tableName,
      where: "$columnEmail = ? AND $columnPass = ?",
      whereArgs: [email, pass],
    );
    return data.isNotEmpty;
  }

  // --- Get User Details (Name & Image) ---
  Future<Map<String, dynamic>?> getUserDetails(String email) async {
    var db = await getDb();
    List<Map<String, dynamic>> data = await db.query(
      tableName,
      // Fetch all columns to ensure we get the data correctly
      where: "$columnEmail = ?",
      whereArgs: [email],
    );
    if (data.isNotEmpty) {
      return data.first;
    }
    return null;
  }

  // Backwards compatibility
  Future<String?> getUserName(String email) async {
    var data = await getUserDetails(email);
    return data?[columnName] as String?;
  }

  // --- Update User Profile (Name, Email) ---
  Future<bool> updateUserProfile({
    required String oldEmail,
    required String newEmail,
    required String newName,
  }) async {
    var db = await getDb();
    try {
      if (oldEmail != newEmail) {
        var existingUser = await db.query(
          tableName,
          where: "$columnEmail = ?",
          whereArgs: [newEmail],
        );
        if (existingUser.isNotEmpty) {
          return false;
        }
      }

      int rowsEffected = await db.update(
        tableName,
        {columnEmail: newEmail, columnName: newName},
        where: "$columnEmail = ?",
        whereArgs: [oldEmail],
      );
      return rowsEffected > 0;
    } catch (e) {
      return false;
    }
  }

  // --- Update Profile Image ---
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

  // --- Reset Password (New Feature) ---
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

  // --- Update Data (Dark Mode) ---
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

  // --- Get All Data ---
  Future<List<Map<String, dynamic>>> getAllData() async {
    var db = await getDb();
    List<Map<String, dynamic>> data = await db.query(tableName);
    return data;
  }
}
