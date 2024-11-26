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
    try {
      return await openDatabase(
        join(await getDatabasesPath(), 'my_database.db'),
        version: 1,
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
              humor_index INTEGER NOT NULL,
              punchline TEXT NOT NULL,
              ai_analysis TEXT NOT NULL,
              author TEXT NOT NULL,
              sender TEXT NOT NULL,
              source TEXT NOT NULL,
              img_url TEXT NOT NULL
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
              ai_analysis TEXT NOT NULL,
              sender TEXT NOT NULL,
              source TEXT NOT NULL,
              uuid TEXT UNIQUE NOT NULL,
              img_url TEXT NOT NULL
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
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow; // Propagate the error for higher-level handling
    }
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
      print('Error removing bookmark: $e');
      return false;
    }
  }

  Future<bool> syncBookmark(BookmarkHumor humor) async {
    final db = await database;
    try {
      int result = await db.update(
        'bookmarks',
        humor.humorToMap(),
        where: 'uuid = ?',
        whereArgs: [humor.uuid],
      );
      return result > 0;
    } catch (e) {
      print('Error syncing bookmark: $e');
      return false;
    }
  }

  Future<List<BookmarkHumor>> getAllBookmarks() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT bookmarks.*, library.title as source_name
        FROM bookmarks
        LEFT JOIN library ON bookmarks.source = library.uuid
        ORDER BY bookmarks.bookmark_ord DESC
      ''');

      return maps.map((map) {
        return BookmarkHumor.loadFromTable({
          ...map,
          'source_name': map['source_name'] ?? map['source'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching all bookmarks: $e');
      return [];
    }
  }

  Future<int> getBookmarkCount() async {
    final db = await database;
    try {
      return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM bookmarks'),
          ) ??
          0;
    } catch (e) {
      print('Error getting bookmark count: $e');
      return 0;
    }
  }

  Future<List<BookmarkHumor>> getBookmarksByKeyword(String keyword) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT bookmarks.*, library.title as source_name
        FROM bookmarks
        LEFT JOIN library ON bookmarks.source = library.uuid
        WHERE context LIKE ? OR source_name LIKE ?
        ORDER BY bookmark_ord DESC
        ''',
        ['%$keyword%', '%$keyword%'],
      );

      return maps.map((map) {
        return BookmarkHumor.loadFromTable({
          ...map,
          'source_name': map['source_name'] ?? map['source'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching bookmarks by keyword: $e');
      return [];
    }
  }

  Future<bool> isBookmarked(Humor humor) async {
    final db = await database;
    try {
      final result = await db.query(
        'bookmarks',
        where: 'uuid = ?',
        whereArgs: [humor.uuid],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking if humor is bookmarked: $e');
      return false;
    }
  }

  Future<void> clearBookmarks() async {
    final db = await database;
    try {
      await db.delete('bookmarks');
    } catch (e) {
      print('Error clearing bookmarks: $e');
    }
  }

  Future<bool> saveBundleIntoLibrary(
      Bundle bundle, List<Humor> bundleHumors) async {
    final db = await database;
    try {
      // Add bundle into library (if exists, update it)
      await db.insert(
        'library',
        bundle.bundleToMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Use batch to optimize inserting multiple rows
      Batch batch = db.batch();

      // Remove all previous humors associated with the bundle
      batch.delete(
        'bundle_humors',
        where: 'source = ?',
        whereArgs: [bundle.uuid],
      );

      // Add all bundle humors
      for (var humor in bundleHumors) {
        batch.insert(
          'bundle_humors',
          humor.humorToMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      return true;
    } catch (e) {
      print('Error saving bundle into library: $e');
      return false;
    }
  }

  Future<List<Bundle>> getAllBundles() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.query('library', orderBy: 'bundle_id DESC');

      return maps.map((map) {
        return Bundle.fromJson({
          ...map,
          'cover_img_list': map['cover_img_list'].split('@@@'),
        });
      }).toList();
    } catch (e) {
      print('Error fetching all bundles: $e');
      return [];
    }
  }

  Future<List<Humor>> getAllBundleHumors(Bundle bundle) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'bundle_humors',
        where: 'source = ?',
        whereArgs: [bundle.uuid],
        orderBy: 'humor_index ASC',
      );

      return maps.map((map) {
        return DailyHumor.loadFromTable({
          ...map,
          'source_name': bundle.title,
        });
      }).toList();
    } catch (e) {
      print('Error fetching all bundle humors: $e');
      return [];
    }
  }
}
