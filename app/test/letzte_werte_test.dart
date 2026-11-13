// WP2.3: Letzte Werte beim Gerät (F7), Vorbefüllung pro Satz-Nr.,
// „wie letztes Mal“ mit Rückgängig.

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/satz_logik.dart';
import 'package:trainingsapp/data/db/session_logik.dart';

void main() {
  late Datenbank db;
  late int nord, sued, b4, legNord, legSued, c3, t1;

  setUp(() async {
    db = Datenbank(NativeDatabase.memory());
    nord = await db.legeStandortAn('Nordstadt');
    sued = await db.legeStandortAn('Südstadt');
    Future<int> geraet(int ort, String k, String? f, Einheit e,
            {bool lr = false, bool assistiert = false}) =>
        db.into(db.geraete).insert(GeraeteCompanion.insert(
            standortId: ort,
            kuerzel: k,
            funktion: Value(f),
            einheit: e,
            linksRechtsGetrennt: Value(lr),
            assistiert: Value(assistiert)));
    b4 = await geraet(nord, 'B4', 'Row', Einheit.kg);
    legNord = await geraet(nord, 'A2', 'Leg Press', Einheit.kg);
    legSued = await geraet(sued, 'A2', ' leg press ', Einheit.lbs);
    c3 = await geraet(nord, 'C3', 'Cable Row', Einheit.lbs, lr: true);
    t1 = await geraet(nord, 'T1', null, Einheit.kg, assistiert: true);
  });
  tearDown(() => db.close());

  Future<int> session(int ort, String datum, {double? kg}) async {
    final id = await db.starteSession(
        standortId: ort, heute: datum, koerpergewichtKg: kg);
    return id;
  }

  Future<void> satz(int s, int g, int wdh, double wert, Einheit e,
          [Seite? seite]) =>
      db.speichereSatz(
          sessionId: s,
          geraetId: g,
          seite: seite,
          wiederholungen: wdh,
          eingabewert: wert,
          einheit: e);

  Future<Geraet> g(int id) =>
      (db.select(db.geraete)..where((x) => x.id.equals(id))).getSingle();

  test('tageZwischen', () {
    expect(tageZwischen('2026-11-11', '2026-11-13'), 2);
    expect(tageZwischen('2026-02-27', '2026-03-01'), 2);
  });

  test('Letztes Mal am Gerät: letzte Session mit dem Gerät, nicht die laufende',
      () async {
    final s1 = await session(nord, '2026-10-01');
    await satz(s1, b4, 15, 41, Einheit.kg);
    await satz(s1, b4, 20, 45, Einheit.kg);
    await db.beendeSession(s1);
    final s2 = await session(nord, '2026-10-20'); // ohne B4
    await satz(s2, legNord, 15, 100, Einheit.kg);
    await db.beendeSession(s2);
    final heute = await session(nord, '2026-11-13');
    await satz(heute, b4, 12, 50, Einheit.kg);

    final l = await db.letzteSessionAmGeraet(b4, ohneSessionId: heute);
    expect(l!.session.datum, '2026-10-01');
    expect(l.standort.name, 'Nordstadt');
    expect(l.saetze.map((s) => (s.satzNr, s.wiederholungen, s.eingabewert)),
        [(1, 15, 41.0), (2, 20, 45.0)]);
    expect(await db.letzteSessionAmGeraet(t1), isNull);
  });

  test('Vorbefüllung pro Satz-Nr.; mehr Sätze als letztes Mal → zuletzt gespeichert',
      () async {
    final s1 = await session(nord, '2026-11-11');
    await satz(s1, b4, 15, 41, Einheit.kg);
    await satz(s1, b4, 20, 45, Einheit.kg);
    await db.beendeSession(s1);
    final heute = await session(nord, '2026-11-13');
    final geraet = await g(b4);

    var v = await db.vorbefuellung(sessionId: heute, geraet: geraet);
    expect((v.satzNr, v.wiederholungen, v.eingabewert), (1, 15, 41.0));
    await satz(heute, b4, 16, 43, Einheit.kg);
    v = await db.vorbefuellung(sessionId: heute, geraet: geraet);
    expect((v.satzNr, v.wiederholungen, v.eingabewert), (2, 20, 45.0));
    await satz(heute, b4, 18, 47.5, Einheit.kg);
    v = await db.vorbefuellung(sessionId: heute, geraet: geraet);
    expect((v.satzNr, v.wiederholungen, v.eingabewert), (3, 18, 47.5));
  });

  test('Anderer Standort über gleiche Funktion – nur wenn neuer', () async {
    final hier = await session(nord, '2026-11-01');
    await satz(hier, legNord, 15, 100, Einheit.kg);
    await db.beendeSession(hier);
    final dort = await session(sued, '2026-11-10');
    await satz(dort, legSued, 15, 230, Einheit.lbs);
    await satz(dort, legSued, 12, 250, Einheit.lbs);
    await db.beendeSession(dort);
    final heute = await session(nord, '2026-11-13');

    final a = await db.letztesMalAndererStandort(await g(legNord),
        ohneSessionId: heute);
    expect(a!.standort.name, 'Südstadt');
    expect(a.geraet.kuerzel, 'A2');
    expect(a.saetze.map((s) => s.eingabewert), [230.0, 250.0]);

    // Am Gerät hier neuer als dort → nichts anzeigen
    await db.beendeSession(heute); // leer → verworfen
    final neu = await session(nord, '2026-11-12');
    await satz(neu, legNord, 15, 105, Einheit.kg);
    await db.beendeSession(neu);
    final morgen = await session(nord, '2026-11-14');
    expect(
        await db.letztesMalAndererStandort(await g(legNord),
            ohneSessionId: morgen),
        isNull);
    // Ohne Funktion: nie
    expect(await db.letztesMalAndererStandort(await g(t1)), isNull);
  });

  test('Wie letztes Mal: alle Sätze inkl. Seiten, assistiert mit heutigem Körpergewicht',
      () async {
    final s1 = await session(nord, '2026-11-11', kg: 80);
    await satz(s1, c3, 15, 40, Einheit.lbs, Seite.L);
    await satz(s1, c3, 15, 40, Einheit.lbs, Seite.R);
    await satz(s1, c3, 12, 45, Einheit.lbs, Seite.L);
    await satz(s1, t1, 8, 30, Einheit.kg);
    await db.beendeSession(s1);
    final heute = await session(nord, '2026-11-13', kg: 82);

    final ids = await db.wieLetztesMal(heute, c3);
    expect(ids, hasLength(3));
    final kopie = await (db.select(db.saetze)
          ..where((s) => s.sessionId.equals(heute))
          ..orderBy([(s) => OrderingTerm.asc(s.id)]))
        .get();
    expect(kopie.map((s) => (s.seite, s.satzNr, s.wiederholungen, s.eingabewert)),
        [(Seite.L, 1, 15, 40.0), (Seite.R, 1, 15, 40.0), (Seite.L, 2, 12, 45.0)]);

    // Ein zweites Mal geht nicht (sonst doppelt)
    expect(db.wieLetztesMal(heute, c3), throwsStateError);

    final t = await db.wieLetztesMal(heute, t1);
    final tSatz = await (db.select(db.saetze)
          ..where((s) => s.id.equals(t.single)))
        .getSingle();
    expect(tSatz.gewichtKg, 52); // 82 − 30

    // Rückgängig
    await db.loescheSaetze(ids);
    final rest = await (db.select(db.saetze)
          ..where((s) => s.sessionId.equals(heute)))
        .get();
    expect(rest.map((s) => s.geraetId), [t1]);
    // danach wieder möglich
    expect(await db.wieLetztesMal(heute, c3), hasLength(3));
  });

  test('Wie letztes Mal ohne früheren Satz: Hinweis', () async {
    final heute = await session(nord, '2026-11-13');
    expect(db.wieLetztesMal(heute, b4), throwsStateError);
  });
}
