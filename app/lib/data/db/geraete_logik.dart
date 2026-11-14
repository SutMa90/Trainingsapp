// WP2.5 Geräteverwaltung und neues Gerät (F3) – Regeln gemäss DATENMODELL
// R1.2, R1.3, R1.6, R2.2, R2.4. Reine Dart-Datei (kein Flutter), ohne
// Bildschirm testbar.
//
// Entscheide des Nutzers (14.11.2026, docs/m2/WP2.5-Geraete.md):
// - Kürzel umbenennen nur, solange das Gerät keine Sätze hat (Excel-Abgleich).
// - Löschen nur bei Geräten ohne Sätze.
// - assistiert, links/rechts und Einheit jederzeit änderbar; gilt nur für
//   neue Sätze, alte Sätze bleiben unverändert.

import 'package:drift/drift.dart';

import 'datenbank.dart';
import 'satz_logik.dart' show vergleicheKuerzel;

/// Eingaben aus dem Formular „Neues Gerät“ / „Gerät bearbeiten“.
class GeraetDaten {
  final String kuerzel;
  final String? funktion;
  final int? muskelgruppeId;
  final String? hersteller;
  final String? modell;
  final Einheit einheit;
  final bool assistiert;
  final bool linksRechtsGetrennt;
  final String? einstellung1;
  final String? einstellung2;
  final String? einstellung3;
  final String? notiz;

  const GeraetDaten({
    required this.kuerzel,
    this.funktion,
    this.muskelgruppeId,
    this.hersteller,
    this.modell,
    this.einheit = Einheit.kg,
    this.assistiert = false,
    this.linksRechtsGetrennt = false,
    this.einstellung1,
    this.einstellung2,
    this.einstellung3,
    this.notiz,
  });
}

/// Gerät mit Muskelgruppe und Anzahl Sätze (für die Geräteliste).
class GeraetEintrag {
  final Geraet geraet;
  final Muskelgruppe? muskelgruppe;
  final int anzahlSaetze;
  const GeraetEintrag({
    required this.geraet,
    required this.muskelgruppe,
    required this.anzahlSaetze,
  });
}

/// Kürzel am Standort schon vergeben (R1.2: eindeutig über Standort + Kürzel).
class KuerzelVergeben implements Exception {
  final String kuerzel;
  const KuerzelVergeben(this.kuerzel);
  @override
  String toString() => 'Das Kürzel $kuerzel gibt es an diesem Standort schon.';
}

/// Aktion nicht erlaubt, weil das Gerät schon Sätze hat.
class GeraetHatSaetze implements Exception {
  final String meldung;
  const GeraetHatSaetze(this.meldung);
  @override
  String toString() => meldung;
}

/// Kürzel wie gespeichert: ohne Leerzeichen aussen, in Grossbuchstaben.
String normalisiereKuerzel(String k) => k.trim().toUpperCase();

/// Leere Texte werden als „nicht angegeben“ gespeichert.
String? _leerAlsNull(String? t) {
  final s = t?.trim();
  return (s == null || s.isEmpty) ? null : s;
}

/// Vergleichsschlüssel für Vorschläge: Gross-/Kleinschreibung und
/// Leerzeichen egal.
String _schluessel(String t) => t.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

/// Vorschläge für Hersteller und Modell aus bestehenden Einträgen (R2.2).
class GeraeteVorschlaege {
  /// Hersteller aller Standorte, alphabetisch, ohne Doppelte.
  final List<String> hersteller;
  final Map<String, List<String>> _modelle;

  const GeraeteVorschlaege._(this.hersteller, this._modelle);

  /// Modelle, die es zu diesem Hersteller schon gibt (alphabetisch).
  List<String> modelleVon(String? hersteller) =>
      hersteller == null ? const [] : _modelle[_schluessel(hersteller)] ?? const [];

