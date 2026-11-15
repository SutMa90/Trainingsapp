// WP2.6 Rückübertragung App → Excel (Weg A: USB-Kabel + Doppelklick am PC).
//
// Aufruf über die Doppelklick-Datei im Projektordner oder im Ordner app/:
//   dart run tool/rueckuebertragung/main.dart [--probe]
//
// Optionen:
//   --probe           schreibt nur in eine Kopie der Excel in Sicherungen/Probe/
//   --excel PFAD      Excel-Datei (Standard ../Krafttraining_Log.xlsx)
//   --sicherungen P   Ordner für Sicherungen und Bericht (Standard ../Sicherungen)
//   --db PFAD         App-Datenbank aus einer Datei statt vom Handy
//
// Ablauf: Handy-Kopie holen (= Sicherung) → Excel lesen → Vorschau →
// „J“ → Sicherung der Excel → schreiben → prüfen → Bericht.
// Jeder Abbruch erklärt den Grund und was zu tun ist; die Excel bleibt dann
// unverändert.

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:trainingsapp/data/db/datenbank.dart';

import '../import_excel/xlsx_leser.dart';
import 'abgleich.dart';
import 'dateien.dart';
import 'xlsx_schreiber.dart';

const paket = 'com.sutma90.trainingsapp';
const datenbankAufHandy = 'app_flutter/trainingsapp.sqlite';

/// Abbruch mit Erklärung für den Nutzer.
class Abbruch implements Exception {
  final String grund, wasTun;
  const Abbruch(this.grund, this.wasTun);
}

final _bericht = StringBuffer();

void sag([String text = '']) {
  stdout.writeln(text);
  _bericht.writeln(text);
}

String heute() => DateTime.now().toIso8601String().substring(0, 10);

Future<void> main(List<String> args) async {
  final opt = <String, String>{
    'excel': '../Krafttraining_Log.xlsx',
    'sicherungen': '../Sicherungen',
  };
  var probe = false;
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--probe') {
      probe = true;
    } else if (a.startsWith('--') && i + 1 < args.length && {'excel', 'sicherungen', 'db'}.contains(a.substring(2))) {
      opt[a.substring(2)] = args[++i];
    } else {
      stderr.writeln('Unbekannter Parameter: $a');
      exit(64);
    }
  }

  String? berichtOrdner;
  try {
    berichtOrdner = await ablauf(opt, probe: probe);
    exitCode = 0;
  } on Abbruch catch (a) {
    sag();
    sag('ABBRUCH: ${a.grund}');
    sag('Was tun: ${a.wasTun}');
    sag('Die Excel wurde nicht verändert.');
    exitCode = 1;
  } catch (e) {
    sag();
    sag('ABBRUCH wegen eines unerwarteten Fehlers: $e');
    sag('Was tun: Fenster offen lassen und den Text an Claude weitergeben. '
        'Die Excel wurde nicht verändert.');
    exitCode = 2;
  }
  // Bericht immer ablegen (auch bei Abbruch), nie im Repository
  try {
    final ordner = berichtOrdner ?? opt['sicherungen']!;
    Directory(ordner).createSync(recursive: true);
    final pfad = eindeutigerPfad(
        ordner, 'Rueckuebertragung_${heute()}${probe ? '_Probe' : ''}', '.txt');
    File(pfad).writeAsStringSync(_bericht.toString());
    stdout.writeln('\nBericht gespeichert: ${zeig(pfad)}');
  } catch (_) {
    // Bericht ist Zusatz – kein weiterer Abbruch
  }
}

