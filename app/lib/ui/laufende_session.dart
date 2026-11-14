import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/geraete_logik.dart';
import '../data/db/satz_logik.dart';
import '../data/db/session_logik.dart';
import 'format.dart';
import 'geraet_formular.dart';
import 'satz_erfassen.dart';
import 'satz_bearbeiten.dart';
import 'session_details.dart';
import 'session_loeschen.dart';

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
        content: Text('Session ohne Sätze verworfen.'),
      ),
      BeendenErgebnis.beendet => SnackBar(
        content: const Text('Session beendet.'),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Wieder aufnehmen',
          onPressed: () async {
            try {
              await db.nimmSessionWiederAuf(sessionId, isoDatum(jetzt()));
              navigator.push(
                MaterialPageRoute(
                  builder: (_) => LaufendeSessionSeite(
                    db: db,
                    sessionId: sessionId,
                    jetzt: jetzt,
                  ),
                ),
              );
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
                    const Text(
                      'Diese Session ist beendet.',
                      textAlign: TextAlign.center,
                    ),
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
            actions: [
              // WP2.4 [Änderung M2]: Session löschen (z. B. Test-Session)
              PopupMenuButton<String>(
                tooltip: 'Menü',
                onSelected: (_) async {
                  final navigator = Navigator.of(context);
                  final anzahl =
                      (await db.beobachteSaetzeDerSession(sessionId).first)
                          .length;
                  if (!context.mounted) return;
                  final weg = await frageUndLoescheSession(
                    context,
                    db: db,
                    session: s,
                    standort: laufend.standort.name,
                    anzahlSaetze: anzahl,
                  );
                  if (weg) navigator.pop();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'loeschen',
                    child: Text('Session löschen'),
                  ),
                ],
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              _Kacheln(
                db: db,
                standort: laufend.standort,
                sessionId: sessionId,
              ),
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
                      // WP2.4: Satz antippen → korrigieren oder löschen
                      final e = saetze[i - 1];
                      return SatzZeile(
                        eintrag: e,
                        onTap: () => zeigeSatzBearbeiten(
                          context,
                          db: db,
                          satzId: e.satz.id,
                          heute: s.datum,
                        ),
                      );
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
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Gerätekacheln des Standorts (WP2.2). Antippen öffnet die Erfassung.
/// [Änderung WP2.5] Letzte Kachel „＋ Neu“ legt ein Gerät an und öffnet gleich
/// den ersten Satz; langer Druck auf eine Kachel = Gerät bearbeiten.
class _Kacheln extends StatelessWidget {
  const _Kacheln({
    required this.db,
    required this.standort,
    required this.sessionId,
  });

  final Datenbank db;
  final Standort standort;
  final int sessionId;

  Future<void> _neuesGeraet(BuildContext context) async {
    final id = await zeigeGeraetFormular(
      context,
      db: db,
      standortId: standort.id,
      standortName: standort.name,
    );
    if (id == null) return;
    final g = await db.geraetMitId(id);
    if (!context.mounted) return;
    await zeigeSatzErfassen(context, db: db, sessionId: sessionId, geraet: g);
  }

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<GeraetKachel>>(
      stream: db.beobachteKacheln(standort.id, sessionId),
      builder: (context, snap) {
        final kacheln = snap.data ?? const <GeraetKachel>[];
        return SliverMainAxisGroup(
          slivers: [
            if (snap.hasData && kacheln.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'An diesem Standort gibt es noch keine Geräte – '
                    '„＋ Neu“ antippen.',
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 104,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: snap.hasData ? kacheln.length + 1 : 0,
                itemBuilder: (context, i) {
                  if (i == kacheln.length) {
                    return Material(
                      color: farben.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: farben.outlineVariant),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _neuesGeraet(context),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: farben.primary),
                                Text(
                                  'Neu',
                                  style: text.titleMedium?.copyWith(
                                    color: farben.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
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
                      onTap: () => zeigeSatzErfassen(
                        context,
                        db: db,
                        sessionId: sessionId,
                        geraet: g,
                      ),
                      onLongPress: () => zeigeGeraetFormular(
                        context,
                        db: db,
                        standortId: standort.id,
                        standortName: standort.name,
                        geraet: g,
                      ),
                      // [Änderung 0.2.3] Anzahl als Abzeichen in der Ecke; der
                      // Inhalt wird verkleinert statt abgeschnitten.
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SizedBox(
                                  width: 92,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        g.kuerzel,
                                        style: text.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (g.funktion != null)
                                        Text(
                                          g.funktion!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: text.bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (gemacht)
                            Positioned(
                              top: 4,
                              right: 6,
                              child: Text(
                                '${k.saetzeHeute} ✓',
                                style: text.labelMedium?.copyWith(
                                  color: farben.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
