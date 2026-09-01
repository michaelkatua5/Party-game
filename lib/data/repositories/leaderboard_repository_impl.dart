import 'dart:convert';
import '../../core/services/storage_service.dart';
import '../../domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final StorageService storage;

  LeaderboardRepositoryImpl({required this.storage});

  static const _keyLeaderboard = 'local_party_leaderboard';

  @override
  Future<List<LeaderboardEntry>> getLocalLeaderboard() async {
    final raw = storage.getStringList(_keyLeaderboard) ?? [];
    final list = raw.map((item) {
      try {
        return LeaderboardEntry.fromJson(jsonDecode(item) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<LeaderboardEntry>().toList();

    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  @override
  Future<void> addLeaderboardEntry(LeaderboardEntry entry) async {
    final current = await getLocalLeaderboard();
    current.add(entry);
    current.sort((a, b) => b.score.compareTo(a.score));
    final capped = current.take(50).toList();

    final encoded = capped.map((e) => jsonEncode(e.toJson())).toList();
    await storage.setStringList(_keyLeaderboard, encoded);
  }
}
