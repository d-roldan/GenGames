import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_game/core/services/app_services.dart';
import 'package:kids_game/core/storage/local_database.dart';
import 'package:kids_game/screens/home/home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });
  testWidgets('shows all three large game choices and opens drawing', (tester) async {
    final db = await LocalDatabase.open(path: inMemoryDatabasePath);
    final services = AppServices.forTesting(db);
    await tester.pumpWidget(MaterialApp(home: HomeScreen(services: services)));
    expect(find.text('Gatito'), findsOneWidget);
    expect(find.text('Dibujar'), findsOneWidget);
    expect(find.text('Animales'), findsOneWidget);
    await tester.tap(find.text('Dibujar'));
    await tester.pumpAndSettle();
    expect(find.text('🎨'), findsOneWidget);
    await db.close();
  });
}

