// WP2.5: Geräteverwaltung – anlegen, ändern, löschen, Vorschläge (R2.2),
// Muskelgruppen erweitern (R2.4).

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/geraete_logik.dart';
import 'package:trainingsapp/data/db/satz_logik.dart';
import 'package:trainingsapp/data/db/session_logik.dart';

void main() {
  late Datenbank db;
  late int nord, sued;

  setUp(() async {
    db = Datenbank(NativeDatabase.memory());
    nord = await db.legeStandortAn('Nordstadt');
    sued = await db.legeStandortAn('Südstadt');
  });
  tearDown(() => db.close());

  test('Neues Gerät: Kürzel gross, leere Felder leer, Vorgabe kg', () async {
    final id = await db.legeGeraetAn(
        nord, const GeraetDaten(kuerzel: ' x7 ', funktion: 'Chest Press', hersteller: ' '));
    final g = await db.geraetMitId(id);
    expect(g.kuerzel, 'X7');
    expect(g.standortId, nord);
    expect(g.funktion, 'Chest Press');
    expect(g.hersteller, isNull);
    expect(g.einheit, Einheit.kg);
    expect(g.assistiert, isFalse);
    expect(g.linksRechtsGetrennt, isFalse);
  });

  test('Kürzel pro Standort eindeutig, am anderen Standort frei', () async {
    await db.legeGeraetAn(nord, const GeraetDaten(kuerzel: 'A1'));
    expect(() => db.legeGeraetAn(nord, const GeraetDaten(kuerzel: 'a1')),
        throwsA(isA<KuerzelVergeben>()));
    expect(await db.legeGeraetAn(sued, const GeraetDaten(kuerzel: 'A1')), isPositive);
    expect(() => db.legeGeraetAn(nord, const GeraetDaten(kuerzel: '  ')),
        throwsArgumentError);
  });

  test('Neues Gerät erscheint sofort bei den Kacheln', () async {
    final session = await db.starteSession(standortId: nord, heute: '2026-11-14');
    final kacheln = db.beobachteKacheln(nord, session);
    expect(await kacheln.first, isEmpty);
    await db.legeGeraetAn(nord, const GeraetDaten(kuerzel: 'Z9', funktion: 'Neu'));
    expect((await kacheln.first).map((k) => k.geraet.kuerzel), ['Z9']);
  });

  group('mit Sätzen', () {
    late int geraet, session, satz;
    setUp(() async {
      geraet = await db.legeGeraetAn(
          nord, const GeraetDaten(kuerzel: 'T1', einheit: Einheit.lbs));
      session = await db.starteSession(
          standortId: nord, heute: '2026-11-14', koerpergewichtKg: 80);
      satz = await db.speichereSatz(
          sessionId: session,
          geraetId: geraet,
          wiederholungen: 10,
          eingabewert: 20,
          einheit: Einheit.lbs);
    });

    test('Kürzel bleibt, alles andere änderbar; alte Sätze unverändert', () async {
      final vorher =
          await (db.select(db.saetze)..where((s) => s.id.equals(satz))).getSingle();
      final mg = (await db.muskelgruppenListe()).first.id;
      expect(
          () => db.aendereGeraet(geraet, const GeraetDaten(kuerzel: 'T2')),
          throwsA(isA<GeraetHatSaetze>()));
      // gleiche Schreibweise (auch klein) gilt nicht als Umbenennen
      await db.aendereGeraet(
          geraet,
          GeraetDaten(
              kuerzel: 't1',
              funktion: 'Klimmzug',
              muskelgruppeId: mg,
              einheit: Einheit.kg,
              assistiert: true,
              linksRechtsGetrennt: true));
      final g = await db.geraetMitId(geraet);
      expect(g.kuerzel, 'T1');
      expect(g.funktion, 'Klimmzug');
      expect(g.muskelgruppeId, mg);
      expect(g.einheit, Einheit.kg);
      expect(g.assistiert, isTrue);
      expect(g.linksRechtsGetrennt, isTrue);
      final nachher =
          await (db.select(db.saetze)..where((s) => s.id.equals(satz))).getSingle();
      expect(nachher, vorher);
    });

    test('Löschen nur ohne Sätze', () async {
      expect(() => db.loescheGeraet(geraet), throwsA(isA<GeraetHatSaetze>()));
      final leer = await db.legeGeraetAn(nord, const GeraetDaten(kuerzel: 'Q1'));
      await db.loescheGeraet(leer);
      expect(await (db.select(db.geraete)..where((g) => g.id.equals(leer))).get(),
          isEmpty);
    });

    test('Liste pro Standort mit Muskelgruppe und Anzahl Sätze', () async {
      await db.legeGeraetAn(nord, const GeraetDaten(kuerzel: 'A10'));
      await db.legeGeraetAn(nord, const GeraetDaten(kuerzel: 'A2'));
      await db.legeGeraetAn(sued, const GeraetDaten(kuerzel: 'S1'));
      final liste = await db.beobachteGeraete(nord).first;
      expect(liste.map((e) => e.geraet.kuerzel), ['A2', 'A10', 'T1']);
      expect(liste.last.anzahlSaetze, 1);
      expect(liste.first.anzahlSaetze, 0);
      expect(liste.first.muskelgruppe, isNull);
    });
  });

  test('Ohne Sätze darf das Kürzel umbenannt werden, aber nicht auf ein vergebenes',
      () async {
    final a = await db.legeGeraetAn(nord, const GeraetDaten(kuerzel: 'E1'));
    await db.legeGeraetAn(nord, const GeraetDaten(kuerzel: 'E2'));
    expect(() => db.aendereGeraet(a, const GeraetDaten(kuerzel: 'e2')),
        throwsA(isA<KuerzelVergeben>()));
    await db.aendereGeraet(a, const GeraetDaten(kuerzel: 'E3'));
    expect((await db.geraetMitId(a)).kuerzel, 'E3');
  });

  test('Vorschläge Hersteller (alle Standorte) und Modell zum Hersteller', () async {
    Future<void> g(int ort, String k, String? h, String? m) =>
        db.legeGeraetAn(ort, GeraetDaten(kuerzel: k, hersteller: h, modell: m));
    await g(nord, 'A1', 'Technogym', 'Selection 900');
    await g(nord, 'A2', 'technogym ', 'Selection  900');
    await g(sued, 'B1', 'Technogym', 'Pure');
    await g(sued, 'B2', 'Cybex', 'Eagle');
    await g(sued, 'B3', null, 'ohne Hersteller');
    final v = await db.geraeteVorschlaege();
    expect(v.hersteller, ['Cybex', 'Technogym']);
    expect(v.modelleVon('TECHNOGYM'), ['Pure', 'Selection 900']);
    expect(v.modelleVon('Cybex'), ['Eagle']);
    expect(v.modelleVon('Unbekannt'), isEmpty);
    expect(v.modelleVon(null), isEmpty);
  });

  test('Muskelgruppe ergänzen: ans Ende, keine Doppelten', () async {
    final vorher = await db.muskelgruppenListe();
    expect(vorher.map((m) => m.name), startMuskelgruppen);
    final id = await db.legeMuskelgruppeAn(' Unterarme ');
    final nachher = await db.muskelgruppenListe();
    expect(nachher.last.id, id);
    expect(nachher.last.name, 'Unterarme');
    expect(await db.legeMuskelgruppeAn('unterarme'), id);
    expect(await db.legeMuskelgruppeAn('rücken'),
        vorher.firstWhere((m) => m.name == 'Rücken').id);
    expect((await db.muskelgruppenListe()).length, vorher.length + 1);
  });
}
