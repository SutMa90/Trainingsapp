// WP2.1: Session starten / beenden (DATENMODELL R1.4 [Änderung M2])
// und Umstellung der Datenbank von Version 1 auf 2.

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/session_logik.dart';

/// Aufbau der Datenbank-Version 1 (Stand M1), wie ihn die App erzeugt hat.
const _v1 = [
  'CREATE TABLE "standorte" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT NOT NULL UNIQUE)',
  'CREATE TABLE "muskelgruppen" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT NOT NULL UNIQUE, "sortierung" INTEGER NOT NULL DEFAULT 0)',
  'CREATE TABLE "geraete" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "standort_id" INTEGER NOT NULL REFERENCES standorte (id), "kuerzel" TEXT NOT NULL, "funktion" TEXT NULL, "muskelgruppe_id" INTEGER NULL REFERENCES muskelgruppen (id), "hersteller" TEXT NULL, "modell" TEXT NULL, "einheit" TEXT NOT NULL, "assistiert" INTEGER NOT NULL DEFAULT 0 CHECK ("assistiert" IN (0, 1)), "links_rechts_getrennt" INTEGER NOT NULL DEFAULT 0 CHECK ("links_rechts_getrennt" IN (0, 1)), "einstellung1" TEXT NULL, "einstellung2" TEXT NULL, "einstellung3" TEXT NULL, "notiz" TEXT NULL, UNIQUE ("standort_id", "kuerzel"))',
  'CREATE TABLE "sessions" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "datum" TEXT NOT NULL, "standort_id" INTEGER NOT NULL REFERENCES standorte (id), "koerpergewicht_kg" REAL NULL)',
  'CREATE TABLE "saetze" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "session_id" INTEGER NOT NULL REFERENCES sessions (id) ON DELETE CASCADE, "geraet_id" INTEGER NOT NULL REFERENCES geraete (id), "satz_nr" INTEGER NOT NULL, "seite" TEXT NULL, "wiederholungen" INTEGER NOT NULL, "eingabewert" REAL NOT NULL, "eingabeeinheit" TEXT NOT NULL, "gewicht_kg" REAL NOT NULL, "notiz" TEXT NULL)',
];

