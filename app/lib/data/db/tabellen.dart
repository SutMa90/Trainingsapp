// Tabellen gemäss docs/DATENMODELL.md (V1, freigegeben 11.11.2026).
// Reine Dart-Datei (kein Flutter) – wird auch vom Umwandlungsskript genutzt.

import 'package:drift/drift.dart';

import '../../domain/einheiten.dart';

/// R1.1 Standort – Dielsdorf, Grüze, erweiterbar.
@DataClassName('Standort')
class Standorte extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

/// R2.4 Muskelgruppen – eigene, erweiterbare Liste.
@DataClassName('Muskelgruppe')
class Muskelgruppen extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();

  /// Anzeigereihenfolge in Auswahllisten.
  IntColumn get sortierung => integer().withDefault(const Constant(0))();
}

/// R1.2 / R1.3 Gerät – eindeutig über Standort + Kürzel.
@DataClassName('Geraet')
class Geraete extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get standortId => integer().references(Standorte, #id)();
  TextColumn get kuerzel => text()();
  TextColumn get funktion => text().nullable()();

  /// Hauptmuskelgruppe; leer, solange unbekannt.
  IntColumn get muskelgruppeId =>
      integer().nullable().references(Muskelgruppen, #id)();
  TextColumn get hersteller => text().nullable()();
  TextColumn get modell => text().nullable()();

  /// Vorgabe-Einheit für neue Sätze (R1.6) – ändert alte Sätze nicht.
  TextColumn get einheit => textEnum<Einheit>()();
  BoolColumn get assistiert => boolean().withDefault(const Constant(false))();
  BoolColumn get linksRechtsGetrennt =>
      boolean().withDefault(const Constant(false))();
  TextColumn get einstellung1 => text().nullable()();
  TextColumn get einstellung2 => text().nullable()();
  TextColumn get einstellung3 => text().nullable()();
  TextColumn get notiz => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {standortId, kuerzel},
      ];
}

/// R1.4 / R2.6 Session – Datum, Standort, Körpergewicht des Tages.
@DataClassName('TrainingsSession')
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Kalenderdatum als Text `JJJJ-MM-TT` (ohne Uhrzeit, ohne Zeitzonen-Effekte).
  TextColumn get datum => text().withLength(min: 10, max: 10)();
  IntColumn get standortId => integer().references(Standorte, #id)();
  RealColumn get koerpergewichtKg => real().nullable()();
}

/// R1.5 / R2.7 Satz.
///
/// Die Reihenfolge der Sätze innerhalb einer Session entspricht der
/// Reihenfolge der `id` (Erfassungs- bzw. Import-Reihenfolge).
@DataClassName('Satz')
class Saetze extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();

  /// Verweist auf das Gerät, nicht auf das Kürzel (R1.6).
  IntColumn get geraetId => integer().references(Geraete, #id)();

  /// Zählt pro Gerät, Seite und Session (R2.7).
  IntColumn get satzNr => integer()();

  /// L / R bei links/rechts getrennten Geräten, sonst leer.
  TextColumn get seite => textEnum<Seite>().nullable()();
  IntColumn get wiederholungen => integer()();

  /// Original-Eingabe, z. B. 70 + lbs.
  RealColumn get eingabewert => real()();
  TextColumn get eingabeeinheit => textEnum<Einheit>()();

  /// Effektives Gewicht in kg (berechnet, bei assistiert: Körpergewicht − Eingabe).
  RealColumn get gewichtKg => real()();
  TextColumn get notiz => text().nullable()();
}
