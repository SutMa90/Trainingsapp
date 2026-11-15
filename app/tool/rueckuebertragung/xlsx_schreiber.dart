// WP2.6 Rückübertragung: neue Zeilen in die Excel schreiben.
//
// Grundsatz: Bestehende Zeilen bleiben Byte für Byte gleich. Geändert wird
// nur, was neu ist:
// - Tab Log: die vorbereiteten leeren Zeilen am Ende (nur Volumen-Formel)
//   werden mit den neuen Sätzen gefüllt, danach wird angehängt.
// - Tab Geräte: neue Geräte werden angehängt; fehlt die Überschrift
//   „Muskelgruppe“, kommt sie in die nächste freie Spalte von Zeile 1.
// - Bereichsangabe (<dimension>) der beiden Tabs.
// Alle anderen Teile der Datei werden unverändert übernommen.

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:trainingsapp/data/db/datenbank.dart' show Einheit;

import '../import_excel/xlsx_leser.dart';
import 'abgleich.dart';

/// Die Excel lässt sich nicht sicher ergänzen (Grund für den Nutzer).
class SchreibFehler implements Exception {
  final String grund;
  const SchreibFehler(this.grund);
  @override
  String toString() => grund;
}

/// Spaltenbuchstabe (0 = A).
String spalte(int i) {
  var s = '';
  var n = i + 1;
  while (n > 0) {
    final r = (n - 1) % 26;
    s = String.fromCharCode(65 + r) + s;
    n = (n - 1) ~/ 26;
  }
  return s;
}

int _spaltenIndex(String ref) {
  var i = 0;
  for (final ch in ref.codeUnits) {
    if (ch < 65 || ch > 90) break;
    i = i * 26 + (ch - 64);
  }
  return i - 1;
}

String _esc(String v) =>
    v.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

String _zahl(num v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toString();
}

String _textZelle(String ref, String v, String? stil) {
  final raum = v.trim() != v ? ' xml:space="preserve"' : '';
  return '<c r="$ref"${stil == null ? '' : ' s="$stil"'} t="inlineStr">'
      '<is><t$raum>${_esc(v)}</t></is></c>';
}

String _zahlZelle(String ref, num v, String? stil) =>
    '<c r="$ref"${stil == null ? '' : ' s="$stil"'} t="n"><v>${_zahl(v)}</v></c>';

final _reZeile = RegExp(r'<row\b[^>]*?\br="(\d+)"[^>]*?(?:/>|>.*?</row>)', dotAll: true);
final _reZelle = RegExp(r'<c\b[^>]*?\br="([A-Z]+)\d+"[^>]*?(?:/>|>.*?</c>)', dotAll: true);
final _reStil = RegExp(r'\bs="(\d+)"');

/// Ein Tabellenblatt als Text mit den Positionen seiner Zeilen.
class _Blatt {
  _Blatt(this.xml) {
    for (final m in _reZeile.allMatches(xml)) {
      zeilen[int.parse(m[1]!)] = m;
    }
  }
  final String xml;
  final zeilen = <int, RegExpMatch>{};

  /// Spalten (0 = A) mit Zellen in Zeile [nr].
  Map<int, String> zellen(int nr) {
    final m = zeilen[nr];
    if (m == null) return const {};
    return {
      for (final c in _reZelle.allMatches(m[0]!)) _spaltenIndex(c[1]!): c[0]!,
    };
  }

  String? stil(int nr, int sp) {
    final c = zellen(nr)[sp];
    return c == null ? null : _reStil.firstMatch(c.substring(0, c.indexOf('>')))?[1];
  }
}

