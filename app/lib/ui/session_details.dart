import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/session_logik.dart';
import 'format.dart';
import 'laufende_session.dart';
import 'satz_bearbeiten.dart';
import 'session_loeschen.dart';

/// Liste der Sätze einer Session (M1, Variante a).
/// Reihenfolge = Erfassungsreihenfolge (wie in der Excel).
/// [Änderung M2] Eine heute beendete Session lässt sich hier wieder aufnehmen;
/// ihre Sätze lassen sich antippen und korrigieren (WP2.4). Von der App
/// erzeugte Sessions lassen sich löschen; Kopf zeigt die App-Version / „imp“.
class SessionDetails extends StatelessWidget {
  const SessionDetails({
    super.key,
    required this.db,
    required this.uebersicht,
    this.jetzt = DateTime.now,
  });

  final Datenbank db;
  final SessionUebersicht uebersicht;
  final DateTime Function() jetzt;

  Future<void> _wiederAufnehmen(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await db.nimmSessionWiederAuf(uebersicht.session.id, isoDatum(jetzt()));
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => LaufendeSessionSeite(
            db: db,
            sessionId: uebersicht.session.id,
            jetzt: jetzt,
          ),
        ),
      );
    } on StateError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = uebersicht.session;
    final kw = s.koerpergewichtKg;
    final heute = isoDatum(jetzt());
    final vonHeute = s.datum == heute;
    return Scaffold(
      appBar: AppBar(
        title: Text('${formatDatum(s.datum)} · ${uebersicht.standort.name}'),
        actions: [
          if (s.appVersion != null)
            PopupMenuButton<String>(
              tooltip: 'Menü',
              onSelected: (_) async {
                final navigator = Navigator.of(context);
                final weg = await frageUndLoescheSession(
                  context,
                  db: db,
                  session: s,
                  standort: uebersicht.standort.name,
                  anzahlSaetze: uebersicht.anzahlSaetze,
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
      bottomNavigationBar: vonHeute && s.abgeschlossen
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: OutlinedButton.icon(
                  onPressed: () => _wiederAufnehmen(context),
                  icon: const Icon(Icons.replay),
                  label: const Text('Session wieder aufnehmen'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            )
          : null,
      body: StreamBuilder<List<SatzMitGeraet>>(
        stream: db.beobachteSaetzeDerSession(s.id),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Fehler beim Laden: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final saetze = snap.data!;
          return ListView.separated(
            itemCount: saetze.length + 1,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    '${saetze.length} Sätze'
                    '${kw != null ? ' · Körpergewicht ${formatZahl(kw)} kg' : ''}'
                    ' · App ${versionText(s)}'
                    '${vonHeute ? ' · Satz antippen zum Korrigieren' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
              final e = saetze[i - 1];
              return SatzZeile(
                eintrag: e,
                onTap: vonHeute
                    ? () => zeigeSatzBearbeiten(
                        context,
                        db: db,
                        satzId: e.satz.id,
                        heute: heute,
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class SatzZeile extends StatelessWidget {
  const SatzZeile({super.key, required this.eintrag, this.onTap});

  final SatzMitGeraet eintrag;

  /// WP2.4: Antippen öffnet „Satz bearbeiten“ (nur Sätze von heute).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final satz = eintrag.satz;
    final g = eintrag.geraet;
    final text = Theme.of(context).textTheme;
    final grau = Theme.of(context).colorScheme.onSurfaceVariant;

    final seite = satz.seite == null ? '' : ' · ${satz.seite!.name}';
    final eingabe =
        '${satz.wiederholungen} × ${formatZahl(satz.eingabewert)} ${satz.eingabeeinheit.name}';
    // Anzeige immer in beiden Einheiten (DATENMODELL R1.6)
    final kg = formatZahl(satz.gewichtKg);
    final lbs = formatZahl(ausKg(satz.gewichtKg, Einheit.lbs));
    final umrechnung = g.assistiert
        ? 'effektiv $kg kg ($lbs lbs)'
        : '$kg kg, $lbs lbs';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${g.kuerzel} · Satz ${satz.satzNr}$seite',
                    style: text.titleSmall,
                  ),
                  if (g.funktion != null)
                    Text(
                      g.funktion!,
                      style: text.bodySmall?.copyWith(color: grau),
                    ),
                  if (g.assistiert)
                    Text(
                      'assistiert',
                      style: text.bodySmall?.copyWith(color: grau),
                    ),
                  if (satz.notiz != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        satz.notiz!,
                        style: text.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // [Änderung 0.2.3] Bricht bei grosser Schrift um statt überzulaufen.
            Flexible(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    eingabe,
                    style: text.bodyLarge,
                    textAlign: TextAlign.end,
                  ),
                  Text(
                    umrechnung,
                    style: text.bodySmall?.copyWith(color: grau),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
