import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/storage_service.dart';
import '../../../domain/models/player.dart';

final sharedPlayersProvider =
    StateNotifierProvider<SharedPlayersNotifier, List<Player>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SharedPlayersNotifier(storage);
});

class SharedPlayersNotifier extends StateNotifier<List<Player>> {
  final StorageService storage;

  static const _keyPlayers = 'saved_shared_players_list';

  SharedPlayersNotifier(this.storage) : super([]) {
    _loadPlayers();
  }

  static const List<String> _avatarOptions = [
    '🙋🏾‍♂️', '🙆🏾‍♀️', '👨🏾‍🦱', '🧑🏾', '💁🏾‍♀️', '🦁', '👑', '🔥', '⚡', '🎉',
  ];

  Future<void> _loadPlayers() async {
    final raw = storage.getStringList(_keyPlayers);
    if (raw != null && raw.isNotEmpty) {
      final loaded = raw.map((item) {
        try {
          final Map<String, dynamic> json = jsonDecode(item) as Map<String, dynamic>;
          return Player(
            id: json['id'] as String? ?? 'p_${DateTime.now().millisecondsSinceEpoch}',
            name: json['name'] as String? ?? 'Player',
            avatar: json['avatar'] as String? ?? '🧑🏾',
            totalCorrect: json['totalCorrect'] as int? ?? 0,
            totalPassed: json['totalPassed'] as int? ?? 0,
          );
        } catch (_) {
          return null;
        }
      }).whereType<Player>().toList();

      if (loaded.isNotEmpty) {
        state = loaded;
        return;
      }
    }
    // No hardcoded names: starts empty so users enter their own friend names!
    state = [];
  }

  Future<void> addPlayer(String name, {String? avatar}) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    final assignedAvatar = avatar ?? _avatarOptions[state.length % _avatarOptions.length];

    final newPlayer = Player(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}_${state.length}',
      name: cleanName,
      avatar: assignedAvatar,
    );

    state = [...state, newPlayer];
    await _savePlayers();
  }

  Future<void> editPlayer(int index, String newName, {String? newAvatar}) async {
    if (index < 0 || index >= state.length) return;
    final cleanName = newName.trim();
    if (cleanName.isEmpty) return;

    final current = state[index];
    final updated = Player(
      id: current.id,
      name: cleanName,
      avatar: newAvatar ?? current.avatar,
      totalCorrect: current.totalCorrect,
      totalPassed: current.totalPassed,
    );

    final list = List<Player>.from(state);
    list[index] = updated;
    state = list;
    await _savePlayers();
  }

  Future<void> removePlayer(int index) async {
    if (index < 0 || index >= state.length) return;
    final list = List<Player>.from(state)..removeAt(index);
    state = list;
    await _savePlayers();
  }

  Future<void> reorderPlayers(int oldIndex, int newIndex) async {
    final list = List<Player>.from(state);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final player = list.removeAt(oldIndex);
    list.insert(newIndex, player);
    state = list;
    await _savePlayers();
  }

  Future<void> _savePlayers() async {
    final encoded = state.map((p) => jsonEncode({
      'id': p.id,
      'name': p.name,
      'avatar': p.avatar,
      'totalCorrect': p.totalCorrect,
      'totalPassed': p.totalPassed,
    })).toList();

    await storage.setStringList(_keyPlayers, encoded);
  }
}
