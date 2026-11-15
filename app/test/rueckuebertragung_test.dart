// WP2.6 Abnahme-Test (Rückübertragung App → Excel) mit den Testdaten:
// Import → 2 Sessions in der App ergänzen (lbs, assistiert in kg und lbs,
// links/rechts, neues Gerät mit neuer Muskelgruppe, Notizen) →
// Rückübertragung: bestehende Zeilen byte-gleich, übrige Teile gleich,
// 2. Lauf ergänzt 0 Zeilen, erneuter Import = dieselben Sätze wie in der App.

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators, OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/geraete_logik.dart';
import 'package:trainingsapp/data/db/satz_logik.dart';
import 'package:trainingsapp/data/db/session_logik.dart';

import '../tool/import_excel/importer.dart';
import '../tool/import_excel/xlsx_leser.dart';
import '../tool/rueckuebertragung/abgleich.dart';
import '../tool/rueckuebertragung/dateien.dart';
import '../tool/rueckuebertragung/xlsx_schreiber.dart';

const testlog = '../testdaten/Testlog.xlsx';
const entscheidungsdatei = '../testdaten/entscheidungen.json';

Future<Datenbank> importiert(List<int> excel) async {
  final db = Datenbank(NativeDatabase.memory());
  await importiere(
    mappe: XlsxMappe.ausBytes(excel),
    entscheidungen: Entscheidungen.ausDatei(entscheidungsdatei),
    db: db,
  );
  return db;
}

/// Alle Sätze beendeter Sessions als vergleichbare Texte, nach Session.
Future<Map<String, List<String>>> saetzeNachSession(Datenbank db) async {
  final orte = {for (final s in await db.select(db.standorte).get()) s.id: s.name};
  final geraete = {for (final g in await db.select(db.geraete).get()) g.id: g};
  final ergebnis = <String, List<String>>{};
  final sessions = await db.select(db.sessions).get();
  for (final s in sessions.where((s) => s.abgeschlossen)) {
    final saetze = await (db.select(db.saetze)
          ..where((x) => x.sessionId.equals(s.id))
          ..orderBy([(x) => OrderingTerm.asc(x.id)]))
        .get();
    ergebnis['${s.datum} ${orte[s.standortId]}'] = [
      for (final x in saetze)
        '${geraete[x.geraetId]!.kuerzel}|${x.seite?.name}|${x.satzNr}|'
            '${x.wiederholungen}|${x.eingabewert}|${x.eingabeeinheit.name}|'
            '${x.gewichtKg.toStringAsFixed(6)}|${x.notiz}',
    ];
  }
  return ergebnis;
}

Map<int, String> zeilenXml(List<int> xlsx, String teil) {
  final xml = utf8.decode(ZipDecoder().decodeBytes(xlsx).findFile(teil)!.content);
  return {
    for (final m in RegExp(r'<row\b[^>]*?\br="(\d+)"[^>]*?(?:/>|>.*?</row>)', dotAll: true)
        .allMatches(xml))
      int.parse(m[1]!): m[0]!,
  };
}

