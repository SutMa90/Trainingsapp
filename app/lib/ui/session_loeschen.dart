import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/session_logik.dart';
import 'format.dart';

/// Anzeige der App-Version einer Session; leer = importiert → „imp“.
String versionText(TrainingsSession s) => s.appVersion ?? 'imp';

/// WP2.4 [Änderung M2]: Session nach Rückfrage endgültig löschen.
/// Importierte Sessions sind geschützt. Gibt true zurück, wenn gelöscht.
Future<bool> frageUndLoescheSession(
  BuildContext context, {
  required Datenbank db,
  required TrainingsSession session,
  required String standort,
  required int anzahlSaetze,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Session löschen?'),
      content: Text(
        '${formatDatum(session.datum)} · $standort · '
        '$anzahlSaetze ${anzahlSaetze == 1 ? 'Satz' : 'Sätze'}\n\n'
        'Endgültig löschen? Das lässt sich nicht rückgängig machen.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
            foregroundColor: Theme.of(ctx).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Endgültig löschen'),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  try {
    await db.loescheSession(session.id);
    messenger.showSnackBar(const SnackBar(content: Text('Session gelöscht.')));
    return true;
  } on StateError catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return false;
  }
}
