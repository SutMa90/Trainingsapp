import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/session_logik.dart';
import '../version.dart';
import 'format.dart';
import 'laufende_session.dart';
import 'session_details.dart';
import 'session_loeschen.dart';
import 'start_seite.dart';

/// Startseite: „Session starten“ bzw. laufende Session, darunter alle
/// Sessions mit Datum, Standort und Anzahl Sätze.
///
/// [Änderung M2] Beim Öffnen und bei jeder Rückkehr in die App werden
/// Sessions vergangener Tage automatisch beendet (keine Session über mehrere
/// Tage). Läuft beim App-Start eine Session, öffnet sie sich direkt.
class SessionListe extends StatefulWidget {
  const SessionListe({super.key, required this.db, this.jetzt = DateTime.now});

  final Datenbank db;
  final DateTime Function() jetzt;

  @override
  State<SessionListe> createState() => _SessionListeState();
}

class _SessionListeState extends State<SessionListe>
    with WidgetsBindingObserver {
  Datenbank get db => widget.db;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _beimStart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tagesPruefung();
  }

  Future<void> _tagesPruefung() =>
      db.schliesseVergangeneSessions(isoDatum(widget.jetzt()));

  Future<void> _beimStart() async {
    await _tagesPruefung();
    final laufend = await db.laufendeSession();
    if (laufend != null && mounted) _oeffneLaufende(laufend.session.id);
  }

  void _oeffneLaufende(int id) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          LaufendeSessionSeite(db: db, sessionId: id, jetzt: widget.jetzt),
    ),
  );

  void _oeffneStart() => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => StartSeite(db: db, jetzt: widget.jetzt),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Gymi')),
      body: Column(
        children: [
          StreamBuilder<LaufendeSession?>(
            stream: db.beobachteLaufendeSession(),
            builder: (context, snap) {
              final laufend = snap.data;
              if (laufend != null) {
                return Card(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: const Text('Laufende Session'),
                    subtitle: Text(
                      '${laufend.standort.name} · '
                      '${formatDatum(laufend.session.datum)}',
                    ),
                    trailing: FilledButton(
                      onPressed: () => _oeffneLaufende(laufend.session.id),
                      child: const Text('Weiter'),
                    ),
                    onTap: () => _oeffneLaufende(laufend.session.id),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: FilledButton.icon(
                  onPressed:
                      snap.hasData ||
                          snap.connectionState == ConnectionState.active
                      ? _oeffneStart
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Session starten'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<List<SessionUebersicht>>(
              stream: db.beobachteSessionUebersicht(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text('Fehler beim Laden: ${snap.error}'),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final liste = snap.data!;
                final summe = liste.fold<int>(0, (s, e) => s + e.anzahlSaetze);
                return Column(
                  children: [
                    Expanded(
                      child: liste.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'Noch keine Sessions.\nDie Datenbank ist bereit.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: liste.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) =>
                                  _zeile(context, liste[i]),
                            ),
                    ),
                    if (liste.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${liste.length} Sessions · $summe Sätze',
                          style: text.bodySmall,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
              child: Text(
                'Version $appVersion',
                style: text.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _zeile(BuildContext context, SessionUebersicht e) {
    final laeuft = !e.session.abgeschlossen;
    return ListTile(
      title: Text(formatDatum(e.session.datum)),
      // [Änderung M2] App-Version bzw. „imp“ (importiert)
      subtitle: Text(
        '${e.standort.name} · ${versionText(e.session)}'
        '${laeuft ? ' · läuft' : ''}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${e.anzahlSaetze} Sätze',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => laeuft
          ? _oeffneLaufende(e.session.id)
          : Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    SessionDetails(db: db, uebersicht: e, jetzt: widget.jetzt),
              ),
            ),
    );
  }
}
