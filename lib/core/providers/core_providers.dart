import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import '../../data/datasources/local_word_datasource.dart';
import '../../data/repositories/word_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/stats_repository_impl.dart';
import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/word_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/stats_repository.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../domain/repositories/auth_repository.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return SharedPrefsStorageService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return SystemAudioService();
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  return SystemHapticService();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return LocalAnalyticsService();
});

final localWordDatasourceProvider = Provider<LocalWordDatasource>((ref) {
  return LocalWordDatasource();
});

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final ds = ref.watch(localWordDatasourceProvider);
  return WordRepositoryImpl(datasource: ds);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final ds = ref.watch(localWordDatasourceProvider);
  return CategoryRepositoryImpl(datasource: ds);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsRepositoryImpl(storage: storage);
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return StatsRepositoryImpl(storage: storage);
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LeaderboardRepositoryImpl(storage: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(storage: storage);
});
