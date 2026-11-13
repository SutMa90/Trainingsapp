import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/session_logik.dart';
import 'format.dart';
import 'laufende_session.dart';

/// WP2.1 Session starten (F4): Standort (letzter vorausgewählt),
/// Datum automatisch, Körpergewicht vom letzten Wert (R2.6).
class StartSeite extends StatefulWidget {
  const StartSeite({super.key, required this.db, required this.jetzt});

  final Datenbank db;
  final DateTime Function() jetzt;

  @override
  State<StartSeite> createState() => _StartSeiteState();
}

class _StartSeiteState extends State<StartSeite> {
  StartVorschlag? _vorschlag;
  int? _standortId;
  final _gewicht = TextEditingController();
  bool _laeuft = false;

  @override
  void initState() {
    super.initState();
    _lade();
  }

  @override
  void dispose() {
    _gewicht.dispose();
    super.dispose();
  }

  Future<void> _lade({int? auswahl}) async {
    final v = await widget.db.startVorschlag();
    if (!mounted) return;
    setState(() {
      final ersterAufruf = _vorschlag == null;
      _vorschlag = v;
      _standortId = auswahl ??
          _standortId ??
          v.letzterStandortId ??
          (v.standorte.length == 1 ? v.standorte.first.id : null);
      if (ersterAufruf && v.letztesKoerpergewichtKg != null) {
        _gewicht.text = formatZahl(v.letztesKoerpergewichtKg!, stellen: 1);
      }
    });
  }

  Future<void> _neuerStandort() async {
    final eingabe = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neuer Standort'),
        content: TextField(
          controller: eingabe,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (t) => Navigator.pop(ctx, t),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, eingabe.text),
              child: const Text('Anlegen')),
        ],
      ),
    );
    eingabe.dispose();
    if (name == null || name.trim().isEmpty) return;
    final vorhanden = _vorschlag!.standorte
        .where((s) => s.name.toLowerCase() == name.trim().toLowerCase());
    if (vorhanden.isNotEmpty) {
      await _lade(auswahl: vorhanden.first.id);
      return;
    }
    final id = await widget.db.legeStandortAn(name);
    await _lade(auswahl: id);
  }

  Future<void> _starte() async {
    final kgText = _gewicht.text;
    final kg = leseZahl(kgText);
    if (kgText.trim().isNotEmpty && (kg == null || kg <= 0)) {
      _meldung('Körpergewicht bitte als Zahl eingeben, z. B. 82,5.');
      return;
    }
    setState(() => _laeuft = true);
    final heute = isoDatum(widget.jetzt());
    try {
      final id = await widget.db.starteSession(
          standortId: _standortId!, heute: heute, koerpergewichtKg: kg);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => LaufendeSessionSeite(
            db: widget.db, sessionId: id, jetzt: widget.jetzt),
      ));
    } on StateError catch (e) {
      setState(() => _laeuft = false);
      _meldung(e.message);
    }
  }

  void _meldung(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final v = _vorschlag;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Session starten')),
      body: v == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Datum', style: text.labelLarge),
                const SizedBox(height: 4),
                Text('Heute, ${formatDatum(isoDatum(widget.jetzt()))}',
                    style: text.titleMedium),
                const SizedBox(height: 24),
                Text('Standort', style: text.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in v.standorte)
                      ChoiceChip(
                        label: Text(s.name),
                        selected: s.id == _standortId,
                        onSelected: (_) => setState(() => _standortId = s.id),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Neuer Standort'),
                      onPressed: _neuerStandort,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _gewicht,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Körpergewicht (kg)',
                    helperText: 'Für assistierte Geräte; vom letzten Mal übernommen',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _standortId == null || _laeuft ? null : _starte,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Starten'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56)),
                ),
              ],
            ),
    );
  }
}
