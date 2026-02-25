import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'zoo_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de Animales
    await db.execute('''
      CREATE TABLE animals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        enclosureId TEXT NOT NULL,
        lastCheckup TEXT NOT NULL,
        imageUrl TEXT
      )
    ''');

    // Tabla de Bitácora (Care Logs)
    await db.execute('''
      CREATE TABLE care_logs (
        id TEXT PRIMARY KEY,
        animalId TEXT NOT NULL,
        note TEXT NOT NULL,
        caregiverId TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY (animalId) REFERENCES animals (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de Inventario
    await db.execute('''
      CREATE TABLE inventory (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit TEXT NOT NULL,
        minThreshold INTEGER NOT NULL
      )
    ''');
  }

  // Métodos genéricos para facilitar el uso
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    if (db == null) return 0;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    if (db == null) return [];
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    if (db == null) return 0;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> clearTable(String table) async {
    final db = await database;
    if (db == null) return;
    await db.delete(table);
  }
}