void main() {
  late Datenbank db;
  late int nord, sued, geraet;

  setUp(() async {
    db = Datenbank(NativeDatabase.memory());
    nord = await db.legeStandortAn('Nordstadt');
    sued = await db.legeStandortAn('Südstadt');
    geraet = await db.into(db.geraete).insert(GeraeteCompanion.insert(
        standortId: nord, kuerzel: 'A2', einheit: Einheit.kg));
  });
  tearDown(() => db.close());

  Future<void> satz(int sessionId) => db.into(db.saetze).insert(
      SaetzeCompanion.insert(
          sessionId: sessionId,
          geraetId: geraet,
          satzNr: 1,
          wiederholungen: 15,
          eingabewert: 80,
          eingabeeinheit: Einheit.kg,
          gewichtKg: 80));

  Future<TrainingsSession> lies(int id) =>
      (db.select(db.sessions)..where((s) => s.id.equals(id))).getSingle();

  Future<int> anzahlSessions() async =>
      (await db.select(db.sessions).get()).length;

  test('isoDatum', () {
    expect(isoDatum(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
  });

  test('Start: neue Session läuft; Vorschlag = letzter Standort und Körpergewicht',
      () async {
    final leer = await db.startVorschlag();
    expect(leer.standorte.map((s) => s.name), ['Nordstadt', 'Südstadt']);
    expect(leer.letzterStandortId, isNull);
    expect(leer.letztesKoerpergewichtKg, isNull);

    final id = await db.starteSession(
        standortId: sued, heute: '2026-11-13', koerpergewichtKg: 80.5);
    final laufend = await db.laufendeSession();
    expect(laufend!.session.id, id);
    expect(laufend.standort.name, 'Südstadt');
    expect(laufend.session.abgeschlossen, isFalse);

    final v = await db.startVorschlag();
    expect(v.letzterStandortId, sued);
    expect(v.letztesKoerpergewichtKg, 80.5);
  });

  test('Beenden: mit Sätzen abgeschlossen, ohne Sätze verworfen', () async {
    final a = await db.starteSession(standortId: nord, heute: '2026-11-13');
    await satz(a);
    expect(await db.beendeSession(a), BeendenErgebnis.beendet);
    expect((await lies(a)).abgeschlossen, isTrue);
    expect(await db.laufendeSession(), isNull);

    final b = await db.starteSession(standortId: sued, heute: '2026-11-13');
    expect(await db.beendeSession(b), BeendenErgebnis.leerVerworfen);
    expect(await anzahlSessions(), 1);
  });

  test('Eine Session pro Tag und Standort: erneuter Start führt sie weiter',
      () async {
    final a = await db.starteSession(
        standortId: nord, heute: '2026-11-13', koerpergewichtKg: 80);
    await satz(a);
    await db.beendeSession(a);
    final b = await db.starteSession(
        standortId: nord, heute: '2026-11-13', koerpergewichtKg: 81);
    expect(b, a);
    expect(await anzahlSessions(), 1);
    final s = await lies(a);
    expect(s.abgeschlossen, isFalse);
    expect(s.koerpergewichtKg, 81);
    // Am nächsten Tag am selben Ort: neue Session
    await db.beendeSession(a);
    final c = await db.starteSession(standortId: nord, heute: '2026-11-14');
    expect(c, isNot(a));
  });

  test('Nur eine laufende Session: Start an anderem Ort wird abgewiesen',
      () async {
    await db.starteSession(standortId: nord, heute: '2026-11-13');
    expect(db.starteSession(standortId: sued, heute: '2026-11-13'),
        throwsStateError);
    expect(await anzahlSessions(), 1);
  });

  test('Wieder aufnehmen: nur am selben Tag', () async {
    final a = await db.starteSession(standortId: nord, heute: '2026-11-13');
    await satz(a);
    await db.beendeSession(a);
    await db.nimmSessionWiederAuf(a, '2026-11-13');
    expect((await lies(a)).abgeschlossen, isFalse);

    await db.beendeSession(a);
    expect(db.nimmSessionWiederAuf(a, '2026-11-14'), throwsStateError);
    expect((await lies(a)).abgeschlossen, isTrue);
  });

  test('Tageswechsel: alte laufende Session endet, leere wird verworfen',
      () async {
    final a = await db.starteSession(standortId: nord, heute: '2026-11-12');
    await satz(a);
    expect(await db.schliesseVergangeneSessions('2026-11-12'), 0);
    expect(await db.schliesseVergangeneSessions('2026-11-13'), 1);
    final s = await lies(a);
    expect(s.abgeschlossen, isTrue);
    expect(s.datum, '2026-11-12');

    await db.starteSession(standortId: sued, heute: '2026-11-13');
    expect(await db.schliesseVergangeneSessions('2026-11-14'), 1);
    expect(await anzahlSessions(), 1);
  });

  test('Umstellung Version 1 → 3: abgeschlossen, App-Version leer (imp)',
      () async {
    // Zweite, unabhängige Datenbank im Arbeitsspeicher – hier gewollt.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);
    final alt = Datenbank(NativeDatabase.memory(setup: (raw) {
      for (final sql in _v1) {
        raw.execute(sql);
      }
      raw.execute("INSERT INTO standorte (name) VALUES ('Nordstadt')");
      raw.execute(
          "INSERT INTO sessions (datum, standort_id, koerpergewicht_kg) VALUES ('2025-03-03', 1, 78)");
      raw.execute('PRAGMA user_version = 1');
    }));
    addTearDown(alt.close);

    final s = await alt.select(alt.sessions).getSingle();
    expect(s.datum, '2025-03-03');
    expect(s.koerpergewichtKg, 78);
    expect(s.abgeschlossen, isTrue);
    expect(s.appVersion, isNull);
    expect(await alt.laufendeSession(), isNull);
    final version =
        await alt.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 3);
  });

  test('Umstellung Version 2 → 3 (Handy): laufende Session bleibt laufend',
      () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);
    final alt = Datenbank(NativeDatabase.memory(setup: (raw) {
      for (final sql in _v1) {
        raw.execute(sql);
      }
      raw.execute('ALTER TABLE "sessions" ADD COLUMN "abgeschlossen" INTEGER '
          'NOT NULL DEFAULT 1 CHECK ("abgeschlossen" IN (0, 1))');
      raw.execute("INSERT INTO standorte (name) VALUES ('Nordstadt')");
      raw.execute("INSERT INTO sessions (datum, standort_id) VALUES ('2026-08-03', 1)");
      raw.execute("INSERT INTO sessions (datum, standort_id, abgeschlossen) "
          "VALUES ('2026-11-13', 1, 0)");
      raw.execute('PRAGMA user_version = 2');
    }));
    addTearDown(alt.close);

    final liste = await alt.select(alt.sessions).get();
    expect(liste.map((s) => (s.datum, s.abgeschlossen, s.appVersion)),
        [('2026-08-03', true, null), ('2026-11-13', false, null)]);
    expect((await alt.laufendeSession())!.session.datum, '2026-11-13');
  });
}