void main() {
  late List<int> original;
  late Datenbank app;
  late Plan plan;
  late List<int> ergebnis;

  setUpAll(() async {
    original = File(testlog).readAsBytesSync();
    app = await importiert(original);
    final nord = (await (app.select(app.standorte)
              ..where((s) => s.name.equals('Nordstadt')))
            .getSingle())
        .id;
    final sued = (await (app.select(app.standorte)
              ..where((s) => s.name.equals('Südstadt')))
            .getSingle())
        .id;
    Future<int> geraet(int ort, String k) async =>
        (await (app.select(app.geraete)
                  ..where((g) => g.standortId.equals(ort) & g.kuerzel.equals(k)))
                .getSingle())
            .id;

    // Neues Gerät mit neuer Muskelgruppe, links/rechts getrennt
    final unterarme = await app.legeMuskelgruppeAn('Unterarme');
    final n9 = await app.legeGeraetAn(
        sued,
        GeraetDaten(
            kuerzel: 'N9',
            funktion: 'Wrist Curl',
            muskelgruppeId: unterarme,
            hersteller: 'Beta',
            modell: 'Linie X',
            linksRechtsGetrennt: true,
            notiz: 'Griff schmal'));

    // Session 1 Südstadt: lbs, kg auf lbs-Gerät mit Notiz, links/rechts
    final s1 = await app.starteSession(standortId: sued, heute: '2026-11-20');
    Future<void> satz(int s, int g, int wdh, double w, Einheit e,
            {Seite? seite, String? notiz}) =>
        app.speichereSatz(
            sessionId: s,
            geraetId: g,
            seite: seite,
            wiederholungen: wdh,
            eingabewert: w,
            einheit: e,
            notiz: notiz);
    final a2s = await geraet(sued, 'A2');
    await satz(s1, a2s, 15, 200, Einheit.lbs, notiz: 'müde');
    await satz(s1, a2s, 12, 210, Einheit.lbs);
    await satz(s1, await geraet(sued, 'X4'), 15, 32.5, Einheit.kg, notiz: 'Sitz 4');
    await satz(s1, n9, 20, 10, Einheit.kg, seite: Seite.L);
    await satz(s1, n9, 20, 10, Einheit.kg, seite: Seite.R);
    await satz(s1, n9, 18, 12.5, Einheit.kg, seite: Seite.L);
    await app.beendeSession(s1);

    // Session 2 Nordstadt: assistiert in kg und in lbs
    final s2 = await app.starteSession(
        standortId: nord, heute: '2026-11-21', koerpergewichtKg: 78.5);
    final t1 = await geraet(nord, 'T1');
    await satz(s2, t1, 8, 40, Einheit.kg);
    await satz(s2, t1, 6, 50, Einheit.lbs);
    await satz(s2, await geraet(nord, 'A2'), 15, 85, Einheit.kg);
    await app.beendeSession(s2);

    // Laufende Session: wird nicht übertragen
    final s3 = await app.starteSession(standortId: nord, heute: '2026-11-22');
    await satz(s3, await geraet(nord, 'A2'), 15, 90, Einheit.kg);

    plan = await erstellePlan(app, XlsxMappe.ausBytes(original));
    ergebnis = ergaenzeXlsx(original, plan);
  });
  tearDownAll(() => app.close());

  test('Vorschau: 2 neue Sessions, 9 Sätze, 1 neues Gerät, laufende gemeldet', () {
    expect(plan.neueSessions.map((s) => '${s.datum} ${s.ort} ${s.zeilen.length}'),
        ['2026-11-20 Südstadt 6', '2026-11-21 Nordstadt 3']);
    expect(plan.anzahlZeilen, 9);
    expect(plan.neueGeraete.map((g) => '${g.standort}/${g.kuerzel}'), ['Südstadt/N9']);
    expect(plan.laufend, ['2026-11-22 Nordstadt']);
    expect(plan.importiert, 6);
    expect(plan.schonDa, isEmpty);
    expect(plan.abweichend, isEmpty);
    expect(plan.probleme, isEmpty);
    expect(plan.letzteSessionExcel, '2025-04-02');
  });

  test('Zeilen im Format wie bisher (Auto-Notizen, kg/lbs, L/R)', () {
    final z = [for (final s in plan.neueSessions) ...s.zeilen];
    String text(NeueLogZeile x) =>
        '${x.geraet} ${x.satzNr} ${x.kg} ${x.lbs} ${x.einheit.name} ${x.wdh} ${x.notiz}';
    expect(z.map(text), [
      'A2 1 90.72 200.0 lbs 15 Eingabe: 200 lbs; müde',
      'A2 2 95.26 210.0 lbs 12 Eingabe: 210 lbs',
      'X4 1 32.5 71.65 kg 15 Sitz 4',
      'N9-links 1 10.0 22.05 kg 20 null',
      'N9-rechts 1 10.0 22.05 kg 20 null',
      'N9-links 2 12.5 27.56 kg 18 null',
      'T1 1 38.5 84.88 kg 8 assistiert: 78.5 - 40 kg Eingabe',
      'T1 2 55.82 123.06 lbs 6 assistiert: 78.5 kg - 50 lbs Eingabe',
      'A2 1 85.0 187.39 kg 15 null',
    ]);
    final n9 = plan.neueGeraete.single;
    expect(n9.notiz, 'links/rechts getrennt; Griff schmal');
    expect(n9.muskelgruppe, 'Unterarme');
  });

  test('Bestehende Zeilen byte-gleich, vorbereitete Zeilen gefüllt, Rest gleich',
      () {
    final vorher = zeilenXml(original, 'xl/worksheets/sheet1.xml');
    final nachher = zeilenXml(ergebnis, 'xl/worksheets/sheet1.xml');
    for (var nr = 1; nr <= 54; nr++) {
      expect(nachher[nr], vorher[nr], reason: 'Log-Zeile $nr');
    }
    // Zeilen 55–58 waren vorbereitet (nur Volumen-Formel) → gefüllt, dann angehängt
    expect(vorher.keys.where((n) => n > 54), [55, 56, 57, 58]);
    expect(nachher.keys.where((n) => n > 54), [55, 56, 57, 58, 59, 60, 61, 62, 63]);
    expect(nachher[55], contains('2026-11-20'));
    expect(nachher[55], contains('<f>E55*H55</f>'));
    expect(nachher[55], contains('s="2"')); // lbs-Eingabe: kg grau kursiv
    expect(nachher[61], contains('assistiert: 78.5 - 40 kg Eingabe'));

    final gVorher = zeilenXml(original, 'xl/worksheets/sheet2.xml');
    final gNachher = zeilenXml(ergebnis, 'xl/worksheets/sheet2.xml');
    for (var nr = 2; nr <= 16; nr++) {
      expect(gNachher[nr], gVorher[nr], reason: 'Geräte-Zeile $nr');
    }
    expect(gNachher[1], startsWith(gVorher[1]!.replaceAll('</row>', '')));
    expect(gNachher[1], contains('Muskelgruppe'));
    expect(gNachher[17], contains('N9'));

    final a = ZipDecoder().decodeBytes(original);
    final b = ZipDecoder().decodeBytes(ergebnis);
    expect(b.files.map((f) => f.name), a.files.map((f) => f.name));
    for (final f in a.files) {
      if (f.name.startsWith('xl/worksheets/sheet1') ||
          f.name.startsWith('xl/worksheets/sheet2')) {
        continue;
      }
      expect(b.findFile(f.name)!.content, f.content, reason: f.name);
    }
    expect(
        pruefeErgebnis(XlsxMappe.ausBytes(original), XlsxMappe.ausBytes(ergebnis), plan),
        isEmpty);
  });

  test('Erneuter Import des Ergebnisses = dieselben Sätze wie in der App', () async {
    final neu = await importiert(ergebnis);
    addTearDown(neu.close);
    expect(await saetzeNachSession(neu), await saetzeNachSession(app));
    final n9 = await (neu.select(neu.geraete)..where((g) => g.kuerzel.equals('N9')))
        .getSingle();
    expect(n9.linksRechtsGetrennt, isTrue);
    final gruppe = await (neu.select(neu.muskelgruppen)
          ..where((m) => m.id.equals(n9.muskelgruppeId!)))
        .getSingle();
    expect(gruppe.name, 'Unterarme');
    final s2 = await (neu.select(neu.sessions)..where((s) => s.datum.equals('2026-11-21')))
        .getSingle();
    expect(s2.koerpergewichtKg, 78.5);
  });

  test('2. Lauf ergänzt nichts; Korrektur danach wird nur gemeldet', () async {
    final zweiter = await erstellePlan(app, XlsxMappe.ausBytes(ergebnis));
    expect(zweiter.nichtsZuTun, isTrue);
    expect(zweiter.schonDa, ['2026-11-20 Südstadt', '2026-11-21 Nordstadt']);

    // In der App korrigiert → abweichend, nichts geschrieben
    final satz = await (app.select(app.saetze)
          ..orderBy([(s) => OrderingTerm.desc(s.id)])
          ..limit(1))
        .getSingle();
    final s = await (app.select(app.sessions)..where((x) => x.datum.equals('2026-11-21')))
        .getSingle();
    final letzter = await (app.select(app.saetze)
          ..where((x) => x.sessionId.equals(s.id))
          ..orderBy([(x) => OrderingTerm.desc(x.id)])
          ..limit(1))
        .getSingle();
    expect(satz.id, isNot(letzter.id)); // laufende Session hat den neuesten Satz
    await app.aendereSatz(
        satzId: letzter.id,
        heute: '2026-11-21',
        wiederholungen: 12,
        eingabewert: 85,
        einheit: Einheit.kg);
    final dritter = await erstellePlan(app, XlsxMappe.ausBytes(ergebnis));
    expect(dritter.nichtsZuTun, isTrue);
    expect(dritter.abweichend.single, startsWith('2026-11-21 Nordstadt'));
  });

  test('Geräte nur in der App geändert → gemeldet', () async {
    final t1 = await (app.select(app.geraete)..where((g) => g.kuerzel.equals('T1')))
        .getSingle();
    await app.aendereGeraet(
        t1.id,
        GeraetDaten(
            kuerzel: 'T1',
            funktion: 'Klimmzug',
            muskelgruppeId: t1.muskelgruppeId,
            einheit: t1.einheit,
            assistiert: true));
    final p = await erstellePlan(app, XlsxMappe.ausBytes(ergebnis));
    // Vorgabe-Einheit wechselte mit den Sätzen (R2.1)
    expect(p.geaenderteGeraete, [
      'Nordstadt T1: Funktion „Klimmzug“, Vorgabe-Einheit „lbs“',
      'Südstadt X4: Vorgabe-Einheit „kg“',
    ]);
  });

  test('Sicherungen werden nie überschrieben', () {
    final ordner = Directory.systemTemp.createTempSync('rueck');
    addTearDown(() => ordner.deleteSync(recursive: true));
    final a = eindeutigerPfad(ordner.path, 'Krafttraining_Log_Stand_2025-04-02', '.xlsx');
    File(a).writeAsStringSync('x');
    final b = eindeutigerPfad(ordner.path, 'Krafttraining_Log_Stand_2025-04-02', '.xlsx');
    File(b).writeAsStringSync('y');
    final c = eindeutigerPfad(ordner.path, 'Krafttraining_Log_Stand_2025-04-02', '.xlsx');
    expect([a, b, c].map((p) => p.split(Platform.pathSeparator).last), [
      'Krafttraining_Log_Stand_2025-04-02.xlsx',
      'Krafttraining_Log_Stand_2025-04-02_2.xlsx',
      'Krafttraining_Log_Stand_2025-04-02_3.xlsx',
    ]);
  });
}