/// Gibt den Ordner für den Bericht zurück.
Future<String> ablauf(Map<String, String> opt, {required bool probe}) async {
  sag('Rückübertragung Gymi → Excel${probe ? ' (PROBELAUF auf einer Kopie)' : ''}');
  sag('Datum: ${heute()}');
  sag();

  final sicherungen = Directory(opt['sicherungen']!);
  sicherungen.createSync(recursive: true);
  final ablage = probe ? Directory('${sicherungen.path}/Probe') : sicherungen;
  ablage.createSync(recursive: true);

  // ------------------------------------------------------------ Excel
  final echt = File(opt['excel']!);
  if (!echt.existsSync()) {
    throw Abbruch('Die Excel wurde nicht gefunden (${zeig(echt.path)}).',
        'Die Datei muss „Krafttraining_Log.xlsx“ heissen und im Projektordner liegen.');
  }
  pruefeNichtGeoeffnet(echt);
  var excel = echt;
  if (probe) {
    final kopie = eindeutigerPfad(ablage.path, 'Krafttraining_Log_Probe_${heute()}', '.xlsx');
    echt.copySync(kopie);
    excel = File(kopie);
    sag('Probelauf: geschrieben wird nur in die Kopie');
    sag('  ${zeig(excel.path)}');
    sag();
  }

  // ------------------------------------------------- App-Datenbank holen
  final Uint8List dbBytes;
  if (opt['db'] != null) {
    final f = File(opt['db']!);
    if (!f.existsSync()) {
      throw Abbruch('Die angegebene Datenbank-Datei fehlt (${f.path}).', 'Pfad prüfen.');
    }
    dbBytes = f.readAsBytesSync();
    sag('App-Datenbank aus Datei: ${f.path}');
  } else {
    dbBytes = await holeVomHandy();
    sag('App-Datenbank vom Handy geholt (${(dbBytes.length / 1024).round()} KB).');
  }
  final arbeit = Directory.systemTemp.createTempSync('gymi_rueck');
  final arbeitsDb = File('${arbeit.path}/trainingsapp.sqlite')..writeAsBytesSync(dbBytes);
  final Datenbank db;
  try {
    db = await oeffneGeprueft(arbeitsDb, Datenbank(NativeDatabase.memory()).schemaVersion);
  } catch (_) {
    try {
      arbeit.deleteSync(recursive: true);
    } catch (_) {}
    rethrow;
  }
  try {
    final mappeVorher = liesExcel(excel);
    final plan = await erstellePlan(db, mappeVorher);

    // Sicherung der App-Datenbank (immer, unverändert)
    final dbSicherung = eindeutigerPfad(ablage.path,
        'App-Datenbank_Stand_${plan.letzteSessionApp ?? heute()}', '.sqlite');
    File(dbSicherung).writeAsBytesSync(dbBytes);
    sag('Sicherung der App-Datenbank: ${zeig(dbSicherung)}');
    sag();

    zeigeVorschau(plan);
    if (plan.nichtsZuTun) {
      sag();
      sag('Nichts zu übertragen – die Excel bleibt unverändert.');
      return ablage.path;
    }

    // -------------------------------------------------------- Rückfrage
    sag();
    stdout.write('Übertragen? J = ja, N = nein: ');
    final antwort = stdin.readLineSync()?.trim().toUpperCase();
    _bericht.writeln('Übertragen? → ${antwort ?? ''}');
    if (antwort != 'J') {
      sag('Nicht übertragen (Antwort „${antwort ?? ''}“) – die Excel bleibt unverändert.');
      return ablage.path;
    }
    pruefeNichtGeoeffnet(excel);

    // -------------------------------------- Sicherung der Excel, schreiben
    final original = excel.readAsBytesSync();
    final xlsxSicherung = eindeutigerPfad(ablage.path,
        'Krafttraining_Log_Stand_${plan.letzteSessionExcel ?? 'leer'}', '.xlsx');
    File(xlsxSicherung).writeAsBytesSync(original);
    sag('Sicherung der Excel: ${zeig(xlsxSicherung)}');

    final List<int> neu;
    try {
      neu = ergaenzeXlsx(original, plan);
    } on SchreibFehler catch (e) {
      throw Abbruch('Die Excel lässt sich nicht sicher ergänzen: ${e.grund}',
          'Text an Claude weitergeben.');
    }
    final probleme = pruefeErgebnis(mappeVorher, XlsxMappe.ausBytes(neu), plan);
    if (probleme.isNotEmpty) {
      throw Abbruch('Die Prüfung nach dem Schreiben hat Unterschiede gefunden: '
          '${probleme.take(5).join('; ')}', 'Text an Claude weitergeben.');
    }
    final temp = File('${excel.path}.neu');
    temp.writeAsBytesSync(neu, flush: true);
    try {
      pruefeNichtGeoeffnet(excel);
      temp.renameSync(excel.path);
    } on FileSystemException catch (e) {
      if (temp.existsSync()) temp.deleteSync();
      throw Abbruch('Die Excel konnte nicht ersetzt werden (${e.message}).',
          'Excel schliessen und nochmals doppelklicken.');
    }
    sag();
    sag('Übertragen: ${anzahl(plan.neueSessions.length, 'Session', 'Sessions')}, '
        '${anzahl(plan.anzahlZeilen, 'Zeile', 'Zeilen')}'
        '${plan.neueGeraete.isEmpty ? '' : ', ${anzahl(plan.neueGeraete.length, 'neues Gerät', 'neue Geräte')}'}.');
    sag('Fertig. Excel: ${zeig(excel.path)}');
    return ablage.path;
  } finally {
    await db.close();
    try {
      arbeit.deleteSync(recursive: true);
    } catch (_) {}
  }
}

