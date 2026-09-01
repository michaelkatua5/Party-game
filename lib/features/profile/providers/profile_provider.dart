import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../domain/models/game_stats.dart';
import '../../../domain/models/achievement.dart';
import '../../../domain/repositories/auth_repository.dart';

final profileUserProvider = FutureProvider<UserProfile>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return await authRepo.getCurrentUser();
});

final userStatsProvider = FutureProvider<GameStats>((ref) async {
  final repo = ref.watch(statsRepositoryProvider);
  return await repo.getStats();
});

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repo = ref.watch(statsRepositoryProvider);
  return await repo.getAchievements();
});
