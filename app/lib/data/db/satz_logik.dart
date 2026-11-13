// WP2.2 Satz erfassen (F5, F6) – Regeln gemäss DATENMODELL R1.5, R1.6,
// R2.1, R2.5, R2.7. Reine Dart-Datei (kein Flutter), ohne Bildschirm testbar.

import 'package:drift/drift.dart';

import 'datenbank.dart';

/// Vorbefüllung des Erfassungsbildschirms für ein Gerät (und ggf. eine Seite).
class Vorbefuellung {
  final int? wiederholungen;

  /// Eingabewert in [einheit] (bei Umrechnung auf 1 Stelle gerundet).
  final double? eingabewert;

  /// Immer die Vorgabe-Einheit des Geräts (R1.6).
  final Einheit einheit;

  /// true, wenn der letzte Satz in der anderen Einheit erfasst war und der
  /// Wert umgerechnet wurde.
  final bool umgerechnet;

  /// Nächste Satz-Nr. in dieser Session (pro Gerät und Seite, R2.7).
  final int satzNr;

  const Vorbefuellung({
    required this.einheit,
    required this.satzNr,
    this.wiederholungen,
    this.eingabewert,
    this.umgerechnet = false,
  });
}

/// Gerät mit Anzahl Sätze in der laufenden Session (für die Kacheln).
class GeraetKachel {
  final Geraet geraet;
  final int saetzeHeute;
  const GeraetKachel({required this.geraet, required this.saetzeHeute});
}

/// WP2.3: Sätze einer früheren Session an einem Gerät (F7).
class LetztesMal {
  final TrainingsSession session;
  final Standort standort;
  final Geraet geraet;
  final List<Satz> saetze;
  const LetztesMal({
    required this.session,
    required this.standort,
    required this.geraet,
    required this.saetze,
  });
}

/// Tage zwischen zwei Kalendertagen `JJJJ-MM-TT` (bis − von).
int tageZwischen(String von, String bis) =>
    DateTime.utc(int.parse(bis.substring(0, 4)), int.parse(bis.substring(5, 7)),
            int.parse(bis.substring(8, 10)))
        .difference(DateTime.utc(int.parse(von.substring(0, 4)),
            int.parse(von.substring(5, 7)), int.parse(von.substring(8, 10))))
        .inDays;

/// Fehlendes Körpergewicht bei einem assistierten Gerät.
class KoerpergewichtFehlt implements Exception {
  const KoerpergewichtFehlt();
  @override
  String toString() => 'Für assistierte Geräte braucht die Session ein Körpergewicht.';
}

/// Sortierung der Kürzel „natürlich“: A2 vor A10, Buchstaben zuerst.
int vergleicheKuerzel(String a, String b) {
  final re = RegExp(r'(\d+)|(\D+)');
  final ta = re.allMatches(a.toUpperCase()).map((m) => m.group(0)!).toList();
  final tb = re.allMatches(b.toUpperCase()).map((m) => m.group(0)!).toList();
  for (var i = 0; i < ta.length && i < tb.length; i++) {
    final na = int.tryParse(ta[i]), nb = int.tryParse(tb[i]);
    final c = (na != null && nb != null) ? na.compareTo(nb) : ta[i].compareTo(tb[i]);
    if (c != 0) return c;
  }
  return ta.length.compareTo(tb.length);
}

/// Rundet auf eine Nachkommastelle (Eingabefelder, R2.5).
double aufEineStelle(double v) => (v * 10).round() / 10;

extension SatzLogik on Datenbank {
  /// Geräte des Standorts als Kacheln, sortiert nach Kürzel, mit der Anzahl
  /// Sätze in der Session [sessionId].
  Stream<List<GeraetKachel>> beobachteKacheln(int standortId, int sessionId) {
    final anzahl = saetze.id.count();
    final q = select(geraete).join([
      leftOuterJoin(
          saetze,
          saetze.geraetId.equalsExp(geraete.id) &
              saetze.sessionId.equals(sessionId)),
    ])
      ..where(geraete.standortId.equals(standortId))
      ..addColumns([anzahl])
      ..groupBy([geraete.id]);
    return q.watch().map((rows) {
      final liste = [
        for (final r in rows)
          GeraetKachel(geraet: r.readTable(geraete), saetzeHeute: r.read(anzahl) ?? 0),
      ];
      liste.sort((a, b) => vergleicheKuerzel(a.geraet.kuerzel, b.geraet.kuerzel));
      return liste;
    });
  }

  /// Nächste Satz-Nr. pro Gerät und Seite in der Session (R2.7).
  Future<int> naechsteSatzNr(int sessionId, int geraetId, Seite? seite) async {
    final hoechste = saetze.satzNr.max();
    final q = selectOnly(saetze)
      ..addColumns([hoechste])
      ..where(saetze.sessionId.equals(sessionId) &
          saetze.geraetId.equals(geraetId) &
          (seite == null ? saetze.seite.isNull() : saetze.seite.equalsValue(seite)));
    final n = await q.map((r) => r.read(hoechste)).getSingle();
    return (n ?? 0) + 1;
  }

