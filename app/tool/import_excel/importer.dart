// Umwandlung Trainings-Excel (Tabs „Log“ und „Geräte“) → Datenbank.
//
// Grundsätze (WP1.3/1.4, Entscheide vom 12.11.2026):
// - Trainingsdaten werden NICHT verändert: Eingabewert und Eingabeeinheit
//   kommen 1:1 aus der Excel. Auffälliges wird nur gemeldet.
// - Nicht eindeutige Zeilen werden nicht geraten, sondern als Fehler gemeldet
//   und nicht importiert.
// - Doppel-Kürzel werden nur gemäss Entscheidungsdatei zusammengeführt.
//
// Reine Dart-Datei (kein Flutter).

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:trainingsapp/data/db/datenbank.dart';

import 'xlsx_leser.dart';

// ------------------------------------------------------------ Meldungen

enum Stufe { fehler, warnung, info }

class Meldung {
  Meldung(this.stufe, this.text, {this.zeile});
  final Stufe stufe;
  final String text;

  /// Excel-Zeile im Tab Log (null = betrifft Gerät oder Konfiguration).
  final int? zeile;

  @override
  String toString() => '${zeile != null ? 'Zeile $zeile: ' : ''}$text';
}

// ------------------------------------------------------ Entscheidungen

class Zusammenfuehrung {
  Zusammenfuehrung(this.standort, this.basis, this.zusatz);
  final String standort, basis, zusatz;
}

class Entscheidungen {
  Entscheidungen({
    required this.zusammenfuehren,
    required this.muskelgruppeNachFunktion,
    required this.muskelgruppeOhneFunktion,
    required this.stichproben,
  });

  final List<Zusammenfuehrung> zusammenfuehren;

  /// Funktion (Tab Geräte) → Muskelgruppe.
  final Map<String, String> muskelgruppeNachFunktion;

  /// „Standort/Kürzel“ → Muskelgruppe, für Geräte ohne Funktion.
  final Map<String, String> muskelgruppeOhneFunktion;

  /// Sessions „JJJJ-MM-TT Standort“, die der Prüfbericht Satz für Satz zeigt.
  final List<String> stichproben;

  factory Entscheidungen.ausJson(Map<String, dynamic> j) => Entscheidungen(
        zusammenfuehren: [
          for (final z in (j['zusammenfuehren'] as List? ?? []))
            Zusammenfuehrung(z['standort'] as String, z['basis'] as String,
                z['zusatz'] as String),
        ],
        muskelgruppeNachFunktion:
            Map<String, String>.from(j['muskelgruppeNachFunktion'] as Map? ?? {}),
        muskelgruppeOhneFunktion:
            Map<String, String>.from(j['muskelgruppeOhneFunktion'] as Map? ?? {}),
        stichproben: List<String>.from(j['stichproben'] as List? ?? []),
      );

  factory Entscheidungen.ausDatei(String pfad) => Entscheidungen.ausJson(
      jsonDecode(File(pfad).readAsStringSync()) as Map<String, dynamic>);
}

// ------------------------------------------------------------ Ergebnis

class SessionZaehlung {
  SessionZaehlung(this.datum, this.standort);
  final String datum, standort;
  int excelZeilen = 0;
  int importiert = 0;
  int fehler = 0;
}

class StichprobenSatz {
  StichprobenSatz(this.zeile, this.excelKuerzel, this.geraet, this.seite,
      this.satzNr, this.wdh, this.eingabe, this.einheit, this.kg, this.notiz);
  final int zeile, satzNr, wdh;
  final String excelKuerzel, geraet;
  final Seite? seite;
  final double eingabe, kg;
  final Einheit einheit;
  final String? notiz;
}

class ImportErgebnis {
  final meldungen = <Meldung>[];
  int logZeilenMitInhalt = 0;
  int leereZeilen = 0;
  int importierteSaetze = 0;
  int geraeteTabZeilen = 0;
  int geraeteImportiert = 0;
  final sessions = <String, SessionZaehlung>{};
  final stichproben = <String, List<StichprobenSatz>>{};

  Iterable<Meldung> get fehler => meldungen.where((m) => m.stufe == Stufe.fehler);
  Iterable<Meldung> get warnungen =>
      meldungen.where((m) => m.stufe == Stufe.warnung);
  Iterable<Meldung> get infos => meldungen.where((m) => m.stufe == Stufe.info);

