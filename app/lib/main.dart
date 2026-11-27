import 'package:flutter/material.dart';

import 'data/db/datenbank.dart';
import 'data/db/verbindung.dart';
import 'ui/session_liste.dart';
import 'ui/tastatur_waechter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = oeffneDatenbank();
  runApp(TrainingsApp(db: db));
}

/// Dunkelmodus.
///
/// [Änderung 0.2.12] Hinweisleiste unten (z. B. „Session beendet · Wieder
/// aufnehmen“): Material 3 zeigt sie im Dunkelmodus hell (umgekehrte Farben).
/// Das wirkte wie ein Fehler (Rückmeldung 26.11.2026). Jetzt dunkelgrau mit
/// türkisem Knopftext, als schwebende Karte mit Abstand zum Rand – weiterhin
/// gut vom Hintergrund abgehoben.
ThemeData gymiDunkel() {
  final farben = ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.dark,
  );
  return ThemeData(
    colorScheme: farben,
    useMaterial3: true,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: farben.surfaceContainerHighest,
      contentTextStyle: TextStyle(color: farben.onSurface, fontSize: 16),
      actionTextColor: farben.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: farben.outlineVariant),
      ),
    ),
  );
}

class TrainingsApp extends StatelessWidget {
  const TrainingsApp({super.key, required this.db, this.jetzt = DateTime.now});

  final Datenbank db;

  /// Uhr der App (in Tests ersetzbar, z. B. für den Tageswechsel).
  final DateTime Function() jetzt;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gymi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      darkTheme: gymiDunkel(),
      // [Änderung 0.2.11] kein hängender Tastaturbereich (siehe Datei)
      builder: (context, kind) => TastaturWaechter(child: kind!),
      home: SessionListe(db: db, jetzt: jetzt),
    );
  }
}
