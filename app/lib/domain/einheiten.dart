/// Gewichtseinheiten und Umrechnung.
///
/// Regel (DATENMODELL R1.5 / Logikzusammenfassung): intern wird immer in kg
/// gerechnet, 1 lbs = 0,4536 kg. Eingabewert und Eingabeeinheit bleiben pro
/// Satz unverändert erhalten.
library;

/// Reine Dart-Datei (kein Flutter) – wird auch vom Umwandlungsskript genutzt.

enum Einheit { kg, lbs }

/// Seite bei Geräten, die links/rechts getrennt gezählt werden.
enum Seite { L, R }

const double kgProLbs = 0.4536;

/// Rechnet einen Wert in der gegebenen Einheit in kg um.
double inKg(double wert, Einheit einheit) =>
    einheit == Einheit.kg ? wert : wert * kgProLbs;

/// Rechnet kg in die gewünschte Einheit um.
double ausKg(double kg, Einheit einheit) =>
    einheit == Einheit.kg ? kg : kg / kgProLbs;

/// Effektives Trainingsgewicht eines Satzes in kg.
///
/// Bei assistierten Geräten (R1.3) nimmt das Gerät Gewicht ab:
/// effektiv = Körpergewicht − Eingabe.
double gewichtKgFuerSatz({
  required double eingabewert,
  required Einheit eingabeeinheit,
  bool assistiert = false,
  double? koerpergewichtKg,
}) {
  final eingabeKg = inKg(eingabewert, eingabeeinheit);
  if (!assistiert) return eingabeKg;
  if (koerpergewichtKg == null) {
    throw ArgumentError(
        'Assistiertes Gerät braucht das Körpergewicht der Session.');
  }
  return koerpergewichtKg - eingabeKg;
}
