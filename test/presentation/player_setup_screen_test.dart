import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheza_game/core/l10n/app_localizations.dart';
import 'package:cheza_game/features/game_setup/presentation/player_setup_screen.dart';

void main() {
  testWidgets('PlayerSetupScreen renders navigation, difficulty selector, and dynamic inputs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
          ],
          home: PlayerSetupScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all core elements are present and visible
    expect(find.text('GAME SETUP 👥'), findsOneWidget);
    expect(find.text('🔥 TEAMS'), findsOneWidget);
    expect(find.text('🙋🏾 INDIVIDUALS'), findsOneWidget);
    expect(find.text('DIFFICULTY LEVEL'), findsOneWidget);
    expect(find.text('🎲 MIXED'), findsOneWidget);
    expect(find.text('🟢 EASY'), findsOneWidget);
    expect(find.text('+ ADD'), findsOneWidget);
    expect(find.text('CONTINUE TO CATEGORIES →'), findsOneWidget);
  });

  testWidgets('PlayerSetupScreen can add custom teams and switch modes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
          ],
          home: PlayerSetupScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap quick suggestion '+ Simba 🦁'
    await tester.tap(find.text('+ Simba 🦁'));
    await tester.pumpAndSettle();

    expect(find.text('Team Simba'), findsOneWidget);

    // Switch to Individuals
    await tester.tap(find.text('🙋🏾 INDIVIDUALS'));
    await tester.pumpAndSettle();

    expect(find.text('ADD PLAYERS'), findsOneWidget);
  });
}
