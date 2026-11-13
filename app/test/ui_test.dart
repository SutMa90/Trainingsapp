// WP1.5: Session-Liste und Satz-Detailansicht mit den synthetischen Testdaten.

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/main.dart';
import 'package:trainingsapp/ui/format.dart';

import '../tool/import_excel/importer.dart';
import '../tool/import_excel/xlsx_leser.dart';

void main() {
  late Datenbank db;

  // Datenbank ausserhalb der simulierten Test-Zeit anlegen und befüllen.
  setUpAll(() async {
    db = Datenbank(DatabaseConnection(NativeDatabase.memory(),
        closeStreamsSynchronously: true));
    await importiere(
      mappe: XlsxMappe.lies('../testdaten/Testlog.xlsx'),
      entscheidungen: Entscheidungen.ausDatei('../testdaten/entscheidungen.json'),
      db: db,
    );
  });
  tearDownAll(() => db.close());

  test('Anzeigeformate', () {
    expect(formatDatum('2025-03-06'), '06.03.2025');
    expect(formatZahl(90.72), '90,72');
    expect(formatZahl(35), '35');
    expect(formatZahl(32.5), '32,5');
    expect(formatZahl(99.79000000000001), '99,79');
  });

  testWidgets('Session-Liste und Detailansicht', (tester) async {
    // drift-Abfragen laufen echt asynchron: abwechselnd echte Zeit und Frames.
    Future<void> warte() async {
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    await tester.pumpWidget(TrainingsApp(db: db));
    await warte();

    // Liste: 6 Sessions, neueste oben
    expect(find.text('02.04.2025'), findsOneWidget);
    expect(find.text('03.03.2025'), findsOneWidget);
    expect(find.text('12 Sätze'), findsOneWidget);
    expect(find.text('6 Sessions · 48 Sätze'), findsOneWidget);

    // Antippen → Sätze der Session vom 06.03.2025
    await tester.tap(find.text('06.03.2025'));
    await warte();

    expect(find.text('06.03.2025 · Südstadt'), findsOneWidget);
    expect(find.text('A2 · Satz 1'), findsOneWidget);
    expect(find.text('15 × 200 lbs'), findsNWidgets(2));
    expect(find.text('90,72 kg, 200 lbs'), findsNWidgets(2));
    expect(find.text('X4 · Satz 1'), findsOneWidget);
    expect(find.text('15 × 30 kg'), findsOneWidget);

    // Seite verlassen, damit keine Abfrage offen bleibt
    await tester.pumpWidget(const SizedBox());
    await warte();
  }, timeout: const Timeout(Duration(seconds: 60)));
}
