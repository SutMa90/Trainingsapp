# WP1.4 – Umwandlungsskript Excel → Startdatenbank

Stand: 12.11.2026 · Status: ✅ abgeschlossen

**Abnahmekriterium:** Automatischer Test gegen `testdaten/Testlog.xlsx` grün (Soll: `testdaten/ERWARTET.md`); Lauf auf den echten Daten meldet nur Zeilen, über die der Nutzer entschieden hat.

## Bedienung (im Ordner `app/`)
```
dart run tool/import_excel/main.dart
```
Liest `../Krafttraining_Log.xlsx`, schreibt `assets/db/startdb.sqlite` und den Prüfbericht `tool/import_excel/out/pruefbericht.md`. Beide Ausgaben sind per `.gitignore` vom Repository ausgeschlossen. Pfade sind per `--excel`, `--entscheidungen`, `--ziel`, `--bericht` änderbar.

## Aufbau
| Datei | Inhalt |
|---|---|
| `app/tool/import_excel/xlsx_leser.dart` | liest die Tabellenblätter einer .xlsx (Text, Zahl, leer) |
| `app/tool/import_excel/importer.dart` | Prüf- und Importlogik, Prüfbericht |
| `app/tool/import_excel/main.dart` | Aufruf auf dem PC |
| `app/tool/import_excel/entscheidungen.json` | Entscheidungen für die echten Daten (ohne Trainingswerte) |
| `testdaten/entscheidungen.json` | Entscheidungen für die Testdaten |
| `app/test/import_excel_test.dart` | 16 automatische Tests gegen die Testdaten |

## Regeln des Skripts
- **Fehler** (Zeile wird *nicht* importiert): Datum nicht eindeutig (nur `JJJJ-MM-TT` oder Excel-Datumszahl), Standort/Kürzel nicht im Tab Geräte, Einheit nicht kg/lbs, Wiederholungen fehlen, Gewicht fehlt, Auto-Notiz widerspricht dem Eingabewert, assistiertes Gerät ohne bzw. mit unstimmiger „assistiert“-Notiz.
- **Warnung** (importiert, gemeldet): Eingabeeinheit ≠ Vorgabe-Einheit des Geräts (mit Hinweis, falls der Wert = runde lbs-Zahl × 0,45 ist); Satz-Nr. nicht fortlaufend (wird fortlaufend nummeriert); Funktion ohne Muskelgruppen-Zuordnung; mögliches Doppel-Kürzel, das nicht in der Entscheidungsdatei steht.
- **Hinweis**: Zusammenführungen, Rundung der Excel-kg-Spalte, Geräte ohne Muskelgruppe, Markierung assistiert / links-rechts.
- **Eingabewert und Eingabeeinheit** werden unverändert übernommen. **Gewicht kg** wird nach der festen Regel berechnet (lbs × 0,4536; assistiert: Körpergewicht − Eingabe). [Vorschlag] Dadurch weichen 8 Sätze vom 06.08. um höchstens 0,02 kg von der gerundeten Excel-Spalte ab; sie sind im Prüfbericht als Hinweis aufgeführt.
- **assistiert**: Gerät mit „assistiert“ in der Geräte-Notiz. Eingabe und Körpergewicht kommen aus der Satz-Notiz „assistiert: KG − X kg Eingabe“; das Körpergewicht wird bei der Session gespeichert.
- **links/rechts getrennt**: Gerät, für das im Log `-links` / `-rechts` vorkommt.
- **Zusammengeführte Geräte** übernehmen Kürzel, Hersteller, Modell und Vorgabe-Einheit vom Basis-Kürzel; die Angaben des „.1“-Geräts landen in der Geräte-Notiz.
- Reihenfolge der Sätze = Reihenfolge der Excel-Zeilen.

## Ergebnis
- **Testdaten:** 53 Zeilen → 48 Sätze, 5 Fehler, 8 Warnungen, 6 Sessions, 13 Geräte – genau wie in `ERWARTET.md`. `flutter test`: 21 von 21 grün (5 Datenbank + 16 Import).
- **Echte Daten (lokal):** 276 Log-Zeilen → **276 Sätze, 0 Fehler**, 13 Sessions, 31 Geräte (33 Einträge − 2 zusammengeführt).
  20 Warnungen, alle aus vom Nutzer entschiedenen Fällen: 12 × Session 18.08. Grüze (kg auf lbs-Geräten), 8 × D1 Dielsdorf (kg-Sätze, Vorgabe im Tab Geräte ist lbs). Der Zusatz „× 0,45“ ist bei D1 Dielsdorf ein Zufallstreffer.
  16 Hinweise (Zusammenführung, Rundung, assistiert, links/rechts, Muskelgruppe leer bei T1/T2/C3).