  /// Baut die Vorschläge aus einer Geräteliste. Gibt es dieselbe Angabe in
  /// verschiedener Schreibweise, gilt die häufigste.
  factory GeraeteVorschlaege.aus(Iterable<Geraet> geraete) {
    String haeufigste(Map<String, int> zaehler) =>
        (zaehler.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;
    final herstellerZaehler = <String, Map<String, int>>{};
    final modellZaehler = <String, Map<String, Map<String, int>>>{};
    for (final g in geraete) {
      final h = _leerAlsNull(g.hersteller);
      if (h == null) continue;
      final hk = _schluessel(h);
      (herstellerZaehler[hk] ??= {}).update(h, (n) => n + 1, ifAbsent: () => 1);
      final m = _leerAlsNull(g.modell);
      if (m == null) continue;
      ((modellZaehler[hk] ??= {})[_schluessel(m)] ??= {})
          .update(m, (n) => n + 1, ifAbsent: () => 1);
    }
    int alphabetisch(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());
    return GeraeteVorschlaege._(
      [for (final z in herstellerZaehler.values) haeufigste(z)]..sort(alphabetisch),
      {
        for (final e in modellZaehler.entries)
          e.key: [for (final z in e.value.values) haeufigste(z)]..sort(alphabetisch),
      },
    );
  }
}

extension GeraeteLogik on Datenbank {
  /// Alle Standorte, alphabetisch, als Live-Abfrage.
  Stream<List<Standort>> beobachteStandorte() =>
      (select(standorte)..orderBy([(s) => OrderingTerm.asc(s.name)])).watch();

  /// Muskelgruppen in Anzeigereihenfolge (R2.4).
  Future<List<Muskelgruppe>> muskelgruppenListe() => (select(muskelgruppen)
        ..orderBy([
          (m) => OrderingTerm.asc(m.sortierung),
          (m) => OrderingTerm.asc(m.name),
        ]))
      .get();

  /// Neue Muskelgruppe ans Ende der Liste (R2.4, erweiterbar). Gibt es sie
  /// schon (Gross-/Kleinschreibung egal), wird die bestehende zurückgegeben.
  Future<int> legeMuskelgruppeAn(String name) async {
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError('Name der Muskelgruppe fehlt.');
    for (final m in await muskelgruppenListe()) {
      if (_schluessel(m.name) == _schluessel(n)) return m.id;
    }
    final hoechste = muskelgruppen.sortierung.max();
    final max = await (selectOnly(muskelgruppen)..addColumns([hoechste]))
        .map((r) => r.read(hoechste))
        .getSingle();
    return into(muskelgruppen).insert(
        MuskelgruppenCompanion.insert(name: n, sortierung: Value((max ?? 0) + 1)));
  }

  /// Geräte eines Standorts mit Muskelgruppe und Anzahl Sätze, nach Kürzel.
  Stream<List<GeraetEintrag>> beobachteGeraete(int standortId) {
    final anzahl = saetze.id.count();
    final q = select(geraete).join([
      leftOuterJoin(muskelgruppen, muskelgruppen.id.equalsExp(geraete.muskelgruppeId)),
      leftOuterJoin(saetze, saetze.geraetId.equalsExp(geraete.id)),
    ])
      ..where(geraete.standortId.equals(standortId))
      ..addColumns([anzahl])
      ..groupBy([geraete.id]);
    return q.watch().map((rows) {
      final liste = [
        for (final r in rows)
          GeraetEintrag(
            geraet: r.readTable(geraete),
            muskelgruppe: r.readTableOrNull(muskelgruppen),
            anzahlSaetze: r.read(anzahl) ?? 0,
          ),
      ];
      liste.sort((a, b) => vergleicheKuerzel(a.geraet.kuerzel, b.geraet.kuerzel));
      return liste;
    });
  }

  Future<Geraet> geraetMitId(int id) =>
      (select(geraete)..where((g) => g.id.equals(id))).getSingle();

