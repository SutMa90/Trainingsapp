import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import 'format.dart';

/// Schreibgeschützte Liste der Sätze einer Session (M1, Variante a).
/// Reihenfolge = Erfassungsreihenfolge (wie in der Excel).
class SessionDetails extends StatelessWidget {
  const SessionDetails({super.key, required this.db, required this.uebersicht});

  final Datenbank db;
  final SessionUebersicht uebersicht;

  @override
  Widget build(BuildContext context) {
    final s = uebersicht.session;
    final kw = s.koerpergewichtKg;
    return Scaffold(
      appBar: AppBar(
        title: Text('${formatDatum(s.datum)} · ${uebersicht.standort.name}'),
      ),
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
              return _SatzZeile(eintrag: saetze[i - 1]);
            },
          );
        },
      ),
    );
  }
}

class _SatzZeile extends StatelessWidget {
  const _SatzZeile({required this.eintrag});

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
