// WP2.4 Abnahme-Test (Oberfläche): Satz antippen → ändern, Satz löschen
// (Neunummerierung), Session löschen; importierte Session geschützt,
// App-Version bzw. „imp“ sichtbar.

import 'package:drift/drift.dart'
    show BooleanExpressionOperators, DatabaseConnection, OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/satz_logik.dart';
import 'package:trainingsapp/data/db/session_logik.dart';
import 'package:trainingsapp/main.dart';
import 'package:trainingsapp/version.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;

  late Datenbank db;
  late int sued, a2, session;

  setUpAll(() async {
    db = Datenbank(DatabaseConnection(NativeDatabase.memory(),
        closeStreamsSynchronously: true));
    sued = await db.legeStandortAn('Südstadt');
    a2 = await db.into(db.geraete).insert(GeraeteCompanion.insert(
        standortId: sued,
        kuerzel: 'A2',
        funktion: const Value('Leg Press'),
        einheit: Einheit.kg));
    // Importierte Session (ohne App-Version)
    final imp = await db.into(db.sessions).insert(
        SessionsCompanion.insert(datum: '2026-11-10', standortId: sued));
    await db.into(db.saetze).insert(SaetzeCompanion.insert(
        sessionId: imp,
        geraetId: a2,
        satzNr: 1,
        wiederholungen: 15,
        eingabewert: 80,
        eingabeeinheit: Einheit.kg,
        gewichtKg: 80));
    // Laufende App-Session mit 3 Sätzen
    session = await db.starteSession(standortId: sued, heute: '2026-11-14');
    for (final kg in [80.0, 85.0, 90.0]) {
      await db.speichereSatz(
          sessionId: session,
          geraetId: a2,
          wiederholungen: 15,
          eingabewert: kg,
          einheit: Einheit.kg);
    }
  });
  tearDownAll(() => db.close());

  testWidgets('Korrigieren, Löschen, Session löschen', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(bottom: 144);
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    addTearDown(tester.view.reset);

    Future<void> warte() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    Future<void> tippe(Finder f) async {
      await tester.ensureVisible(f);
      await tester.tap(f);
      await warte();
    }

    Future<List<Satz>> heute() async =>
        (await tester.runAsync(() => (db.select(db.saetze)
              ..where((s) => s.sessionId.equals(session) & s.geraetId.equals(a2))
              ..orderBy([(s) => OrderingTerm.asc(s.id)]))
            .get()))!;

    await tester.pumpWidget(
        TrainingsApp(db: db, jetzt: () => DateTime(2026, 11, 14, 18)));
    await warte();
    expect(find.text('Südstadt · 14.11.2026'), findsOneWidget);

    // Satz 2 antippen → Gewicht ändern
    await tippe(find.text('A2 · Satz 2'));
    expect(find.text('A2 · Satz 2 bearbeiten'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Gewicht'), '87,5');
    await warte();
    await tippe(find.text('Änderung speichern'));
    expect((await heute()).map((s) => s.eingabewert), [80.0, 87.5, 90.0]);
    expect(find.text('15 × 87,5 kg'), findsOneWidget);

    // Satz 1 löschen → übrige Sätze neu nummeriert
    await tippe(find.text('A2 · Satz 1'));
    await tippe(find.text('Satz löschen'));
    expect(find.text('Satz löschen?'), findsOneWidget);
    await tippe(find.text('Löschen'));
    expect((await heute()).map((s) => (s.satzNr, s.eingabewert)),
        [(1, 87.5), (2, 90.0)]);
    expect(find.text('A2 · Satz 3'), findsNothing);

    // Session löschen über das Menü
    await tippe(find.byTooltip('Menü'));
    await tippe(find.text('Session löschen'));
    expect(find.textContaining('Endgültig löschen?'), findsOneWidget);
    await tippe(find.text('Endgültig löschen'));
    expect(find.text('Session gelöscht.'), findsOneWidget);
    expect(find.text('Session starten'), findsOneWidget);
    final reste = await tester.runAsync(() => db.select(db.sessions).get());
    expect(reste!.map((s) => s.appVersion), [null]);
    expect(await heute(), isEmpty);

    // Importierte Session: „imp“, kein Menü zum Löschen, nicht korrigierbar
    expect(find.text('Südstadt · imp'), findsOneWidget);
    await tippe(find.text('10.11.2026'));
    expect(find.textContaining('App imp'), findsOneWidget);
    expect(find.byTooltip('Menü'), findsNothing);
    expect(find.textContaining('zum Korrigieren'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await warte();
  }, timeout: const Timeout(Duration(seconds: 90)));

  test('Neue Session in der Liste zeigt die App-Version', () async {
    final id = await db.starteSession(standortId: sued, heute: '2026-11-15');
    final s = await (db.select(db.sessions)..where((x) => x.id.equals(id)))
        .getSingle();
    expect(s.appVersion, appVersion);
  });
}
