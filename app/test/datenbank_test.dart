// WP1.2 Abnahme-Test: In alle 5 Tabellen schreiben und zurücklesen.
// Läuft auf dem PC gegen eine Datenbank im Arbeitsspeicher.

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';

void main() {
  late Datenbank db;

  setUp(() => db = Datenbank(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('neue Datenbank enthält die 9 Start-Muskelgruppen in Reihenfolge',
      () async {
    final gruppen = await (db.select(db.muskelgruppen)
          ..orderBy([(m) => OrderingTerm.asc(m.sortierung)]))
        .get();
    expect(gruppen.map((g) => g.name), startMuskelgruppen);
  });

  test('Schreiben und Lesen über alle 5 Tabellen', () async {
    final nord = await db
        .into(db.standorte)
        .insert(StandorteCompanion.insert(name: 'Nordstadt'));
    final beine = (await (db.select(db.muskelgruppen)
              ..where((m) => m.name.equals('Beine')))
            .getSingle())
        .id;

    final legPress = await db.into(db.geraete).insert(GeraeteCompanion.insert(
          standortId: nord,
          kuerzel: 'A2',
          funktion: const Value('Leg Press'),
          muskelgruppeId: Value(beine),
          einheit: Einheit.lbs,
        ));
    final assist = await db.into(db.geraete).insert(GeraeteCompanion.insert(
          standortId: nord,
          kuerzel: 'T1',
          einheit: Einheit.kg,
          assistiert: const Value(true),
        ));

    final session = await db.into(db.sessions).insert(SessionsCompanion.insert(
          datum: '2025-03-03',
          standortId: nord,
          koerpergewichtKg: const Value(78),
        ));

    await db.into(db.saetze).insert(SaetzeCompanion.insert(
          sessionId: session,
          geraetId: legPress,
          satzNr: 1,
          wiederholungen: 15,
          eingabewert: 200,
          eingabeeinheit: Einheit.lbs,
          gewichtKg: gewichtKgFuerSatz(
              eingabewert: 200, eingabeeinheit: Einheit.lbs),
        ));
    await db.into(db.saetze).insert(SaetzeCompanion.insert(
          sessionId: session,
          geraetId: assist,
          satzNr: 1,
          wiederholungen: 8,
          eingabewert: 40,
          eingabeeinheit: Einheit.kg,
          gewichtKg: gewichtKgFuerSatz(
              eingabewert: 40,
              eingabeeinheit: Einheit.kg,
              assistiert: true,
              koerpergewichtKg: 78),
          notiz: const Value('Testnotiz'),
        ));

    final uebersicht = await db.beobachteSessionUebersicht().first;
    expect(uebersicht, hasLength(1));
    expect(uebersicht.single.standort.name, 'Nordstadt');
    expect(uebersicht.single.session.datum, '2025-03-03');
    expect(uebersicht.single.anzahlSaetze, 2);

    final saetze = await db.beobachteSaetzeDerSession(session).first;
    expect(saetze.map((s) => s.geraet.kuerzel), ['A2', 'T1']);
    final a2 = saetze[0].satz;
    expect(a2.eingabewert, 200);
    expect(a2.eingabeeinheit, Einheit.lbs);
    expect(a2.gewichtKg, closeTo(90.72, 0.0001));
    expect(a2.seite, isNull);
    final t1 = saetze[1].satz;
    expect(t1.gewichtKg, 38); // 78 kg − 40 kg
    expect(t1.notiz, 'Testnotiz');
    expect(saetze[0].geraet.muskelgruppeId, beine);
    expect(saetze[1].geraet.assistiert, isTrue);
  });

  test('Standort + Kürzel ist eindeutig', () async {
    final nord = await db
        .into(db.standorte)
        .insert(StandorteCompanion.insert(name: 'Nordstadt'));
    final sued = await db
        .into(db.standorte)
        .insert(StandorteCompanion.insert(name: 'Südstadt'));
    final a2 = GeraeteCompanion.insert(
        standortId: nord, kuerzel: 'A2', einheit: Einheit.kg);
    await db.into(db.geraete).insert(a2);
    // gleiches Kürzel an anderem Standort ist erlaubt
    await db.into(db.geraete).insert(a2.copyWith(standortId: Value(sued)));
    // gleiches Kürzel am selben Standort nicht
    expect(() => db.into(db.geraete).insert(a2),
        throwsA(isA<SqliteException>()));
  });

  test('Satz ohne gültiges Gerät wird abgewiesen (Fremdschlüssel aktiv)',
      () async {
    final nord = await db
        .into(db.standorte)
        .insert(StandorteCompanion.insert(name: 'Nordstadt'));
    final session = await db.into(db.sessions).insert(
        SessionsCompanion.insert(datum: '2025-03-03', standortId: nord));
    expect(
      () => db.into(db.saetze).insert(SaetzeCompanion.insert(
            sessionId: session,
            geraetId: 999,
            satzNr: 1,
            wiederholungen: 10,
            eingabewert: 20,
            eingabeeinheit: Einheit.kg,
            gewichtKg: 20,
          )),
      throwsA(isA<SqliteException>()),
    );
  });

  test('Umrechnung lbs ↔ kg mit Faktor 0,4536', () {
    expect(inKg(70, Einheit.lbs), closeTo(31.752, 1e-9));
    expect(inKg(35, Einheit.kg), 35);
    expect(ausKg(31.752, Einheit.lbs), closeTo(70, 1e-9));
    expect(
        () => gewichtKgFuerSatz(
            eingabewert: 40, eingabeeinheit: Einheit.kg, assistiert: true),
        throwsArgumentError);
  });
}
