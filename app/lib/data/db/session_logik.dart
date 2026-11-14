// WP2.1 Session starten / beenden (F4) – Regeln gemäss DATENMODELL R1.4
// [Änderung M2]. Reine Dart-Datei (kein Flutter), dadurch ohne Bildschirm
// testbar. „heute“ wird immer von aussen übergeben (Text JJJJ-MM-TT).

import 'package:drift/drift.dart';

import '../../version.dart';
import 'datenbank.dart';

/// Kalendertag als Text `JJJJ-MM-TT` (Ortszeit).
String isoDatum(DateTime t) => '${t.year.toString().padLeft(4, '0')}-'
    '${t.month.toString().padLeft(2, '0')}-'
    '${t.day.toString().padLeft(2, '0')}';

/// Vorbelegung des Start-Bildschirms.
class StartVorschlag {
  final List<Standort> standorte;

  /// Standort der zuletzt erfassten Session (falls vorhanden).
  final int? letzterStandortId;

  /// Letztes bekanntes Körpergewicht (R2.6).
  final double? letztesKoerpergewichtKg;

  const StartVorschlag({
    required this.standorte,
    this.letzterStandortId,
    this.letztesKoerpergewichtKg,
  });
}

/// Laufende (nicht abgeschlossene) Session mit Standort.
class LaufendeSession {
  final TrainingsSession session;
  final Standort standort;
  const LaufendeSession({required this.session, required this.standort});
}

/// Ergebnis von „Session beenden“.
enum BeendenErgebnis { beendet, leerVerworfen }

extension SessionLogik on Datenbank {
  /// Keine Session über mehrere Tage: Sessions vor [heute], die noch laufen,
  /// werden abgeschlossen – oder verworfen, wenn sie keine Sätze haben.
  /// Gibt die Anzahl betroffener Sessions zurück.
  Future<int> schliesseVergangeneSessions(String heute) {
    return transaction(() async {
      final alte = await (select(sessions)
            ..where((s) =>
                s.abgeschlossen.equals(false) & s.datum.isSmallerThanValue(heute)))
          .get();
      for (final s in alte) {
        await _beende(s.id);
      }
      return alte.length;
    });
  }

  /// Die laufende Session (höchstens eine) als Live-Abfrage.
  Stream<LaufendeSession?> beobachteLaufendeSession() {
    final q = select(sessions).join([
      innerJoin(standorte, standorte.id.equalsExp(sessions.standortId)),
    ])
      ..where(sessions.abgeschlossen.equals(false))
      ..orderBy([OrderingTerm.desc(sessions.id)])
      ..limit(1);
    return q.watchSingleOrNull().map((r) => r == null
        ? null
        : LaufendeSession(
            session: r.readTable(sessions), standort: r.readTable(standorte)));
  }

  Future<LaufendeSession?> laufendeSession() =>
      beobachteLaufendeSession().first;

  /// Eine Session als Live-Abfrage (z. B. um ein automatisches Ende zu sehen).
  Stream<TrainingsSession?> beobachteSession(int id) =>
      (select(sessions)..where((s) => s.id.equals(id))).watchSingleOrNull();