  /// Fehler, die nicht zu einer Log-Zeile gehören (Konfiguration, Gerät).
  Iterable<Meldung> get grundfehler => fehler.where((m) => m.zeile == null);

  String alsMarkdown({required String quelle}) {
    final b = StringBuffer()
      ..writeln('# Prüfbericht Umwandlung Excel → Startdatenbank')
      ..writeln()
      ..writeln('Quelle: `$quelle`  ')
      ..writeln('Erstellt: ${DateTime.now().toIso8601String().substring(0, 16)}')
      ..writeln()
      ..writeln('## Zahlen')
      ..writeln()
      ..writeln('| Grösse | Wert |')
      ..writeln('|---|---|')
      ..writeln('| Log-Zeilen mit Inhalt | $logZeilenMitInhalt |')
      ..writeln('| Leere Zeilen (ignoriert) | $leereZeilen |')
      ..writeln('| Fehler (nicht importiert) | ${fehler.length} |')
      ..writeln('| **Importierte Sätze** | **$importierteSaetze** |')
      ..writeln('| Sessions | ${sessions.length} |')
      ..writeln('| Zeilen im Tab Geräte | $geraeteTabZeilen |')
      ..writeln('| Geräte importiert (nach Zusammenführung) | $geraeteImportiert |')
      ..writeln('| Warnungen | ${warnungen.length} |')
      ..writeln('| Hinweise | ${infos.length} |')
      ..writeln();
    void liste(String titel, Iterable<Meldung> ms) {
      b
        ..writeln('## $titel (${ms.length})')
        ..writeln();
      if (ms.isEmpty) b.writeln('keine');
      for (final m in ms) {
        b.writeln('- $m');
      }
      b.writeln();
    }

    liste('Fehler – nicht importiert', fehler);
    liste('Warnungen – importiert, bitte prüfen', warnungen);
    liste('Hinweise', infos);

    b
      ..writeln('## Sessions')
      ..writeln()
      ..writeln('| Datum | Standort | Excel-Zeilen | importiert | Fehler |')
      ..writeln('|---|---|---|---|---|');
    final sortiert = sessions.values.toList()
      ..sort((a, c) => a.datum.compareTo(c.datum));
    for (final s in sortiert) {
      b.writeln('| ${s.datum} | ${s.standort} | ${s.excelZeilen} | '
          '${s.importiert} | ${s.fehler} |');
    }
    b.writeln();

    if (stichproben.isNotEmpty) {
      b
        ..writeln('## Stichproben (Satz für Satz)')
        ..writeln();
      stichproben.forEach((key, saetze) {
        b
          ..writeln('### $key – ${saetze.length} Sätze')
          ..writeln()
          ..writeln('| Excel-Zeile | Excel-Kürzel | Gerät | Seite | Satz | Wdh | '
              'Eingabe | kg | Notiz |')
          ..writeln('|---|---|---|---|---|---|---|---|---|');
        for (final s in saetze) {
          b.writeln('| ${s.zeile} | ${s.excelKuerzel} | ${s.geraet} | '
              '${s.seite?.name ?? ''} | ${s.satzNr} | ${s.wdh} | '
              '${_z(s.eingabe)} ${s.einheit.name} | ${_z(s.kg)} | '
              '${s.notiz ?? ''} |');
        }
        b.writeln();
      });
    }
    return b.toString();
  }
}

String _z(double v) {
  var s = v.toStringAsFixed(2);
  s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return s;
}

// ------------------------------------------------------------- Import

class _GeraetRoh {
  _GeraetRoh({
    required this.zeile,
    required this.standort,
    required this.kuerzel,
    required this.funktion,
    required this.hersteller,
    required this.modell,
    required this.einheit,
    required this.einstellungen,
    required this.notiz,
  });
  final int zeile;
  final String standort, kuerzel;
  final String? funktion, hersteller, modell, notiz;
  final Einheit einheit;
  final List<String?> einstellungen;
  bool linksRechts = false;
  int? id;
  String? zusatzNotiz;

  bool get assistiert => (notiz ?? '').toLowerCase().contains('assistiert');
  String get schluessel => '$standort/$kuerzel';
}