/// Ersetzt bzw. ergänzt Zeilen und setzt die Bereichsangabe neu.
String _setzeZeilen(_Blatt b, Map<int, String> neu, int letzteSpalte) {
  var xml = b.xml;
  final anhaengen = <String>[];
  // von hinten nach vorne ersetzen, damit die Positionen stimmen
  final ersetzen = neu.keys.where(b.zeilen.containsKey).toList()..sort();
  for (final nr in ersetzen.reversed) {
    final m = b.zeilen[nr]!;
    xml = xml.replaceRange(m.start, m.end, neu[nr]!);
  }
  final hoechste = b.zeilen.keys.fold(0, (a, c) => c > a ? c : a);
  for (final nr in neu.keys.where((n) => !b.zeilen.containsKey(n)).toList()..sort()) {
    if (nr <= hoechste) {
      throw SchreibFehler('Interner Fehler: Zeile $nr liegt zwischen bestehenden Zeilen.');
    }
    anhaengen.add(neu[nr]!);
  }
  if (anhaengen.isNotEmpty) {
    if (xml.contains('<sheetData/>')) {
      xml = xml.replaceFirst('<sheetData/>', '<sheetData>${anhaengen.join()}</sheetData>');
    } else {
      final i = xml.lastIndexOf('</sheetData>');
      if (i < 0) throw const SchreibFehler('Tabellenblatt ohne Zeilenbereich (sheetData).');
      xml = xml.replaceRange(i, i, anhaengen.join());
    }
  }
  // Bereichsangabe, z. B. <dimension ref="A1:K292"/>
  final maxZeile = [hoechste, ...neu.keys].fold(0, (a, c) => c > a ? c : a);
  final dim = RegExp(r'<dimension ref="([A-Z]+)(\d+)(?::([A-Z]+)(\d+))?"\s*/>').firstMatch(xml);
  if (dim != null) {
    final endSp = dim[3] == null ? 0 : _spaltenIndex(dim[3]!);
    final ref = '${dim[1]}${dim[2]}:${spalte(endSp > letzteSpalte ? endSp : letzteSpalte)}$maxZeile';
    xml = xml.replaceRange(dim.start, dim.end, '<dimension ref="$ref"/>');
  }
  return xml;
}

({String log, String geraete}) _blattPfade(Archive archiv) {
  String text(String n) {
    final f = archiv.findFile(n);
    if (f == null) throw SchreibFehler('Teil „$n“ fehlt in der Excel-Datei.');
    return utf8.decode(f.content);
  }

  final rels = text('xl/_rels/workbook.xml.rels');
  final ziele = <String, String>{};
  for (final m in RegExp(r'<Relationship\b[^>]*>').allMatches(rels)) {
    final id = RegExp(r'\bId="([^"]+)"').firstMatch(m[0]!);
    final ziel = RegExp(r'\bTarget="([^"]+)"').firstMatch(m[0]!);
    if (id != null && ziel != null) ziele[id[1]!] = ziel[1]!;
  }
  final wb = text('xl/workbook.xml');
  String? pfad(String name) {
    for (final m in RegExp(r'<sheet\b[^>]*>').allMatches(wb)) {
      final s = m[0]!;
      if (RegExp(r'\bname="([^"]+)"').firstMatch(s)?[1] != name) continue;
      final rid = RegExp(r'\br:id="([^"]+)"').firstMatch(s)?[1];
      var ziel = ziele[rid];
      if (ziel == null) return null;
      return ziel.startsWith('/') ? ziel.substring(1) : 'xl/$ziel';
    }
    return null;
  }

  final log = pfad('Log'), geraete = pfad('Geräte');
  if (log == null || geraete == null) {
    throw const SchreibFehler('Die Excel braucht die Tabs „Log“ und „Geräte“.');
  }
  return (log: log, geraete: geraete);
}

