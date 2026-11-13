// WP2.1 Abnahme-Test (Oberfläche): Session starten → App schliessen und
// wieder öffnen → läuft weiter → beenden → wieder aufnehmen → Tageswechsel.

import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/session_logik.dart';
import 'package:trainingsapp/main.dart';
import 'package:trainingsapp/version.dart';

void main() {
  late Datenbank db;
  late int sued, geraet;

  // Datenbank ausserhalb der simulierten Test-Zeit anlegen und befüllen.
  setUpAll(() async {
    db = Datenbank(DatabaseConnection(NativeDatabase.memory(),
        closeStreamsSynchronously: true));
    await db.legeStandortAn('Nordstadt');
    sued = await db.legeStandortAn('Südstadt');
    geraet = await db.into(db.geraete).insert(GeraeteCompanion.insert(
        standortId: sued, kuerzel: 'A2', einheit: Einheit.lbs));
    final alt = await db.into(db.sessions).insert(SessionsCompanion.insert(
        datum: '2026-11-10',
        standortId: sued,
        koerpergewichtKg: const Value(80)));
    await _satz(db, alt, geraet);
  });
  tearDownAll(() => db.close());

  test('Versionsnummer stimmt mit pubspec.yaml überein', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('\nversion: $appVersion+'));
  });

  testWidgets('Session starten, fortsetzen, beenden, wieder aufnehmen',
      (tester) async {
    Future<void> warte() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    DateTime heute() => DateTime(2026, 11, 13, 18, 30);
    DateTime morgen() => DateTime(2026, 11, 14, 7, 0);

    await tester.pumpWidget(TrainingsApp(db: db, jetzt: heute));
    await warte();
    expect(find.text('Version $appVersion'), findsOneWidget);

    // Start-Bildschirm: Datum heute, letzter Standort und Körpergewicht vorbelegt
    await tester.tap(find.text('Session starten'));
    await warte();
    expect(find.text('Heute, 13.11.2026'), findsOneWidget);
    expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Südstadt'))
            .selected,
        isTrue);
    expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Körpergewicht (kg)'))
            .controller!
            .text,
        '80');

    await tester.tap(find.text('Starten'));
    await warte();
    expect(find.text('Südstadt · 13.11.2026'), findsOneWidget);
    expect(find.textContaining('Noch keine Sätze'), findsOneWidget);

    // App ganz schliessen und wieder öffnen → laufende Session öffnet sich
    await tester.pumpWidget(const SizedBox());
    await warte();
    await tester.pumpWidget(TrainingsApp(db: db, jetzt: heute));
    await warte();
    expect(find.text('Südstadt · 13.11.2026'), findsOneWidget);

    // Ein Satz (Erfassung folgt in WP2.2) – direkt in die Datenbank
    final laufend = (await tester.runAsync(db.laufendeSession))!;
    await tester.runAsync(() => _satz(db, laufend.session.id, geraet));
    await warte();
    expect(find.textContaining('Heute · 1 Sätze'), findsOneWidget);

    // Beenden → Startseite mit Hinweis und „Wieder aufnehmen“
    await tester.tap(find.text('Session beenden'));
    await warte();
    expect(find.text('Session beendet.'), findsOneWidget);
    expect(find.text('Session starten'), findsOneWidget);
    await tester.tap(find.text('Wieder aufnehmen'));
    await warte();
    expect(find.text('Südstadt · 13.11.2026'), findsOneWidget);

    // Tageswechsel: am nächsten Morgen ist die Session automatisch beendet
    await tester.pumpWidget(const SizedBox());
    await warte();
    await tester.pumpWidget(TrainingsApp(db: db, jetzt: morgen));
    await warte();
    expect(find.text('Session starten'), findsOneWidget);
    expect(find.text('Laufende Session'), findsNothing);
    final s = await tester.runAsync(() => (db.select(db.sessions)
          ..where((x) => x.id.equals(laufend.session.id)))
        .getSingle());
    expect(s!.abgeschlossen, isTrue);
    expect(s.datum, '2026-11-13');

    // Seite verlassen, damit keine Abfrage offen bleibt
    await tester.pumpWidget(const SizedBox());
    await warte();
  }, timeout: const Timeout(Duration(seconds: 60)));
}

Future<void> _satz(Datenbank db, int sessionId, int geraetId) =>
    db.into(db.saetze).insert(SaetzeCompanion.insert(
        sessionId: sessionId,
        geraetId: geraetId,
        satzNr: 1,
        wiederholungen: 15,
        eingabewert: 100,
        eingabeeinheit: Einheit.lbs,
        gewichtKg: inKg(100, Einheit.lbs)));
