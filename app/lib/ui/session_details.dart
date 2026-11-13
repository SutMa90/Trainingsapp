import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/session_logik.dart';
import 'format.dart';
import 'laufende_session.dart';

/// Schreibgeschützte Liste der Sätze einer Session (M1, Variante a).
/// Reihenfolge = Erfassungsreihenfolge (wie in der Excel).
/// [Änderung M2] Eine heute beendete Session lässt sich hier wieder aufnehmen.
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
      await db.nimmSessionWiederAuf(
          uebersicht.session.id, isoDatum(jetzt()));
      navigator.pushReplacement(MaterialPageRoute(
        builder: (_) => LaufendeSessionSeite(
            db: db, sessionId: uebersicht.session.id, jetzt: jetzt),
      ));
    } on StateError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = uebersicht.session;
    final kw = s.koerpergewichtKg;
    final vonHeute = s.datum == isoDatum(jetzt());
    return Scaffold(
      appBar: AppBar(
        title: Text('${formatDatum(s.datum)} · ${uebersicht.standort.name}'),
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
                      minimumSize: const Size.fromHeight(52)),
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
                    '${kw != null ? ' · Körpergewicht ${formatZahl(kw)} kg' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
              return SatzZeile(eintrag: saetze[i - 1]);
            },
          );
        },
      ),
    );
  }
}

class SatzZeile extends StatelessWidget {
  const SatzZeile({super.key, required this.eintrag});

  final SatzMitGeraet eintrag;

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
    final umrechnung = g.assistiert ? 'effektiv $kg kg ($lbs lbs)' : '$kg kg, $lbs lbs';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${g.kuerzel} · Satz ${satz.satzNr}$seite',
                    style: text.titleSmall),
                if (g.funktion != null)
                  Text(g.funktion!, style: text.bodySmall?.copyWith(color: grau)),
                if (g.assistiert)
                  Text('assistiert', style: text.bodySmall?.copyWith(color: grau)),
                if (satz.notiz != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(satz.notiz!,
                        style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(eingabe, style: text.bodyLarge),
              Text(umrechnung, style: text.bodySmall?.copyWith(color: grau)),
            ],
          ),
        ],
      ),
    );
  }
}
