import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../domain/repositories/leaderboard_repository.dart';

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final repo = ref.watch(leaderboardRepositoryProvider);
  return await repo.getLocalLeaderboard();
});

final leaderboardEntriesProvider = leaderboardProvider;
