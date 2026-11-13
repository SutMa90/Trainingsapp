import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/satz_logik.dart';
import '../data/db/session_logik.dart';
import 'format.dart';
import 'satz_erfassen.dart';
import 'session_details.dart';

/// WP2.1 Laufende Session: Sätze von heute und „Session beenden“.
/// [Änderung WP2.2] Gerätekacheln oben, darunter die Sätze von heute.
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
          body: CustomScrollView(
            slivers: [
              _Kacheln(
                  db: db,
                  standortId: laufend.standort.id,
                  sessionId: sessionId),
              StreamBuilder<List<SatzMitGeraet>>(
                stream: db.beobachteSaetzeDerSession(sessionId),
                builder: (context, satzSnap) {
                  // Neueste zuerst – im Gym ist der letzte Satz am wichtigsten.
                  final saetze = (satzSnap.data ?? const <SatzMitGeraet>[])
                      .reversed
                      .toList();
                  return SliverList.separated(
                    itemCount: saetze.length + 1,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            saetze.isEmpty
                                ? 'Noch keine Sätze – Gerät antippen.'
                                : 'Heute · ${saetze.length} Sätze'
                                    '${kw != null ? ' · Körpergewicht ${formatZahl(kw)} kg' : ''}',
                            style: text.titleSmall,
                          ),
                        );
                      }
                      return SatzZeile(eintrag: saetze[i - 1]);
                    },
                  );
                },
              ),
            ],
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

/// Gerätekacheln des Standorts (WP2.2). Antippen öffnet die Erfassung.
class _Kacheln extends StatelessWidget {
  const _Kacheln(
      {required this.db, required this.standortId, required this.sessionId});

  final Datenbank db;
  final int standortId;
  final int sessionId;

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<GeraetKachel>>(
      stream: db.beobachteKacheln(standortId, sessionId),
      builder: (context, snap) {
        final kacheln = snap.data ?? const <GeraetKachel>[];
        if (snap.hasData && kacheln.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('An diesem Standort gibt es noch keine Geräte. '
                  'Neue Geräte anlegen folgt mit WP2.5.'),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 104,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: kacheln.length,
            itemBuilder: (context, i) {
              final k = kacheln[i];
              final g = k.geraet;
              final gemacht = k.saetzeHeute > 0;
              return Material(
                color: gemacht
                    ? farben.primaryContainer
                    : farben.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => zeigeSatzErfassen(context,
                      db: db, sessionId: sessionId, geraet: g),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(g.kuerzel,
                            style: text.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        if (g.funktion != null)
                          Text(g.funktion!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: text.bodySmall),
                        if (gemacht)
                          Text('${k.saetzeHeute} ✓',
                              style: text.labelMedium
                                  ?.copyWith(color: farben.primary)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