  /// Anzahl Sätze eines Geräts über alle Sessions.
  Future<int> anzahlSaetzeAmGeraet(int geraetId) async {
    final anzahl = saetze.id.count();
    final q = selectOnly(saetze)
      ..addColumns([anzahl])
      ..where(saetze.geraetId.equals(geraetId));
    return await q.map((r) => r.read(anzahl)).getSingle() ?? 0;
  }

  /// Vorschläge für Hersteller und Modell aus allen Geräten (R2.2).
  Future<GeraeteVorschlaege> geraeteVorschlaege() async =>
      GeraeteVorschlaege.aus(await select(geraete).get());

  Future<void> _pruefeKuerzelFrei(int standortId, String kuerzel, {int? ausser}) async {
    final andere = await (select(geraete)..where((g) => g.standortId.equals(standortId)))
        .get();
    for (final g in andere) {
      if (g.id != ausser && normalisiereKuerzel(g.kuerzel) == kuerzel) {
        throw KuerzelVergeben(kuerzel);
      }
    }
  }

  GeraeteCompanion _felder(GeraetDaten d, String kuerzel) => GeraeteCompanion(
        kuerzel: Value(kuerzel),
        funktion: Value(_leerAlsNull(d.funktion)),
        muskelgruppeId: Value(d.muskelgruppeId),
        hersteller: Value(_leerAlsNull(d.hersteller)),
        modell: Value(_leerAlsNull(d.modell)),
        einheit: Value(d.einheit),
        assistiert: Value(d.assistiert),
        linksRechtsGetrennt: Value(d.linksRechtsGetrennt),
        einstellung1: Value(_leerAlsNull(d.einstellung1)),
        einstellung2: Value(_leerAlsNull(d.einstellung2)),
        einstellung3: Value(_leerAlsNull(d.einstellung3)),
        notiz: Value(_leerAlsNull(d.notiz)),
      );

  /// Legt ein neues Gerät am [standortId] an und gibt die id zurück.
  Future<int> legeGeraetAn(int standortId, GeraetDaten d) => transaction(() async {
        final k = normalisiereKuerzel(d.kuerzel);
        if (k.isEmpty) throw ArgumentError('Kürzel fehlt.');
        await _pruefeKuerzelFrei(standortId, k);
        return into(geraete)
            .insert(_felder(d, k).copyWith(standortId: Value(standortId)));
      });

  /// Ändert ein Gerät. Das Kürzel lässt sich nur ändern, solange das Gerät
  /// keine Sätze hat. Alte Sätze bleiben in jedem Fall unverändert (R1.6).
  Future<void> aendereGeraet(int id, GeraetDaten d) => transaction(() async {
        final alt = await geraetMitId(id);
        var k = normalisiereKuerzel(d.kuerzel);
        if (k.isEmpty) throw ArgumentError('Kürzel fehlt.');
        if (k == normalisiereKuerzel(alt.kuerzel)) {
          k = alt.kuerzel; // unverändert (Schreibweise wie gespeichert)
        } else {
          if (await anzahlSaetzeAmGeraet(id) > 0) {
            throw const GeraetHatSaetze(
                'Das Gerät hat schon Sätze – das Kürzel bleibt. '
                'Bei einer Verwechslung ein neues Gerät anlegen.');
          }
          await _pruefeKuerzelFrei(alt.standortId, k, ausser: id);
        }
        await (update(geraete)..where((g) => g.id.equals(id))).write(_felder(d, k));
      });

  /// Löscht ein Gerät ohne Sätze (z. B. versehentlich angelegt).
  Future<void> loescheGeraet(int id) => transaction(() async {
        if (await anzahlSaetzeAmGeraet(id) > 0) {
          throw const GeraetHatSaetze(
              'Das Gerät hat schon Sätze und kann nicht gelöscht werden.');
        }
        await (delete(geraete)..where((g) => g.id.equals(id))).go();
      });
}
