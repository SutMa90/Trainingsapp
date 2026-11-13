import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/session_logik.dart';
import 'format.dart';
import 'session_details.dart';

/// WP2.1 Laufende Session: Sätze von heute und „Session beenden“.
/// Die Satz-Erfassung (Gerätekacheln) folgt in WP2.2.
class LaufendeSessionSeite extends StatelessWidget {
  const LaufendeSessionSeite({
    super.key,
    required this.db,
    required this.sessionId,
    required this.jetzt,
  });

  final Datenbank db;
  final int sessionId;
  final DateTime Function() jetzt;

  Future<void> _beende(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ergebnis = await db.beendeSession(sessionId);
    navigator.pop();
    messenger.showSnackBar(switch (ergebnis) {
      BeendenErgebnis.leerVerworfen => const SnackBar(
          content: Text('Session ohne Sätze verworfen.')),
      BeendenErgebnis.beendet => SnackBar(
          content: const Text('Session beendet.'),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Wieder aufnehmen',
            onPressed: () async {
              try {
                await db.nimmSessionWiederAuf(sessionId, isoDatum(jetzt()));
                navigator.push(MaterialPageRoute(
                  builder: (_) => LaufendeSessionSeite(
                      db: db, sessionId: sessionId, jetzt: jetzt),
                ));
              } on StateError catch (e) {
                messenger.showSnackBar(SnackBar(content: Text(e.message)));
              }
            },
          ),
        ),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LaufendeSession?>(
      stream: db.beobachteLaufendeSession(),
      builder: (context, snap) {
        if (!snap.hasData && snap.connectionState != ConnectionState.active) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final laufend = snap.data;
        if (laufend == null || laufend.session.id != sessionId) {
          // Beendet – z. B. automatisch beim Tageswechsel.
          return Scaffold(
            appBar: AppBar(title: const Text('Session')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Diese Session ist beendet.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Zur Übersicht'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final s = laufend.session;
        final kw = s.koerpergewichtKg;
        final text = Theme.of(context).textTheme;
        return Scaffold(
          appBar: AppBar(
            title: Text('${laufend.standort.name} · ${formatDatum(s.datum)}'),
          ),
          body: StreamBuilder<List<SatzMitGeraet>>(
            stream: db.beobachteSaetzeDerSession(sessionId),
            builder: (context, satzSnap) {
              final saetze = satzSnap.data ?? const <SatzMitGeraet>[];
              return ListView.separated(
                itemCount: saetze.length + 1,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        saetze.isEmpty
                            ? 'Session läuft. Noch keine Sätze – die Erfassung '
                                'folgt mit dem nächsten Paket (WP2.2).'
                            : 'Session läuft · ${saetze.length} Sätze'
                                '${kw != null ? ' · Körpergewicht ${formatZahl(kw)} kg' : ''}',
                        style: text.bodyMedium,
                      ),
                    );
                  }
                  return SatzZeile(eintrag: saetze[i - 1]);
                },
              );
            },
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: () => _beende(context),
                icon: const Icon(Icons.stop),
                label: const Text('Session beenden'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
              ),
            ),
          ),
        );
      },
    );
  }
}
