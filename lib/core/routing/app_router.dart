import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/game_setup/presentation/game_mode_selection_screen.dart';
import '../../features/game_setup/presentation/player_setup_screen.dart';
import '../../features/game_setup/presentation/custom_game_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/game/presentation/charades_calibration_screen.dart';
import '../../features/game/presentation/game_screen.dart';
import '../../features/kings_cup/presentation/kings_cup_board_screen.dart';
import '../../features/kings_cup/presentation/kings_cup_final_king_screen.dart';
import '../../features/results/presentation/results_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/practice/presentation/practice_screen.dart';
import '../../features/how_to_play/presentation/how_to_play_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (context, state) => const MaterialPage(child: SplashScreen()),
    ),
    GoRoute(
      path: '/',
      redirect: (_, __) => '/home',
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => const MaterialPage(child: HomeScreen()),
    ),
    GoRoute(
      path: '/choose-game',
      name: 'choose_game',
      pageBuilder: (context, state) => const MaterialPage(child: GameModeSelectionScreen()),
    ),
    GoRoute(
      path: '/game-modes',
      name: 'game_modes',
      pageBuilder: (context, state) => const MaterialPage(child: GameModeSelectionScreen()),
    ),
    GoRoute(
      path: '/player-setup',
      name: 'player_setup',
      pageBuilder: (context, state) => const MaterialPage(child: PlayerSetupScreen()),
    ),
    GoRoute(
      path: '/charades-calibration',
      name: 'charades_calibration',
      pageBuilder: (context, state) => const MaterialPage(child: CharadesCalibrationScreen()),
    ),
    GoRoute(
      path: '/category-select',
      name: 'category_select',
      pageBuilder: (context, state) => const MaterialPage(child: CategoriesScreen()),
    ),
    GoRoute(
      path: '/custom-game',
      name: 'custom_game',
      pageBuilder: (context, state) => const MaterialPage(child: CustomGameScreen()),
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      pageBuilder: (context, state) => const MaterialPage(child: CategoriesScreen()),
    ),
    GoRoute(
      path: '/game',
      name: 'game',
      pageBuilder: (context, state) => const MaterialPage(child: GameScreen()),
    ),
    GoRoute(
      path: '/kings-cup',
      name: 'kings_cup',
      pageBuilder: (context, state) => const MaterialPage(child: KingsCupBoardScreen()),
    ),
    GoRoute(
      path: '/kings-cup/final-king',
      name: 'kings_cup_final_king',
      pageBuilder: (context, state) => const MaterialPage(child: KingsCupFinalKingScreen()),
    ),
    GoRoute(
      path: '/results',
      name: 'results',
      pageBuilder: (context, state) => const MaterialPage(child: ResultsScreen()),
    ),
    GoRoute(
      path: '/leaderboard',
      name: 'leaderboard',
      pageBuilder: (context, state) => const MaterialPage(child: LeaderboardScreen()),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => const MaterialPage(child: ProfileScreen()),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => const MaterialPage(child: SettingsScreen()),
    ),
    GoRoute(
      path: '/practice',
      name: 'practice',
      pageBuilder: (context, state) => const MaterialPage(child: PracticeScreen()),
    ),
    GoRoute(
      path: '/how-to-play',
      name: 'how_to_play',
      pageBuilder: (context, state) => const MaterialPage(child: HowToPlayScreen()),
    ),
  ],
);
