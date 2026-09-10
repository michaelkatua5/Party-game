import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cheza_game/main.dart' as app;

void main() {
  testWidgets('tap charades and check for black screen / errors', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER ERROR CAUGHT: ${details.exceptionAsString()}');
    };

    app.main();
    await tester.pumpAndSettle();
    
    final charadesFinder = find.text('CHARADES');
    expect(charadesFinder, findsOneWidget);
    
    await tester.tap(charadesFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    final playerSetupFinder = find.text('GAME SETUP 👥');
    if (playerSetupFinder.evaluate().isEmpty) {
      print('GAME SETUP SCREEN FAILED TO RENDER');
    } else {
      print('GAME SETUP SCREEN RENDERED SUCCESSFULLY');
    }
  });
}
