import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/word_stats.dart';
import '../database/app_database.dart';

final wordStatsRepositoryProvider = Provider<WordStatsRepository>((ref) {
  return WordStatsRepository(AppDatabase.instance);
});

class WordStatsRepository {
  final AppDatabase _appDatabase;

  WordStatsRepository(this._appDatabase);

  Future<WordStats> getStatsForWord(String wordId) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      'word_stats',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );

    if (maps.isNotEmpty) {
      return WordStats.fromJson(maps.first);
    } else {
      return WordStats(wordId: wordId);
    }
  }

  Future<List<WordStats>> getAllStats() async {
    final db = await _appDatabase.database;
    final maps = await db.query('word_stats');
    return maps.map((map) => WordStats.fromJson(map)).toList();
  }

  Future<void> saveStats(WordStats stats) async {
    final db = await _appDatabase.database;
    await db.insert(
      'word_stats',
      stats.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveBatchStats(List<WordStats> statsList) async {
    final db = await _appDatabase.database;
    await db.transaction((txn) async {
      for (final stats in statsList) {
        await txn.insert(
          'word_stats',
          stats.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> resetAllStats() async {
    final db = await _appDatabase.database;
    await db.delete('word_stats');
  }
}
