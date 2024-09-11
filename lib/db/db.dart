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
            bookmark_id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT UNIQUE NOT NULL,
            bookmark_ord INTEGER,
            bookmark_added_date TEXT NOT NULL,
            category TEXT NOT NULL,
            context TEXT NOT NULL,
            context_list TEXT NOT NULL,
            punchline TEXT NOT NULL,
            author TEXT NOT NULL,
            sender TEXT NOT NULL,
            source TEXT NOT NULL
          );
        ''');
        // await db.execute('''
        //   CREATE TABLE library (
        //     id INTEGER PRIMARY KEY AUTOINCREMENT,
        //     create_date TEXT,
        //     added_date TEXT,
        //     category INTEGER,
        //     title TEXT,
        //     context TEXT,
        //     context_list TEXT,
        //     punchline TEXT,
        //     author TEXT,
        //     sender TEXT,
        //     source TEXT NOT NULL
        //   );
        // ''');
        await db.execute('''
          CREATE TRIGGER set_bookmark_order
          AFTER INSERT ON bookmarks
          FOR EACH ROW
          WHEN NEW.bookmark_ord IS NULL
          BEGIN
            UPDATE bookmarks SET bookmark_ord = NEW.bookmark_id WHERE bookmark_id = NEW.bookmark_id;
          END;
        ''');
      },
      version: 1,
    );
  }

  Future<bool> addBookmark(BookmarkHumor humor) async {
    final db = await database;
    try {
      int bookmarkId = await db.insert(
        'bookmarks',
        humor.humorToMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      humor.bookmarkOrd ??= bookmarkId;
      return true;
    } catch (e) {
      print('Error adding bookmark: $e');
      return false;
    }
  }

  Future<bool> removeBookmark(Humor humor) async {
    final db = await database;
    try {
      int result = await db.delete(
        'bookmarks',
        where: 'uuid = ?',
        whereArgs: [humor.uuid],
      );
      return result > 0;
    } catch (e) {
      print('Error deleting humor: $e');
      return false;
    }
  }

  Future<bool> syncBookmark(BookmarkHumor humor) async {
    final db = await database;
    try {
      Map<String, dynamic> updatedValues = humor.humorToMap();
      // Execute the update method
      int result = await db.update(
        'bookmarks',
        updatedValues,
        where: 'uuid = ?',
        whereArgs: [humor.uuid],
      );
      return result > 0;
    } catch (e) {
      print('Error deleting humor: $e');
      return false;
    }
  }

  /// Get all bookmarks
  Future<List<BookmarkHumor>> getAllBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarks',
      orderBy:
          'bookmark_ord ASC', // This orders the results by the "order" column in ascending order
    );

    return List.generate(maps.length, (i) {
      return BookmarkHumor.loadFromTable(maps[i]);
    });
  }

  Future<int> getBookmarkCount() async {
    final db = await database;
    return (await db.query('bookmarks')).length;
  }

  /// Get bookmarks by keyword
  Future<List<BookmarkHumor>> getBookmarksByKeyword(String keyword) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarks',
      where: 'context LIKE ? OR source LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'bookmark_ord ASC',
    );

    print(maps);

    return List.generate(maps.length, (i) {
      return BookmarkHumor.loadFromTable(maps[i]);
    });
  }

  Future<bool> isBookmarked(Humor humor) async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('bookmarks', where: 'uuid = ?', whereArgs: [humor.uuid]);
    print('query result: $result');
    if (result.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> clearBookmarks() async {
    final db = await database;
    await db.delete('bookmarks');
  }
}
