import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/satz_logik.dart';
import 'format.dart';
import 'satz_erfassen.dart';

/// WP2.4 (F8): Satz korrigieren oder löschen – nur in Sessions von heute.
/// Gibt true zurück, wenn etwas geändert oder gelöscht wurde.
Future<bool> zeigeSatzBearbeiten(
  BuildContext context, {
  required Datenbank db,
  required int satzId,
  required String heute,
}) async {
  final geaendert = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => SatzBearbeiten(db: db, satzId: satzId, heute: heute),
  );
  return geaendert ?? false;
}

class SatzBearbeiten extends StatefulWidget {
  const SatzBearbeiten({
    super.key,
    required this.db,
    required this.satzId,
    required this.heute,
  });

  final Datenbank db;
  final int satzId;
  final String heute;

  @override
  State<SatzBearbeiten> createState() => _SatzBearbeitenState();
}

class _SatzBearbeitenState extends State<SatzBearbeiten> {
  final _wdh = TextEditingController();
  final _gewicht = TextEditingController();
  final _notiz = TextEditingController();
  Satz? _satz;
  Geraet? _geraet;
  Einheit _einheit = Einheit.kg;
  Seite? _seite;
  bool _arbeitet = false;

  @override
  void initState() {
    super.initState();
    _lade();
  }

  @override
  void dispose() {
    _wdh.dispose();
    _gewicht.dispose();
    _notiz.dispose();
    super.dispose();
  }

  Future<void> _lade() async {
    final db = widget.db;
    final s = await (db.select(
      db.saetze,
    )..where((x) => x.id.equals(widget.satzId))).getSingle();
    final g = await (db.select(
      db.geraete,
    )..where((x) => x.id.equals(s.geraetId))).getSingle();
    if (!mounted) return;
    setState(() {
      _satz = s;
      _geraet = g;
      _einheit = s.eingabeeinheit;
      _seite = s.seite;
      _wdh.text = '${s.wiederholungen}';
      _gewicht.text = formatZahl(s.eingabewert, stellen: 1);
      _notiz.text = s.notiz ?? '';
    });
  }

  int? get _wdhWert => int.tryParse(_wdh.text.trim());
  double? get _gewichtWert => leseZahl(_gewicht.text);
  bool get _gueltig => (_wdhWert ?? 0) > 0 && _gewichtWert != null;

  void _meldung(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _speichere() async {
    if (!_gueltig || _arbeitet) return;
    setState(() => _arbeitet = true);
    try {
      await widget.db.aendereSatz(
        satzId: widget.satzId,
        heute: widget.heute,
        wiederholungen: _wdhWert!,
        eingabewert: _gewichtWert!,
        einheit: _einheit,
        seite: _seite,
        notiz: _notiz.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on StateError catch (e) {
      _meldung(e.message);
      setState(() => _arbeitet = false);
    } on ArgumentError catch (e) {
      _meldung('${e.message}');
      setState(() => _arbeitet = false);
    }
  }

  Future<void> _loesche() async {
    final s = _satz!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Satz löschen?'),
        content: Text(
          '${_geraet!.kuerzel} · Satz ${s.satzNr}'
          '${s.seite == null ? '' : ' ${s.seite!.name}'}: '
          '${s.wiederholungen} × ${formatZahl(s.eingabewert)} '
          '${s.eingabeeinheit.name}\n\nDie übrigen Sätze werden neu nummeriert.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await widget.db.loescheSatz(widget.satzId, widget.heute);
      if (mounted) Navigator.of(context).pop(true);
    } on StateError catch (e) {
      _meldung(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _satz;
    final g = _geraet;
    if (s == null || g == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final text = Theme.of(context).textTheme;
    final grau = Theme.of(context).colorScheme.onSurfaceVariant;
    final mq = MediaQuery.of(context);
    final unten = math.max(mq.viewInsets.bottom, mq.viewPadding.bottom);
    final wert = _gewichtWert;
    final hinweis = [
      if (wert != null)
        g.assistiert
            ? 'Unterstützung – effektiv = Körpergewicht − ${formatZahl(inKg(wert, _einheit))} kg'
            : '= ${formatZahl(inKg(wert, _einheit))} kg, '
                  '${formatZahl(ausKg(inKg(wert, _einheit), Einheit.lbs))} lbs',
      if (_einheit != s.eingabeeinheit) 'Zahl bleibt, nur die Einheit ändert',
      if (_einheit != g.einheit) 'wird neue Vorgabe des Geräts',
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.only(bottom: unten),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${g.kuerzel} · Satz ${s.satzNr} bearbeiten',
                    style: text.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Schliessen',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (g.linksRechtsGetrennt) ...[
                    const SizedBox(height: 8),
                    SegmentedButton<Seite>(
                      segments: const [
                        ButtonSegment(value: Seite.L, label: Text('Links')),
                        ButtonSegment(value: Seite.R, label: Text('Rechts')),
                      ],
                      selected: {_seite ?? Seite.L},
                      onSelectionChanged: (x) =>
                          setState(() => _seite = x.first),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Zahlenfeld(
                          controller: _wdh,
                          label: 'Wdh',
                          dezimal: false,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Zahlenfeld(
                          controller: _gewicht,
                          label: g.assistiert ? 'Unterstützung' : 'Gewicht',
                          dezimal: true,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bei der Korrektur wird nicht umgerechnet: meist war die
                  // Zahl richtig und nur die Einheit falsch.
                  SegmentedButton<Einheit>(
                    segments: const [
                      ButtonSegment(value: Einheit.kg, label: Text('kg')),
                      ButtonSegment(value: Einheit.lbs, label: Text('lbs')),
                    ],
                    selected: {_einheit},
                    onSelectionChanged: (x) =>
                        setState(() => _einheit = x.first),
                  ),
                  const SizedBox(height: 6),
                  Text(hinweis, style: text.bodySmall?.copyWith(color: grau)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notiz,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notiz (optional)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _arbeitet ? null : _loesche,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Satz löschen'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _gueltig && !_arbeitet ? _speichere : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Änderung speichern'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