XlsxMappe liesExcel(File f) {
  try {
    return XlsxMappe.ausBytes(f.readAsBytesSync(), pfad: f.path);
  } on Object catch (e) {
    throw Abbruch('Die Excel lässt sich nicht lesen ($e).',
        'Prüfen, ob die Datei in Excel normal aufgeht; sonst Text an Claude weitergeben.');
  }
}

/// Bricht ab, wenn die Excel gerade in Excel geöffnet ist.
void pruefeNichtGeoeffnet(File excel) {
  final sperre = File('${excel.parent.path}${Platform.pathSeparator}~\$${excel.uri.pathSegments.last}');
  var offen = sperre.existsSync();
  if (!offen) {
    try {
      excel.openSync(mode: FileMode.append).closeSync();
    } on FileSystemException {
      offen = true;
    }
  }
  if (offen) {
    throw const Abbruch('Die Excel ist gerade in Excel geöffnet.',
        'Excel schliessen (auch im Hintergrund), dann nochmals doppelklicken.');
  }
}

String adbPfad() {
  final local = Platform.environment['LOCALAPPDATA'] ?? '';
  return '$local\\Android\\Sdk\\platform-tools\\adb.exe';
}

Future<Uint8List> holeVomHandy() async {
  final adb = adbPfad();
  if (!File(adb).existsSync()) {
    throw Abbruch('Das Android-Werkzeug adb wurde nicht gefunden ($adb).',
        'Android Studio bzw. die Android-SDK-Platform-Tools müssen installiert sein.');
  }
  final geraete = await Process.run(adb, ['devices']);
  final zeilen = '${geraete.stdout}'
      .split('\n')
      .skip(1)
      .map((z) => z.trim())
      .where((z) => z.isNotEmpty)
      .toList();
  if (zeilen.isEmpty) {
    throw const Abbruch('Kein Handy gefunden.',
        'Handy per USB-Kabel verbinden und entsperren; USB-Debugging muss eingeschaltet sein.');
  }
  if (zeilen.any((z) => z.endsWith('unauthorized'))) {
    throw const Abbruch('Das Handy hat den Zugriff noch nicht erlaubt.',
        'Auf dem Handy die Frage „USB-Debugging zulassen?“ bestätigen, dann nochmals doppelklicken.');
  }
  if (zeilen.any((z) => z.endsWith('offline'))) {
    throw const Abbruch('Das Handy antwortet nicht (offline).',
        'USB-Kabel kurz aus- und wieder einstecken, Handy entsperren, nochmals doppelklicken.');
  }
  if (zeilen.length > 1) {
    throw const Abbruch('Mehr als ein Android-Gerät ist verbunden.',
        'Nur das Handy verbunden lassen (Emulator schliessen), dann nochmals doppelklicken.');
  }
  final ls = await Process.run(adb, ['exec-out', 'run-as', paket, 'ls', 'app_flutter']);
  final dateien = '${ls.stdout}'.split(RegExp(r'\s+'));
  if (ls.exitCode != 0 || !dateien.contains('trainingsapp.sqlite')) {
    throw Abbruch('Die Gymi-Datenbank wurde auf dem Handy nicht gefunden '
        '(${'${ls.stderr}${ls.stdout}'.trim()}).',
        'Gymi einmal öffnen; die Debug-Version von Gymi muss installiert sein.');
  }
  if (dateien.any((d) => d.endsWith('-journal') || d.endsWith('-wal'))) {
    throw const Abbruch('Gymi schreibt gerade in die Datenbank.',
        'Gymi am Handy ganz schliessen (aus den zuletzt verwendeten Apps wegwischen), '
            'dann nochmals doppelklicken.');
  }
  final cat = await Process.run(
      adb, ['exec-out', 'run-as', paket, 'cat', datenbankAufHandy],
      stdoutEncoding: null);
  final bytes = Uint8List.fromList(cat.stdout as List<int>);
  const kopf = 'SQLite format 3';
  if (cat.exitCode != 0 ||
      bytes.length < 100 ||
      String.fromCharCodes(bytes.sublist(0, kopf.length)) != kopf) {
    throw const Abbruch('Die Kopie der Gymi-Datenbank ist unvollständig.',
        'Handy entsperrt lassen und nochmals doppelklicken.');
  }
  return bytes;
}

