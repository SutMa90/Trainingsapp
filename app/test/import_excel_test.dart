// WP1.4 Abnahme-Test: Umwandlungsskript gegen die synthetischen Testdaten.
// Soll-Werte: testdaten/ERWARTET.md

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';

import '../tool/import_excel/importer.dart';
import '../tool/import_excel/xlsx_leser.dart';

void main() {
  late Datenbank db;
  late ImportErgebnis erg;

  setUpAll(() async {
    db = Datenbank(NativeDatabase.memory());
    erg = await importiere(
      mappe: XlsxMappe.lies('../testdaten/Testlog.xlsx'),
      entscheidungen: Entscheidungen.ausDatei('../testdaten/entscheidungen.json'),
      db: db,
    );
  });
  tearDownAll(() => db.close());

  Future<Geraet> geraet(String standort, String kuerzel) async {
    final q = db.select(db.geraete).join([
      innerJoin(db.standorte, db.standorte.id.equalsExp(db.geraete.standortId)),
    ])
      ..where(db.standorte.name.equals(standort) &
          db.geraete.kuerzel.equals(kuerzel));
    return (await q.getSingle()).readTable(db.geraete);
  }

  Future<List<SatzMitGeraet>> saetzeVon(String datum, String standort) async {
    final s = (await db.beobachteSessionUebersicht().first).singleWhere(
        (e) => e.session.datum == datum && e.standort.name == standort);
    return db.beobachteSaetzeDerSession(s.session.id).first;
  }

  test('Gesamtzahlen', () async {
    expect(erg.logZeilenMitInhalt, 53);
    expect(erg.leereZeilen, 4);
    expect(erg.fehler, hasLength(5));
    expect(erg.importierteSaetze, 48);
    expect(await db.select(db.saetze).get(), hasLength(48));
    expect(await db.select(db.sessions).get(), hasLength(6));
    expect((await db.select(db.standorte).get()).map((s) => s.name),
        ['Nordstadt', 'Südstadt']);
    expect(await db.select(db.geraete).get(), hasLength(13));
    expect(await db.select(db.muskelgruppen).get(), hasLength(9));
    expect(erg.grundfehler, isEmpty);
  });

  test('Sätze pro Session', () async {
    final u = await db.beobachteSessionUebersicht().first;
    expect({for (final e in u) '${e.session.datum} ${e.standort.name}': e.anzahlSaetze}, {
      '2025-03-03 Nordstadt': 10,
      '2025-03-06 Südstadt': 12,
      '2025-03-12 Nordstadt': 8,
      '2025-03-18 Südstadt': 6,
      '2025-03-25 Südstadt': 7,
      '2025-04-02 Nordstadt': 5,
    });
  });

  test('Fehler: genau die 5 unklaren Zeilen, nicht importiert', () {
    expect(erg.fehler.map((m) => m.zeile), [45, 47, 50, 51, 54]);
  });

  test('Warnungen: Einheit, Faktor 0,45, Satz-Nr., Funktion ohne Zuordnung', () {
    final zeilen = erg.warnungen.map((m) => m.zeile).toList();
    expect(zeilen, [26, 27, 32, 33, 34, 35, 53, null]);
    expect(erg.warnungen.where((m) => m.text.contains('0,45')), hasLength(4));
    expect(erg.warnungen.last.text, contains('Cable Row einarmig'));
  });

  test('Hinweis Rundung nur für Zeile 12', () {
    final r = erg.infos.where((m) => m.text.contains('gerundet'));
    expect(r.map((m) => m.zeile), [12]);
  });

  test('S1: assistiertes T1 mit Körpergewicht 78', () async {
    final t1 = await geraet('Nordstadt', 'T1');
    expect(t1.assistiert, isTrue);
    final s = (await saetzeVon('2025-03-03', 'Nordstadt'))
        .where((e) => e.geraet.kuerzel == 'T1')
        .map((e) => e.satz)
        .toList();
    expect(s.map((x) => [x.satzNr, x.eingabewert, x.gewichtKg, x.wiederholungen]),
        [
          [1, 40, 38, 8],
          [2, 45, 33, 10],
        ]);
    expect(s.every((x) => x.notiz == null), isTrue); // Auto-Notiz entfernt
    final session = (await db.select(db.sessions).get())
        .singleWhere((x) => x.datum == '2025-03-03');
    expect(session.koerpergewichtKg, 78);
  });

  test('S1: Reihenfolge der Sätze wie in der Excel', () async {
    final s = await saetzeVon('2025-03-03', 'Nordstadt');
    expect(s.map((e) => '${e.geraet.kuerzel}/${e.satz.satzNr}'), [
      'A2/1', 'A2/2', 'D1/1', 'B4/1', 'D1/2', 'B4/2', 'T1/1', 'T1/2', 'E1/1', 'E2/1',
    ]);
  });

  test('S2: C3 links/rechts als ein Gerät', () async {
    final c3 = await geraet('Südstadt', 'C3');
    expect(c3.linksRechtsGetrennt, isTrue);
    expect(c3.muskelgruppeId, isNull);
    final s = (await saetzeVon('2025-03-06', 'Südstadt'))
        .where((e) => e.geraet.kuerzel == 'C3')
        .map((e) => e.satz)
        .toList();
    expect(s.map((x) => '${x.seite!.name}${x.satzNr} ${x.eingabewert}'),
        ['L1 40.0', 'R1 40.0', 'L2 45.0', 'R2 45.0']);
    expect(s.map((x) => x.gewichtKg.toStringAsFixed(2)),
        ['18.14', '18.14', '20.41', '20.41']);
  });

  test('S2: gerundete kg-Spalte wird aus der Eingabe berechnet', () async {
    final a2 = (await saetzeVon('2025-03-06', 'Südstadt'))
        .firstWhere((e) => e.geraet.kuerzel == 'A2')
        .satz;
    expect(a2.eingabewert, 200);
    expect(a2.eingabeeinheit, Einheit.lbs);
    expect(a2.gewichtKg, closeTo(90.72, 1e-9));
  });

  test('X4 / X4.1 zusammengeführt, Einheiten bleiben pro Satz', () async {
    final x4 = await geraet('Südstadt', 'X4');
    expect(x4.einheit, Einheit.lbs);
    expect(x4.notiz, contains('zusammengeführt mit X4.1'));
    final alle = await (db.select(db.saetze)
          ..where((s) => s.geraetId.equals(x4.id))
          ..orderBy([(s) => OrderingTerm.asc(s.id)]))
        .get();
    expect(alle.map((s) => '${s.eingabewert} ${s.eingabeeinheit.name}'), [
      '30.0 kg', '32.5 kg', '32.5 kg', '35.0 kg', '65.0 lbs', '70.0 lbs',
    ]);
    expect(
        (await db.select(db.geraete).get()).where((g) => g.kuerzel == 'X4.1'),
        isEmpty);
  });

  test('X5 / X5.1 zusammengeführt (anderer Hersteller)', () async {
    final x5 = await geraet('Südstadt', 'X5');
    expect(x5.hersteller, 'Beta');
    expect(x5.notiz, contains('zusammengeführt mit X5.1 (Gamma, kg'));
    final alle = await (db.select(db.saetze)
          ..where((s) => s.geraetId.equals(x5.id)))
        .get();
    expect(alle.map((s) => '${s.eingabewert} ${s.eingabeeinheit.name}'),
        ['35.0 kg', '35.0 kg', '70.0 lbs', '75.0 lbs']);
  });

  test('S3: lbs-Eingabe auf kg-Gerät bleibt unverändert, Zusatzgewicht-Notiz bleibt',
      () async {
    final s = await saetzeVon('2025-03-12', 'Nordstadt');
    final d1 = s.where((e) => e.geraet.kuerzel == 'D1').map((e) => e.satz);
    expect(d1.map((x) => '${x.eingabewert} ${x.eingabeeinheit.name}'),
        ['50.0 lbs', '60.0 lbs']);
    final b4 = s.where((e) => e.geraet.kuerzel == 'B4').map((e) => e.satz);
    expect(b4.map((x) => x.notiz),
        everyElement('inkl. 5 kg Zusatzgewicht (Anzeige 30 kg)'));
  });

  test('S4: Werte mit Verdacht Faktor 0,45 werden NICHT verändert', () async {
    final s = await saetzeVon('2025-03-18', 'Südstadt');
    expect(
        s.map((e) =>
            '${e.geraet.kuerzel} ${e.satz.eingabewert} ${e.satz.eingabeeinheit.name}'),
        [
          'A2 85.5 kg', 'A2 90.0 kg', 'E1 27.0 kg', 'E2 31.5 kg',
          'X4 32.5 kg', 'X4 35.0 kg',
        ]);
  });

  test('S6: Satz-Nr.-Lücke wird fortlaufend nummeriert', () async {
    final d1 = (await saetzeVon('2025-04-02', 'Nordstadt'))
        .where((e) => e.geraet.kuerzel == 'D1')
        .map((e) => e.satz.satzNr);
    expect(d1, [1, 2]);
  });

  test('Muskelgruppen gemäss Entscheidungsdatei', () async {
    final gruppen = {
      for (final g in await db.select(db.muskelgruppen).get()) g.id: g.name,
    };
    Future<String?> mg(String o, String k) async =>
        gruppen[(await geraet(o, k)).muskelgruppeId];
    expect(await mg('Nordstadt', 'A2'), 'Beine');
    expect(await mg('Nordstadt', 'E1'), 'Gesäss/Hüfte');
    expect(await mg('Nordstadt', 'C1'), 'Core');
    expect(await mg('Nordstadt', 'T1'), 'Trizeps'); // ohne Funktion, per Entscheid
    expect(await mg('Südstadt', 'X4'), 'Beine');
    expect(await mg('Südstadt', 'C3'), isNull); // Funktion ohne Zuordnung
  });

  test('Prüfbericht enthält die Stichproben', () {
    final md = erg.alsMarkdown(quelle: 'Testlog.xlsx');
    expect(erg.stichproben.keys, hasLength(5));
    expect(md, contains('### 2025-03-06 Südstadt – 12 Sätze'));
    expect(md, contains('| 18 | C3-links | C3 | L | 1 | 15 | 40 lbs | 18.14 |'));
  });
}