  /// Letzter Satz des Geräts (über alle Sessions; bei links/rechts getrennten
  /// Geräten bevorzugt derselben Seite).
  Future<Satz?> letzterSatz(int geraetId, {Seite? seite}) async {
    Future<Satz?> suche(Expression<bool> bedingung) async {
      final q = select(saetze).join([
        innerJoin(sessions, sessions.id.equalsExp(saetze.sessionId)),
      ])
        ..where(bedingung)
        ..orderBy([OrderingTerm.desc(sessions.datum), OrderingTerm.desc(saetze.id)])
        ..limit(1);
      return (await q.getSingleOrNull())?.readTable(saetze);
    }

    final geraet = saetze.geraetId.equals(geraetId);
    if (seite != null) {
      final s = await suche(geraet & saetze.seite.equalsValue(seite));
      if (s != null) return s;
    }
    return suche(geraet);
  }

  /// Vorbefüllung: letzte Werte des Geräts in der Vorgabe-Einheit des Geräts.
  Future<Vorbefuellung> vorbefuellung({
    required int sessionId,
    required Geraet geraet,
    Seite? seite,
  }) async {
    final nr = await naechsteSatzNr(sessionId, geraet.id, seite);
    // [Änderung WP2.3] Zuerst derselbe Satz (Nr. + Seite) vom letzten Mal an
    // diesem Gerät; gibt es den nicht, der zuletzt gespeicherte Satz.
    final letztesMal =
        await letzteSessionAmGeraet(geraet.id, ohneSessionId: sessionId);
    final letzter = letztesMal?.saetze
            .where((s) => s.satzNr == nr && s.seite == seite)
            .firstOrNull ??
        await letzterSatz(geraet.id, seite: seite);
    if (letzter == null) {
      return Vorbefuellung(einheit: geraet.einheit, satzNr: nr);
    }
    final gleich = letzter.eingabeeinheit == geraet.einheit;
    return Vorbefuellung(
      einheit: geraet.einheit,
      satzNr: nr,
      wiederholungen: letzter.wiederholungen,
      eingabewert: gleich
          ? letzter.eingabewert
          : aufEineStelle(
              ausKg(inKg(letzter.eingabewert, letzter.eingabeeinheit), geraet.einheit)),
      umgerechnet: !gleich,
    );
  }

  /// Speichert einen Satz. Satz-Nr. und Gewicht kg berechnet die App.
  /// Weicht [einheit] von der Vorgabe des Geräts ab, wird sie die neue
  /// Vorgabe (R2.1). Gibt die id des Satzes zurück.
  Future<int> speichereSatz({
    required int sessionId,
    required int geraetId,
    Seite? seite,
    required int wiederholungen,
    required double eingabewert,
    required Einheit einheit,
    String? notiz,
  }) async {
    if (wiederholungen <= 0) {
      throw ArgumentError('Wiederholungen müssen grösser als 0 sein.');
    }
    if (eingabewert < 0) {
      throw ArgumentError('Gewicht darf nicht negativ sein.');
    }
    return transaction(() async {
      final g = await (select(geraete)..where((x) => x.id.equals(geraetId)))
          .getSingle();
      final s = await (select(sessions)..where((x) => x.id.equals(sessionId)))
          .getSingle();
      if (g.linksRechtsGetrennt && seite == null) {
        throw ArgumentError('Bei diesem Gerät bitte Seite L oder R wählen.');
      }
      final seiteGespeichert = g.linksRechtsGetrennt ? seite : null;
      if (g.assistiert && s.koerpergewichtKg == null) {
        throw const KoerpergewichtFehlt();
      }
      final kg = gewichtKgFuerSatz(
        eingabewert: eingabewert,
        eingabeeinheit: einheit,
        assistiert: g.assistiert,
        koerpergewichtKg: s.koerpergewichtKg,
      );
      final nr = await naechsteSatzNr(sessionId, geraetId, seiteGespeichert);
      final text = notiz?.trim();
      final id = await into(saetze).insert(SaetzeCompanion.insert(
        sessionId: sessionId,
        geraetId: geraetId,
        satzNr: nr,
        seite: Value(seiteGespeichert),
        wiederholungen: wiederholungen,
        eingabewert: eingabewert,
        eingabeeinheit: einheit,
        gewichtKg: kg,
        notiz: Value(text == null || text.isEmpty ? null : text),
      ));
      if (g.einheit != einheit) {
        await (update(geraete)..where((x) => x.id.equals(geraetId)))
            .write(GeraeteCompanion(einheit: Value(einheit)));
      }
      return id;
    });
  }

  /// Körpergewicht der Session nachtragen (für assistierte Geräte).
  Future<void> setzeKoerpergewicht(int sessionId, double kg) =>
      (update(sessions)..where((s) => s.id.equals(sessionId)))
          .write(SessionsCompanion(koerpergewichtKg: Value(kg)));

  // ------------------------------------------------ WP2.3 letzte Werte (F7)

