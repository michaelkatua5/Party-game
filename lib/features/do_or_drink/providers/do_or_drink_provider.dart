import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/player.dart';
import '../data/do_or_drink_prompts.dart';
import '../domain/models/do_or_drink_session.dart';

class DoOrDrinkController extends StateNotifier<DoOrDrinkSession?> {
  DoOrDrinkController() : super(null);

  late List<String> _remainingPrompts;

  void startNewGame({required List<Player> players, required String mode}) {
    List<String> promptSource;
    if (mode == 'spicy') {
      promptSource = List.from(doOrDrinkSpicy);
    } else if (mode == 'mild') {
      promptSource = List.from(doOrDrinkMild);
    } else {
      promptSource = List.from(doOrDrinkFriendly);
    }

    promptSource.shuffle();
    _remainingPrompts = promptSource;

    state = DoOrDrinkSession(
      players: players,
      mode: mode,
      currentPlayerIndex: 0,
      currentPrompt: null,
    );
  }

  void drawCard() {
    if (state == null) return;
    
    if (_remainingPrompts.isEmpty) {
      // Reshuffle if out of prompts
      if (state!.mode == 'spicy') {
        _remainingPrompts = List.from(doOrDrinkSpicy)..shuffle();
      } else if (state!.mode == 'mild') {
        _remainingPrompts = List.from(doOrDrinkMild)..shuffle();
      } else {
        _remainingPrompts = List.from(doOrDrinkFriendly)..shuffle();
      }
    }

    final prompt = _remainingPrompts.removeLast();

    state = state!.copyWith(
      currentPrompt: prompt,
    );
  }

  void nextTurn() {
    if (state == null) return;

    int nextIndex = state!.currentPlayerIndex + 1;
    if (nextIndex >= state!.players.length) {
      nextIndex = 0;
    }

    state = state!.copyWith(
      currentPlayerIndex: nextIndex,
      currentPrompt: null,
    );
  }
}

final doOrDrinkControllerProvider = StateNotifierProvider<DoOrDrinkController, DoOrDrinkSession?>((ref) {
  return DoOrDrinkController();
});
