import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cheza_game.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE word_stats (
  word_id TEXT PRIMARY KEY,
  times_shown INTEGER NOT NULL DEFAULT 0,
  times_guessed INTEGER NOT NULL DEFAULT 0,
  times_skipped INTEGER NOT NULL DEFAULT 0,
  times_failed INTEGER NOT NULL DEFAULT 0,
  total_time_to_guess_ms INTEGER NOT NULL DEFAULT 0,
  difficulty_score INTEGER NOT NULL DEFAULT 50,
  status TEXT NOT NULL DEFAULT 'active'
)
''');

    // Create indexes for efficient querying
    await db.execute('CREATE INDEX idx_word_stats_status ON word_stats(status)');
    await db.execute('CREATE INDEX idx_word_stats_score ON word_stats(difficulty_score)');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
