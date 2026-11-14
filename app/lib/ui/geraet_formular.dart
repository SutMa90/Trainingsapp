import 'package:flutter/material.dart';

import '../data/db/datenbank.dart';
import '../data/db/geraete_logik.dart';
import 'eingabe_dialog.dart';

/// WP2.5 Kurzformular „Neues Gerät“ (F3) bzw. „Gerät bearbeiten“.
///
/// Gibt die id des gespeicherten Geräts zurück, sonst null (abgebrochen oder
/// gelöscht).
Future<int?> zeigeGeraetFormular(
  BuildContext context, {
  required Datenbank db,
  required int standortId,
  required String standortName,
  Geraet? geraet,
}) {
  return Navigator.of(context).push<int>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => GeraetFormular(
        db: db,
        standortId: standortId,
        standortName: standortName,
        geraet: geraet,
      ),
    ),
  );
}

class GeraetFormular extends StatefulWidget {
  const GeraetFormular({
    super.key,
    required this.db,
    required this.standortId,
    required this.standortName,
    this.geraet,
  });

  final Datenbank db;
  final int standortId;
  final String standortName;

  /// null = neues Gerät.
  final Geraet? geraet;

  @override
  State<GeraetFormular> createState() => _GeraetFormularState();
}

class _GeraetFormularState extends State<GeraetFormular> {
  late final _kuerzel = TextEditingController(text: widget.geraet?.kuerzel);
  late final _funktion = TextEditingController(text: widget.geraet?.funktion);
  late final _hersteller = TextEditingController(
    text: widget.geraet?.hersteller,
  );
  late final _modell = TextEditingController(text: widget.geraet?.modell);
  late final _einstellung1 = TextEditingController(
    text: widget.geraet?.einstellung1,
  );
  late final _einstellung2 = TextEditingController(
    text: widget.geraet?.einstellung2,
  );
  late final _einstellung3 = TextEditingController(
    text: widget.geraet?.einstellung3,
  );
  late final _notiz = TextEditingController(text: widget.geraet?.notiz);
  final _herstellerFokus = FocusNode();
  final _modellFokus = FocusNode();

  late int? _muskelgruppeId = widget.geraet?.muskelgruppeId;
  late Einheit _einheit = widget.geraet?.einheit ?? Einheit.kg;
  late bool _assistiert = widget.geraet?.assistiert ?? false;
  late bool _linksRechts = widget.geraet?.linksRechtsGetrennt ?? false;

  List<Muskelgruppe> _gruppen = const [];
  GeraeteVorschlaege? _vorschlaege;
  int _anzahlSaetze = 0;
  String? _fehlerKuerzel;
  bool _speichert = false;

  bool get _neu => widget.geraet == null;

  /// Kürzel nur änderbar, solange das Gerät keine Sätze hat.
  bool get _kuerzelGesperrt => _anzahlSaetze > 0;

  @override
  void initState() {
    super.initState();
    _lade();
  }

  Future<void> _lade() async {
    final gruppen = await widget.db.muskelgruppenListe();
    final vorschlaege = await widget.db.geraeteVorschlaege();
    final anzahl = _neu
        ? 0
        : await widget.db.anzahlSaetzeAmGeraet(widget.geraet!.id);
    if (!mounted) return;
    setState(() {
      _gruppen = gruppen;
      _vorschlaege = vorschlaege;
      _anzahlSaetze = anzahl;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _kuerzel,
      _funktion,
      _hersteller,
      _modell,
      _einstellung1,
      _einstellung2,
      _einstellung3,
      _notiz,
    ]) {
      c.dispose();
    }
    _herstellerFokus.dispose();
    _modellFokus.dispose();
    super.dispose();
  }

  Future<void> _neueMuskelgruppe() async {
    final name = await frageText(
      context,
      titel: 'Neue Muskelgruppe',
      label: 'Name',
      okText: 'Anlegen',
      grossschreibung: TextCapitalization.words,
    );
    if (name == null || name.trim().isEmpty) return;
    final id = await widget.db.legeMuskelgruppeAn(name);
    final gruppen = await widget.db.muskelgruppenListe();
    if (!mounted) return;
    setState(() {
      _gruppen = gruppen;
      _muskelgruppeId = id;
    });
  }

