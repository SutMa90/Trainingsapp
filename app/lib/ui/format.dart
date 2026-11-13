/// Anzeigeformate (Schweizer Schreibweise).
library;

/// `2025-03-06` → `06.03.2025`
String formatDatum(String isoDatum) {
  final teile = isoDatum.split('-');
  if (teile.length != 3) return isoDatum;
  return '${teile[2]}.${teile[1]}.${teile[0]}';
}

/// Zahl mit höchstens [stellen] Nachkommastellen, Komma als Dezimalzeichen.
/// 90.72 → `90,72`, 35.0 → `35`
String formatZahl(double wert, {int stellen = 2}) {
  var s = wert.toStringAsFixed(stellen);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return s.replaceAll('.', ',');
}

/// Liest eine Zahl mit Komma oder Punkt (`80,5` / `80.5`); leer → null.
double? leseZahl(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}
