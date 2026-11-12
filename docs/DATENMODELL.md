# Trainings-App – Datenmodell V1

Stand: 11.11.2026 · Status: **Runde 1 + 2 abgestimmt – Datenmodell V1 freigegeben**
Strukturelle Entscheidung → Änderungen nur nach Abstimmung, geänderte Abschnitte markieren.

## Runde 1 (abgestimmt 11.11.2026)

**R1.1 Standort** – eigene Tabelle (Dielsdorf, Grüze, erweiterbar).

**R1.2 Gerät** – eindeutig über Standort + Kürzel. Felder: Funktion, Hauptmuskelgruppe (Liste, siehe R2.4), Hersteller, Modell, Einheit kg/lbs, Einstellung 1–3, Notiz.

**R1.3 Geräteeigenschaften** – zwei unabhängige Schalter: *assistiert* (ja/nein), *links/rechts getrennt* (ja/nein).

**R1.4 Session** – Datum, Standort, Körpergewicht des Tages (für assistierte Geräte).
Keine Start-/Endzeit in V1 (→ Backlog I-17, relevant mit Cardio).

**R1.5 Satz** – Session, Gerät, Satz-Nr., Seite (L/R/leer), Wiederholungen, Eingabewert + Eingabeeinheit (Original), Gewicht kg (berechnet), Notiz. Kein RPE in V1.

**R1.6 Gerätebezug und Korrekturen** – Satz verweist intern auf das Gerät, nicht auf das Kürzel.
- Umbenennen wirkt auch auf die Anzeige alter Sätze.
- Verwechslung (z. B. E1/E2) → neues Gerät anlegen; alte Logs bleiben unverändert.
- **Einheit jederzeit umschaltbar** in den Geräteeigenschaften (Geräte mit kg- und lbs-Anzeige). Alte Sätze bleiben unverändert, weil jeder Satz seine eigene Eingabeeinheit speichert. Die Einheit des Geräts gilt nur als Vorgabe für neue Sätze.
- **[Änderung M0] Anzeige letzter Werte (abgestimmt):** immer beide Einheiten, „xx kg, yy lbs“ – unabhängig von der Geräteeinheit.

## Runde 2 (abgestimmt 11.11.2026)

**R2.1 Doppel-Kürzel wegen Einheit zusammenlegen** – A4/A4.1, A5/A5.1 usw. werden beim Import zu einem Gerät zusammengeführt; jeder Satz behält seine Original-Einheit.
- Umsetzung: **kg/lbs-Schalter direkt im Erfassungsbildschirm**. Umschalten gilt für den aktuellen Satz und wird als neue Vorgabe ins Gerät übernommen.
- Offen für M1: Die genaue Liste der Paare wird beim Import aus den Daten erstellt und vom Nutzer bestätigt.
- **[Änderung M1] Liste bestätigt (12.11.2026):** In den Daten gibt es genau zwei Paare, beide in Grüze:
  - **A4 + A4.1 → A4** (Leg Extension)
  - **A5 + A5.1 → A5** (Seated Leg Curl), obwohl die Hersteller verschieden sind (Cybex lbs / LifeFitness kg) – bewusst so entschieden, der kg/lbs-Schalter deckt die Einheit ab.
  - Regel: Kürzel, Hersteller, Modell und Vorgabe-Einheit kommen vom Basis-Kürzel (ohne „.1“). Abweichende Angaben des „.1“-Geräts werden in die Geräte-Notiz übernommen (z. B. „zusammengeführt mit A5.1 – LifeFitness, kg“).

**R2.2 Ein Gerät, mehrere Übungen** – Jedes Kürzel bleibt ein eigenes Gerät. **Keine** Verknüpfung „gleiches physisches Gerät“, auch nicht später.
- Stattdessen: Beim Anlegen eines Geräts **Vorschläge aus bestehenden Einträgen** für Hersteller (danach Modell zu diesem Hersteller).

**R2.3 Zusatzgewicht** – Kein eigenes Feld. Das eingegebene Trainingsgewicht enthält Zusatzgewichte bereits; Sonderfälle nur als Notiz.

**R2.4 Muskelgruppen** – eigene, **erweiterbare** Liste. Startwerte: Beine, Gesäss/Hüfte, Waden, Brust, Rücken, Schultern, Bizeps, Trizeps, Core.

**R2.5 Eingabe Gewicht/Wdh** – Zahlenfelder mit einer Nachkommastelle, vorbefüllt mit den letzten Werten. Kein Stepper in V1 (→ I-18).

**R2.6 Körpergewicht** – wird beim Session-Start vom letzten Wert übernommen und lässt sich dort ändern.

**R2.7 Satz-Nr.** – zählt pro Gerät, Seite und Session automatisch hoch; beim Löschen nummeriert die App neu.
