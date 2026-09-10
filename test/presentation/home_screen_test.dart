import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheza_game/core/l10n/app_localizations.dart';
import 'package:cheza_game/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders game selection, Charades and Kings Cup cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
          ],
          home: HomeScreen(),
        ),
      ),
    );

    // Settle all flutter_animate animations
    await tester.pumpAndSettle();

    // Verify Streamlined Game Selection Elements
    expect(find.text('CHOOSE YOUR GAME'), findsOneWidget);
    expect(find.text('CHARADES'), findsOneWidget);
    expect(find.text('KINGS CUP'), findsOneWidget);
  });
}
