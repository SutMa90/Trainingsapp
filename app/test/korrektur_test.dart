// WP2.4: Satz korrigieren / löschen (F8, R2.7), Session löschen und
// App-Version pro Session (DATENMODELL R1.4 [Änderung M2]).

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/satz_logik.dart';
import 'package:trainingsapp/data/db/session_logik.dart';
import 'package:trainingsapp/version.dart';

void main() {
  late Datenbank db;
  late int nord, a2, c3, t1, session;
  const heute = '2026-11-14';

  setUp(() async {
    db = Datenbank(NativeDatabase.memory());
    nord = await db.legeStandortAn('Nordstadt');
    Future<int> geraet(String k, Einheit e,
            {bool lr = false, bool assistiert = false}) =>
        db.into(db.geraete).insert(GeraeteCompanion.insert(
            standortId: nord,
            kuerzel: k,
            einheit: e,
            linksRechtsGetrennt: Value(lr),
            assistiert: Value(assistiert)));
    a2 = await geraet('A2', Einheit.kg);
    c3 = await geraet('C3', Einheit.lbs, lr: true);
    t1 = await geraet('T1', Einheit.kg, assistiert: true);
    session = await db.starteSession(
        standortId: nord, heute: heute, koerpergewichtKg: 80);
  });
  tearDown(() => db.close());

  Future<int> satz(int g, int wdh, double wert, Einheit e, [Seite? seite]) =>
      db.speichereSatz(
          sessionId: session,
          geraetId: g,
          seite: seite,
          wiederholungen: wdh,
          eingabewert: wert,
          einheit: e);

  Future<List<Satz>> saetzeVon(int g) => (db.select(db.saetze)
        ..where((s) => s.sessionId.equals(session) & s.geraetId.equals(g))
        ..orderBy([(s) => OrderingTerm.asc(s.id)]))
      .get();

  test('Neue Session merkt sich die App-Version', () async {
    final s = await (db.select(db.sessions)..where((x) => x.id.equals(session)))
        .getSingle();
    expect(s.appVersion, appVersion);
  });

  test('Satz ändern: Werte, Einheit (neue Vorgabe), kg neu berechnet', () async {
    final id = await satz(a2, 15, 80, Einheit.kg);
    await db.aendereSatz(
        satzId: id,
        heute: heute,
        wiederholungen: 12,
        eingabewert: 180,
        einheit: Einheit.lbs,
        notiz: ' falsche Einheit ');
    final s = (await saetzeVon(a2)).single;
    expect((s.wiederholungen, s.eingabewert, s.eingabeeinheit, s.notiz),
        (12, 180.0, Einheit.lbs, 'falsche Einheit'));
    expect(s.gewichtKg, closeTo(81.648, 1e-9));
    final g = await (db.select(db.geraete)..where((x) => x.id.equals(a2)))
        .getSingle();
    expect(g.einheit, Einheit.lbs);
  });

  test('Assistiert: kg nach Korrektur = Körpergewicht − neue Eingabe', () async {
    final id = await satz(t1, 8, 30, Einheit.kg);
    await db.aendereSatz(
        satzId: id,
        heute: heute,
        wiederholungen: 8,
        eingabewert: 25,
        einheit: Einheit.kg);
    expect((await saetzeVon(t1)).single.gewichtKg, 55);
  });

  test('Satz löschen: Satz-Nr. lückenlos (R2.7)', () async {
    await satz(a2, 15, 80, Einheit.kg);
    final zwei = await satz(a2, 12, 85, Einheit.kg);
    await satz(a2, 10, 90, Einheit.kg);
    await db.loescheSatz(zwei, heute);
    expect((await saetzeVon(a2)).map((s) => (s.satzNr, s.eingabewert)),
        [(1, 80.0), (2, 90.0)]);
    // nächster Satz bekommt Nr. 3
    expect(await db.naechsteSatzNr(session, a2, null), 3);
  });

  test('Seite ändern: Satz-Nr. pro Seite neu vergeben', () async {
    await satz(c3, 15, 40, Einheit.lbs, Seite.L);
    final falsch = await satz(c3, 15, 40, Einheit.lbs, Seite.L);
    await satz(c3, 12, 45, Einheit.lbs, Seite.L);
    await db.aendereSatz(
        satzId: falsch,
        heute: heute,
        wiederholungen: 15,
        eingabewert: 40,
        einheit: Einheit.lbs,
        seite: Seite.R);
    expect((await saetzeVon(c3)).map((s) => (s.seite, s.satzNr)),
        [(Seite.L, 1), (Seite.R, 1), (Seite.L, 2)]);
  });

  test('Nur Sätze von heute lassen sich korrigieren', () async {
    final id = await satz(a2, 15, 80, Einheit.kg);
    expect(
        db.aendereSatz(
            satzId: id,
            heute: '2026-11-15',
            wiederholungen: 1,
            eingabewert: 1,
            einheit: Einheit.kg),
        throwsStateError);
    expect(db.loescheSatz(id, '2026-11-15'), throwsStateError);
    expect((await saetzeVon(a2)).single.eingabewert, 80);
  });

  test('Session löschen: App-Session samt Sätzen; importierte geschützt',
      () async {
    await satz(a2, 15, 80, Einheit.kg);
    await db.loescheSession(session);
    expect(await db.select(db.sessions).get(), isEmpty);
    expect(await db.select(db.saetze).get(), isEmpty);

    final imp = await db.into(db.sessions).insert(
        SessionsCompanion.insert(datum: '2026-08-03', standortId: nord));
    expect(db.loescheSession(imp), throwsStateError);
    expect(await db.select(db.sessions).get(), hasLength(1));
  });
}
