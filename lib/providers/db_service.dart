// lib/providers/db_service.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  static const _dbName = 'container_ledger.db';
  static const _dbVersion = 2; // ⬅ bump เวอร์ชันเพื่อสร้างตารางใหม่

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE containers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Active',
        location TEXT,
        owner TEXT,
        lastInspectionAt INTEGER
      )
    ''');
    await db.execute('CREATE INDEX idx_containers_code ON containers(code);');

    // Movements
    await db.execute('''
      CREATE TABLE movements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        containerId INTEGER NOT NULL,
        fromLocation TEXT,
        toLocation TEXT,
        movedAt INTEGER,
        by TEXT,
        FOREIGN KEY(containerId) REFERENCES containers(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_movements_containerId ON movements(containerId);');
    await db.execute('CREATE INDEX idx_movements_movedAt ON movements(movedAt);');

    // Maintenances
    await db.execute('''
      CREATE TABLE maintenances(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        containerId INTEGER NOT NULL,
        date INTEGER,
        remark TEXT,
        cost REAL,
        FOREIGN KEY(containerId) REFERENCES containers(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_maint_containerId ON maintenances(containerId);');
    await db.execute('CREATE INDEX idx_maint_date ON maintenances(date);');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // อัปเกรดจาก v1 -> v2: เพิ่มตาราง movements, maintenances
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS movements(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          containerId INTEGER NOT NULL,
          fromLocation TEXT,
          toLocation TEXT,
          movedAt INTEGER,
          by TEXT,
          FOREIGN KEY(containerId) REFERENCES containers(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_movements_containerId ON movements(containerId);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_movements_movedAt ON movements(movedAt);');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS maintenances(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          containerId INTEGER NOT NULL,
          date INTEGER,
          remark TEXT,
          cost REAL,
          FOREIGN KEY(containerId) REFERENCES containers(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_maint_containerId ON maintenances(containerId);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_maint_date ON maintenances(date);');
    }
  }
}
