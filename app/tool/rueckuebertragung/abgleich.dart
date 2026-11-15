// WP2.6 Rückübertragung App → Excel: Abgleich (was ist neu, was ist schon da).
// Reine Dart-Datei (kein Flutter), ohne Handy und ohne Datei testbar.
//
// Regeln: docs/m2/WP2.6-Rueckuebertragung.md
// - Nur beendete Sessions, die die App angelegt hat (App-Version gesetzt).
// - Eine Session gilt als übertragen, wenn die Excel Zeilen mit gleichem
//   Datum + Ort hat. Weicht sie ab, wird nichts geschrieben, nur gemeldet.
// - Neue Geräte (Standort + Kürzel nicht im Tab Geräte) werden angehängt;
//   geänderte bestehende Geräte werden nur gemeldet.

import 'package:drift/drift.dart';
import 'package:trainingsapp/data/db/datenbank.dart';
import 'package:trainingsapp/data/db/satz_logik.dart' show vergleicheKuerzel;

import '../import_excel/importer.dart' show excelDatum;
import '../import_excel/xlsx_leser.dart';

/// Auf 2 Nachkommastellen (wie die bisherige Excel).
double r2(double v) => (v * 100).round() / 100;

/// Zahl für Notizen: ganze Zahl ohne Nachkommastellen, sonst mit Punkt.
String notizZahl(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : '${r2(v)}';

const notizAssistiertesGeraet =
    'assistiertes Gerät - Gewicht = Körpergewicht minus Eingabewert';
const notizLinksRechts = 'links/rechts getrennt';

/// Eine neue Zeile im Tab Log.
class NeueLogZeile {
  final String datum, ort, geraet;
  final int satzNr, wdh;
  final double kg, lbs;
  final Einheit einheit;
  final String? notiz;
  const NeueLogZeile({
    required this.datum,
    required this.ort,
    required this.geraet,
    required this.satzNr,
    required this.kg,
    required this.lbs,
    required this.einheit,
    required this.wdh,
    this.notiz,
  });

  /// Vergleichsschlüssel für „schon übertragen, aber abweichend?“.
  String get schluessel =>
      '$geraet|$satzNr|${einheit.name}|$wdh|${r2(kg).toStringAsFixed(2)}';
}

/// Eine neue Zeile im Tab Geräte.
class NeueGeraeteZeile {
  final String standort, kuerzel;
  final String? funktion, hersteller, modell, notiz, muskelgruppe;
  final Einheit einheit;
  final List<String?> einstellungen;
  const NeueGeraeteZeile({
    required this.standort,
    required this.kuerzel,
    required this.einheit,
    required this.einstellungen,
    this.funktion,
    this.hersteller,
    this.modell,
    this.notiz,
    this.muskelgruppe,
  });
}

class NeueSession {
  final String datum, ort;
  final List<NeueLogZeile> zeilen;
  const NeueSession(this.datum, this.ort, this.zeilen);
}

/// Ergebnis des Abgleichs = Vorschau und Grundlage für das Schreiben.
class Plan {
  final neueSessions = <NeueSession>[];
  final neueGeraete = <NeueGeraeteZeile>[];

  /// App-Sessions, die schon gleich in der Excel stehen.
  final schonDa = <String>[];

  /// Aus der Excel importierte Sessions (werden nicht verglichen).
  int importiert = 0;
  final laufend = <String>[];
  final abweichend = <String>[];
  final nurExcel = <String>[];
  final nurAppImportiert = <String>[];
  final geaenderteGeraete = <String>[];

  /// Probleme, wegen denen eine Session nicht übertragen wird.
  final probleme = <String>[];

  String? letzteSessionApp, letzteSessionExcel;

  int get anzahlZeilen => neueSessions.fold(0, (n, s) => n + s.zeilen.length);
  bool get nichtsZuTun => neueSessions.isEmpty && neueGeraete.isEmpty;
}

String? _t(Object? v) {
  if (v == null) return null;
  final s = '$v'.trim();
  return s.isEmpty ? null : s;
}

double? _n(Object? v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}');

Map<String, int> _kopf(Map<int, Object>? zeile) =>
    {for (final e in (zeile ?? const {}).entries) '${e.value}'.trim(): e.key};

/// Gleicht die App-Datenbank [db] mit der Excel [excel] ab.
Future<Plan> erstellePlan(Datenbank db, XlsxMappe excel) async {
  final plan = Plan();
  final log = excel.blaetter['Log'];
  final geraeteBlatt = excel.blaetter['Geräte'];
  if (log == null || geraeteBlatt == null) {
    throw const FormatException('Die Excel braucht die Tabs „Log“ und „Geräte“.');
  }

  // ------------------------------------------------ Excel: Log-Zeilen
  final lk = _kopf(log[1]);
  for (final k in ['Datum', 'Ort', 'Gerät', 'Satz-Nr.', 'Gewicht (kg)',
      'Einheit (Eingabe)', 'Wiederholungen']) {
    if (!lk.containsKey(k)) {
      throw FormatException('Tab „Log“: Spalte „$k“ fehlt in Zeile 1.');
    }
  }
  final excelSessions = <String, List<String>>{}; // „Datum Ort“ → Schlüssel
  for (final nr in log.keys.where((n) => n > 1)) {
    final z = log[nr]!;
    final datum = excelDatum(z[lk['Datum']]);
    final ort = _t(z[lk['Ort']]);
    if (datum == null || ort == null) continue;
    final einheit = _t(z[lk['Einheit (Eingabe)']])?.toLowerCase();
    final zeile = NeueLogZeile(
      datum: datum,
      ort: ort,
      geraet: _t(z[lk['Gerät']]) ?? '',
      satzNr: _n(z[lk['Satz-Nr.']])?.round() ?? 0,
      kg: _n(z[lk['Gewicht (kg)']]) ?? double.nan,
      lbs: 0,
      einheit: einheit == 'lbs' ? Einheit.lbs : Einheit.kg,
      wdh: _n(z[lk['Wiederholungen']])?.round() ?? 0,
    );
    (excelSessions['$datum $ort'] ??= []).add(zeile.schluessel);
    if (plan.letzteSessionExcel == null ||
        datum.compareTo(plan.letzteSessionExcel!) > 0) {
      plan.letzteSessionExcel = datum;
    }
  }

  // --------------------------------------------- Excel: Tab Geräte
  final gk = _kopf(geraeteBlatt[1]);
  for (final k in ['Standort', 'Kürzel']) {
    if (!gk.containsKey(k)) {
      throw FormatException('Tab „Geräte“: Spalte „$k“ fehlt in Zeile 1.');
    }
  }
  final excelGeraete = <String, Map<int, Object>>{};
  for (final nr in geraeteBlatt.keys.where((n) => n > 1)) {
    final z = geraeteBlatt[nr]!;
    final s = _t(z[gk['Standort']]), k = _t(z[gk['Kürzel']]);
    if (s != null && k != null) excelGeraete['$s/$k'] = z;
  }

  // ------------------------------------------------------ App lesen
  final standorte = {for (final s in await db.select(db.standorte).get()) s.id: s.name};
  final gruppen = {for (final m in await db.select(db.muskelgruppen).get()) m.id: m.name};
  final geraete = {for (final g in await db.select(db.geraete).get()) g.id: g};
  final sessions = await (db.select(db.sessions)
        ..orderBy([(s) => OrderingTerm.asc(s.datum), (s) => OrderingTerm.asc(s.id)]))
      .get();
  final appSchluessel = <String>{};

  for (final s in sessions) {
    final ort = standorte[s.standortId]!;
    final name = '${s.datum} $ort';
    appSchluessel.add(name);
    if (plan.letzteSessionApp == null || s.datum.compareTo(plan.letzteSessionApp!) > 0) {
      plan.letzteSessionApp = s.datum;
    }
    final importiert = s.appVersion == null;
    if (!s.abgeschlossen) {
      plan.laufend.add(name);
      continue;
    }
    final inExcel = excelSessions[name];
    if (importiert) {
      if (inExcel == null) {
        plan.nurAppImportiert.add(name);
      } else {
        plan.importiert++;
      }
      continue;
    }
    final saetze = await (db.select(db.saetze)
          ..where((x) => x.sessionId.equals(s.id))
          ..orderBy([(x) => OrderingTerm.asc(x.id)]))
        .get();
    if (saetze.isEmpty) continue;

    final zeilen = <NeueLogZeile>[];
    String? problem;
    for (final satz in saetze) {
      final g = geraete[satz.geraetId]!;
      final code = g.kuerzel +
          switch (satz.seite) {
            Seite.L => '-links',
            Seite.R => '-rechts',
            null => '',
          };
      final eingabe = satz.eingabewert;
      final double kg, lbs;
      String? auto;
      if (g.assistiert) {
        final kw = s.koerpergewichtKg;
        if (kw == null) {
          problem = '$name: assistiertes Gerät ${g.kuerzel} ohne Körpergewicht';
          break;
        }
        kg = r2(satz.gewichtKg);
        lbs = r2(ausKg(satz.gewichtKg, Einheit.lbs));
        auto = satz.eingabeeinheit == Einheit.kg
            ? 'assistiert: ${notizZahl(kw)} - ${notizZahl(eingabe)} kg Eingabe'
            : 'assistiert: ${notizZahl(kw)} kg - ${notizZahl(eingabe)} lbs Eingabe';
      } else if (satz.eingabeeinheit == Einheit.kg) {
        kg = eingabe;
        lbs = r2(ausKg(eingabe, Einheit.lbs));
      } else {
        kg = r2(satz.gewichtKg);
        lbs = eingabe;
        auto = 'Eingabe: ${notizZahl(eingabe)} lbs';
      }
      final notiz = [auto, _t(satz.notiz)].whereType<String>().join('; ');
      zeilen.add(NeueLogZeile(
        datum: s.datum,
        ort: ort,
        geraet: code,
        satzNr: satz.satzNr,
        kg: kg,
        lbs: lbs,
        einheit: satz.eingabeeinheit,
        wdh: satz.wiederholungen,
        notiz: notiz.isEmpty ? null : notiz,
      ));
    }
    if (problem != null) {
      plan.probleme.add(problem);
      continue;
    }
    if (inExcel == null) {
      plan.neueSessions.add(NeueSession(s.datum, ort, zeilen));
      continue;
    }
    final app = zeilen.map((z) => z.schluessel).toList()..sort();
    final ex = [...inExcel]..sort();
    if (app.join('\n') == ex.join('\n')) {
      plan.schonDa.add(name);
    } else {
      plan.abweichend.add('$name: in der App ${zeilen.length} Sätze, in der '
          'Excel ${inExcel.length} Zeilen – Inhalt verschieden');
    }
  }
  for (final name in excelSessions.keys) {
    if (!appSchluessel.contains(name)) plan.nurExcel.add(name);
  }
  plan.nurExcel.sort();

  // --------------------------------------------------------- Geräte
  final neu = <Geraet>[];
  for (final g in geraete.values) {
    final ort = standorte[g.standortId]!;
    final ex = excelGeraete['$ort/${g.kuerzel}'];
    if (ex == null) {
      neu.add(g);
      continue;
    }
    // Nur melden, was in der App anders ist (wird nicht zurückgeschrieben)
    final unterschiede = <String>[];
    void vergleiche(String spalte, String? app, [String? anzeige]) {
      final i = gk[spalte];
      if (i == null) return;
      if (_t(ex[i]) != _t(app)) unterschiede.add('${anzeige ?? spalte} „${app ?? '–'}“');
    }

    vergleiche('Funktion/Muskelgruppe', g.funktion, 'Funktion');
    vergleiche('Hersteller', g.hersteller);
    vergleiche('Modell', g.modell);
    if (gk.containsKey('Einheit') &&
        _t(ex[gk['Einheit']])?.toLowerCase() != g.einheit.name) {
      unterschiede.add('Vorgabe-Einheit „${g.einheit.name}“');
    }
    vergleiche('Einstellung 1', g.einstellung1);
    vergleiche('Einstellung 2', g.einstellung2);
    vergleiche('Einstellung 3', g.einstellung3);
    if (gk.containsKey('Muskelgruppe') && _t(ex[gk['Muskelgruppe']]) != null) {
      vergleiche('Muskelgruppe', gruppen[g.muskelgruppeId]);
    }
    final exAssist = (_t(ex[gk['Notiz']]) ?? '').toLowerCase().contains('assistiert');
    if (exAssist != g.assistiert) {
      unterschiede.add(g.assistiert ? 'assistiert' : 'nicht mehr assistiert');
    }
    if (unterschiede.isNotEmpty) {
      plan.geaenderteGeraete.add('$ort ${g.kuerzel}: ${unterschiede.join(', ')}');
    }
  }
  neu.sort((a, b) {
    final c = standorte[a.standortId]!.compareTo(standorte[b.standortId]!);
    return c != 0 ? c : vergleicheKuerzel(a.kuerzel, b.kuerzel);
  });
  for (final g in neu) {
    final notiz = [
      if (g.assistiert) notizAssistiertesGeraet,
      if (g.linksRechtsGetrennt) notizLinksRechts,
      _t(g.notiz),
    ].whereType<String>().join('; ');
    plan.neueGeraete.add(NeueGeraeteZeile(
      standort: standorte[g.standortId]!,
      kuerzel: g.kuerzel,
      funktion: g.funktion,
      hersteller: g.hersteller,
      modell: g.modell,
      einheit: g.einheit,
      einstellungen: [g.einstellung1, g.einstellung2, g.einstellung3],
      notiz: notiz.isEmpty ? null : notiz,
      muskelgruppe: gruppen[g.muskelgruppeId],
    ));
  }
  return plan;
}
