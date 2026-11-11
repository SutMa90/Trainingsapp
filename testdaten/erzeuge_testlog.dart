// Erzeugt testdaten/Testlog.xlsx – eine SYNTHETISCHE Trainings-Excel
// im gleichen Aufbau wie die echte (Tabs Log, Geräte, Legende).
//
// Alle Werte, Standorte und Hersteller sind erfunden. Jeder Sonderfall
// aus der echten Datei ist genau einmal gezielt eingebaut; die
// erwarteten Ergebnisse stehen in testdaten/ERWARTET.md.
//
// Aufruf (im Projektordner):  dart run testdaten/erzeuge_testlog.dart
// Benötigt keine Zusatzpakete.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const lbsFaktor = 0.4536;

double r2(double v) => (v * 100).round() / 100;

// ---------------------------------------------------------------- Log
// Eine Zeile: Datum, Ort, Gerät, Satz-Nr., kg, lbs, Einheit, Wdh, Notiz.
// Bei Einheit kg ist die kg-Spalte die Eingabe (fett), sonst die lbs-Spalte.
class LogZeile {
  final String datum, ort, geraet, einheit, notiz;
  final int? satz, wdh;
  final double kg, lbs;
  LogZeile(this.datum, this.ort, this.geraet, this.satz, this.kg, this.lbs,
      this.einheit, this.wdh, [this.notiz = '']);
}

LogZeile kg(String d, String o, String g, int s, double kg, int? wdh,
        [String notiz = '', String einheit = 'kg']) =>
    LogZeile(d, o, g, s, kg, r2(kg / lbsFaktor), einheit, wdh, notiz);

LogZeile lbs(String d, String o, String g, int s, double lbs, int wdh,
        {String? notiz, double? kgWert}) =>
    LogZeile(d, o, g, s, kgWert ?? r2(lbs * lbsFaktor), lbs, 'lbs', wdh,
        notiz ?? 'Eingabe: ${_zahl(lbs)} lbs');

/// Assistiertes Gerät: kg-Spalte = Körpergewicht − Eingabe, Eingabe in Notiz.
LogZeile assistiert(String d, String o, String g, int s, double kw,
        double eingabe, int wdh) =>
    kg(d, o, g, s, kw - eingabe, wdh,
        'assistiert: ${_zahl(kw)} - ${_zahl(eingabe)} kg Eingabe');

