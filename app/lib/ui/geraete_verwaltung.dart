import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/geraete_logik.dart';
import '../data/db/session_logik.dart';
import 'geraet_formular.dart';

/// WP2.5 Geräteverwaltung pro Standort (F3): Liste nach Kürzel, Gerät
/// antippen = bearbeiten, „Neues Gerät“ unten rechts.
class GeraeteVerwaltung extends StatefulWidget {
  const GeraeteVerwaltung({super.key, required this.db});

  final Datenbank db;

  @override
  State<GeraeteVerwaltung> createState() => _GeraeteVerwaltungState();
}

class _GeraeteVerwaltungState extends State<GeraeteVerwaltung> {
  int? _standortId;

  @override
  void initState() {
    super.initState();
    _vorauswahl();
  }

  /// Standort der laufenden Session, sonst der zuletzt besuchte.
  Future<void> _vorauswahl() async {
    final laufend = await widget.db.laufendeSession();
    final id =
        laufend?.standort.id ??
        (await widget.db.startVorschlag()).letzterStandortId;
    if (mounted && _standortId == null && id != null) {
      setState(() => _standortId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Standort>>(
      stream: widget.db.beobachteStandorte(),
      builder: (context, snap) {
        final standorte = snap.data ?? const <Standort>[];
        final gewaehlt =
            standorte.where((s) => s.id == _standortId).firstOrNull ??
            standorte.firstOrNull;
        return Scaffold(
          appBar: AppBar(title: const Text('Geräte')),
          floatingActionButton: gewaehlt == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => zeigeGeraetFormular(
                    context,
                    db: widget.db,
                    standortId: gewaehlt.id,
                    standortName: gewaehlt.name,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Neues Gerät'),
                ),
          body: standorte.isEmpty
              ? Center(child: Text(snap.hasData ? 'Noch keine Standorte.' : ''))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in standorte)
                            ChoiceChip(
                              label: Text(s.name),
                              selected: s.id == gewaehlt!.id,
                              onSelected: (_) =>
                                  setState(() => _standortId = s.id),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _GeraeteListe(db: widget.db, standort: gewaehlt!),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _GeraeteListe extends StatelessWidget {
  const _GeraeteListe({required this.db, required this.standort});

  final Datenbank db;
  final Standort standort;

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return StreamBuilder<List<GeraetEintrag>>(
      stream: db.beobachteGeraete(standort.id),
      builder: (context, snap) {
        final liste = snap.data ?? const <GeraetEintrag>[];
        if (snap.hasData && liste.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('An diesem Standort gibt es noch keine Geräte.'),
          );
        }
        final fehlt = TextStyle(
          color: farben.error,
          fontWeight: FontWeight.bold,
        );
        return ListView.separated(
          // Platz für den Knopf „Neues Gerät“ unten rechts
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: liste.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final e = liste[i];
            final g = e.geraet;
            final eigenschaften = [
              g.einheit.name,
              if (g.assistiert) 'assistiert',
              if (g.linksRechtsGetrennt) 'L/R',
              '${e.anzahlSaetze} Sätze',
            ].join(' · ');
            return ListTile(
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: g.kuerzel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' · '),
                    g.funktion == null
                        ? TextSpan(text: 'Funktion fehlt', style: fehlt)
                        : TextSpan(text: g.funktion),
                  ],
                ),
              ),
              subtitle: Text.rich(
                TextSpan(
                  children: [
                    e.muskelgruppe == null
                        ? TextSpan(text: 'Muskelgruppe fehlt', style: fehlt)
                        : TextSpan(text: e.muskelgruppe!.name),
                    TextSpan(text: ' · $eigenschaften'),
                  ],
                ),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => zeigeGeraetFormular(
                context,
                db: db,
                standortId: standort.id,
                standortName: standort.name,
                geraet: g,
              ),
            );
          },
        );
      },
    );
  }
}
