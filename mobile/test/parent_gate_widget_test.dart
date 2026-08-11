import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_game/screens/parent/parent_gate.dart';

void main() {
  testWidgets('parent area requires a long press and adult challenge',
      (tester) async {
    var authorized = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ParentGateButton(onAuthorized: () => authorized = true))));

    await tester.longPress(find.byIcon(Icons.lock_outline));
    await tester.pumpAndSettle();
    expect(find.text('Área para adultos'), findsOneWidget);
    expect(find.text('¿Cuánto es 3 + 4?'), findsOneWidget);

    await tester.tap(find.text('6'));
    await tester.pumpAndSettle();
    expect(find.text('Área para adultos'), findsNothing);
    expect(authorized, isFalse);
  });
}
