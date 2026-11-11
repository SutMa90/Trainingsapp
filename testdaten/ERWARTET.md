# Testdaten – erwartete Ergebnisse

`Testlog.xlsx` ist eine **synthetische** Trainings-Excel: gleicher Aufbau wie die echte Datei (Tabs Log, Geräte, Legende; fett = Eingabe, grau kursiv = berechnet; Volumen als Formel), aber **alle Werte, Standorte und Hersteller sind erfunden**. Sie darf deshalb im öffentlichen Repository liegen.

Neu erzeugen: `dart run testdaten/erzeuge_testlog.dart`
Zweck: Das Umwandlungsskript (WP1.4) wird automatisch gegen diese Datei getestet. Erst wenn alle Tests grün sind, wird die echte Excel lokal umgewandelt.

## Annahmen (Entscheidungsdatei für die Testdaten)
- **X4 / X4.1** (Südstadt): zusammenführen zu **X4**, Vorgabe-Einheit lbs.
- **X5 / X5.1** (Südstadt): **nicht** zusammenführen (anderer Hersteller).
- **Session 2025-03-18 Südstadt**: Zeilen mit Verdacht „lbs × 0,45 als kg erfasst“ werden als lbs-Eingabe wiederhergestellt.
- Ohne diese Entscheidungen meldet das Skript die Fälle nur und ändert nichts.

## Gesamtzahlen

| Grösse | Erwartet |
|---|---|
| Log-Zeilen mit Inhalt | 53 (Excel-Zeilen 2–54) |
| Leere Zeilen am Ende (nur Volumen-Formel) | 4, werden ignoriert |
| **Fehler** – nicht importiert, gemeldet | 5 |
| **Importierte Sätze** | **48** |
| Sessions | 6 |
| Standorte | 2 (Nordstadt, Südstadt) |
| Geräte nach Zusammenführung | 14 (Nordstadt 7, Südstadt 7; Tab Geräte hat 15 Zeilen) |
| Muskelgruppen | 9 Startwerte gemäss R2.4 |

## Sessions

| # | Datum | Standort | Sätze | Körpergewicht | Geprüfte Sonderfälle |
|---|---|---|---|---|---|
| S1 | 2025-03-03 | Nordstadt | 10 | 78 kg | assistiert (T1), abwechselnde Reihenfolge D1/B4 |
| S2 | 2025-03-06 | Südstadt | 12 | – | lbs-Geräte, Rundung, X4.1/X5.1 in kg, C3 links/rechts |
| S3 | 2025-03-12 | Nordstadt | 8 | – | einmalige lbs-Eingabe auf kg-Gerät (D1), Zusatzgewicht-Notiz |
| S4 | 2025-03-18 | Südstadt | 6 | – | Faktor 0,45 (4 Zeilen), echtes kg-Gerät X4.1 bleibt kg |
| S5 | 2025-03-25 | Südstadt | 7 | – | X4/X5 in lbs, widersprüchliche Auto-Notiz |
| S6 | 2025-04-02 | Nordstadt | 5 | – | absichtlich unklare Zeilen, Satz-Nr.-Lücke |

## Fehler (nicht importiert, im Prüfbericht gemeldet)

| Excel-Zeile | Grund |
|---|---|
| 45 | E2 Südstadt: Notiz „Eingabe: 70 lbs“ widerspricht dem Eingabewert 75 lbs |
| 47 | A2 Nordstadt: Wiederholungen fehlen |
| 50 | Kürzel Z9 steht nicht im Tab Geräte |
| 51 | Einheit „kgs“ unbekannt |
| 54 | Datum „04/02/2025“ mehrdeutig (2. April oder 4. Februar) |

## Warnungen (importiert, im Prüfbericht gemeldet)

| Excel-Zeile | Fall | Erwartetes Ergebnis |
|---|---|---|
| 12 | kg-Spalte gerundet (90,7 statt 90,72) | kg neu berechnet: 200 × 0,4536 = 90,72 |
| 26–27 | D1 Nordstadt (kg-Gerät) einmalig in lbs | übernommen wie erfasst: 50 lbs / 60 lbs |
| 32–35 | Südstadt, lbs-Geräte als kg erfasst, Werte = lbs × 0,45 | mit Entscheidung: 190 lbs, 200 lbs, 60 lbs, 70 lbs → kg = lbs × 0,4536 |
| 53 | D1 Nordstadt: Satz-Nr. springt von 1 auf 3 | importiert als Satz 2 |
| – | Doppel-Kürzel-Kandidaten X4/X4.1 und X5/X5.1 | gemäss Entscheidungsdatei |
| – | T1 Nordstadt ohne Funktion | Muskelgruppe bleibt leer |

## Stichproben (Satz für Satz)

**S1 – T1 Nordstadt (assistiert):** Satz 1: Eingabe 40 kg, Gewicht 38 kg, 8 Wdh. Satz 2: Eingabe 45 kg, Gewicht 33 kg, 10 Wdh. Das Gerät ist als *assistiert* markiert.

**S2 – C3 Südstadt (links/rechts):** ein Gerät C3 (*links/rechts getrennt*), 4 Sätze: L1 40 lbs, R1 40 lbs, L2 45 lbs, R2 45 lbs; kg 18,14 / 18,14 / 20,41 / 20,41.

**X4 Südstadt (zusammengeführt):** 6 Sätze an einem Gerät:
S2: 30 kg, 32,5 kg · S4: 32,5 kg, 35 kg · S5: 65 lbs (29,48 kg), 70 lbs (31,75 kg).
X5 hat 2 Sätze (lbs), X5.1 hat 2 Sätze (kg).

**S4 Südstadt (nach Entscheidung):** A2 190 lbs (86,18 kg) und 200 lbs (90,72 kg); E1 60 lbs (27,22 kg); E2 70 lbs (31,75 kg); X4 32,5 kg und 35 kg.

**S3 – B4 Nordstadt:** 2 Sätze à 35 kg, Notiz „inkl. 5 kg Zusatzgewicht (Anzeige 30 kg)“ bleibt erhalten.

**Notizen allgemein:** Auto-Notizen („Eingabe: … lbs“, „assistiert: …“) entfallen, wenn sie zu Eingabewert und Einheit passen. Alle anderen Notizen bleiben.
