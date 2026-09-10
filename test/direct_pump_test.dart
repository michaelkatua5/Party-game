import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cheza_game/features/game_setup/presentation/player_setup_screen.dart';

void main() {
  testWidgets('direct pump player setup', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER ERROR CAUGHT: ${details.exceptionAsString()}');
      print(details.stack);
    };

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PlayerSetupScreen(),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    print('Rendered text widgets:');
    find.byType(Text).evaluate().forEach((element) {
      print((element.widget as Text).data);
    });
  });
}
