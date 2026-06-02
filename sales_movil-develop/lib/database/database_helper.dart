import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _dbName = 'sales.db';
  static const int _version = 5;
  static const String _tableClients = 'clients';
  static const String _tableSuppliers = 'suppliers';
  static const String _tableSales = 'sales';
  static const String _tableSaleDetails = 'sale_details';

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
        client_id INTEGER NOT NULL,
        client_name TEXT,
        subtotal REAL NOT NULL,
        igv REAL NOT NULL,
        total REAL NOT NULL,
        date TEXT,
        is_synced INTEGER DEFAULT 0,
        server_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableSaleDetails (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tableClients ADD COLUMN server_id INTEGER');
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

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableSales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client_id INTEGER NOT NULL,
          client_name TEXT,
          subtotal REAL NOT NULL,
          igv REAL NOT NULL,
          total REAL NOT NULL,
          date TEXT,
          is_synced INTEGER DEFAULT 0,
          server_id INTEGER
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableSaleDetails (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          product_name TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          price REAL NOT NULL,
          subtotal REAL NOT NULL,
          FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Métodos genéricos
  // ─────────────────────────────────────────────────────────────
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

  Future<List<Map<String, dynamic>>> queryWhere(
      String table, String where, List<dynamic> args) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: args);
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

  // ─────────────────────────────────────────────────────────────
  // Métodos específicos para ventas con detalles
  // ─────────────────────────────────────────────────────────────
  Future<int> insertSaleWithDetails(
      Map<String, dynamic> saleRow,
      List<Map<String, dynamic>> detailsRows) async {
    final db = await database;
    return await db.transaction((txn) async {
      final saleId = await txn.insert(_tableSales, saleRow);
      for (var detail in detailsRows) {
        final detailCopy = Map<String, dynamic>.of(detail);
        detailCopy['sale_id'] = saleId;
        await txn.insert(_tableSaleDetails, detailCopy);
      }
      return saleId;
    });
  }

  Future<Map<String, dynamic>?> getSaleWithDetails(int saleId) async {
    final db = await database;
    final sales = await db.query(_tableSales, where: 'id = ?', whereArgs: [saleId]);
    if (sales.isEmpty) return null;

    // ✅ FIX: convertir a mapa mutable antes de agregar 'details'
    final sale = Map<String, dynamic>.of(sales.first);
    final details = await db.query(_tableSaleDetails,
        where: 'sale_id = ?', whereArgs: [saleId]);
    sale['details'] = details;
    return sale;
  }

  Future<List<Map<String, dynamic>>> getAllSalesWithDetails() async {
    final db = await database;
    final rawSales = await db.query(_tableSales, orderBy: 'id DESC');

    // ✅ FIX PRINCIPAL: convertir cada mapa a uno mutable con Map.of()
    // sqflite devuelve mapas de solo lectura — asignar sale['details'] crasheaba
    final sales = rawSales.map((s) => Map<String, dynamic>.of(s)).toList();

    for (var sale in sales) {
      final details = await db.query(_tableSaleDetails,
          where: 'sale_id = ?', whereArgs: [sale['id']]);
      sale['details'] = details;
    }
    return sales;
  }

  Future<void> deleteSaleWithDetails(int saleId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_tableSaleDetails,
          where: 'sale_id = ?', whereArgs: [saleId]);
      await txn.delete(_tableSales, where: 'id = ?', whereArgs: [saleId]);
    });
  }
}