  /// Standorte, letzter Standort und letztes Körpergewicht.
  Future<StartVorschlag> startVorschlag() async {
    final alle = await (select(standorte)
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .get();
    final letzte = await (select(sessions)
          ..orderBy([
            (s) => OrderingTerm.desc(s.datum),
            (s) => OrderingTerm.desc(s.id),
          ])
          ..limit(1))
        .getSingleOrNull();
    final mitGewicht = await (select(sessions)
          ..where((s) => s.koerpergewichtKg.isNotNull())
          ..orderBy([
            (s) => OrderingTerm.desc(s.datum),
            (s) => OrderingTerm.desc(s.id),
          ])
          ..limit(1))
        .getSingleOrNull();
    return StartVorschlag(
      standorte: alle,
      letzterStandortId: letzte?.standortId,
      letztesKoerpergewichtKg: mitGewicht?.koerpergewichtKg,
    );
  }

  /// Legt einen neuen Standort an (R1.1, erweiterbar) und gibt die id zurück.
  Future<int> legeStandortAn(String name) =>
      into(standorte).insert(StandorteCompanion.insert(name: name.trim()));

  /// Startet eine Session am [standortId] für [heute].
  ///
  /// Gibt es heute am selben Standort schon eine Session, wird sie
  /// weitergeführt (eine Session pro Tag und Standort). Läuft bereits eine
  /// andere Session, wird nichts geändert ([StateError]).
  ///
  /// [Änderung M2] Eine neue Session merkt sich die App-Version ([version]).
  Future<int> starteSession({
    required int standortId,
    required String heute,
    double? koerpergewichtKg,
    String version = appVersion,
  }) {
    return transaction(() async {
      final laufend = await (select(sessions)
            ..where((s) => s.abgeschlossen.equals(false)))
          .get();
      final andere = laufend.where(
          (s) => !(s.datum == heute && s.standortId == standortId));
      if (andere.isNotEmpty) {
        throw StateError('Es läuft bereits eine andere Session.');
      }
      final bestehend = await (select(sessions)
            ..where((s) => s.datum.equals(heute) & s.standortId.equals(standortId))
            ..orderBy([(s) => OrderingTerm.asc(s.id)])
            ..limit(1))
          .getSingleOrNull();
      if (bestehend != null) {
        await (update(sessions)..where((s) => s.id.equals(bestehend.id))).write(
          SessionsCompanion(
            abgeschlossen: const Value(false),
            koerpergewichtKg: koerpergewichtKg == null
                ? const Value.absent()
                : Value(koerpergewichtKg),
          ),
        );
        return bestehend.id;
      }
      return into(sessions).insert(SessionsCompanion.insert(
        datum: heute,
        standortId: standortId,
        koerpergewichtKg: Value(koerpergewichtKg),
        abgeschlossen: const Value(false),
        appVersion: Value(version),
      ));
    });
  }

  /// Beendet die Session bewusst. Ohne Sätze wird sie verworfen.
  Future<BeendenErgebnis> beendeSession(int id) =>
      transaction(() => _beende(id));

  /// Nimmt eine versehentlich beendete Session wieder auf – nur am selben Tag
  /// und nur, wenn keine andere Session läuft.
  Future<void> nimmSessionWiederAuf(int id, String heute) {
    return transaction(() async {
      final s = await (select(sessions)..where((x) => x.id.equals(id)))
          .getSingle();
      if (s.datum != heute) {
        throw StateError('Nur Sessions von heute lassen sich wieder aufnehmen.');
      }
      final andere = await (select(sessions)
            ..where((x) => x.abgeschlossen.equals(false) & x.id.equals(id).not()))
          .get();
      if (andere.isNotEmpty) {
        throw StateError('Es läuft bereits eine andere Session.');
      }
      await (update(sessions)..where((x) => x.id.equals(id)))
          .write(const SessionsCompanion(abgeschlossen: Value(false)));
    });
  }

  /// [Änderung M2] Löscht eine von der App erzeugte Session samt Sätzen.
  /// Importierte Sessions (ohne App-Version) sind geschützt ([StateError]).
  Future<void> loescheSession(int id) {
    return transaction(() async {
      final s = await (select(sessions)..where((x) => x.id.equals(id)))
          .getSingle();
      if (s.appVersion == null) {
        throw StateError('Importierte Sessions sind geschützt.');
      }
      await (delete(saetze)..where((x) => x.sessionId.equals(id))).go();
      await (delete(sessions)..where((x) => x.id.equals(id))).go();
    });
  }

  Future<BeendenErgebnis> _beende(int id) async {
    final anzahl = saetze.id.count();
    final n = await (selectOnly(saetze)
          ..addColumns([anzahl])
          ..where(saetze.sessionId.equals(id)))
        .map((r) => r.read(anzahl) ?? 0)
        .getSingle();
    if (n == 0) {
      await (delete(sessions)..where((s) => s.id.equals(id))).go();
      return BeendenErgebnis.leerVerworfen;
    }
    await (update(sessions)..where((s) => s.id.equals(id)))
        .write(const SessionsCompanion(abgeschlossen: Value(true)));
    return BeendenErgebnis.beendet;
  }
}