String _zahl(num v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';

const n = 'Nordstadt', s = 'Südstadt';

final log = <LogZeile>[
  // S1 – Nordstadt: kg-Geräte, assistiert, abwechselnde Reihenfolge
  kg('2025-03-03', n, 'A2', 1, 80, 15),
  kg('2025-03-03', n, 'A2', 2, 85, 15),
  kg('2025-03-03', n, 'D1', 1, 25, 15),
  kg('2025-03-03', n, 'B4', 1, 30, 15),
  kg('2025-03-03', n, 'D1', 2, 27.5, 12),
  kg('2025-03-03', n, 'B4', 2, 30, 15),
  assistiert('2025-03-03', n, 'T1', 1, 78, 40, 8),
  assistiert('2025-03-03', n, 'T1', 2, 78, 45, 10),
  kg('2025-03-03', n, 'E1', 1, 40, 20),
  kg('2025-03-03', n, 'E2', 1, 35, 20),

  // S2 – Südstadt: lbs-Geräte, Rundung, Doppel-Kürzel in kg, links/rechts
  lbs('2025-03-06', s, 'A2', 1, 200, 15, kgWert: 90.7), // auf 1 Stelle gerundet
  lbs('2025-03-06', s, 'A2', 2, 200, 15),
  kg('2025-03-06', s, 'X4.1', 1, 30, 15),
  kg('2025-03-06', s, 'X4.1', 2, 32.5, 12),
  kg('2025-03-06', s, 'X5.1', 1, 35, 15),
  kg('2025-03-06', s, 'X5.1', 2, 35, 15),
  lbs('2025-03-06', s, 'C3-links', 1, 40, 15),
  lbs('2025-03-06', s, 'C3-rechts', 1, 40, 15),
  lbs('2025-03-06', s, 'C3-links', 2, 45, 12),
  lbs('2025-03-06', s, 'C3-rechts', 2, 45, 12),
  lbs('2025-03-06', s, 'E1', 1, 60, 20),
  lbs('2025-03-06', s, 'E2', 1, 70, 20),

  // S3 – Nordstadt: einmalige lbs-Eingabe auf kg-Gerät, Zusatzgewicht
  kg('2025-03-12', n, 'A2', 1, 85, 15),
  kg('2025-03-12', n, 'A2', 2, 90, 12),
  lbs('2025-03-12', n, 'D1', 1, 50, 15),
  lbs('2025-03-12', n, 'D1', 2, 60, 12),
  kg('2025-03-12', n, 'B4', 1, 35, 12, 'inkl. 5 kg Zusatzgewicht (Anzeige 30 kg)'),
  kg('2025-03-12', n, 'B4', 2, 35, 12, 'inkl. 5 kg Zusatzgewicht (Anzeige 30 kg)'),
  kg('2025-03-12', n, 'C1', 1, 30, 20),
  kg('2025-03-12', n, 'C1', 2, 30, 20),

  // S4 – Südstadt: lbs-Geräte als "kg" erfasst, Werte = lbs × 0,45
  kg('2025-03-18', s, 'A2', 1, 85.5, 15), // 190 lbs × 0,45
  kg('2025-03-18', s, 'A2', 2, 90, 15), //   200 lbs × 0,45
  kg('2025-03-18', s, 'E1', 1, 27, 20), //    60 lbs × 0,45
  kg('2025-03-18', s, 'E2', 1, 31.5, 20), //  70 lbs × 0,45
  kg('2025-03-18', s, 'X4.1', 1, 32.5, 15), // echtes kg-Gerät
  kg('2025-03-18', s, 'X4.1', 2, 35, 12),

  // S5 – Südstadt: Doppel-Kürzel in lbs, widersprüchliche Auto-Notiz
  lbs('2025-03-25', s, 'X4', 1, 65, 15),
  lbs('2025-03-25', s, 'X4', 2, 70, 15),
  lbs('2025-03-25', s, 'X5', 1, 70, 15),
  lbs('2025-03-25', s, 'X5', 2, 75, 12),
  lbs('2025-03-25', s, 'A2', 1, 210, 15),
  lbs('2025-03-25', s, 'A2', 2, 210, 15),
  lbs('2025-03-25', s, 'E1', 1, 65, 20),
  lbs('2025-03-25', s, 'E2', 1, 75, 20, notiz: 'Eingabe: 70 lbs'), // Widerspruch

  // S6 – Nordstadt: absichtlich unklare Zeilen
  kg('2025-04-02', n, 'A2', 1, 90, 15),
  kg('2025-04-02', n, 'A2', 2, 90, null), // Wdh fehlt
  kg('2025-04-02', n, 'B4', 1, 32.5, 15),
  kg('2025-04-02', n, 'B4', 2, 32.5, 15),
  kg('2025-04-02', n, 'Z9', 1, 20, 15), // Kürzel nicht im Tab Geräte
  kg('2025-04-02', n, 'C1', 1, 30, 20, '', 'kgs'), // Einheit unbekannt
  kg('2025-04-02', n, 'D1', 1, 30, 15),
  kg('2025-04-02', n, 'D1', 3, 30, 12), // Satz-Nr. springt von 1 auf 3
  kg('04/02/2025', n, 'E1', 1, 45, 20), // Datum mehrdeutig
];

const leereZeilenAmEnde = 4; // nur Volumen-Formel, sonst leer

// ------------------------------------------------------------- Geräte
const geraeteKopf = [
  'Standort', 'Kürzel', 'Funktion/Muskelgruppe', 'Hersteller', 'Modell',
  'Einheit', 'Einstellung 1', 'Einstellung 2', 'Einstellung 3', 'Notiz'
];
final geraete = <List<String>>[
  [n, 'A2', 'Leg Press', 'Alpha', 'Serie 1', 'kg', 'Sitz: 4', '', '', ''],
  [n, 'D1', 'Chest Press', 'Alpha', 'Serie 1', 'kg', '', '', '',
    'am 2025-03-12 einmalig in lbs erfasst (vermutlich Fehleingabe)'],
  [n, 'B4', 'Row', 'Alpha', 'Serie 1', 'kg', '', '', '', ''],
  [n, 'T1', '', '', '', 'kg', '', '', '',
    'assistiertes Gerät - Gewicht = Körpergewicht minus Eingabewert'],
  [n, 'E1', 'Hip Adduction', 'Alpha', 'Serie 1', 'kg', '', '', '',
    'gleiches Gerät wie E2, unterschiedliche Einstellung'],
  [n, 'E2', 'Hip Abduction', 'Alpha', 'Serie 1', 'kg', '', '', '',
    'gleiches Gerät wie E1, unterschiedliche Einstellung'],
  [n, 'C1', 'Abdominal', 'Delta', '', 'kg', '', '', '', ''],
  [s, 'A2', 'Leg Press', 'Beta', 'Linie X', 'lbs', '', '', '', ''],
  [s, 'X4', 'Leg Extension', 'Beta', 'Linie X', 'lbs', '', '', '',
    'gleiche Übung wie X4.1 (kg), getrennt geführt wegen Einheit'],
  [s, 'X4.1', '', '', '', 'kg', '', '', '',
    'gleiche Übung wie X4 (lbs), getrennt geführt wegen Einheit'],
  [s, 'X5', 'Seated Leg Curl', 'Beta', 'Linie X', 'lbs', '', '', '',
    'eigenständig neben X5.1 (Gamma, kg)'],
  [s, 'X5.1', 'Seated Leg Curl', 'Gamma', '', 'kg', '', '', '', ''],
  [s, 'C3', 'Cable Row einarmig', 'Beta', 'Linie X', 'lbs', '', '', '',
    'beidseitig nutzbar (links/rechts getrennt einstellbar)'],
  [s, 'E1', 'Hip Abduction', 'Beta', 'Linie X', 'lbs', '', '', '', ''],
  [s, 'E2', 'Hip Adduction', 'Beta', 'Linie X', 'lbs', '', '', '', ''],
];

// ------------------------------------------------------------ Legende
final legende = <List<String>>[
  ['Bereich', 'Erklärung'],
  ['--- Tab "Log" ---', ''],
  ['Datum', 'Tag der Session'],
  ['Ort', 'Studio-Standort, z.B. Nordstadt, Südstadt'],
  ['Gerät', 'Immer exakt gleiche Schreibweise. Geräte mit Seite: "C3-links"/"C3-rechts"'],
  ['Satz-Nr.', 'Fortlaufende Nummer des Satzes für dieses Gerät (bzw. diese Seite) in dieser Session'],
  ['Gewicht (kg)', 'Effektives Gewicht in kg. lbs-Eingaben umgerechnet (1 lbs = 0,4536 kg). Bei T1: Körpergewicht minus Eingabewert'],
  ['--- Allgemein ---', ''],
  ['Körpergewicht', '78 kg (Stand 2025-03-03) - Basis für T1 Berechnung'],
];

// ===================================================== XLSX-Erzeugung
String esc(String v) => const HtmlEscape(HtmlEscapeMode.element).convert(v);

String colName(int i) => String.fromCharCode(65 + i);

String strZelle(String ref, String v, [int stil = 0]) =>
    '<c r="$ref"${stil > 0 ? ' s="$stil"' : ''} t="inlineStr"><is><t>${esc(v)}</t></is></c>';

String zahlZelle(String ref, num v, [int stil = 0]) =>
    '<c r="$ref"${stil > 0 ? ' s="$stil"' : ''} t="n"><v>${_zahl(v)}</v></c>';

String blatt(List<String> zeilen) =>
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
    '<sheetData>${zeilen.join()}</sheetData></worksheet>';

String textBlatt(List<String> kopf, List<List<String>> daten) {
  final zeilen = <String>[];
  final alle = [kopf, ...daten];
  for (var r = 0; r < alle.length; r++) {
    final zellen = StringBuffer();
    for (var c = 0; c < alle[r].length; c++) {
      if (alle[r][c].isEmpty) continue;
      zellen.write(strZelle('${colName(c)}${r + 1}', alle[r][c], r == 0 ? 1 : 0));
    }
    zeilen.add('<row r="${r + 1}">$zellen</row>');
  }
  return blatt(zeilen);
}

String logBlatt() {
  const kopf = [
    'Datum', 'Ort', 'Gerät', 'Satz-Nr.', 'Gewicht (kg)', 'Gewicht (lbs)',
    'Einheit (Eingabe)', 'Wiederholungen', 'Volumen (kg)', 'RPE (1-10)', 'Notiz'
  ];
  final zeilen = <String>[];
  final k = StringBuffer();
  for (var c = 0; c < kopf.length; c++) {
    k.write(strZelle('${colName(c)}1', kopf[c], 1));
  }
  zeilen.add('<row r="1">$k</row>');
  var r = 2;
  for (final z in log) {
    final eingabeKg = z.einheit != 'lbs';
    final b = StringBuffer()
      ..write(strZelle('A$r', z.datum))
      ..write(strZelle('B$r', z.ort))
      ..write(strZelle('C$r', z.geraet))
      ..write(zahlZelle('D$r', z.satz!))
      ..write(zahlZelle('E$r', z.kg, eingabeKg ? 1 : 2))
      ..write(zahlZelle('F$r', z.lbs, eingabeKg ? 2 : 1))
      ..write(strZelle('G$r', z.einheit));
    if (z.wdh != null) b.write(zahlZelle('H$r', z.wdh!));
    b.write('<c r="I$r"><f>E$r*H$r</f></c>');
    if (z.notiz.isNotEmpty) b.write(strZelle('K$r', z.notiz));
    zeilen.add('<row r="$r">$b</row>');
    r++;
  }
  for (var i = 0; i < leereZeilenAmEnde; i++, r++) {
    zeilen.add('<row r="$r"><c r="I$r"><f>E$r*H$r</f></c></row>');
  }
  return blatt(zeilen);
}

const contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
    '<Default Extension="xml" ContentType="application/xml"/>'
    '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
    '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
    '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
    '<Override PartName="/xl/worksheets/sheet2.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
    '<Override PartName="/xl/worksheets/sheet3.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
    '</Types>';

const rootRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
    '</Relationships>';

const workbook = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
    '<sheets><sheet name="Log" sheetId="1" r:id="rId1"/>'
    '<sheet name="Geräte" sheetId="2" r:id="rId2"/>'
    '<sheet name="Legende" sheetId="3" r:id="rId3"/></sheets>'
    '<calcPr calcId="124519" fullCalcOnLoad="1"/></workbook>';

const workbookRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
    '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/>'
    '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet3.xml"/>'
    '<Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
    '</Relationships>';

// Stil 0 normal, 1 fett (Eingabe), 2 grau kursiv (berechnet) – wie das Original.
const styles = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
    '<fonts count="3"><font><sz val="11"/><name val="Calibri"/></font>'
    '<font><b val="1"/><sz val="11"/><name val="Calibri"/></font>'
    '<font><i val="1"/><color rgb="00808080"/><sz val="11"/><name val="Calibri"/></font></fonts>'
    '<fills count="2"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill></fills>'
    '<borders count="1"><border/></borders>'
    '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
    '<cellXfs count="3"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
    '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
    '<xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="1"/></cellXfs>'
    '</styleSheet>';

// ------------------------------------------------- minimaler ZIP-Writer
final _crcTabelle = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int crc32(List<int> daten) {
  var c = 0xFFFFFFFF;
  for (final b in daten) {
    c = _crcTabelle[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}

Uint8List zip(Map<String, String> dateien) {
  final out = BytesBuilder();
  final zentral = BytesBuilder();
  void u16(BytesBuilder b, int v) => b.add([v & 0xFF, (v >> 8) & 0xFF]);
  void u32(BytesBuilder b, int v) =>
      b.add([v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF]);
  const dosZeit = 0, dosDatum = (45 << 9) | (1 << 5) | 1; // 2025-01-01
  dateien.forEach((name, inhalt) {
    final roh = utf8.encode(inhalt);
    final gepackt = ZLibEncoder(raw: true, level: 9).convert(roh);
    final crc = crc32(roh);
    final nameB = utf8.encode(name);
    final offset = out.length;
    u32(out, 0x04034b50); u16(out, 20); u16(out, 0x0800); u16(out, 8);
    u16(out, dosZeit); u16(out, dosDatum); u32(out, crc);
    u32(out, gepackt.length); u32(out, roh.length);
    u16(out, nameB.length); u16(out, 0); out.add(nameB); out.add(gepackt);
    u32(zentral, 0x02014b50); u16(zentral, 20); u16(zentral, 20);
    u16(zentral, 0x0800); u16(zentral, 8); u16(zentral, dosZeit);
    u16(zentral, dosDatum); u32(zentral, crc); u32(zentral, gepackt.length);
    u32(zentral, roh.length); u16(zentral, nameB.length); u16(zentral, 0);
    u16(zentral, 0); u16(zentral, 0); u16(zentral, 0); u32(zentral, 0);
    u32(zentral, offset); zentral.add(nameB);
  });
  final zStart = out.length;
  final zBytes = zentral.takeBytes();
  out.add(zBytes);
  u32(out, 0x06054b50); u16(out, 0); u16(out, 0);
  u16(out, dateien.length); u16(out, dateien.length);
  u32(out, zBytes.length); u32(out, zStart); u16(out, 0);
  return out.takeBytes();
}

void main() {
  final ziel = File.fromUri(Platform.script.resolve('Testlog.xlsx'));
  ziel.writeAsBytesSync(zip({
    '[Content_Types].xml': contentTypes,
    '_rels/.rels': rootRels,
    'xl/workbook.xml': workbook,
    'xl/_rels/workbook.xml.rels': workbookRels,
    'xl/styles.xml': styles,
    'xl/worksheets/sheet1.xml': logBlatt(),
    'xl/worksheets/sheet2.xml': textBlatt(geraeteKopf, geraete),
    'xl/worksheets/sheet3.xml': textBlatt(legende.first, legende.skip(1).toList()),
  }));
  stdout.writeln('${ziel.path} geschrieben: ${log.length} Log-Zeilen, '
      '${geraete.length} Geräte.');
}
