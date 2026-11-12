// Öffnet die Datenbankdatei auf dem Handy.
// (Flutter-spezifisch; das Umwandlungsskript öffnet die Datei auf dem PC selbst.)

import 'package:drift_flutter/drift_flutter.dart';

import 'datenbank.dart';

const datenbankName = 'trainingsapp';

Datenbank oeffneDatenbank() => Datenbank(driftDatabase(name: datenbankName));
