// Minimaler Leser für .xlsx-Dateien: liefert pro Tabellenblatt die Zellwerte
// (Text, Zahl oder leer). Formeln ohne gespeicherten Wert gelten als leer.
// Formatierung (fett/kursiv) wird nicht benötigt: die Eingabeeinheit steht
// in einer eigenen Spalte.

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

class XlsxMappe {
  XlsxMappe(this.blaetter);

  /// Blattname → Zeilennummer (1-basiert, wie in Excel) → Spalte (0 = A) → Wert.
  final Map<String, Map<int, Map<int, Object>>> blaetter;

  static XlsxMappe lies(String pfad) {
    final archiv = ZipDecoder().decodeBytes(File(pfad).readAsBytesSync());

    String utf8Text(String name) {
      final f = archiv.findFile(name);
      if (f == null) throw FormatException('Datei $name fehlt in $pfad');
      return utf8.decode(f.content);
    }

    // Gemeinsame Texte (falls die Datei sie nutzt)
    final geteilt = <String>[];
    if (archiv.findFile('xl/sharedStrings.xml') != null) {
      final doc = XmlDocument.parse(utf8Text('xl/sharedStrings.xml'));
      for (final si in doc.findAllElements('si')) {
        geteilt.add(si.findAllElements('t').map((t) => t.innerText).join());
      }
    }

    // Blattnamen → Datei
    final rels = XmlDocument.parse(utf8Text('xl/_rels/workbook.xml.rels'));
    final ziele = {
      for (final r in rels.findAllElements('Relationship'))
        r.getAttribute('Id')!: r.getAttribute('Target')!,
    };
    final wb = XmlDocument.parse(utf8Text('xl/workbook.xml'));
    final blaetter = <String, Map<int, Map<int, Object>>>{};
    for (final s in wb.findAllElements('sheet')) {
      final name = s.getAttribute('name')!;
      final rid = s.attributes
          .firstWhere((a) => a.name.local == 'id')
          .value;
      var ziel = ziele[rid]!;
      ziel = ziel.startsWith('/') ? ziel.substring(1) : 'xl/$ziel';
      blaetter[name] = _liesBlatt(XmlDocument.parse(utf8Text(ziel)), geteilt);
    }
    return XlsxMappe(blaetter);
  }

  static Map<int, Map<int, Object>> _liesBlatt(
      XmlDocument doc, List<String> geteilt) {
    final zeilen = <int, Map<int, Object>>{};
    for (final row in doc.findAllElements('row')) {
      final nr = int.parse(row.getAttribute('r')!);
      final zellen = <int, Object>{};
      for (final c in row.findElements('c')) {
        final ref = c.getAttribute('r')!;
        final spalte = _spaltenIndex(ref);
        final typ = c.getAttribute('t');
        Object? wert;
        if (typ == 'inlineStr') {
          wert = c.findAllElements('t').map((t) => t.innerText).join();
        } else {
          final v = c.getElement('v')?.innerText;
          if (v != null && v.isNotEmpty) {
            if (typ == 's') {
              wert = geteilt[int.parse(v)];
            } else if (typ == 'str' || typ == 'b') {
              wert = v;
            } else {
              wert = num.tryParse(v) ?? v;
            }
          }
        }
        if (wert is String && wert.trim().isEmpty) wert = null;
        if (wert != null) zellen[spalte] = wert is String ? wert.trim() : wert;
      }
      zeilen[nr] = zellen;
    }
    return zeilen;
  }

  static int _spaltenIndex(String ref) {
    var i = 0;
    for (final ch in ref.codeUnits) {
      if (ch < 65 || ch > 90) break;
      i = i * 26 + (ch - 64);
    }
    return i - 1;
  }
}

