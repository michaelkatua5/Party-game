import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheza_game/core/l10n/app_localizations.dart';
import 'package:cheza_game/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders sound, haptic, and mode toggles', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify sections and toggles are visible
    expect(find.text('Sound Effects'), findsOneWidget);
    expect(find.text('Haptic Vibration'), findsOneWidget);
    expect(find.text('Family Friendly Mode'), findsOneWidget);
  });
}
