import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  // --- IMPLEMENTACIÓN DE SQLITE ---
  // Se utiliza como capa de persistencia local (offline)
  static Database? _db;

  // Acceso asíncrono a la instancia de la base de datos
  Future<Database?> get database async {
    // SQLite no es compatible con Web en este paquete nativo
    if (kIsWeb) return null;
    
    // Si ya existe la conexión, la reutilizamos
    if (_db != null) return _db!;
    
    // Si es la primera vez, inicializamos el archivo .db
    _db = await _initDB();
    return _db!;
  }

  // Define la ruta y configuración del archivo de base de datos local
  Future<Database> _initDB() async {
    // Crea el archivo 'zoo_database.db' en el almacenamiento interno del dispositivo
    final path = join(await getDatabasesPath(), 'zoo_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Definición de las tablas (Esquema SQL)
  Future<void> _createDB(Database db, int version) async {
    // Tabla de Animales: Cachea los datos de Firestore para acceso sin internet
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

    // Tabla de Bitácora: Registra historiales médicos y de cuidados diarios
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

    // Tabla de Inventario: Stock y recursos del zoológico
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

  // --- MÉTODOS CRUD (Cómo sirve la base de datos) ---

  // Inserta o actualiza datos (ConflictAlgorithm.replace asegura que no haya duplicados)
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    if (db == null) return 0;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Realiza consultas a las tablas locales
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    if (db == null) return [];
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  // Elimina registros específicos (ej: cuando se borra un animal de Firebase)
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    if (db == null) return 0;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Borra todo el contenido de una tabla (reset)
  Future<void> clearTable(String table) async {
    final db = await database;
    if (db == null) return;
    await db.delete(table);
  }
}
