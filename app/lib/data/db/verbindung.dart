// Öffnet die Datenbankdatei auf dem Handy.
// (Flutter-spezifisch; das Umwandlungsskript öffnet die Datei auf dem PC selbst.)
//
// Erster Start: Gibt es noch keine Datenbankdatei, übernimmt die App die
// Startdatenbank aus `assets/db/startdb.sqlite` (vom Umwandlungsskript
// erzeugt). Fehlt diese, startet die App mit einer leeren Datenbank.
// Bei jedem weiteren Start wird nichts überschrieben.

import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'datenbank.dart';

const datenbankName = 'trainingsapp';
const startdatenbankAsset = 'assets/db/startdb.sqlite';

Datenbank oeffneDatenbank() => Datenbank(driftDatabase(
      name: datenbankName,
      native: DriftNativeOptions(databasePath: _pfadMitStartdatenbank),
    ));

Future<String> _pfadMitStartdatenbank() async {
  final ordner = await getApplicationDocumentsDirectory();
  final datei = File(p.join(ordner.path, '$datenbankName.sqlite'));
  if (!datei.existsSync()) {
    try {
      final daten = await rootBundle.load(startdatenbankAsset);
      await datei.writeAsBytes(
          daten.buffer.asUint8List(daten.offsetInBytes, daten.lengthInBytes),
          flush: true);
      debugPrint('Startdatenbank übernommen (${daten.lengthInBytes} Bytes).');
    } on FlutterError {
      debugPrint('Keine Startdatenbank im Paket – starte mit leerer Datenbank.');
    }
  }
  return datei.path;
}