  /// Letzte Session (ausser [ohneSessionId]) mit Sätzen an diesem Gerät –
  /// egal wie lange her (Nutzerentscheid 13.11.2026).
  Future<LetztesMal?> letzteSessionAmGeraet(int geraetId,
      {int? ohneSessionId}) async {
    final q = select(saetze).join([
      innerJoin(sessions, sessions.id.equalsExp(saetze.sessionId)),
    ])
      ..where(saetze.geraetId.equals(geraetId) &
          (ohneSessionId == null
              ? const Constant(true)
              : saetze.sessionId.equals(ohneSessionId).not()))
      ..orderBy([OrderingTerm.desc(sessions.datum), OrderingTerm.desc(sessions.id)])
      ..limit(1);
    final r = await q.getSingleOrNull();
    if (r == null) return null;
    return _letztesMal(r.readTable(sessions), geraetId);
  }

  /// Letzte Werte „überhaupt“: Gerät mit gleicher Funktion an einem anderen
  /// Standort (Nutzerentscheid 13.11.2026, Variante b). Nur wenn diese
  /// Session neuer ist als das letzte Mal an [geraet] selbst.
  Future<LetztesMal?> letztesMalAndererStandort(Geraet geraet,
      {int? ohneSessionId}) async {
    final funktion = geraet.funktion?.trim().toLowerCase();
    if (funktion == null || funktion.isEmpty) return null;
    final gleiche = (await (select(geraete)
              ..where((g) => g.standortId.equals(geraet.standortId).not()))
            .get())
        .where((g) => g.funktion?.trim().toLowerCase() == funktion)
        .map((g) => g.id)
        .toList();
    if (gleiche.isEmpty) return null;
    final q = select(saetze).join([
      innerJoin(sessions, sessions.id.equalsExp(saetze.sessionId)),
    ])
      ..where(saetze.geraetId.isIn(gleiche) &
          (ohneSessionId == null
              ? const Constant(true)
              : saetze.sessionId.equals(ohneSessionId).not()))
      ..orderBy([
        OrderingTerm.desc(sessions.datum),
        OrderingTerm.desc(sessions.id),
        OrderingTerm.desc(saetze.id),
      ])
      ..limit(1);
    final r = await q.getSingleOrNull();
    if (r == null) return null;
    final dort = r.readTable(sessions);
    final hier =
        await letzteSessionAmGeraet(geraet.id, ohneSessionId: ohneSessionId);
    if (hier != null && hier.session.datum.compareTo(dort.datum) >= 0) {
      return null;
    }
    return _letztesMal(dort, r.readTable(saetze).geraetId);
  }

  Future<LetztesMal> _letztesMal(TrainingsSession s, int geraetId) async {
    final standort = await (select(standorte)
          ..where((x) => x.id.equals(s.standortId)))
        .getSingle();
    final g = await (select(geraete)..where((x) => x.id.equals(geraetId)))
        .getSingle();
    final liste = await (select(saetze)
          ..where((x) => x.sessionId.equals(s.id) & x.geraetId.equals(geraetId))
          ..orderBy([(x) => OrderingTerm.asc(x.id)]))
        .get();
    return LetztesMal(session: s, standort: standort, geraet: g, saetze: liste);
  }

  /// „Wie letztes Mal“: speichert alle Sätze vom letzten Mal an diesem Gerät
  /// (Wdh, Eingabewert, Eingabeeinheit, Seite; ohne Notiz). Nur solange es
  /// heute an diesem Gerät noch keinen Satz gibt. Gibt die neuen ids zurück.
  Future<List<int>> wieLetztesMal(int sessionId, int geraetId) {
    return transaction(() async {
      final heute = await (select(saetze)
            ..where((s) => s.sessionId.equals(sessionId) & s.geraetId.equals(geraetId)))
          .get();
      if (heute.isNotEmpty) {
        throw StateError('An diesem Gerät gibt es heute schon Sätze.');
      }
      final letztes =
          await letzteSessionAmGeraet(geraetId, ohneSessionId: sessionId);
      if (letztes == null) {
        throw StateError('An diesem Gerät gibt es noch kein letztes Mal.');
      }
      final ids = <int>[];
      for (final s in letztes.saetze) {
        ids.add(await speichereSatz(
          sessionId: sessionId,
          geraetId: geraetId,
          seite: s.seite,
          wiederholungen: s.wiederholungen,
          eingabewert: s.eingabewert,
          einheit: s.eingabeeinheit,
        ));
      }
      return ids;
    });
  }

  /// Löscht Sätze (z. B. „Rückgängig“ nach „wie letztes Mal“).
  Future<void> loescheSaetze(List<int> ids) =>
      (delete(saetze)..where((s) => s.id.isIn(ids))).go();

  /// Sätze eines Geräts in einer Session (für den Erfassungsbildschirm).
  Stream<List<Satz>> beobachteSaetzeDesGeraets(int sessionId, int geraetId) =>
      (select(saetze)
            ..where((s) => s.sessionId.equals(sessionId) & s.geraetId.equals(geraetId))
            ..orderBy([(s) => OrderingTerm.asc(s.id)]))
          .watch();
}
