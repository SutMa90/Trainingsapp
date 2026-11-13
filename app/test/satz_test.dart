// WP2.2: Satz erfassen – Satz-Nr., Gewicht kg, Einheit als Vorgabe,
// Vorbefüllung, Gerätekacheln.

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/satz_logik.dart';
import 'package:trainingsapp/data/db/session_logik.dart';

void main() {
  late Datenbank db;
  late int nord, lbsGeraet, kgGeraet, assist, seitlich, session;

  setUp(() async {
    db = Datenbank(NativeDatabase.memory());
    nord = await db.legeStandortAn('Nordstadt');
    Future<int> geraet(String k, Einheit e,
            {bool assistiert = false, bool lr = false}) =>
        db.into(db.geraete).insert(GeraeteCompanion.insert(
            standortId: nord,
            kuerzel: k,
            einheit: e,
            assistiert: Value(assistiert),
            linksRechtsGetrennt: Value(lr)));
    lbsGeraet = await geraet('A10', Einheit.lbs);
    kgGeraet = await geraet('A2', Einheit.kg);
    assist = await geraet('T1', Einheit.kg, assistiert: true);
    seitlich = await geraet('C3', Einheit.lbs, lr: true);
    session = await db.starteSession(
        standortId: nord, heute: '2026-11-13', koerpergewichtKg: 80);
  });
  tearDown(() => db.close());

  Future<Geraet> g(int id) =>
      (db.select(db.geraete)..where((x) => x.id.equals(id))).getSingle();
  Future<Satz> satz(int id) =>
      (db.select(db.saetze)..where((x) => x.id.equals(id))).getSingle();

  test('Kürzel natürlich sortiert', () {
    final l = ['A10', 'B1', 'A2', 'a3', 'T1', 'A4.1'];
    l.sort(vergleicheKuerzel);
    expect(l, ['A2', 'a3', 'A4.1', 'A10', 'B1', 'T1']);
  });

  test('Satz-Nr. zählt pro Gerät und Seite hoch', () async {
    Future<int> s(int geraet, [Seite? seite]) async => (await satz(
            await db.speichereSatz(
                sessionId: session,
                geraetId: geraet,
                seite: seite,
                wiederholungen: 10,
                eingabewert: 50,
                einheit: Einheit.lbs)))
        .satzNr;
    expect(await s(lbsGeraet), 1);
    expect(await s(lbsGeraet), 2);
    expect(await s(kgGeraet), 1);
    expect(await s(seitlich, Seite.L), 1);
    expect(await s(seitlich, Seite.R), 1);
    expect(await s(seitlich, Seite.L), 2);
    expect(await s(lbsGeraet), 3);
  });

  test('Gewicht kg: lbs umgerechnet, assistiert = Körpergewicht − Eingabe',
      () async {
    final a = await satz(await db.speichereSatz(
        sessionId: session,
        geraetId: lbsGeraet,
        wiederholungen: 15,
        eingabewert: 200,
        einheit: Einheit.lbs));
    expect(a.gewichtKg, closeTo(90.72, 1e-9));
    expect(a.eingabewert, 200);
    expect(a.eingabeeinheit, Einheit.lbs);

    final t = await satz(await db.speichereSatz(
        sessionId: session,
        geraetId: assist,
        wiederholungen: 8,
        eingabewert: 32.5,
        einheit: Einheit.kg,
        notiz: '  breiter Griff  '));
    expect(t.gewichtKg, 47.5);
    expect(t.notiz, 'breiter Griff');
  });

  test('Assistiert ohne Körpergewicht: Hinweis statt falscher Wert', () async {
    await db.beendeSession(session); // leer → verworfen
    final ohne = await db.starteSession(standortId: nord, heute: '2026-11-14');
    expect(
        db.speichereSatz(
            sessionId: ohne,
            geraetId: assist,
            wiederholungen: 8,
            eingabewert: 30,
            einheit: Einheit.kg),
        throwsA(isA<KoerpergewichtFehlt>()));
    await db.setzeKoerpergewicht(ohne, 81);
    final t = await satz(await db.speichereSatz(
        sessionId: ohne,
        geraetId: assist,
        wiederholungen: 8,
        eingabewert: 30,
        einheit: Einheit.kg));
    expect(t.gewichtKg, 51);
  });

  test('Ungültige Eingaben werden abgewiesen', () async {
    expect(
        db.speichereSatz(
            sessionId: session,
            geraetId: kgGeraet,
            wiederholungen: 0,
            eingabewert: 50,
            einheit: Einheit.kg),
        throwsArgumentError);
    expect(
        db.speichereSatz(
            sessionId: session,
            geraetId: seitlich,
            wiederholungen: 10,
            eingabewert: 50,
            einheit: Einheit.lbs),
        throwsArgumentError);
  });

  test('Einheit umschalten: neue Vorgabe, alte Sätze unverändert', () async {
    final alt = await db.speichereSatz(
        sessionId: session,
        geraetId: kgGeraet,
        wiederholungen: 15,
        eingabewert: 80,
        einheit: Einheit.kg);
    await db.speichereSatz(
        sessionId: session,
        geraetId: kgGeraet,
        wiederholungen: 15,
        eingabewert: 180,
        einheit: Einheit.lbs);
    expect((await g(kgGeraet)).einheit, Einheit.lbs);
    final a = await satz(alt);
    expect(a.eingabewert, 80);
    expect(a.eingabeeinheit, Einheit.kg);
    expect(a.gewichtKg, 80);
  });

  test('Vorbefüllung: leer, dann letzte Werte, umgerechnet bei anderer Einheit',
      () async {
    var v = await db.vorbefuellung(sessionId: session, geraet: await g(kgGeraet));
    expect(v.wiederholungen, isNull);
    expect(v.eingabewert, isNull);
    expect(v.einheit, Einheit.kg);
    expect(v.satzNr, 1);

    await db.speichereSatz(
        sessionId: session,
        geraetId: kgGeraet,
        wiederholungen: 12,
        eingabewert: 82.5,
        einheit: Einheit.kg);
    v = await db.vorbefuellung(sessionId: session, geraet: await g(kgGeraet));
    expect(v.wiederholungen, 12);
    expect(v.eingabewert, 82.5);
    expect(v.umgerechnet, isFalse);
    expect(v.satzNr, 2);

    // Vorgabe-Einheit nachträglich lbs (z. B. Datenpflege): Wert wird umgerechnet
    await (db.update(db.geraete)..where((x) => x.id.equals(kgGeraet)))
        .write(const GeraeteCompanion(einheit: Value(Einheit.lbs)));
    v = await db.vorbefuellung(sessionId: session, geraet: await g(kgGeraet));
    expect(v.einheit, Einheit.lbs);
    expect(v.eingabewert, 181.9); // 82,5 kg / 0,4536 = 181,88 lbs
    expect(v.umgerechnet, isTrue);
  });

  test('Vorbefüllung aus früherer Session; links/rechts nach Seite', () async {
    await db.speichereSatz(
        sessionId: session,
        geraetId: seitlich,
        seite: Seite.L,
        wiederholungen: 15,
        eingabewert: 40,
        einheit: Einheit.lbs);
    await db.speichereSatz(
        sessionId: session,
        geraetId: seitlich,
        seite: Seite.R,
        wiederholungen: 12,
        eingabewert: 45,
        einheit: Einheit.lbs);
    await db.beendeSession(session);
    final neu = await db.starteSession(standortId: nord, heute: '2026-11-20');
    final c3 = await g(seitlich);
    final l = await db.vorbefuellung(sessionId: neu, geraet: c3, seite: Seite.L);
    expect((l.wiederholungen, l.eingabewert, l.satzNr), (15, 40.0, 1));
    final r = await db.vorbefuellung(sessionId: neu, geraet: c3, seite: Seite.R);
    expect((r.wiederholungen, r.eingabewert, r.satzNr), (12, 45.0, 1));
  });

  test('Kacheln: sortiert, mit Anzahl Sätze der Session', () async {
    await db.speichereSatz(
        sessionId: session,
        geraetId: lbsGeraet,
        wiederholungen: 10,
        eingabewert: 100,
        einheit: Einheit.lbs);
    await db.speichereSatz(
        sessionId: session,
        geraetId: lbsGeraet,
        wiederholungen: 10,
        eingabewert: 100,
        einheit: Einheit.lbs);
    final k = await db.beobachteKacheln(nord, session).first;
    expect(k.map((e) => e.geraet.kuerzel), ['A2', 'A10', 'C3', 'T1']);
    expect(k.map((e) => e.saetzeHeute), [0, 2, 0, 0]);
  });
}
