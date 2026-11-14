// WP2.5 Abnahme-Test (Oberfläche): „＋ Neu“ in der laufenden Session →
// Kurzformular mit Vorschlägen Hersteller/Modell → sofort Kachel und erster
// Satz; langer Druck = Gerät bearbeiten (Kürzel gesperrt bei Sätzen);
// Geräteverwaltung über das Menü der Startseite, Gerät ohne Sätze löschen.

import 'package:drift/drift.dart'
    show BooleanExpressionOperators, DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/session_logik.dart';
import 'package:trainingsapp/main.dart';

void main() {
  // Ein Tipp, der sein Ziel verfehlt (z. B. verdeckt), lässt den Test scheitern.
  WidgetController.hitTestWarningShouldBeFatal = true;

  late Datenbank db;
  late int sued, nord, a2, b1;

  setUpAll(() async {
    db = Datenbank(DatabaseConnection(NativeDatabase.memory(),
        closeStreamsSynchronously: true));
    sued = await db.legeStandortAn('Südstadt');
    nord = await db.legeStandortAn('Nordstadt');
    a2 = await db.into(db.geraete).insert(GeraeteCompanion.insert(
        standortId: sued,
        kuerzel: 'A2',
        funktion: const Value('Leg Press'),
        hersteller: const Value('Technogym'),
        modell: const Value('Selection 900'),
        einheit: Einheit.kg));
    b1 = await db.into(db.geraete).insert(GeraeteCompanion.insert(
        standortId: sued,
        kuerzel: 'B1',
        hersteller: const Value('Cybex'),
        modell: const Value('Eagle'),
        einheit: Einheit.kg));
    await db.into(db.geraete).insert(GeraeteCompanion.insert(
        standortId: nord,
        kuerzel: 'N1',
        funktion: const Value('Rudern'),
        einheit: Einheit.kg));
    final alt = await db.into(db.sessions).insert(
        SessionsCompanion.insert(datum: '2026-11-10', standortId: sued));
    await db.into(db.saetze).insert(SaetzeCompanion.insert(
        sessionId: alt,
        geraetId: a2,
        satzNr: 1,
        wiederholungen: 15,
        eingabewert: 80,
        eingabeeinheit: Einheit.kg,
        gewichtKg: 80));
    await db.starteSession(standortId: sued, heute: '2026-11-14');
  });
  tearDownAll(() => db.close());

  testWidgets('Neues Gerät, bearbeiten, Geräteverwaltung', (tester) async {
    // Handy wie beim Nutzer: 1080 × 2340 Pixel (360 × 780), Android-Tasten
    // unten (48), Schrift 130 %.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(bottom: 144);
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    Future<void> warte() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    Future<void> tippe(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pump();
      await tester.tap(f);
      await warte();
    }

    Future<void> schreibe(String label, String text) async {
      final f = find.widgetWithText(TextField, label);
      await tester.ensureVisible(f);
      await tester.enterText(f, text);
      await warte();
    }

    void knopfFrei(String beschriftung) {
      final knopf = find
          .ancestor(
              of: find.text(beschriftung),
              matching: find.byWidgetPredicate((w) => w is ButtonStyleButton))
          .first;
      expect(tester.getRect(knopf).bottom, lessThanOrEqualTo(780 - 48),
          reason: '$beschriftung darf nicht unter den Android-Tasten liegen');
    }

    Future<Geraet?> geraet(int ort, String kuerzel) async =>
        (await tester.runAsync<Geraet?>(() => (db.select(db.geraete)
              ..where((g) => g.standortId.equals(ort) & g.kuerzel.equals(kuerzel)))
            .getSingleOrNull()));

    await tester.pumpWidget(
        TrainingsApp(db: db, jetzt: () => DateTime(2026, 11, 14, 18)));
    await warte();
    expect(find.text('Südstadt · 14.11.2026'), findsOneWidget);

    // ── „＋ Neu“ → Kurzformular ──
    await tippe(find.text('Neu'));
    expect(find.text('Neues Gerät'), findsOneWidget);
    expect(find.text('Standort: Südstadt'), findsOneWidget);
    knopfFrei('Gerät speichern');

    // Kürzel schon vergeben → Hinweis, nichts gespeichert
    await schreibe('Kürzel', 'a2');
    await tippe(find.text('Gerät speichern'));
    expect(find.text('A2 gibt es hier schon'), findsOneWidget);

    await schreibe('Kürzel', 'x9');
    await schreibe('Funktion (z. B. Leg Press)', 'Butterfly');
    await tippe(find.widgetWithText(ChoiceChip, 'Brust'));

    // Vorschläge: Hersteller von allen Geräten, Modell nur zum Hersteller
    await tippe(find.text('Mehr: Hersteller, Modell, Einstellungen, Notiz'));
    await tippe(find.widgetWithText(TextField, 'Hersteller'));
    expect(find.widgetWithText(ListTile, 'Cybex'), findsOneWidget);
    await tippe(find.widgetWithText(ListTile, 'Technogym'));
    await tippe(find.widgetWithText(TextField, 'Modell'));
    expect(find.widgetWithText(ListTile, 'Eagle'), findsNothing);
    await tippe(find.widgetWithText(ListTile, 'Selection 900'));

    knopfFrei('Gerät speichern');
    await tippe(find.text('Gerät speichern'));

    // Sofort erster Satz am neuen Gerät; danach Kachel da
    expect(find.text('X9 · Butterfly'), findsOneWidget);
    await tippe(find.byTooltip('Schliessen'));
    expect(find.text('X9'), findsOneWidget);
    final x9 = (await geraet(sued, 'X9'))!;
    expect(x9.funktion, 'Butterfly');
    expect(x9.hersteller, 'Technogym');
    expect(x9.modell, 'Selection 900');
    expect(x9.einheit, Einheit.kg);
    final muskel = (await tester.runAsync(() => (db.select(db.muskelgruppen)
          ..where((m) => m.id.equals(x9.muskelgruppeId!)))
        .getSingle()))!;
    expect(muskel.name, 'Brust');

    // ── Langer Druck auf A2 (hat Sätze) → bearbeiten ──
    await tester.longPress(find.text('A2'));
    await warte();
    expect(find.text('Gerät A2'), findsOneWidget);
    expect(find.textContaining('Kürzel bleibt'), findsOneWidget);
    expect(find.textContaining('Die 1 bisherigen Sätze bleiben unverändert'),
        findsOneWidget);
    expect(find.byTooltip('Gerät löschen'), findsNothing);
    final kuerzelFeld =
        tester.widget<TextField>(find.widgetWithText(TextField, 'Kürzel'));
    expect(kuerzelFeld.readOnly, isTrue);
    await tippe(find.widgetWithText(ChoiceChip, 'Beine'));
    await tippe(find.text('lbs'));
    await tippe(find.text('links/rechts getrennt'));
    knopfFrei('Änderung speichern');
    await tippe(find.text('Änderung speichern'));
    var a2neu = (await geraet(sued, 'A2'))!;
    expect(a2neu.einheit, Einheit.lbs);
    expect(a2neu.linksRechtsGetrennt, isTrue);
    expect(a2neu.muskelgruppeId, isNotNull);
    expect(find.text('Südstadt · 14.11.2026'), findsOneWidget);

    // ── Startseite → Menü → Geräte ──
    await tippe(find.byType(BackButton));
    expect(find.text('Gymi'), findsOneWidget);
    await tippe(find.byTooltip('Menü'));
    await tippe(find.text('Geräte'));
    expect(find.widgetWithText(AppBar, 'Geräte'), findsOneWidget);
    // Vorauswahl = Standort der laufenden Session; fehlende Angaben markiert
    expect(find.textContaining('A2'), findsOneWidget);
    expect(find.textContaining('X9'), findsOneWidget);
    expect(find.textContaining('Funktion fehlt'), findsOneWidget);
    expect(find.textContaining('Muskelgruppe fehlt'), findsOneWidget);
    expect(find.textContaining('N1'), findsNothing);

    // B1 ohne Sätze: Funktion nachtragen, dann wieder löschen
    await tippe(find.textContaining('B1'));
    expect(find.text('Gerät B1'), findsOneWidget);
    await schreibe('Funktion (z. B. Leg Press)', 'Brustpresse');
    await tippe(find.text('Änderung speichern'));
    expect(find.textContaining('Brustpresse'), findsOneWidget);
    expect(find.textContaining('Funktion fehlt'), findsNothing);
    await tippe(find.textContaining('B1'));
    await tippe(find.byTooltip('Gerät löschen'));
    expect(find.text('Gerät B1 löschen?'), findsOneWidget);
    await tippe(find.text('Löschen'));
    expect(find.textContaining('B1'), findsNothing);
    expect(await geraet(sued, 'B1'), isNull);
    expect(b1, isPositive);

    // Anderer Standort
    await tippe(find.widgetWithText(ChoiceChip, 'Nordstadt'));
    expect(find.textContaining('N1'), findsOneWidget);
    expect(find.textContaining('A2'), findsNothing);

    // Neues Gerät aus der Verwaltung, am gewählten Standort
    await tippe(find.text('Neues Gerät'));
    expect(find.text('Standort: Nordstadt'), findsOneWidget);
    await schreibe('Kürzel', 'N2');
    await tippe(find.text('Gerät speichern'));
    expect(find.textContaining('N2'), findsOneWidget);
    expect(await geraet(nord, 'N2'), isNotNull);
    a2neu = (await geraet(sued, 'A2'))!;
    expect(a2neu.kuerzel, 'A2');
  }, timeout: const Timeout(Duration(seconds: 90)));
}