class _Zeile {
  _Zeile(this.nr, this.werte, this.spalten);
  final int nr;
  final Map<int, Object> werte;
  final Map<String, int> spalten;
  Object? operator [](String kopf) => werte[spalten[kopf]];
}

const _logKoepfe = [
  'Datum', 'Ort', 'Gerät', 'Satz-Nr.', 'Gewicht (kg)', 'Gewicht (lbs)',
  'Einheit (Eingabe)', 'Wiederholungen', 'Notiz',
];
const _geraeteKoepfe = [
  'Standort', 'Kürzel', 'Funktion/Muskelgruppe', 'Hersteller', 'Modell',
  'Einheit', 'Einstellung 1', 'Einstellung 2', 'Einstellung 3', 'Notiz',
];

Map<String, int> _kopfSpalten(Map<int, Object>? kopf, List<String> noetig,
    String blatt) {
  final m = <String, int>{};
  kopf?.forEach((i, v) => m['$v'] = i);
  final fehlt = noetig.where((k) => !m.containsKey(k)).toList();
  if (fehlt.isNotEmpty) {
    throw FormatException('Tab „$blatt“: Spalten fehlen: ${fehlt.join(', ')}');
  }
  return m;
}

String? _text(Object? v) => v == null ? null : '$v'.trim();