/// Ergänzt die Excel [original] um die neuen Zeilen aus [plan].
List<int> ergaenzeXlsx(List<int> original, Plan plan) {
  final archiv = ZipDecoder().decodeBytes(original);
  final werte = XlsxMappe.ausBytes(original);
  final pfade = _blattPfade(archiv);
  final neueTeile = <String, String>{};

  // --------------------------------------------------------------- Log
  if (plan.neueSessions.isNotEmpty) {
    final logWerte = werte.blaetter['Log']!;
    final kopf = {for (final e in logWerte[1]!.entries) '${e.value}'.trim(): e.key};
    int sp(String k) {
      final i = kopf[k];
      if (i == null) throw SchreibFehler('Tab „Log“: Spalte „$k“ fehlt in Zeile 1.');
      return i;
    }

    final cDatum = sp('Datum'), cOrt = sp('Ort'), cGeraet = sp('Gerät');
    final cSatz = sp('Satz-Nr.'), cKg = sp('Gewicht (kg)'), cLbs = sp('Gewicht (lbs)');
    final cEinheit = sp('Einheit (Eingabe)'), cWdh = sp('Wiederholungen');
    final cVol = kopf['Volumen (kg)'], cNotiz = sp('Notiz');

    final blatt = _Blatt(utf8.decode(archiv.findFile(pfade.log)!.content));
    // Letzte Zeile mit Inhalt ausserhalb der Volumen-Spalte
    var letzte = 1;
    for (final nr in blatt.zeilen.keys) {
      if (blatt.zellen(nr).keys.any((c) => c != cVol) && nr > letzte) letzte = nr;
    }
    // Vorlage für die Formatierung: letzte Zeile mit Eingabe in kg
    int? vorlage;
    for (final nr in logWerte.keys.toList()..sort()) {
      if (nr > 1 && '${logWerte[nr]![cEinheit] ?? ''}'.trim().toLowerCase() == 'kg') {
        vorlage = nr;
      }
    }
    String? stil(int c) => vorlage == null ? null : blatt.stil(vorlage, c);
    final stilEingabe = stil(cKg), stilBerechnet = stil(cLbs);

    final neu = <int, String>{};
    var nr = letzte;
    for (final s in plan.neueSessions) {
      for (final z in s.zeilen) {
        nr++;
        // Vorbereitete Zeile mit gemeinsamer Formel darf nicht ersetzt werden
        final alt = blatt.zeilen[nr]?[0] ?? '';
        if (RegExp(r'<f\b[^>]*\bt="shared"[^>]*\bref=').hasMatch(alt)) {
          throw SchreibFehler('Tab „Log“, Zeile $nr: Die Volumen-Formel ist eine '
              'gemeinsame Excel-Formel für mehrere Zeilen und kann nicht sicher '
              'ersetzt werden.');
        }
        final kgEingabe = z.einheit == Einheit.kg;
        final zellen = <int, String>{
          cDatum: _textZelle('${spalte(cDatum)}$nr', z.datum, stil(cDatum)),
          cOrt: _textZelle('${spalte(cOrt)}$nr', z.ort, stil(cOrt)),
          cGeraet: _textZelle('${spalte(cGeraet)}$nr', z.geraet, stil(cGeraet)),
          cSatz: _zahlZelle('${spalte(cSatz)}$nr', z.satzNr, stil(cSatz)),
          cKg: _zahlZelle('${spalte(cKg)}$nr', z.kg, kgEingabe ? stilEingabe : stilBerechnet),
          cLbs: _zahlZelle('${spalte(cLbs)}$nr', z.lbs, kgEingabe ? stilBerechnet : stilEingabe),
          cEinheit: _textZelle('${spalte(cEinheit)}$nr', z.einheit.name, stil(cEinheit)),
          cWdh: _zahlZelle('${spalte(cWdh)}$nr', z.wdh, stil(cWdh)),
          ?cVol: '<c r="${spalte(cVol)}$nr"${stil(cVol) == null ? '' : ' s="${stil(cVol)}"'}>'
                '<f>${spalte(cKg)}$nr*${spalte(cWdh)}$nr</f><v>${_zahl(z.kg * z.wdh)}</v></c>',
          if (z.notiz != null) cNotiz: _textZelle('${spalte(cNotiz)}$nr', z.notiz!, stil(cNotiz)),
        };
        final sortiert = zellen.keys.toList()..sort();
        neu[nr] = '<row r="$nr">${sortiert.map((c) => zellen[c]).join()}</row>';
      }
    }
    final maxSp = kopf.values.fold(0, (a, c) => c > a ? c : a);
    neueTeile[pfade.log] = _setzeZeilen(blatt, neu, maxSp);
  }

  // ------------------------------------------------------------ Geräte
  if (plan.neueGeraete.isNotEmpty) {
    final gWerte = werte.blaetter['Geräte']!;
    final kopf = {for (final e in gWerte[1]!.entries) '${e.value}'.trim(): e.key};
    final blatt = _Blatt(utf8.decode(archiv.findFile(pfade.geraete)!.content));
    final neu = <int, String>{};
    var maxSp = kopf.values.fold(0, (a, c) => c > a ? c : a);
    if (!kopf.containsKey('Muskelgruppe')) {
      // [Änderung M2] neue Überschrift in der nächsten freien Spalte
      maxSp++;
      kopf['Muskelgruppe'] = maxSp;
      final z1 = blatt.zeilen[1]![0]!;
      final stilKopf = blatt.stil(1, maxSp - 1);
      final zelle = _textZelle('${spalte(maxSp)}1', 'Muskelgruppe', stilKopf);
      neu[1] = z1.endsWith('/>')
          ? '${z1.substring(0, z1.length - 2)}>$zelle</row>'
          : '${z1.substring(0, z1.length - '</row>'.length)}$zelle</row>';
    }
    var nr = blatt.zeilen.keys.fold(1, (a, c) => c > a ? c : a);
    for (final g in plan.neueGeraete) {
      nr++;
      final felder = <String, String?>{
        'Standort': g.standort,
        'Kürzel': g.kuerzel,
        'Funktion/Muskelgruppe': g.funktion,
        'Hersteller': g.hersteller,
        'Modell': g.modell,
        'Einheit': g.einheit.name,
        'Einstellung 1': g.einstellungen[0],
        'Einstellung 2': g.einstellungen[1],
        'Einstellung 3': g.einstellungen[2],
        'Notiz': g.notiz,
        'Muskelgruppe': g.muskelgruppe,
      };
      final zellen = <int, String>{};
      felder.forEach((k, v) {
        final c = kopf[k];
        if (c == null || v == null || v.trim().isEmpty) return;
        zellen[c] = _textZelle('${spalte(c)}$nr', v, null);
      });
      final sortiert = zellen.keys.toList()..sort();
      neu[nr] = '<row r="$nr">${sortiert.map((c) => zellen[c]).join()}</row>';
    }
    var xml = _setzeZeilen(blatt, neu, maxSp);
    // Spaltenbreite für die neue Spalte (nur wenn noch keine festgelegt ist)
    final cols = RegExp(r'<col\b[^>]*\bmin="(\d+)"[^>]*\bmax="(\d+)"[^>]*/>').allMatches(xml);
    final abgedeckt = cols.any((m) =>
        int.parse(m[1]!) <= maxSp + 1 && maxSp + 1 <= int.parse(m[2]!));
    if (!abgedeckt && xml.contains('</cols>')) {
      xml = xml.replaceFirst('</cols>',
          '<col width="14" customWidth="1" min="${maxSp + 1}" max="${maxSp + 1}"/></cols>');
    }
    neueTeile[pfade.geraete] = xml;
  }

  // ------------------------------------------------- Datei zusammensetzen
  final aus = Archive();
  for (final f in archiv.files) {
    final ersatz = neueTeile[f.name];
    aus.addFile(ersatz == null ? f : ArchiveFile.bytes(f.name, utf8.encode(ersatz)));
  }
  return ZipEncoder().encode(aus);
}

