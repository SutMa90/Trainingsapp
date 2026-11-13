import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/db/datenbank.dart';
import '../data/db/satz_logik.dart';
import 'eingabe_dialog.dart';
import 'format.dart';

/// Öffnet das Erfassungsfenster für ein Gerät (WP2.2, F5/F6).
/// Das Fenster bleibt nach dem Speichern offen, damit der nächste Satz
/// mit einem Tap erfasst werden kann.
Future<void> zeigeSatzErfassen(
  BuildContext context, {
  required Datenbank db,
  required int sessionId,
  required Geraet geraet,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) =>
        SatzErfassen(db: db, sessionId: sessionId, geraetId: geraet.id),
  );
}

class SatzErfassen extends StatefulWidget {
  const SatzErfassen({
    super.key,
    required this.db,
    required this.sessionId,
    required this.geraetId,
  });

  final Datenbank db;
  final int sessionId;
  final int geraetId;

  @override
  State<SatzErfassen> createState() => _SatzErfassenState();
}

class _SatzErfassenState extends State<SatzErfassen> {
  final _wdh = TextEditingController();
  final _gewicht = TextEditingController();
  final _notiz = TextEditingController();
  Geraet? _geraet;
  Vorbefuellung? _vorbefuellung;
  Einheit _einheit = Einheit.kg;
  Seite? _seite;
  String? _bestaetigung;
  bool _speichert = false;

  @override
  void initState() {
    super.initState();
    _lade(erstesMal: true);
  }

  @override
  void dispose() {
    _wdh.dispose();
    _gewicht.dispose();
    _notiz.dispose();
    super.dispose();
  }

  Future<void> _lade({bool erstesMal = false}) async {
    final db = widget.db;
    final g = await (db.select(db.geraete)
          ..where((x) => x.id.equals(widget.geraetId)))
        .getSingle();
    if (erstesMal && g.linksRechtsGetrennt) _seite = Seite.L;
    final v = await db.vorbefuellung(
        sessionId: widget.sessionId, geraet: g, seite: _seite);
    if (!mounted) return;
    setState(() {
      _geraet = g;
      _vorbefuellung = v;
      _einheit = v.einheit;
      _wdh.text = v.wiederholungen?.toString() ?? '';
      _gewicht.text =
          v.eingabewert == null ? '' : formatZahl(v.eingabewert!, stellen: 1);
    });
  }

  void _wechsleEinheit(Einheit neu) {
    if (neu == _einheit) return;
    final wert = leseZahl(_gewicht.text);
    setState(() {
      if (wert != null) {
        _gewicht.text = formatZahl(
            aufEineStelle(ausKg(inKg(wert, _einheit), neu)),
            stellen: 1);
      }
      _einheit = neu;
    });
  }

  Future<void> _wechsleSeite(Seite neu) async {
    setState(() => _seite = neu);
    await _lade();
  }

  int? get _wdhWert => int.tryParse(_wdh.text.trim());
  double? get _gewichtWert => leseZahl(_gewicht.text);
  bool get _gueltig => (_wdhWert ?? 0) > 0 && _gewichtWert != null;

  Future<void> _speichere() async {
    if (!_gueltig || _speichert) return;
    setState(() => _speichert = true);
    final nr = _vorbefuellung!.satzNr;
    try {
      await widget.db.speichereSatz(
        sessionId: widget.sessionId,
        geraetId: widget.geraetId,
        seite: _seite,
        wiederholungen: _wdhWert!,
        eingabewert: _gewichtWert!,
        einheit: _einheit,
        notiz: _notiz.text,
      );
    } on KoerpergewichtFehlt {
      final ok = await _frageKoerpergewicht();
      setState(() => _speichert = false);
      if (ok) await _speichere();
      return;
    }
    HapticFeedback.mediumImpact();
    final seiteText = _seite == null ? '' : ' ${_seite!.name}';
    _notiz.clear();
    // Bei links/rechts getrennten Geräten danach die andere Seite vorschlagen.
    if (_seite != null) _seite = _seite == Seite.L ? Seite.R : Seite.L;
    await _lade();
    if (!mounted) return;
    setState(() {
      _speichert = false;
      _bestaetigung = 'Satz $nr$seiteText gespeichert';
    });
  }

