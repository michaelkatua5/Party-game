import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../domain/models/kings_card.dart';
import '../../../domain/models/kings_cup_session.dart';
import '../../../domain/models/player.dart';
import '../../players/providers/player_provider.dart';

final kingsCupControllerProvider =
    StateNotifierProvider<KingsCupControllerNotifier, KingsCupSession?>((ref) {
  return KingsCupControllerNotifier(ref);
});

class KingsCupControllerNotifier extends StateNotifier<KingsCupSession?> {
  final Ref ref;

  KingsCupControllerNotifier(this.ref) : super(null);

  AudioService get _audio => ref.read(audioServiceProvider);
  HapticService get _haptic => ref.read(hapticServiceProvider);

  void startNewGame({List<Player>? players, bool isFamilyMode = false}) {
    final fullDeck = KingsCard.generateStandard52Deck()..shuffle(Random());

    final sharedPlayers = ref.read(sharedPlayersProvider);
    final gamePlayers = (players != null && players.isNotEmpty)
        ? players
        : (sharedPlayers.isNotEmpty
            ? sharedPlayers
            : const [
                Player(id: 'p1', name: 'Player 1', avatar: '🙋🏾‍♂️'),
                Player(id: 'p2', name: 'Player 2', avatar: '🙆🏾‍♀️'),
              ]);

    state = KingsCupSession(
      id: const Uuid().v4(),
      deck: fullDeck,
      players: gamePlayers,
      isFamilyMode: isFamilyMode,
      activeRules: const [], // Fresh game starts with no active rules
    );
  }

  KingsCard? drawCard() {
    if (state == null || state!.deck.isEmpty) return null;

    _audio.play(GameSound.buttonTap);
    _haptic.trigger(HapticType.medium);

    final deck = List<KingsCard>.from(state!.deck);
    final drawnCard = deck.removeLast();

    final isFinal = (state!.kingsDrawnCount + (drawnCard.isKing ? 1 : 0)) >= 4;

    if (drawnCard.isKing) {
      _audio.play(isFinal ? GameSound.victoryFanfare : GameSound.correct);
      _haptic.trigger(HapticType.heavy);
    }

    state = state!.copyWith(
      deck: deck,
      currentRevealedCard: drawnCard,
      isGameOver: isFinal,
    );

    return drawnCard;
  }

  void addCustomRule(String ruleText) {
    if (state == null || ruleText.trim().isEmpty) return;

    final updatedRules = List<String>.from(state!.activeRules)..add(ruleText.trim());
    state = state!.copyWith(activeRules: updatedRules);
  }

  void removeActiveRule(String ruleText) {
    if (state == null) return;
    final updatedRules = List<String>.from(state!.activeRules)..remove(ruleText);
    state = state!.copyWith(activeRules: updatedRules);
  }

  void removeCustomRule(int index) {
    if (state == null || index < 0 || index >= state!.activeRules.length) return;

    final updatedRules = List<String>.from(state!.activeRules)..removeAt(index);
    state = state!.copyWith(activeRules: updatedRules);
  }

  void nextPlayer() {
    if (state == null) return;

    final revealed = state!.currentRevealedCard;
    final updatedStack = List<KingsCard>.from(state!.drawnStack);
    if (revealed != null) {
      updatedStack.add(revealed);
    }

    state = state!.copyWith(
      drawnStack: updatedStack,
      clearCurrentRevealedCard: true,
      currentPlayerIndex: state!.currentPlayerIndex + 1,
    );
  }

  void linkMate({required String playerAId, required String playerBId}) {
    if (state == null) return;

    final updatedMap = Map<String, String>.from(state!.matesMap);
    updatedMap[playerAId] = playerBId;
    updatedMap[playerBId] = playerAId;

    state = state!.copyWith(matesMap: updatedMap);
  }

  void resetGame() {
    state = null;
  }
}
