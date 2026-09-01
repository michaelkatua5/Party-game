import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheza_game/core/l10n/app_localizations.dart';
import 'package:cheza_game/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders CHARADES and KINGS CUP hero cards and quick actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify 2-in-1 Platform Elements matching Blueprint Screen 2
    expect(find.text('READY TO PLAY?'), findsOneWidget);
    expect(find.text('CHARADES'), findsOneWidget);
    expect(find.text('KINGS CUP'), findsOneWidget);
    expect(find.text('PLAYERS'), findsOneWidget);
    expect(find.text('CATEGORIES'), findsOneWidget);
    expect(find.text('ACHIEVEMENTS'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
  });
}