  Future<bool> _frageKoerpergewicht() async {
    final antwort = await frageText(
      context,
      titel: 'Körpergewicht',
      label: 'Körpergewicht heute (kg)',
      hinweis: 'Für assistierte Geräte nötig',
      okText: 'Übernehmen',
      tastatur: const TextInputType.numberWithOptions(decimal: true),
    );
    final kg = antwort == null ? null : leseZahl(antwort);
    if (kg == null || kg <= 0) return false;
    await widget.db.setzeKoerpergewicht(widget.sessionId, kg);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final g = _geraet;
    final v = _vorbefuellung;
    if (g == null || v == null) {
      return const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator()));
    }
    final text = Theme.of(context).textTheme;
    final grau = Theme.of(context).colorScheme.onSurfaceVariant;
    final wert = _gewichtWert;
    String? umrechnung;
    if (wert != null) {
      final kg = inKg(wert, _einheit);
      umrechnung = g.assistiert
          ? 'Unterstützung – effektiv = Körpergewicht − ${formatZahl(kg)} kg'
          : '= ${formatZahl(kg)} kg, ${formatZahl(ausKg(kg, Einheit.lbs))} lbs';
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${g.kuerzel}${g.funktion != null ? ' · ${g.funktion}' : ''}',
              style: text.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Satz ${v.satzNr}${g.assistiert ? ' · assistiert' : ''}',
              style: text.bodyMedium?.copyWith(color: grau),
            ),
            if (g.linksRechtsGetrennt) ...[
              const SizedBox(height: 12),
              SegmentedButton<Seite>(
                segments: const [
                  ButtonSegment(value: Seite.L, label: Text('Links')),
                  ButtonSegment(value: Seite.R, label: Text('Rechts')),
                ],
                selected: {_seite ?? Seite.L},
                onSelectionChanged: (s) => _wechsleSeite(s.first),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Zahlenfeld(
                    controller: _wdh,
                    label: 'Wdh',
                    dezimal: false,
                    onChanged: () => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _Zahlenfeld(
                    controller: _gewicht,
                    label: g.assistiert ? 'Unterstützung' : 'Gewicht',
                    dezimal: true,
                    onChanged: () => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<Einheit>(
              segments: const [
                ButtonSegment(value: Einheit.kg, label: Text('kg')),
                ButtonSegment(value: Einheit.lbs, label: Text('lbs')),
              ],
              selected: {_einheit},
              onSelectionChanged: (s) => _wechsleEinheit(s.first),
            ),
            const SizedBox(height: 6),
            Text(
              [
                ?umrechnung,
                if (v.umgerechnet) 'letzter Wert umgerechnet',
                if (_einheit != g.einheit) 'wird neue Vorgabe des Geräts',
              ].join(' · '),
              style: text.bodySmall?.copyWith(color: grau),
            ),
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
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _gueltig && !_speichert ? _speichere : null,
              icon: const Icon(Icons.check),
              label: const Text('Satz speichern'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
                textStyle: text.titleMedium,
              ),
            ),
            if (_bestaetigung != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('✓ $_bestaetigung',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
              ),
            const SizedBox(height: 12),
            _HeuteAmGeraet(
                db: widget.db, sessionId: widget.sessionId, geraetId: g.id),
          ],
        ),
      ),
    );
  }
}

class _Zahlenfeld extends StatelessWidget {
  const _Zahlenfeld({
    required this.controller,
    required this.label,
    required this.dezimal,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool dezimal;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
      keyboardType: TextInputType.numberWithOptions(decimal: dezimal),
      inputFormatters: [
        // Wdh: ganze Zahl; Gewicht: eine Nachkommastelle (R2.5)
        FilteringTextInputFormatter.allow(
            dezimal ? RegExp(r'^\d{0,4}([.,]\d?)?') : RegExp(r'^\d{0,3}')),
      ],
      // Antippen markiert den Wert – Tippen ersetzt ihn direkt.
      onTap: () => controller.selection =
          TextSelection(baseOffset: 0, extentOffset: controller.text.length),
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Sätze dieses Geräts in der laufenden Session.
class _HeuteAmGeraet extends StatelessWidget {
  const _HeuteAmGeraet(
      {required this.db, required this.sessionId, required this.geraetId});

  final Datenbank db;
  final int sessionId;
  final int geraetId;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<Satz>>(
      stream: db.beobachteSaetzeDesGeraets(sessionId, geraetId),
      builder: (context, snap) {
        final saetze = snap.data ?? const <Satz>[];
        if (saetze.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Heute an diesem Gerät', style: text.labelLarge),
            const SizedBox(height: 4),
            for (final s in saetze)
              Text(
                'Satz ${s.satzNr}${s.seite == null ? '' : ' ${s.seite!.name}'}: '
                '${s.wiederholungen} × ${formatZahl(s.eingabewert)} ${s.eingabeeinheit.name}'
                '${s.notiz == null ? '' : ' · ${s.notiz}'}',
                style: text.bodyMedium,
              ),
          ],
        );
      },
    );
  }
}
