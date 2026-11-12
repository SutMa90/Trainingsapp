import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import 'format.dart';

/// Kontrollansicht M1: alle Sessions mit Datum, Standort und Anzahl Sätze.
class SessionListe extends StatelessWidget {
  const SessionListe({super.key, required this.db});

  final Datenbank db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: StreamBuilder<List<SessionUebersicht>>(
        stream: db.beobachteSessionUebersicht(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Fehler beim Laden: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final liste = snap.data!;
          if (liste.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Noch keine Sessions.\nDie Datenbank ist bereit.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final summe = liste.fold<int>(0, (s, e) => s + e.anzahlSaetze);
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: liste.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final e = liste[i];
                    return ListTile(
                      title: Text(formatDatum(e.session.datum)),
                      subtitle: Text(e.standort.name),
                      trailing: Text(
                        '${e.anzahlSaetze} Sätze',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('${liste.length} Sessions · $summe Sätze',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