/// Prüft nach dem Schreiben: Alle bisherigen Werte sind unverändert und die
/// neuen Zeilen sind da. Gibt die gefundenen Probleme zurück (leer = gut).
List<String> pruefeErgebnis(XlsxMappe vorher, XlsxMappe nachher, Plan plan) {
  final probleme = <String>[];
  final logKopf = vorher.blaetter['Log']?[1] ?? const {};
  final cVol = logKopf.entries
      .where((e) => '${e.value}'.trim() == 'Volumen (kg)')
      .map((e) => e.key)
      .firstOrNull;
  for (final name in vorher.blaetter.keys) {
    final a = vorher.blaetter[name]!, b = nachher.blaetter[name];
    if (b == null) {
      probleme.add('Tab „$name“ fehlt nach dem Schreiben');
      continue;
    }
    for (final nr in a.keys) {
      final za = a[nr]!, zb = b[nr] ?? const {};
      // Vorbereitete Zeilen im Log (nur Volumen-Formel) dürfen gefüllt werden
      if (name == 'Log' && za.keys.every((c) => c == cVol)) continue;
      for (final sp in za.keys) {
        if ('${za[sp]}' != '${zb[sp]}') {
          probleme.add('Tab „$name“, Zelle ${spalte(sp)}$nr hat sich verändert');
        }
      }
    }
  }
  int inhaltZeilen(XlsxMappe m) =>
      m.blaetter['Log']!.entries.where((e) => e.key > 1 && e.value.length > 1).length;
  final erwartet = inhaltZeilen(vorher) + plan.anzahlZeilen;
  if (inhaltZeilen(nachher) != erwartet) {
    probleme.add('Tab „Log“: erwartet $erwartet Zeilen mit Inhalt, gefunden '
        '${inhaltZeilen(nachher)}');
  }
  final gVorher = vorher.blaetter['Geräte']!.length;
  final gNachher = nachher.blaetter['Geräte']!.length;
  if (gNachher != gVorher + plan.neueGeraete.length) {
    probleme.add('Tab „Geräte“: erwartet ${gVorher + plan.neueGeraete.length} '
        'Zeilen, gefunden $gNachher');
  }
  return probleme;
}
