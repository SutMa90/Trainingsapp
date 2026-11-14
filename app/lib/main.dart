import 'package:flutter/material.dart';

import 'data/db/datenbank.dart';
import 'data/db/verbindung.dart';
import 'ui/session_liste.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = oeffneDatenbank();
  runApp(TrainingsApp(db: db));
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
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: SessionListe(db: db, jetzt: jetzt),
    );
  }
}