/// Öffnet die Datenbank-Kopie, nachdem Vollständigkeit und Version geprüft
/// sind. Die Prüfung läuft beim Öffnen, noch bevor drift die Datenbank
/// umstellen könnte; bei einem Befund bleibt die Kopie unangetastet.
Future<Datenbank> oeffneGeprueft(File datei, int erwartet) async {
  Abbruch? befund;
  final db = Datenbank(NativeDatabase(datei, setup: (roh) {
    final ok = roh.select('PRAGMA integrity_check').first.values.first;
    final version = roh.select('PRAGMA user_version').first.values.first as int;
    if (ok != 'ok') {
      befund = Abbruch('Die Kopie der Gymi-Datenbank ist beschädigt ($ok).',
          'Gymi am Handy ganz schliessen und nochmals doppelklicken.');
    } else if (version > erwartet) {
      befund = Abbruch('Gymi ist neuer als dieses Programm (Datenbank-Version $version).',
          'Projekt aktualisieren (Claude fragen), dann nochmals doppelklicken.');
    } else if (version < erwartet) {
      befund = Abbruch('Gymi auf dem Handy ist veraltet (Datenbank-Version $version).',
          'Zuerst die aktuelle Gymi-Version installieren und einmal öffnen.');
    }
    if (befund != null) throw befund!;
  }));
  try {
    await db.customSelect('SELECT 1').get();
  } catch (e) {
    await db.close();
    throw befund ??
        Abbruch('Die Kopie der Gymi-Datenbank lässt sich nicht öffnen ($e).',
            'Gymi am Handy ganz schliessen und nochmals doppelklicken.');
  }
  return db;
}

void zeigeVorschau(Plan plan) {
  sag('Vorschau');
  sag('--------');
  sag('Letzte Session in der Excel: ${plan.letzteSessionExcel ?? '–'}');
  sag('Letzte Session in der App:   ${plan.letzteSessionApp ?? '–'}');
  sag();
  if (plan.neueSessions.isEmpty) {
    sag('Neue Sessions: keine');
  } else {
    sag('Neue Sessions: ${plan.neueSessions.length} mit ${anzahl(plan.anzahlZeilen, 'Satz', 'Sätzen')}');
    for (final s in plan.neueSessions) {
      sag('  ${s.datum} ${s.ort}: ${anzahl(s.zeilen.length, 'Satz', 'Sätze')}');
    }
  }
  if (plan.neueGeraete.isNotEmpty) {
    sag('Neue Geräte (Tab Geräte): ${plan.neueGeraete.length}');
    for (final g in plan.neueGeraete) {
      sag('  ${g.standort} ${g.kuerzel}${g.funktion == null ? '' : ' – ${g.funktion}'}');
    }
  }
  sag('Schon in der Excel: ${plan.schonDa.length} Sessions aus der App, '
      '${plan.importiert} importierte');
  void liste(String titel, List<String> l) {
    if (l.isEmpty) return;
    sag('$titel: ${l.length}');
    for (final e in l) {
      sag('  $e');
    }
  }

  liste('Läuft noch (wird erst nach „Session beenden“ übertragen)', plan.laufend);
  liste('Abweichend – NICHT übertragen, Excel bleibt so', plan.abweichend);
  liste('Nicht übertragbar', plan.probleme);
  liste('Nur in der Excel (in der App nicht vorhanden oder gelöscht)', plan.nurExcel);
  liste('Nur in der App, aus früherem Import – fehlt in der Excel', plan.nurAppImportiert);
  liste('Geräte nur in der App geändert (kommt nicht in die Excel)', plan.geaenderteGeraete);
}

/// „1 Satz“, „3 Sätze“.
String anzahl(int n, String eins, String mehr) => '$n ${n == 1 ? eins : mehr}';

/// Vollständiger, bereinigter Pfad für die Anzeige.
String zeig(String pfad) => p.normalize(File(pfad).absolute.path);
