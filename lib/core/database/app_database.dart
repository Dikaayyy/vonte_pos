import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'tables.dart';

typedef MigrationFunction = Future<void> Function(Database db);

class AppDatabase {
  AppDatabase({Database? database, String? dbName})
      : _db = database,
        _dbName = dbName ?? defaultDatabaseName;

  static const String defaultDatabaseName = 'vonte_pos.db';
  static const int currentVersion = 1;

  Database? _db;
  final String _dbName;

  /// In-memory database factory helper for tests.
  factory AppDatabase.inMemory() =>
      AppDatabase(dbName: inMemoryDatabasePath);

  /// Access the opened SQLite database.
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final String path;
    if (_dbName == inMemoryDatabasePath) {
      path = inMemoryDatabasePath;
    } else {
      final databasesPath = await getDatabasesPath();
      path = p.join(databasesPath, _dbName);
    }
    return open(path);
  }

  static Future<Database> open(String path) async {
    return openDatabase(
      path,
      version: currentVersion,
      onConfigure: onConfigure,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  /// SQLite disables foreign keys by default for backward compatibility.
  /// onConfigure runs on every connection before any DDL or query.
  static Future<void> onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static final Map<int, MigrationFunction> _migrations = {
    1: _migrateToV1,
  };

  static Future<void> onCreate(Database db, int version) async {
    for (int v = 1; v <= version; v++) {
      final migration = _migrations[v];
      if (migration != null) {
        await migration(db);
      }
    }
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      final migration = _migrations[v];
      if (migration != null) {
        await migration(db);
      }
    }
  }

  static Future<void> _migrateToV1(Database db) async {
    final batch = db.batch();

    // 1. users
    batch.execute('''
      CREATE TABLE ${AppTables.users} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // 2. sessions
    batch.execute('''
      CREATE TABLE ${AppTables.sessions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        logged_in_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${AppTables.users} (id) ON DELETE CASCADE
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_sessions_user_id ON ${AppTables.sessions} (user_id)',
    );

    // 3. store_profile
    batch.execute('''
      CREATE TABLE ${AppTables.storeProfile} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        receipt_footer TEXT NOT NULL
      )
    ''');

    // 4. categories
    batch.execute('''
      CREATE TABLE ${AppTables.categories} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // 5. products
    batch.execute('''
      CREATE TABLE ${AppTables.products} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        photo_path TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES ${AppTables.categories} (id) ON DELETE SET NULL
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_products_category_id ON ${AppTables.products} (category_id)',
    );
    batch.execute(
      'CREATE INDEX idx_products_name ON ${AppTables.products} (name)',
    );
    batch.execute(
      'CREATE INDEX idx_products_is_deleted ON ${AppTables.products} (is_deleted)',
    );

    // 6. addons
    batch.execute('''
      CREATE TABLE ${AppTables.addons} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price INTEGER NOT NULL DEFAULT 0,
        stock INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_addons_is_deleted ON ${AppTables.addons} (is_deleted)',
    );

    // 7. product_addons (pivot table)
    batch.execute('''
      CREATE TABLE ${AppTables.productAddons} (
        product_id INTEGER NOT NULL,
        addon_id INTEGER NOT NULL,
        PRIMARY KEY (product_id, addon_id),
        FOREIGN KEY (product_id) REFERENCES ${AppTables.products} (id) ON DELETE CASCADE,
        FOREIGN KEY (addon_id) REFERENCES ${AppTables.addons} (id) ON DELETE CASCADE
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_product_addons_addon_id ON ${AppTables.productAddons} (addon_id)',
    );

    // 8. transactions
    batch.execute('''
      CREATE TABLE ${AppTables.transactions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT NOT NULL UNIQUE,
        cashier_id INTEGER NOT NULL,
        cashier_name TEXT NOT NULL,
        store_name TEXT NOT NULL,
        store_address TEXT NOT NULL,
        store_phone TEXT NOT NULL,
        subtotal INTEGER NOT NULL,
        discount_type TEXT NOT NULL,
        discount_value INTEGER NOT NULL,
        discount_amount INTEGER NOT NULL,
        total INTEGER NOT NULL,
        cash_received INTEGER NOT NULL,
        change_amount INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_transactions_created_at ON ${AppTables.transactions} (created_at)',
    );

    // 9. transaction_items (snapshot, product_id is reference only)
    batch.execute('''
      CREATE TABLE ${AppTables.transactionItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        unit_price INTEGER NOT NULL,
        qty INTEGER NOT NULL,
        line_total INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES ${AppTables.transactions} (id) ON DELETE CASCADE
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_transaction_items_transaction_id ON ${AppTables.transactionItems} (transaction_id)',
    );

    // 10. transaction_item_addons (snapshot, addon_id is reference only)
    batch.execute('''
      CREATE TABLE ${AppTables.transactionItemAddons} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_item_id INTEGER NOT NULL,
        addon_id INTEGER NOT NULL,
        addon_name TEXT NOT NULL,
        addon_price INTEGER NOT NULL,
        qty INTEGER NOT NULL,
        line_total INTEGER NOT NULL,
        FOREIGN KEY (transaction_item_id) REFERENCES ${AppTables.transactionItems} (id) ON DELETE CASCADE
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_transaction_item_addons_item_id ON ${AppTables.transactionItemAddons} (transaction_item_id)',
    );

    // 11. Seed neutral default store_profile
    batch.insert(AppTables.storeProfile, {
      'id': 1,
      'name': 'Vonte PoS',
      'address': 'Jl. Bisnis No. 1',
      'phone': '081234567890',
      'receipt_footer': 'Terima kasih atas kunjungan Anda',
    });

    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}

