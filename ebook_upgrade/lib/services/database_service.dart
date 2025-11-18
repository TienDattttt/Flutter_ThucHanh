import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final dbPath = path.join(databasePath, 'ebook_reader.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create reading_states table
    await db.execute('''
      CREATE TABLE reading_states (
        book_id TEXT PRIMARY KEY,
        current_page INTEGER NOT NULL,
        total_pages INTEGER NOT NULL,
        last_read_at TEXT NOT NULL
      )
    ''');

    // Create user_settings table
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        is_dark_mode INTEGER NOT NULL,
        font_size REAL NOT NULL
      )
    ''');

    // Create cached_books table
    await db.execute('''
      CREATE TABLE cached_books (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        description TEXT,
        cover_image_url TEXT,
        asset_path TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');

    // Insert default user settings
    await db.insert('user_settings', {
      'id': 1,
      'is_dark_mode': 0,
      'font_size': 18.0,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    // For now, we only have version 1
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // CRUD operations for reading states
  Future<void> saveReadingState(Map<String, dynamic> readingState) async {
    try {
      final db = await database;
      await db.insert(
        'reading_states',
        readingState,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to save reading state: $e');
    }
  }

  Future<Map<String, dynamic>?> getReadingState(String bookId) async {
    try {
      final db = await database;
      final results = await db.query(
        'reading_states',
        where: 'book_id = ?',
        whereArgs: [bookId],
      );
      
      if (results.isEmpty) return null;
      return results.first;
    } catch (e) {
      throw Exception('Failed to get reading state: $e');
    }
  }

  Future<void> deleteReadingState(String bookId) async {
    try {
      final db = await database;
      await db.delete(
        'reading_states',
        where: 'book_id = ?',
        whereArgs: [bookId],
      );
    } catch (e) {
      throw Exception('Failed to delete reading state: $e');
    }
  }

  // CRUD operations for user settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final db = await database;
      await db.update(
        'user_settings',
        settings,
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final db = await database;
      final results = await db.query(
        'user_settings',
        where: 'id = ?',
        whereArgs: [1],
      );
      
      if (results.isEmpty) {
        // Return default settings if not found
        return {
          'id': 1,
          'is_dark_mode': 0,
          'font_size': 18.0,
        };
      }
      return results.first;
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  // CRUD operations for cached books
  Future<void> cacheBooks(List<Map<String, dynamic>> books) async {
    try {
      final db = await database;
      final batch = db.batch();
      
      for (var book in books) {
        batch.insert(
          'cached_books',
          book,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Failed to cache books: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCachedBooks() async {
    try {
      final db = await database;
      return await db.query('cached_books');
    } catch (e) {
      throw Exception('Failed to get cached books: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final db = await database;
      await db.delete('cached_books');
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }
}