double? _zahl(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

int? _ganzzahl(Object? v) {
  final d = _zahl(v);
  if (d == null || d != d.roundToDouble()) return null;
  return d.toInt();
}

Einheit? _einheit(Object? v) => switch (_text(v)?.toLowerCase()) {
      'kg' => Einheit.kg,
      'lbs' => Einheit.lbs,
      _ => null,
    };

String? _datum(Object? v) {
  if (v is num) {
    // Excel-Seriennummer → Datum (eindeutig)
    final d = DateTime.utc(1899, 12, 30).add(Duration(days: v.floor()));
    return d.toIso8601String().substring(0, 10);
  }
  final s = _text(v);
  if (s == null) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (m == null) return null;
  final d = DateTime.tryParse(s);
  if (d == null || d.month != int.parse(m[2]!) || d.day != int.parse(m[3]!)) {
    return null;
  }
  return s;
}

final _reEingabe = RegExp(r'^Eingabe:\s*([\d.,]+)\s*(kg|lbs)$');
final _reAssistiert =
    RegExp(r'^assistiert:\s*([\d.,]+)\s*-\s*([\d.,]+)\s*kg Eingabe$');
final _reGleichesGeraet = RegExp(r'^gleiches Gerät wie\s+\S+$');
final _reSeite = RegExp(r'^(.+)-(links|rechts)$');
final _reZusatzKuerzel = RegExp(r'^(.+)\.(\d+)$');

double _komma(String s) => double.parse(s.replaceAll(',', '.'));

/// Führt den Import aus und schreibt in [db] (leere, neu angelegte Datenbank).
Future<ImportErgebnis> importiere({
  required XlsxMappe mappe,
  required Entscheidungen entscheidungen,
  required Datenbank db,
}) async {
  final erg = ImportErgebnis();
  void melde(Stufe s, String t, {int? zeile}) =>
      erg.meldungen.add(Meldung(s, t, zeile: zeile));

  final logBlatt = mappe.blaetter['Log'];
  final geraeteBlatt = mappe.blaetter['Geräte'];
  if (logBlatt == null || geraeteBlatt == null) {
    throw const FormatException('Tabs „Log“ und „Geräte“ werden benötigt.');
  }

  // --------------------------------------------------------- Geräte lesen
  final gSp = _kopfSpalten(geraeteBlatt[1], _geraeteKoepfe, 'Geräte');
  final geraete = <String, _GeraetRoh>{};
  final standortReihenfolge = <String>[];
  for (final nr in geraeteBlatt.keys.where((k) => k > 1).toList()..sort()) {
    final z = _Zeile(nr, geraeteBlatt[nr]!, gSp);
    if (z.werte.isEmpty) continue;
    erg.geraeteTabZeilen++;
    final standort = _text(z['Standort']);
    final kuerzel = _text(z['Kürzel']);
    final einheit = _einheit(z['Einheit']);
    if (standort == null || kuerzel == null) {
      melde(Stufe.fehler, 'Tab Geräte, Zeile $nr: Standort oder Kürzel fehlt');
      continue;
    }
    if (einheit == null) {
      melde(Stufe.fehler,
          'Tab Geräte, Zeile $nr ($standort/$kuerzel): Einheit „${z['Einheit']}“ unbekannt');
      continue;
    }
    final g = _GeraetRoh(
      zeile: nr,
      standort: standort,
      kuerzel: kuerzel,
      funktion: _text(z['Funktion/Muskelgruppe']),
      hersteller: _text(z['Hersteller']),
      modell: _text(z['Modell']),
      einheit: einheit,
      einstellungen: [
        _text(z['Einstellung 1']),
        _text(z['Einstellung 2']),
        _text(z['Einstellung 3']),
      ],
      notiz: _text(z['Notiz']),
    );
    if (geraete.containsKey(g.schluessel)) {
      melde(Stufe.fehler,
          'Tab Geräte, Zeile $nr: ${g.schluessel} ist doppelt eingetragen');
      continue;
    }
    geraete[g.schluessel] = g;
    if (!standortReihenfolge.contains(standort)) standortReihenfolge.add(standort);
  }

  // ------------------------------------------- Doppel-Kürzel zusammenführen
  /// „Standort/Kürzel“ aus der Excel → Gerät, unter dem importiert wird.
  final alias = <String, _GeraetRoh>{
    for (final g in geraete.values) g.schluessel: g,
  };
  final zusatzGeraete = <String, _GeraetRoh>{};
  for (final z in entscheidungen.zusammenfuehren) {
    final basis = geraete['${z.standort}/${z.basis}'];
    final zusatz = geraete['${z.standort}/${z.zusatz}'];
    if (basis == null || zusatz == null) {
      melde(Stufe.fehler,
          'Entscheidungsdatei: ${z.standort} ${z.basis}/${z.zusatz} – Gerät nicht im Tab Geräte');
      continue;
    }
    alias[zusatz.schluessel] = basis;
    zusatzGeraete[zusatz.schluessel] = zusatz;
    geraete.remove(zusatz.schluessel);
    final angaben = [
      zusatz.hersteller,
      zusatz.modell,
      zusatz.einheit.name,
      zusatz.notiz,
    ].whereType<String>().join(', ');
    basis.zusatzNotiz = [
      if (basis.zusatzNotiz != null) basis.zusatzNotiz!,
      'zusammengeführt mit ${zusatz.kuerzel} ($angaben)',
    ].join(' | ');
    melde(Stufe.info,
        '${z.standort}: ${zusatz.kuerzel} zusammengeführt mit ${basis.kuerzel}');
  }
  for (final g in geraete.values) {
    final m = _reZusatzKuerzel.firstMatch(g.kuerzel);
    if (m != null && geraete.containsKey('${g.standort}/${m[1]}')) {
      melde(Stufe.warnung,
          '${g.standort}: ${g.kuerzel} und ${m[1]} sehen nach Doppel-Kürzel aus, '
          'stehen aber nicht in der Entscheidungsdatei – getrennt gelassen');
    }
  }

  // ------------------------------------------------------- Log vorprüfen
  final lSp = _kopfSpalten(logBlatt[1], _logKoepfe, 'Log');
  final logZeilen = [
    for (final nr in logBlatt.keys.where((k) => k > 1).toList()..sort())
      _Zeile(nr, logBlatt[nr]!, lSp),
  ];

  // Seiten-Kürzel markieren Geräte als links/rechts getrennt
  for (final z in logZeilen) {
    final code = _text(z['Gerät']);
    final ort = _text(z['Ort']);
    final m = code == null ? null : _reSeite.firstMatch(code);
    if (m != null && ort != null) alias['$ort/${m[1]}']?.linksRechts = true;
  }

  // ------------------------------------------------ Muskelgruppen-IDs
  final gruppen = {
    for (final g in await db.select(db.muskelgruppen).get()) g.name: g.id,
  };
  int? gruppeFuer(_GeraetRoh g) {
    String? name;
    if (g.funktion != null) {
      name = entscheidungen.muskelgruppeNachFunktion[g.funktion];
      if (name == null) {
        melde(Stufe.warnung,
            '${g.schluessel}: Funktion „${g.funktion}“ hat keine Muskelgruppen-Zuordnung – bleibt leer');
        return null;
      }
    } else {
      name = entscheidungen.muskelgruppeOhneFunktion[g.schluessel];
      if (name == null) {
        melde(Stufe.info, '${g.schluessel}: keine Funktion – Muskelgruppe bleibt leer');
        return null;
      }
    }
    final id = gruppen[name];
    if (id == null) {
      melde(Stufe.fehler,
          'Entscheidungsdatei: Muskelgruppe „$name“ (für ${g.schluessel}) gibt es nicht');
    }
    return id;
  }

  // --------------------------------------------- Zeilen einzeln auswerten
  final gueltig = <_Satzdaten>[];
  final koerpergewicht = <String, double>{};

  for (final z in logZeilen) {
    final datumRoh = z['Datum'], ortRoh = z['Ort'], codeRoh = z['Gerät'];
    final hatInhalt = [
      datumRoh, ortRoh, codeRoh, z['Satz-Nr.'], z['Gewicht (kg)'],
      z['Gewicht (lbs)'], z['Einheit (Eingabe)'], z['Wiederholungen'], z['Notiz'],
    ].any((v) => v != null);
    if (!hatInhalt) {
      erg.leereZeilen++;
      continue;
    }
    erg.logZeilenMitInhalt++;
    void fehler(String t) => melde(Stufe.fehler, t, zeile: z.nr);

    final ort = _text(ortRoh);
    final datum = _datum(datumRoh);
    if (datum == null) {
      fehler('Datum „${_text(datumRoh) ?? ''}“ nicht eindeutig lesbar '
          '(erwartet JJJJ-MM-TT)');
      continue;
    }
    if (ort == null) {
      fehler('Ort fehlt');
      continue;
    }
    final sKey = '$datum $ort';
    final zaehlung =
        erg.sessions.putIfAbsent(sKey, () => SessionZaehlung(datum, ort));
    zaehlung.excelZeilen++;
    void fehlerS(String t) {
      fehler(t);
      zaehlung.fehler++;
    }

    if (!standortReihenfolge.contains(ort)) {
      fehlerS('Standort „$ort“ steht nicht im Tab Geräte');
      continue;
    }
    final code = _text(codeRoh);
    if (code == null) {
      fehlerS('Gerät fehlt');
      continue;
    }
    final seiteM = _reSeite.firstMatch(code);
    final kuerzel = seiteM?[1] ?? code;
    final seite = switch (seiteM?[2]) {
      'links' => Seite.L,
      'rechts' => Seite.R,
      _ => null,
    };
    final geraet = alias['$ort/$kuerzel'];
    if (geraet == null) {
      fehlerS('Kürzel „$code“ steht nicht im Tab Geräte ($ort)');
      continue;
    }
    final einheit = _einheit(z['Einheit (Eingabe)']);
    if (einheit == null) {
      fehlerS('Einheit „${_text(z['Einheit (Eingabe)']) ?? ''}“ unbekannt '
          '(erwartet kg oder lbs)');
      continue;
    }
    final wdh = _ganzzahl(z['Wiederholungen']);
    if (wdh == null || wdh <= 0) {
      fehlerS('Wiederholungen fehlen oder sind keine ganze Zahl');
      continue;
    }
    final kgExcel = _zahl(z['Gewicht (kg)']);
    final lbsExcel = _zahl(z['Gewicht (lbs)']);

    // Notiz zerlegen: automatische Teile prüfen und entfernen
    final behalten = <String>[];
    double? notizEingabe;
    Einheit? notizEinheit;
    double? assistKw, assistEingabe;
    for (final teil in (_text(z['Notiz']) ?? '').split(';')) {
      final t = teil.trim();
      if (t.isEmpty) continue;
      final mE = _reEingabe.firstMatch(t);
      final mA = _reAssistiert.firstMatch(t);
      if (mE != null) {
        notizEingabe = _komma(mE[1]!);
        notizEinheit = _einheit(mE[2]);
      } else if (mA != null) {
        assistKw = _komma(mA[1]!);
        assistEingabe = _komma(mA[2]!);
      } else if (_reGleichesGeraet.hasMatch(t)) {
        // Geräte-Information, steht im Tab Geräte
      } else {
        behalten.add(t);
      }
    }

    double eingabewert;
    double gewichtKg;
    if (geraet.assistiert) {
      if (assistKw == null || assistEingabe == null) {
        fehlerS('assistiertes Gerät ${geraet.kuerzel}: Notiz '
            '„assistiert: Körpergewicht - Eingabe kg Eingabe“ fehlt');
        continue;
      }
      if (einheit != Einheit.kg) {
        fehlerS('assistiertes Gerät ${geraet.kuerzel}: Eingabe nicht in kg');
        continue;
      }
      eingabewert = assistEingabe;
      gewichtKg = gewichtKgFuerSatz(
          eingabewert: eingabewert,
          eingabeeinheit: einheit,
          assistiert: true,
          koerpergewichtKg: assistKw);
      if (kgExcel == null || (kgExcel - gewichtKg).abs() > 0.01) {
        fehlerS('assistiert: Gewicht (kg) ${kgExcel ?? '–'} passt nicht zu '
            '${_z(assistKw)} − ${_z(assistEingabe)}');
        continue;
      }
      final bisher = koerpergewicht[sKey];
      if (bisher != null && bisher != assistKw) {
        fehlerS('Körpergewicht widersprüchlich in dieser Session '
            '(${_z(bisher)} / ${_z(assistKw)})');
        continue;
      }
      koerpergewicht[sKey] = assistKw;
    } else {
      if (assistKw != null) {
        fehlerS('Notiz „assistiert …“, aber ${geraet.kuerzel} ist im Tab Geräte '
            'nicht als assistiert markiert');
        continue;
      }
      final roh = einheit == Einheit.kg ? kgExcel : lbsExcel;
      if (roh == null) {
        fehlerS('Gewicht (${einheit.name}) fehlt');
        continue;
      }
      eingabewert = roh;
      gewichtKg = gewichtKgFuerSatz(eingabewert: roh, eingabeeinheit: einheit);
      if (einheit == Einheit.lbs && kgExcel != null &&
          (kgExcel - gewichtKg).abs() > 0.005) {
        melde(Stufe.info,
            'kg-Spalte gerundet: Excel ${_z(kgExcel)} kg, aus ${_z(roh)} lbs '
            'berechnet ${_z(gewichtKg)} kg',
            zeile: z.nr);
      }
    }
    if (notizEingabe != null &&
        ((notizEingabe - eingabewert).abs() > 0.001 || notizEinheit != einheit)) {
      fehlerS('Notiz „Eingabe: ${_z(notizEingabe)} ${notizEinheit?.name}“ '
          'widerspricht dem Eingabewert ${_z(eingabewert)} ${einheit.name}');
      continue;
    }

    // Einheit weicht von der Vorgabe des Geräts ab?
    final herkunft = zusatzGeraete['$ort/$kuerzel'] ?? geraet;
    if (einheit != herkunft.einheit) {
      var t = '$code: Eingabe in ${einheit.name}, Gerät hat Vorgabe '
          '${herkunft.einheit.name} – übernommen wie erfasst';
      if (einheit == Einheit.kg && herkunft.einheit == Einheit.lbs) {
        final alsLbs = eingabewert / 0.45;
        if ((alsLbs - (alsLbs / 5).round() * 5).abs() < 0.01) {
          t += ' (Wert = ${_z(alsLbs)} lbs × 0,45 – evtl. mit falschem Faktor '
              'umgerechnet)';
        }
      }
      melde(Stufe.warnung, t, zeile: z.nr);
    }

    gueltig.add(_Satzdaten(
      zeile: z.nr,
      sessionKey: sKey,
      excelKuerzel: code,
      geraet: geraet,
      seite: seite,
      satzNrExcel: _ganzzahl(z['Satz-Nr.']),
      wdh: wdh,
      eingabewert: eingabewert,
      einheit: einheit,
      gewichtKg: gewichtKg,
      notiz: behalten.isEmpty ? null : behalten.join('; '),
    ));
  }

  // Seiten-Kürzel auf Geräten ohne Seite und umgekehrt
  for (final s in gueltig) {
    if (s.geraet.linksRechts && s.seite == null) {
      melde(Stufe.warnung,
          '${s.excelKuerzel}: Gerät wird links/rechts gezählt, Zeile hat keine Seite',
          zeile: s.zeile);
    }
  }

  // ----------------------------------------------------- Satz-Nummern
  final zaehler = <String, int>{};
  for (final s in gueltig) {
    final k = '${s.sessionKey}|${s.geraet.schluessel}|${s.seite?.name}';
    s.satzNr = (zaehler[k] ?? 0) + 1;
    zaehler[k] = s.satzNr;
    if (s.satzNrExcel != s.satzNr) {
      melde(Stufe.warnung,
          '${s.excelKuerzel}: Satz-Nr. ${s.satzNrExcel ?? '–'} in der Excel, '
          'fortlaufend ist es Satz ${s.satzNr} – als Satz ${s.satzNr} importiert',
          zeile: s.zeile);
    }
  }

  // --------------------------------------------------------- Schreiben
  await db.transaction(() async {
    final standortIds = <String, int>{};
    for (final name in standortReihenfolge) {
      standortIds[name] =
          await db.into(db.standorte).insert(StandorteCompanion.insert(name: name));
    }
    final geordnet = geraete.values.toList()
      ..sort((a, c) => a.zeile.compareTo(c.zeile));
    for (final g in geordnet) {
      final notiz = [g.notiz, g.zusatzNotiz].whereType<String>().join(' | ');
      g.id = await db.into(db.geraete).insert(GeraeteCompanion.insert(
            standortId: standortIds[g.standort]!,
            kuerzel: g.kuerzel,
            funktion: Value(g.funktion),
            muskelgruppeId: Value(gruppeFuer(g)),
            hersteller: Value(g.hersteller),
            modell: Value(g.modell),
            einheit: g.einheit,
            assistiert: Value(g.assistiert),
            linksRechtsGetrennt: Value(g.linksRechts),
            einstellung1: Value(g.einstellungen[0]),
            einstellung2: Value(g.einstellungen[1]),
            einstellung3: Value(g.einstellungen[2]),
            notiz: Value(notiz.isEmpty ? null : notiz),
          ));
      if (g.assistiert) melde(Stufe.info, '${g.schluessel}: als assistiert markiert');
      if (g.linksRechts) {
        melde(Stufe.info, '${g.schluessel}: als links/rechts getrennt markiert');
      }
    }
    erg.geraeteImportiert = geordnet.length;

    // Sessions chronologisch anlegen
    final sessionKeys = {for (final s in gueltig) s.sessionKey}.toList()
      ..sort();
    final sessionIds = <String, int>{};
    for (final k in sessionKeys) {
      final z = erg.sessions[k]!;
      sessionIds[k] = await db.into(db.sessions).insert(SessionsCompanion.insert(
            datum: z.datum,
            standortId: standortIds[z.standort]!,
            koerpergewichtKg: Value(koerpergewicht[k]),
          ));
    }

    for (final s in gueltig) {
      await db.into(db.saetze).insert(SaetzeCompanion.insert(
            sessionId: sessionIds[s.sessionKey]!,
            geraetId: s.geraet.id!,
            satzNr: s.satzNr,
            seite: Value(s.seite),
            wiederholungen: s.wdh,
            eingabewert: s.eingabewert,
            eingabeeinheit: s.einheit,
            gewichtKg: s.gewichtKg,
            notiz: Value(s.notiz),
          ));
      erg.sessions[s.sessionKey]!.importiert++;
      erg.importierteSaetze++;
      if (entscheidungen.stichproben.contains(s.sessionKey)) {
        erg.stichproben.putIfAbsent(s.sessionKey, () => []).add(StichprobenSatz(
            s.zeile, s.excelKuerzel, s.geraet.kuerzel, s.seite, s.satzNr,
            s.wdh, s.eingabewert, s.einheit, s.gewichtKg, s.notiz));
      }
    }
  });

  // Sessions ohne einen einzigen gültigen Satz
  erg.sessions.removeWhere((k, v) {
    if (v.importiert > 0) return false;
    melde(Stufe.warnung, 'Session $k: keine gültige Zeile – nicht angelegt');
    return true;
  });
  return erg;
}

class _Satzdaten {
  _Satzdaten({
    required this.zeile,
    required this.sessionKey,
    required this.excelKuerzel,
    required this.geraet,
    required this.seite,
    required this.satzNrExcel,
    required this.wdh,
    required this.eingabewert,
    required this.einheit,
    required this.gewichtKg,
    required this.notiz,
  });
  final int zeile, wdh;
  final String sessionKey, excelKuerzel;
  final _GeraetRoh geraet;
  final Seite? seite;
  final int? satzNrExcel;
  final double eingabewert, gewichtKg;
  final Einheit einheit;
  final String? notiz;
  int satzNr = 0;
}
