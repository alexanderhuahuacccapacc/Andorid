import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _dbName = 'sales.db';
  static const int _version = 3;
  static const String _tableClients = 'clients';
  static const String _tableSuppliers = 'suppliers';
  static const String _tableSales = 'sales';

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableClients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        document_number TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        server_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableSuppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        document_number TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        server_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableSales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        total REAL NOT NULL,
        date TEXT,
        customer_name TEXT,
        product_name TEXT,
        is_synced INTEGER DEFAULT 0,
        server_id INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 → v2: agregar server_id a clients y crear suppliers
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $_tableClients ADD COLUMN server_id INTEGER',
      );
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableSuppliers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          document_number TEXT NOT NULL,
          email TEXT,
          phone TEXT,
          address TEXT,
          is_synced INTEGER NOT NULL DEFAULT 0,
          server_id INTEGER
        )
      ''');
    }

    // v2 → v3: crear tabla sales  ← bloque separado, NO anidado
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableSales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL DEFAULT 1,
          total REAL NOT NULL,
          date TEXT,
          customer_name TEXT,
          product_name TEXT,
          is_synced INTEGER DEFAULT 0,
          server_id INTEGER
        )
      ''');
    }
  }

  // Métodos genéricos que funcionan para cualquier tabla
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  Future<int> update(String table, int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table, orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> queryPending(String table) async {
    final db = await database;
    return await db.query(table, where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<int> updateSynced(String table, int id, int serverId) async {
    final db = await database;
    return await db.update(
      table,
      {'is_synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateSyncedOnly(String table, int id) async {
    final db = await database;
    return await db.update(
      table,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll(String table) async {
    final db = await database;
    await db.delete(table);
  }
}