import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vault_entry.dart';

/// Satu-satunya titik akses ke database.
/// Semua tabel (vault + settings) dibuat di sini.
class DBHelper {
  static Database? _instance;

  static Future<Database> get _db async {
    if (_instance != null) return _instance!;
    _instance = await _open();
    return _instance!;
  }

  static Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'vault_v3.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Tambah tabel settings jika upgrade dari v1
          await db.execute('''
            CREATE TABLE IF NOT EXISTS settings(
              key   TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        }
      },
      onOpen: (db) async {
        // Jaga-jaga: pastikan kedua tabel selalu ada
        await db.execute('''
          CREATE TABLE IF NOT EXISTS vault(
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            title      TEXT    NOT NULL,
            category   TEXT    NOT NULL,
            fields     TEXT    NOT NULL DEFAULT '{}',
            created_at TEXT,
            updated_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS settings(
            key   TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE vault(
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        title      TEXT    NOT NULL,
        category   TEXT    NOT NULL,
        fields     TEXT    NOT NULL DEFAULT '{}',
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE settings(
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // ── Vault CRUD ────────────────────────────────────────────────────────────

  Future<int> insert(VaultEntry entry) async {
    final db = await _db;
    return db.insert('vault', entry.toMap());
  }

  Future<List<VaultEntry>> getAll() async {
    final db = await _db;
    final rows = await db.query('vault', orderBy: 'updated_at DESC');
    return rows.map(VaultEntry.fromMap).toList();
  }

  Future<List<VaultEntry>> getByCategory(VaultCategory cat) async {
    final db = await _db;
    final rows = await db.query(
      'vault',
      where: 'category = ?',
      whereArgs: [cat.key],
      orderBy: 'updated_at DESC',
    );
    return rows.map(VaultEntry.fromMap).toList();
  }

  Future<List<VaultEntry>> search(String query) async {
    final db = await _db;
    final rows = await db.query(
      'vault',
      where: 'title LIKE ? OR fields LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );
    return rows.map(VaultEntry.fromMap).toList();
  }

  Future<int> update(VaultEntry entry) async {
    final db = await _db;
    return db.update(
      'vault',
      entry.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('vault', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<VaultCategory, int>> getCounts() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT category, COUNT(*) as cnt FROM vault GROUP BY category',
    );
    return {
      for (final r in rows)
        VaultCategoryX.fromKey(r['category'] as String): r['cnt'] as int,
    };
  }

  // ── Settings (PIN) ────────────────────────────────────────────────────────

  static Future<String?> getSetting(String key) async {
    final db = await _db;
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  static Future<void> setSetting(String key, String value) async {
    final db = await _db;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