  Future<void> _speichere() async {
    if (_kuerzel.text.trim().isEmpty) {
      setState(() => _fehlerKuerzel = 'Kürzel fehlt');
      return;
    }
    setState(() => _speichert = true);
    final daten = GeraetDaten(
      kuerzel: _kuerzel.text,
      funktion: _funktion.text,
      muskelgruppeId: _muskelgruppeId,
      hersteller: _hersteller.text,
      modell: _modell.text,
      einheit: _einheit,
      assistiert: _assistiert,
      linksRechtsGetrennt: _linksRechts,
      einstellung1: _einstellung1.text,
      einstellung2: _einstellung2.text,
      einstellung3: _einstellung3.text,
      notiz: _notiz.text,
    );
    try {
      final int id;
      if (_neu) {
        id = await widget.db.legeGeraetAn(widget.standortId, daten);
      } else {
        id = widget.geraet!.id;
        await widget.db.aendereGeraet(id, daten);
      }
      if (mounted) Navigator.of(context).pop(id);
    } on KuerzelVergeben catch (e) {
      setState(() {
        _speichert = false;
        _fehlerKuerzel = '${e.kuerzel} gibt es hier schon';
      });
    } on GeraetHatSaetze catch (e) {
      setState(() => _speichert = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.meldung)));
      }
    }
  }

  Future<void> _loesche() async {
    final g = widget.geraet!;
    final ja = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Gerät ${g.kuerzel} löschen?'),
        content: const Text('Das Gerät hat keine Sätze. Endgültig löschen?'),
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
    if (ja != true) return;
    await widget.db.loescheGeraet(g.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final grau = Theme.of(context).colorScheme.onSurfaceVariant;
    final hatMehr = [
      _hersteller,
      _modell,
      _einstellung1,
      _einstellung2,
      _einstellung3,
      _notiz,
    ].any((c) => c.text.trim().isNotEmpty);
    return Scaffold(
      appBar: AppBar(
        title: Text(_neu ? 'Neues Gerät' : 'Gerät ${widget.geraet!.kuerzel}'),
        actions: [
          if (!_neu && _anzahlSaetze == 0)
            IconButton(
              tooltip: 'Gerät löschen',
              icon: const Icon(Icons.delete_outline),
              onPressed: _loesche,
            ),
        ],
      ),
      // Speicherknopf unter der Liste: bleibt über Tastatur und Android-Tasten.
      body: Column(
        children: [
          Expanded(
            // Kein ListView: alle Felder werden gebaut (kurzes Formular).
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Standort: ${widget.standortName}',
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _kuerzel,
                    autofocus: _neu,
                    readOnly: _kuerzelGesperrt,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_fehlerKuerzel != null) {
                        setState(() => _fehlerKuerzel = null);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Kürzel',
                      border: const OutlineInputBorder(),
                      errorText: _fehlerKuerzel,
                      helperText: _kuerzelGesperrt
                          ? 'Gerät hat schon Sätze – Kürzel bleibt (Abgleich mit '
                                'der Excel). Bei Verwechslung neues Gerät anlegen.'
                          : null,
                      helperMaxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _funktion,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Funktion (z. B. Leg Press)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Muskelgruppe', style: text.labelLarge),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final m in _gruppen)
                        ChoiceChip(
                          label: Text(m.name),
                          selected: m.id == _muskelgruppeId,
                          onSelected: (an) => setState(
                            () => _muskelgruppeId = an ? m.id : null,
                          ),
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text('Neue'),
                        tooltip: 'Neue Muskelgruppe',
                        onPressed: _neueMuskelgruppe,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Einheit (Vorgabe für neue Sätze)',
                    style: text.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<Einheit>(
                    segments: const [
                      ButtonSegment(value: Einheit.kg, label: Text('kg')),
                      ButtonSegment(value: Einheit.lbs, label: Text('lbs')),
                    ],
                    selected: {_einheit},
                    onSelectionChanged: (x) =>
                        setState(() => _einheit = x.first),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('assistiert'),
                    subtitle: const Text('effektiv = Körpergewicht − Eingabe'),
                    value: _assistiert,
                    onChanged: (v) => setState(() => _assistiert = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('links/rechts getrennt'),
                    subtitle: const Text('Sätze pro Seite zählen'),
                    value: _linksRechts,
                    onChanged: (v) => setState(() => _linksRechts = v),
                  ),
                  if (_anzahlSaetze > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Änderungen gelten für neue Sätze. Die $_anzahlSaetze '
                        'bisherigen Sätze bleiben unverändert.',
                        style: text.bodySmall?.copyWith(color: grau),
                      ),
                    ),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    initiallyExpanded: hatMehr,
                    title: const Text(
                      'Mehr: Hersteller, Modell, Einstellungen, Notiz',
                    ),
                    children: [
                      VorschlagFeld(
                        controller: _hersteller,
                        fokus: _herstellerFokus,
                        label: 'Hersteller',
                        optionen: () => _vorschlaege?.hersteller ?? const [],
                      ),
                      const SizedBox(height: 12),
                      VorschlagFeld(
                        controller: _modell,
                        fokus: _modellFokus,
                        label: 'Modell',
                        optionen: () =>
                            _vorschlaege?.modelleVon(_hersteller.text) ??
                            const [],
                      ),
                      const SizedBox(height: 12),
                      for (final (c, nr) in [
                        (_einstellung1, 1),
                        (_einstellung2, 2),
                        (_einstellung3, 3),
                      ]) ...[
                        TextField(
                          controller: c,
                          decoration: InputDecoration(
                            labelText: 'Einstellung $nr',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: _notiz,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Notiz',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: FilledButton.icon(
                onPressed: _speichert ? null : _speichere,
                icon: const Icon(Icons.check),
                label: Text(_neu ? 'Gerät speichern' : 'Änderung speichern'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Textfeld mit Vorschlägen aus bestehenden Einträgen (R2.2). Ohne Eingabe
/// erscheinen alle Vorschläge, beim Tippen die passenden.
class VorschlagFeld extends StatelessWidget {
  const VorschlagFeld({
    super.key,
    required this.controller,
    required this.fokus,
    required this.label,
    required this.optionen,
  });

  final TextEditingController controller;
  final FocusNode fokus;
  final String label;
  final List<String> Function() optionen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<String>(
        textEditingController: controller,
        focusNode: fokus,
        optionsBuilder: (wert) {
          final t = wert.text.trim().toLowerCase();
          final alle = optionen();
          if (t.isEmpty) return alle;
          return alle.where((o) {
            final l = o.toLowerCase();
            return l.contains(t) && l != t;
          });
        },
        fieldViewBuilder: (context, c, f, fertig) => TextField(
          controller: c,
          focusNode: f,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => fertig(),
        ),
        optionsViewBuilder: (context, auswahl, optionen) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 220,
                maxWidth: constraints.maxWidth,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final o in optionen)
                    ListTile(
                      dense: true,
                      title: Text(o),
                      onTap: () => auswahl(o),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
