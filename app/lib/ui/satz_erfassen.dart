import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/db/datenbank.dart';
import '../data/db/satz_logik.dart';
import 'eingabe_dialog.dart';
import 'format.dart';
import 'satz_bearbeiten.dart';

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

  // WP2.3 letzte Werte (F7)
  String? _heuteDatum;
  LetztesMal? _letztesHier;
  LetztesMal? _andererStandort;

  /// ids der Sätze aus „wie letztes Mal“ (für „Rückgängig“).
  List<int>? _kopiert;

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
    final g = await (db.select(
      db.geraete,
    )..where((x) => x.id.equals(widget.geraetId))).getSingle();
    if (erstesMal && g.linksRechtsGetrennt) _seite = Seite.L;
    final v = await db.vorbefuellung(
      sessionId: widget.sessionId,
      geraet: g,
      seite: _seite,
    );
    if (erstesMal) {
      final s = await (db.select(
        db.sessions,
      )..where((x) => x.id.equals(widget.sessionId))).getSingle();
      _heuteDatum = s.datum;
      _letztesHier = await db.letzteSessionAmGeraet(
        g.id,
        ohneSessionId: widget.sessionId,
      );
      _andererStandort = await db.letztesMalAndererStandort(
        g,
        ohneSessionId: widget.sessionId,
      );
    }
    if (!mounted) return;
    setState(() {
      _geraet = g;
      _vorbefuellung = v;
      _einheit = v.einheit;
      _wdh.text = v.wiederholungen?.toString() ?? '';
      _gewicht.text = v.eingabewert == null
          ? ''
          : formatZahl(v.eingabewert!, stellen: 1);
    });
  }

  void _wechsleEinheit(Einheit neu) {
    if (neu == _einheit) return;
    final wert = leseZahl(_gewicht.text);
    setState(() {
      if (wert != null) {
        _gewicht.text = formatZahl(
          aufEineStelle(ausKg(inKg(wert, _einheit), neu)),
          stellen: 1,
        );
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
    _kopiert = null;
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

  /// „Wie letztes Mal“: alle Sätze vom letzten Mal auf einmal speichern.
  Future<void> _wieLetztesMal() async {
    if (_speichert) return;
    setState(() => _speichert = true);
    try {
      final ids = await widget.db.wieLetztesMal(
        widget.sessionId,
        widget.geraetId,
      );
      HapticFeedback.mediumImpact();
      if (_seite != null) _seite = Seite.L;
      await _lade();
      if (!mounted) return;
      setState(() {
        _kopiert = ids;
        _bestaetigung =
            '${_anzahlSaetze(ids.length)} wie letztes Mal gespeichert';
      });
    } on KoerpergewichtFehlt {
      final ok = await _frageKoerpergewicht();
      setState(() => _speichert = false);
      if (ok) await _wieLetztesMal();
      return;
    } on StateError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
    if (mounted) setState(() => _speichert = false);
  }

  Future<void> _rueckgaengig() async {
    final ids = _kopiert;
    if (ids == null) return;
    await widget.db.loescheSaetze(ids);
    if (_seite != null) _seite = Seite.L;
    await _lade();
    if (!mounted) return;
    setState(() {
      _kopiert = null;
      _bestaetigung = 'Rückgängig gemacht';
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
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
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

    // [Änderung 0.2.3] Der Speicherknopf hat einen festen Platz am unteren
    // Rand – immer oberhalb der Android-Tasten bzw. der Tastatur.
    final mq = MediaQuery.of(context);
    final unten = math.max(mq.viewInsets.bottom, mq.viewPadding.bottom);

    return Padding(
      padding: EdgeInsets.only(bottom: unten),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titel mit ✕ bleibt beim Scrollen stehen.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${g.kuerzel}${g.funktion != null ? ' · ${g.funktion}' : ''}',
                    style: text.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Schliessen',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _inhalt(g, v, text, grau, umrechnung),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '✓ $_bestaetigung',
                            textAlign: TextAlign.center,
                            style: text.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        if (_kopiert != null)
                          TextButton(
                            onPressed: _rueckgaengig,
                            child: const Text('Rückgängig'),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inhalt(
    Geraet g,
    Vorbefuellung v,
    TextTheme text,
    Color grau,
    String? umrechnung,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
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
        // WP2.3: letzte Werte (F7) und „wie letztes Mal“
        if (_letztesHier != null) ...[
          const SizedBox(height: 12),
          _LetztesMalBlock(
            titel: 'Letztes Mal hier',
            letztes: _letztesHier!,
            heute: _heuteDatum!,
            mitGeraet: false,
          ),
          StreamBuilder<List<Satz>>(
            stream: widget.db.beobachteSaetzeDesGeraets(widget.sessionId, g.id),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.isNotEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: _speichert ? null : _wieLetztesMal,
                  icon: const Icon(Icons.replay),
                  label: Text(
                    'Wie letztes Mal '
                    '(${_anzahlSaetze(_letztesHier!.saetze.length)})',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              );
            },
          ),
        ],
        if (_andererStandort != null) ...[
          const SizedBox(height: 12),
          _LetztesMalBlock(
            titel: 'Zuletzt in ${_andererStandort!.standort.name}',
            letztes: _andererStandort!,
            heute: _heuteDatum!,
            mitGeraet: true,
          ),
        ],
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
        const SizedBox(height: 12),
        _HeuteAmGeraet(
          db: widget.db,
          sessionId: widget.sessionId,
          geraetId: g.id,
          heute: _heuteDatum!,
          onGeaendert: _lade,
        ),
      ],
    );
  }
}

class Zahlenfeld extends StatelessWidget {
  const Zahlenfeld({
    super.key,
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
          dezimal ? RegExp(r'^\d{0,4}([.,]\d?)?') : RegExp(r'^\d{0,3}'),
        ),
      ],
      // Antippen markiert den Wert – Tippen ersetzt ihn direkt.
      onTap: () => controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      ),
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
  const _HeuteAmGeraet({
    required this.db,
    required this.sessionId,
    required this.geraetId,
    required this.heute,
    required this.onGeaendert,
  });

  final Datenbank db;
  final int sessionId;
  final int geraetId;
  final String heute;
  final VoidCallback onGeaendert;

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
            // WP2.4: Antippen → Satz korrigieren oder löschen
            for (final s in saetze)
              InkWell(
                onTap: () async {
                  final geaendert = await zeigeSatzBearbeiten(
                    context,
                    db: db,
                    satzId: s.id,
                    heute: heute,
                  );
                  if (geaendert) onGeaendert();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Satz ${s.satzNr}${s.seite == null ? '' : ' ${s.seite!.name}'}: '
                          '${s.wiederholungen} × ${formatZahl(s.eingabewert)} ${s.eingabeeinheit.name}'
                          '${s.notiz == null ? '' : ' · ${s.notiz}'}',
                          style: text.bodyMedium,
                        ),
                      ),
                      const Icon(Icons.edit_outlined, size: 18),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

String _anzahlSaetze(int n) => n == 1 ? '1 Satz' : '$n Sätze';

String _vorTagen(int tage) => switch (tage) {
  0 => 'heute',
  1 => 'gestern',
  _ => 'vor $tage Tagen',
};

/// WP2.3 (F7): Sätze einer früheren Session, Anzeige immer in beiden
/// Einheiten (R1.6).
class _LetztesMalBlock extends StatelessWidget {
  const _LetztesMalBlock({
    required this.titel,
    required this.letztes,
    required this.heute,
    required this.mitGeraet,
  });

  final String titel;
  final LetztesMal letztes;
  final String heute;
  final bool mitGeraet;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final grau = Theme.of(context).colorScheme.onSurfaceVariant;
    final s = letztes.session;
    final g = letztes.geraet;
    final kopf = StringBuffer(
      '$titel: ${formatDatum(s.datum)} '
      '(${_vorTagen(tageZwischen(s.datum, heute))})',
    );
    if (mitGeraet) kopf.write(' · ${g.kuerzel}');
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kopf.toString(), style: text.labelLarge),
          const SizedBox(height: 4),
          for (final satz in letztes.saetze) ...[
            Text(
              'Satz ${satz.satzNr}'
              '${satz.seite == null ? '' : ' ${satz.seite!.name}'}: '
              '${satz.wiederholungen} × ${formatZahl(satz.eingabewert)} '
              '${satz.eingabeeinheit.name}',
              style: text.bodyMedium,
            ),
            Text(
              '   ${g.assistiert ? 'effektiv ' : ''}'
              '${formatZahl(satz.gewichtKg)} kg, '
              '${formatZahl(ausKg(satz.gewichtKg, Einheit.lbs))} lbs'
              '${satz.notiz == null ? '' : ' · ${satz.notiz}'}',
              style: text.bodySmall?.copyWith(color: grau),
            ),
          ],
        ],
      ),
    );
  }
}
