// WP2.6 Rückübertragung: Dateinamen der Sicherungen (nie überschreiben).

import 'dart:io';

/// `ordner/name.endung`; gibt es die Datei schon, `name_2.endung`, `name_3` …
String eindeutigerPfad(String ordner, String name, String endung) {
  final sep = Platform.pathSeparator;
  var pfad = '$ordner$sep$name$endung';
  for (var i = 2; File(pfad).existsSync(); i++) {
    pfad = '$ordner$sep${name}_$i$endung';
  }
  return pfad;
}
