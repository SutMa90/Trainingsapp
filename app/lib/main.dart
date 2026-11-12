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
  const TrainingsApp({super.key, required this.db});

  final Datenbank db;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trainings-App',
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
      home: SessionListe(db: db),
    );
  }
}
