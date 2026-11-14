import 'package:flutter/material.dart';

/// Kleiner Dialog mit einem Eingabefeld. Gibt den Text zurück oder null
/// (Abbrechen). Das Eingabefeld gehört dem Dialog selbst und wird erst
/// aufgeräumt, wenn der Dialog ganz verschwunden ist.
Future<String?> frageText(
  BuildContext context, {
  required String titel,
  required String label,
  String? hinweis,
  String okText = 'OK',
  TextInputType? tastatur,
  TextCapitalization grossschreibung = TextCapitalization.none,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _EingabeDialog(
      titel: titel,
      label: label,
      hinweis: hinweis,
      okText: okText,
      tastatur: tastatur,
      grossschreibung: grossschreibung,
    ),
  );
}

class _EingabeDialog extends StatefulWidget {
  const _EingabeDialog({
    required this.titel,
    required this.label,
    required this.okText,
    required this.grossschreibung,
    this.hinweis,
    this.tastatur,
  });

  final String titel, label, okText;
  final String? hinweis;
  final TextInputType? tastatur;
  final TextCapitalization grossschreibung;

  @override
  State<_EingabeDialog> createState() => _EingabeDialogState();
}

class _EingabeDialogState extends State<_EingabeDialog> {
  final _eingabe = TextEditingController();

  @override
  void dispose() {
    _eingabe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titel),
      content: TextField(
        controller: _eingabe,
        autofocus: true,
        keyboardType: widget.tastatur,
        textCapitalization: widget.grossschreibung,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: widget.hinweis,
        ),
        onSubmitted: (t) => Navigator.pop(context, t),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _eingabe.text),
          child: Text(widget.okText),
        ),
      ],
    );
  }
}
