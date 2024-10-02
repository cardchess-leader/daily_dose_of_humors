import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/models/bundle.dart';

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
        await db.execute('''
          CREATE TABLE bundle_humors (
            humor_id INTEGER PRIMARY KEY,
            author TEXT NOT NULL,
            category TEXT NOT NULL,
            context TEXT NOT NULL,
            context_list TEXT NOT NULL,
            humor_index INTEGER NOT NULL,
            punchline TEXT NOT NULL,
            sender TEXT NOT NULL,
            source TEXT NOT NULL,
            uuid TEXT UNIQUE NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE library (
            bundle_id INTEGER PRIMARY KEY,
            category TEXT NOT NULL,
            cover_img_list TEXT NOT NULL,
            description TEXT NOT NULL,
            humor_count INTEGER NOT NULL,
            language_code TEXT NOT NULL,
            product_id TEXT NOT NULL,
            title TEXT NOT NULL,
            release_date TEXT NOT NULL,
            uuid TEXT UNIQUE NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TRIGGER set_bookmark_order
          AFTER INSERT ON bookmarks
          FOR EACH ROW
          WHEN NEW.bookmark_ord IS NULL
          BEGIN
            UPDATE bookmarks SET bookmark_ord = NEW.bookmark_id WHERE rowid = NEW.rowid;
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

    return List.generate(maps.length, (i) {
      return BookmarkHumor.loadFromTable(maps[i]);
    });
  }

  Future<bool> isBookmarked(Humor humor) async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('bookmarks', where: 'uuid = ?', whereArgs: [humor.uuid]);
    if (result.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> clearBookmarks() async {
    final db = await database;
    await db.delete('bookmarks');
  }

  Future<bool> saveBundleIntoLibrary(
      Bundle bundle, List<Humor> bundleHumors) async {
    try {
      final db = await database;
      // Add bundle into bundle (if exist then update)
      await db.insert(
        'library',
        bundle.bundleToMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Remove all humors with source equal to bundle
      await db.delete(
        'bundle_humors',
        where: 'source = ?',
        whereArgs: [bundle.uuid],
      );

      // Add all bundle humors
      Batch batch = db.batch();
      for (var humor in bundleHumors) {
        batch.insert(
          'bundle_humors',
          humor.humorToMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Commit the batch
      await batch.commit(noResult: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Bundle>> getAllBundles() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('library');

      print('maps is: ${maps}');

      return List.generate(maps.length, (i) {
        return Bundle.fromJson({
          ...maps[i],
          'cover_img_list': maps[i]['cover_img_list'].split('@@@')
        });
      });
    } catch (e) {
      print('error is: $e');
      return [];
    }
  }

  Future<List<Humor>> getAllBundleHumors(Bundle bundle) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'bundle_humors',
        where: 'source = ?',
        whereArgs: [bundle.uuid],
      );

      return List.generate(
          maps.length, (i) => DailyHumor.loadFromTable(maps[i]));
    } catch (e) {
      print('error is: $e');
      return [];
    }
  }
}
