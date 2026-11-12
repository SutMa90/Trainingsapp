// Zentrale Datenbank der App (drift).
// Reine Dart-Datei (kein Flutter) – wird auch vom Umwandlungsskript genutzt.
// Wie die Datei auf dem Handy geöffnet wird, steht in verbindung.dart.

import 'package:drift/drift.dart';

import '../../domain/einheiten.dart';
import 'tabellen.dart';

export '../../domain/einheiten.dart';

part 'datenbank.g.dart';

/// Startwerte der Muskelgruppen gemäss R2.4 (Reihenfolge = Sortierung).
const startMuskelgruppen = [
  'Beine',
  'Gesäss/Hüfte',
  'Waden',
  'Brust',
  'Rücken',
  'Schultern',
  'Bizeps',
  'Trizeps',
  'Core',
];

@DriftDatabase(tables: [Standorte, Muskelgruppen, Geraete, Sessions, Saetze])
class Datenbank extends _$Datenbank {
  Datenbank(super.e);

  /// Version 1 = Datenmodell V1. Jede Strukturänderung erhöht die Version
  /// und bekommt einen Migrationsschritt (siehe [migration]).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await legeStartMuskelgruppenAn();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> legeStartMuskelgruppenAn() async {
    await batch((b) {
      b.insertAll(
        muskelgruppen,
        [
          for (var i = 0; i < startMuskelgruppen.length; i++)
            MuskelgruppenCompanion.insert(
                name: startMuskelgruppen[i], sortierung: Value(i + 1)),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  /// Übersicht für die Session-Liste: alle Sessions, neueste zuerst,
  /// mit Standortname und Anzahl Sätze.
  Stream<List<SessionUebersicht>> beobachteSessionUebersicht() {
    final anzahl = saetze.id.count();
    final q = select(sessions).join([
      innerJoin(standorte, standorte.id.equalsExp(sessions.standortId)),
      leftOuterJoin(saetze, saetze.sessionId.equalsExp(sessions.id)),
    ])
      ..addColumns([anzahl])
      ..groupBy([sessions.id])
      ..orderBy([OrderingTerm.desc(sessions.datum), OrderingTerm.desc(sessions.id)]);
    return q.watch().map((rows) => [
          for (final r in rows)
            SessionUebersicht(
              session: r.readTable(sessions),
              standort: r.readTable(standorte),
              anzahlSaetze: r.read(anzahl) ?? 0,
            ),
        ]);
  }

  /// Alle Sätze einer Session in Erfassungsreihenfolge, mit Gerät.
  Stream<List<SatzMitGeraet>> beobachteSaetzeDerSession(int sessionId) {
    final q = select(saetze).join([
      innerJoin(geraete, geraete.id.equalsExp(saetze.geraetId)),
    ])
      ..where(saetze.sessionId.equals(sessionId))
      ..orderBy([OrderingTerm.asc(saetze.id)]);
    return q.watch().map((rows) => [
          for (final r in rows)
            SatzMitGeraet(satz: r.readTable(saetze), geraet: r.readTable(geraete)),
        ]);
  }
}

class SessionUebersicht {
  final TrainingsSession session;
  final Standort standort;
  final int anzahlSaetze;
  const SessionUebersicht(
      {required this.session, required this.standort, required this.anzahlSaetze});
}

class SatzMitGeraet {
  final Satz satz;
  final Geraet geraet;
  const SatzMitGeraet({required this.satz, required this.geraet});
}
