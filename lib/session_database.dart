import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SessionDatabase {
  static final SessionDatabase instance = SessionDatabase._privateConstructor();
  static Database? _database;

  SessionDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'session.db');
    return await openDatabase(
      path,
      version: 2, // Increment version number to apply new schema changes
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE session(
        id INTEGER PRIMARY KEY,
        email TEXT,
        ipAddress TEXT,
        userType TEXT
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE session ADD COLUMN userType TEXT
      ''');
    }
  }

  Future<int> insertSession(Map<String, dynamic> row) async {
    Database db = await instance.database;
    await db.delete('session'); // Hapus session yang ada (hanya boleh ada satu session)
    return await db.insert('session', row);
  }

  Future<Map<String, dynamic>> getSession() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('session');
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {};
    }
  }

  Future<void> deleteSession() async {
    Database db = await instance.database;
    await db.delete('session');
  }
}