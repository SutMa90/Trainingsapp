// Umwandlungsskript Excel → Startdatenbank (läuft nur auf dem PC).
//
// Aufruf im Ordner app/:
//   dart run tool/import_excel/main.dart
//
// Standardwerte (alle überschreibbar):
//   --excel           ../Krafttraining_Log.xlsx
//   --entscheidungen  tool/import_excel/entscheidungen.json
//   --ziel            assets/db/startdb.sqlite
//   --bericht         tool/import_excel/out/pruefbericht.md
//
// Testlauf mit den synthetischen Daten:
//   dart run tool/import_excel/main.dart --excel ../testdaten/Testlog.xlsx
//     --entscheidungen ../testdaten/entscheidungen.json
//     --ziel tool/import_excel/out/test.sqlite
//     --bericht tool/import_excel/out/pruefbericht_test.md

import 'dart:io';

import 'package:drift/native.dart';
import 'package:trainingsapp/data/db/datenbank.dart';

import 'importer.dart';
import 'xlsx_leser.dart';

Future<void> main(List<String> args) async {
  final opt = <String, String>{
    'excel': '../Krafttraining_Log.xlsx',
    'entscheidungen': 'tool/import_excel/entscheidungen.json',
    'ziel': 'assets/db/startdb.sqlite',
    'bericht': 'tool/import_excel/out/pruefbericht.md',
  };
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('--') || i + 1 >= args.length || !opt.containsKey(a.substring(2))) {
      stderr.writeln('Unbekannter Parameter: $a');
      exit(64);
    }
    opt[a.substring(2)] = args[++i];
  }

  if (!File(opt['excel']!).existsSync()) {
    stderr.writeln('Excel-Datei nicht gefunden: ${opt['excel']}');
    exit(66);
  }

  final mappe = XlsxMappe.lies(opt['excel']!);
  final entscheidungen = Entscheidungen.ausDatei(opt['entscheidungen']!);

  final ziel = File(opt['ziel']!);
  ziel.parent.createSync(recursive: true);
  if (ziel.existsSync()) ziel.deleteSync();
  final db = Datenbank(NativeDatabase(ziel));

  final erg = await importiere(mappe: mappe, entscheidungen: entscheidungen, db: db);
  await db.close();

  final bericht = File(opt['bericht']!);
  bericht.parent.createSync(recursive: true);
  bericht.writeAsStringSync(erg.alsMarkdown(quelle: opt['excel']!));

  stdout
    ..writeln('Startdatenbank: ${ziel.path}')
    ..writeln('Prüfbericht:    ${bericht.path}')
    ..writeln('Log-Zeilen ${erg.logZeilenMitInhalt}, importiert '
        '${erg.importierteSaetze}, Fehler ${erg.fehler.length}, '
        'Warnungen ${erg.warnungen.length}, Sessions ${erg.sessions.length}, '
        'Geräte ${erg.geraeteImportiert}');
  if (erg.grundfehler.isNotEmpty) {
    stderr.writeln('Achtung: Fehler in Geräten oder Entscheidungsdatei:');
    for (final m in erg.grundfehler) {
      stderr.writeln('  - $m');
    }
    exit(1);
  }
}
