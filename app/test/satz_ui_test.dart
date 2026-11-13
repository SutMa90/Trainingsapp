// WP2.2 Abnahme-Test (Oberfläche): Gerätekachel → vorbefüllt → speichern
// (2 Taps), nächster Satz (1 Tap), kg/lbs-Schalter, links/rechts,
// assistiertes Gerät ohne Körpergewicht.

import 'package:drift/drift.dart'
    show BooleanExpressionOperators, DatabaseConnection, OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/session_logik.dart';
import 'package:trainingsapp/main.dart';

void main() {
  late Datenbank db;
  late int sued, a2, c3, t1, session;

  setUpAll(() async {
    db = Datenbank(DatabaseConnection(NativeDatabase.memory(),
        closeStreamsSynchronously: true));
    sued = await db.legeStandortAn('Südstadt');
    Future<int> geraet(String k, Einheit e, String f,
            {bool assistiert = false, bool lr = false}) =>
        db.into(db.geraete).insert(GeraeteCompanion.insert(
            standortId: sued,
            kuerzel: k,
            funktion: Value(f),
            einheit: e,
            assistiert: Value(assistiert),
            linksRechtsGetrennt: Value(lr)));
    a2 = await geraet('A2', Einheit.lbs, 'Leg Press');
    c3 = await geraet('C3', Einheit.lbs, 'Cable Row', lr: true);
    t1 = await geraet('T1', Einheit.kg, 'Klimmzug', assistiert: true);
    // Letzte Session: A2 15 × 200 lbs
    final alt = await db.into(db.sessions).insert(
        SessionsCompanion.insert(datum: '2026-11-10', standortId: sued));
    await db.into(db.saetze).insert(SaetzeCompanion.insert(
        sessionId: alt,
        geraetId: a2,
        satzNr: 1,
        wiederholungen: 15,
        eingabewert: 200,
        eingabeeinheit: Einheit.lbs,
        gewichtKg: inKg(200, Einheit.lbs)));
    // Laufende Session ohne Körpergewicht
    session = await db.starteSession(standortId: sued, heute: '2026-11-13');
  });
  tearDownAll(() => db.close());

  testWidgets('Satz erfassen mit Vorbefüllung', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    Future<void> warte() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    Future<List<Satz>> saetzeVon(int geraet) async =>
        (await tester.runAsync(() => (db.select(db.saetze)
              ..where((s) => s.sessionId.equals(session) & s.geraetId.equals(geraet))
              ..orderBy([(s) => OrderingTerm.asc(s.id)]))
            .get()))!;

    Future<void> tippe(Finder f) async {
      await tester.ensureVisible(f);
      await tester.tap(f);
      await warte();
    }

    String feld(String label) => tester
        .widget<TextField>(find.widgetWithText(TextField, label))
        .controller!
        .text;

    Future<void> schliesseFenster() async {
      await tester.tapAt(const Offset(20, 20));
      await warte();
    }

    await tester.pumpWidget(
        TrainingsApp(db: db, jetzt: () => DateTime(2026, 11, 13, 18)));
    await warte();
    // Laufende Session öffnet sich direkt, Kacheln sortiert
    expect(find.text('Südstadt · 13.11.2026'), findsOneWidget);
    expect(find.text('Noch keine Sätze – Gerät antippen.'), findsOneWidget);

    // Tap 1: Kachel → vorbefüllt mit dem letzten Mal, Einheit des Geräts
    await tippe(find.text('A2'));
    expect(find.text('A2 · Leg Press'), findsOneWidget);
    expect(find.text('Satz 1'), findsOneWidget);
    expect(feld('Wdh'), '15');
    expect(feld('Gewicht'), '200');
    expect(find.textContaining('= 90,72 kg, 200 lbs'), findsOneWidget);

    // Tap 2: speichern
    await tippe(find.text('Satz speichern'));
    expect(find.text('✓ Satz 1 gespeichert'), findsOneWidget);
    expect(find.text('Satz 2'), findsOneWidget);
    var a2Saetze = await saetzeVon(a2);
    expect(a2Saetze.single.eingabewert, 200);
    expect(a2Saetze.single.eingabeeinheit, Einheit.lbs);

    // Nächster Satz: 1 Tap; geänderte Wdh
    await tester.enterText(find.widgetWithText(TextField, 'Wdh'), '12');
    await tippe(find.text('Satz speichern'));
    expect(find.text('✓ Satz 2 gespeichert'), findsOneWidget);

    // kg/lbs-Schalter: Wert wird umgerechnet, Einheit wird neue Vorgabe
    await tippe(find.text('kg'));
    expect(feld('Gewicht'), '90,7');
    expect(find.textContaining('wird neue Vorgabe des Geräts'), findsOneWidget);
    await tippe(find.text('Satz speichern'));
    a2Saetze = await saetzeVon(a2);
    expect(a2Saetze.map((s) => (s.satzNr, s.wiederholungen, s.eingabewert)),
        [(1, 15, 200.0), (2, 12, 200.0), (3, 12, 90.7)]);
    expect(a2Saetze.last.eingabeeinheit, Einheit.kg);
    final a2Neu = await tester.runAsync(() =>
        (db.select(db.geraete)..where((g) => g.id.equals(a2))).getSingle());
    expect(a2Neu!.einheit, Einheit.kg);
    await schliesseFenster();
    expect(find.text('3 ✓'), findsOneWidget);
    expect(find.text('Heute · 3 Sätze'), findsOneWidget);

    // Links/rechts: nach L wird R vorgeschlagen, Satz-Nr. pro Seite
    await tippe(find.text('C3'));
    expect(feld('Wdh'), '');
    await tester.enterText(find.widgetWithText(TextField, 'Wdh'), '10');
    await tester.enterText(find.widgetWithText(TextField, 'Gewicht'), '40');
    await warte();
    await tippe(find.text('Satz speichern'));
    expect(find.text('✓ Satz 1 L gespeichert'), findsOneWidget);
    // R vorgeschlagen; rechts noch kein Wert → letzter Wert links
    expect(find.text('Satz 1'), findsOneWidget);
    expect(feld('Gewicht'), '40');
    await tester.enterText(find.widgetWithText(TextField, 'Gewicht'), '42,5');
    await warte();
    await tippe(find.text('Satz speichern'));
    expect(find.text('✓ Satz 1 R gespeichert'), findsOneWidget);
    expect(feld('Gewicht'), '40'); // wieder L: letzter Wert links
    final c3Saetze = await saetzeVon(c3);
    expect(c3Saetze.map((s) => (s.seite, s.satzNr, s.eingabewert)),
        [(Seite.L, 1, 40.0), (Seite.R, 1, 42.5)]);
    await schliesseFenster();

    // Assistiert ohne Körpergewicht: Nachfrage, dann gespeichert
    await tippe(find.text('T1'));
    expect(find.text('Satz 1 · assistiert'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Wdh'), '8');
    await tester.enterText(find.widgetWithText(TextField, 'Unterstützung'), '30');
    await warte();
    await tippe(find.text('Satz speichern'));
    expect(find.text('Körpergewicht'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Körpergewicht heute (kg)'), '80');
    await tippe(find.text('Übernehmen'));
    await warte();
    expect(find.text('✓ Satz 1 gespeichert'), findsOneWidget);
    final t1Satz = (await saetzeVon(t1)).single;
    expect(t1Satz.gewichtKg, 50);
    await schliesseFenster();

    await tester.pumpWidget(const SizedBox());
    await warte();
  }, timeout: const Timeout(Duration(seconds: 90)));
}
