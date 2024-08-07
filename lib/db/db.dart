import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:daily_dose_of_humors/models/humor.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'my_database.db'),
      onCreate: (db, version) async {
        print('db newly created!');
        await db.execute('''
          CREATE TABLE bookmarks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT UNIQUE NOT NULL,
            create_date TEXT,
            added_date TEXT,
            category INTEGER NOT NULL,
            title TEXT,
            context TEXT,
            context_list TEXT,
            punchline TEXT,
            author TEXT,
            sender TEXT,
            source TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE library (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            create_date TEXT,
            added_date TEXT,
            category INTEGER,
            title TEXT,
            context TEXT,
            context_list TEXT,
            punchline TEXT,
            author TEXT,
            sender TEXT,
            source TEXT
          );
        ''');
      },
      version: 1,
    );
  }

  Future<bool> addBookmark(Humor humor) async {
    final db = await database;
    try {
      await db.insert(
        'bookmarks',
        humor.humorToMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error adding bookmark: $e');
      return false;
    }
  }

  Future<bool> removeBookmark(String uuid) async {
    final db = await database;
    try {
      int result = await db.delete(
        'bookmarks',
        where: 'uuid = ?',
        whereArgs: [uuid],
      );
      return result > 0;
    } catch (e) {
      print('Error deleting humor: $e');
      return false;
    }
  }

  // Future<List<Map<String, dynamic>>> getBookmarks() async {
  //   final db = await database;
  //   return await db.query('bookmarks');
  // }

  Future<List<Humor>> getBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookmarks');
    return List.generate(maps.length, (i) {
      return Humor.fromDocument(maps[i]);
    });
  }

  Future<bool> isBookmarked(String uuid) async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('bookmarks', where: 'uuid = ?', whereArgs: [uuid]);
    print('query result: $result');
    if (result.isEmpty) {
      return false;
    }
    return true;
  }
}
