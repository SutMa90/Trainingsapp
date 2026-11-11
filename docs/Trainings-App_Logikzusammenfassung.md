# Trainings-Log-Agent: Logik des bisherigen Chats (Grundlage für App-Konzept)

## 1. Ausgangslage
- Nutzer trainiert Kraft an Geräten (Active Fitness, Standorte **Dielsdorf** und **Grüze**), wenig freie Gewichte. Android-Smartphone.
- Heute: Chat mit Claude als Logger + Analyst. Daten liegen in einer Excel/Sheets-Datei (Tabs *Log*, *Geräte*, *Legende*). Claude hat nur Lesezugriff auf Drive, die Datei kommt nach jeder Session als Download-Anhang zurück.
- Ziel der App: gleiche Funktionen, aber deutlich schneller und intuitiver. Session starten und Sätze erfassen in Sekunden, am Ende eine Auswertung.

## 2. Datenmodell

**Log (1 Zeile pro Satz):** Datum, Ort, Gerät, Satz-Nr., Gewicht (kg), Gewicht (lbs), Einheit der Eingabe, Wiederholungen, Volumen (= kg × Wdh, Formel), RPE (kaum genutzt), Notiz.
- Gewicht wird immer in kg normalisiert. Umrechnung: 1 lbs = 0,4536 kg. Original-Eingabe bleibt erhalten (Einheit-Spalte, Notiz "Eingabe: 70 lbs"). Gegebener Wert fett, berechneter grau kursiv.
- Satz-Nr. zählt pro Gerät und Session (bei Geräten mit Seite pro Seite).

**Geräte (Eindeutig über Standort + Kürzel):** Standort, Kürzel, Funktion/Muskelgruppe, Hersteller, Modell, Einheit (kg/lbs), Einstellung 1–3, Notiz.
- Gleiches Kürzel an anderem Standort kann ein anderes Gerät sein (z. B. E1/E2 mit vertauschter Funktion, A5 vs. A5.1, A4 vs. A4.1).
- Einheit gehört zu **Gerät + Standort** und bleibt bestehen, bis der Nutzer sie ändert.

**Stammdaten:** Körpergewicht (82 kg, Stand 03.08.) für assistierte Geräte.

## 3. Eingabeprotokoll (heute per Chat)
| Eingabe | Bedeutung |
|---|---|
| `start <Ort>` | Session beginnt, Datum = heute |
| `A4 15x35 20x35` | Gerät A4, zwei Sätze (Wdh × Gewicht) |
| `20x36` ohne Gerät | gehört zum zuletzt genannten Gerät |
| `c3l` / `c3r` | links/rechts getrennt gezählt |
| `70 lbs` explizit | überschreibt die Standardeinheit des Geräts |
| Nur Kürzel, z. B. `b4` | Abfrage: letzte Werte (siehe 5) |
| `Stopp` / `Training beendet` | Session Ende, Datei + Auswertung |

Antwortstil beim Loggen: nur "Notiert". Rückfragen nur bei echter Unklarheit (unbekanntes Gerät, unklare Einheit, mögliche Tippfehler wie `d7`, `2x210`).

## 4. Fachliche Sonderregeln
- **Assistierte Geräte (T1/T2 Dielsdorf):** effektives Gewicht = Körpergewicht − Eingabewert.
- **Ein Gerät, mehrere Übungen/Einstellungen:** z. B. W1 (Calf Press) am Leg-Press-Gerät A2; D2 (Fly) und B7 (Rear Delt) sind dasselbe Gerät. Eigenes Kürzel, aber gleiche Geräteinfos.
- **Gleiche Übung, zwei Kürzel wegen Einheit:** A4 (lbs) und A4.1 (kg) in Grüze. Getrennt geführt, in Auswertungen als eine Übung behandelt.
- **Zusatzgewichte:** Korrektur "nur für heute +5 kg" auf B4 (Anzeige 41, effektiv 46 kg), mit Notiz.
- **Korrekturen:** letzten Satz oder ganzen Satz ändern ("korrigiere vorigen Eintrag", "Satz 1 …, Satz 2 …"). Rückwirkende Änderungen an Gerätezuordnung gelten **nur ab heute**, alte Logs bleiben (Beispiel E1/E2-Verwechslung).
- **Neue Geräte:** beim ersten Auftauchen Hinweis "nicht in der Geräte-Tabelle", Nutzer nennt Funktion, Hersteller, Modell, Einheit. Wird sofort in die Geräte-Datenbank übernommen.
- **Manuelle Einträge** des Nutzers in der Datei werden beim nächsten Zusammenführen ergänzt, Format vereinheitlicht, nichts überschrieben.

## 5. Abfrage während der Session
- Nur Gerätekürzel eingeben → Antwort: letzte Session mit diesem Gerät (Datum, Ort, Sätze in Gerätewährung, ggf. in kg umgerechnet).
- Falls diese Session an einem anderen Ort war als heute → zusätzlich letzte Session **am heutigen Ort**.
- "Welche Geräte habe ich heute noch nicht genutzt?" und "Welche 2–3 Geräte sollte ich noch machen?" (Priorisierung nach Muskelgruppen-Lücken der Session).

## 6. Auswertung nach Session
Automatisch nach "Training beendet":
- Vergleich pro Gerät mit der **letzten Session am selben Standort** (Gewicht, Wdh, Volumen).
- Gruppierung: Fortschritt / stabil / Rückgang. Sprünge und Auffälligkeiten ansprechen (z. B. lbs/kg-Verwechslung, 8-%-Einbruch bei A2).
- **Zeitliche Distanz** zur letzten Session einordnen (7, 16, 59 Tage Pause).
- Nicht gemachte Geräte auflisten, neue Geräte erwähnen.
- Auf Wunsch: Progressionsvorschlag (z. B. "bei 2×20 Wdh auf nächste Stufe", +5 bis +10 lbs).
- Danach aktualisierte Datei zum Download.

## 7. Weitere Analysen, die der Nutzer angefragt hat
- Reihenfolge der Geräte nach Muskelgruppen optimieren (Beine/Push/Pull blockweise, Core am Ende).
- Muskelgruppen-Lückenanalyse (Schultern, Waden, Hüfte, Arme, Rumpfrotation).
- Plausibilitätsprüfung, ob gleiche Kürzel an beiden Standorten dieselben Muskelgruppen treffen.
- Trainingsoptimierung für Fettabbau und Muskelaufbau: Frequenz pro Muskelgruppe, Rep-Ranges, Pausen, RPE-Nutzung, Supersätze.
- Projektziel: Performance-Entwicklung als Übersicht über die Zeit.

## 8. Schwachstellen des Chat-Ansatzes (Verbesserungspotenzial für die App)
1. **Tippaufwand:** jeder Satz = eine Nachricht, Format `Wdh x Gewicht` von Hand.
2. **Fehleingaben:** Tippfehler (d7), Zahlendreher, falsche Einheit. Korrektur nur per Freitext.
3. **Keine Live-Übersicht:** der Nutzer sieht nicht, was heute schon erfasst ist. Er muss fragen.
4. **Einheitenchaos:** kg/lbs pro Gerät und Standort, Umrechnung und Rückfragen. Ein Gerät wurde einmal fälschlich in lbs erfasst.
5. **Kürzel-Inkonsistenz:** A4/A4.1, A5/A5.1, E1/E2 mit unterschiedlicher Bedeutung je Standort.
6. **Datei-Handling:** nur Lesezugriff, Download nach jeder Session, Zusammenführen mit manuellen Änderungen. Kein echter Datenbank-Backend.
7. **Kontextverlust:** Session-Zustand lebt nur im Chat-Verlauf, Datei muss bei Neustart neu geladen werden.
8. **Vergleichswerte** werden nur auf Nachfrage geliefert.

## 9. Ideen für den Mehrwert der App (zur Diskussion)
**Session-Start in 1 Tap:** Standort automatisch erkannt (GPS/WLAN) oder zuletzt genutzter Ort vorausgewählt. Heutiges Datum automatisch.

**Erfassung während des Trainings:**
- Geräteliste des Standorts als Kacheln, sortiert nach üblicher Reihenfolge oder noch nicht gemacht.
- Beim Öffnen eines Geräts: letzte Werte (dieser Standort und zuletzt überhaupt) sofort sichtbar, **vorbefüllt** als Vorschlag.
- Satz erfassen mit Schnellwahl: Wdh und Gewicht per +/− oder Stepper in den Gerätestufen, "Wie letztes Mal"-Button, "Satz kopieren".
- Einheit pro Gerät hinterlegt, Anzeige in Gerätewährung, intern kg.
- Rückgängig/Korrigieren mit einem Tap. Zusatzgewicht und assistiertes Gerät als Gerätetyp-Eigenschaft.
- Optional: Pausentimer, RPE per Schnellwahl, Notiz per Sprache.
- Offline-fähig (Gym-Empfang), Sync später.

**Live-Übersicht:** Fortschrittsanzeige "heute 8 von 15 Geräten", Muskelgruppen-Heatmap der Session, Hinweis auf Lücken.

**Auswertung am Ende:** automatischer Session-Report (Vergleich zur letzten Session am selben Ort, Fortschritt/stabil/Rückgang, Pausenkontext, Volumen, Bestwerte), Progressionsvorschläge pro Gerät.

**Verlauf:** Performance-Entwicklung pro Gerät und Muskelgruppe über Wochen, Volumenkurven, Frequenz pro Muskelgruppe, Rekorde.

**Geräte-Verwaltung:** Neues Gerät bei erster Nutzung per kurzem Formular (Funktion, Hersteller, Modell, Einheit, Einstellungen). Verknüpfung "gleiches Gerät / gleiche Übung" für Fälle wie A4/A4.1, D2/B7, A2/W1.

**Export/Import:** Excel/CSV-Export im aktuellen Format, damit bestehende Daten (ca. 277 Zeilen Log) importierbar bleiben.

## 10. Offene Fragen für das App-Konzept
- Native Android-App, PWA oder Flutter (Nutzer baut bereits Flutter-Apps)? Offline-first? Datenhaltung lokal (SQLite) mit optionalem Cloud-Sync?
- Soll Claude (KI) in der App stecken (Auswertung, Tipps, freie Texteingabe) oder reicht regelbasierte Logik?
- Sprach-/Schnelleingabe im Stil des Chat-Protokolls (`15x35`) zusätzlich zu den Kacheln?
- Wie werden Zusatzgewichte, assistierte Geräte und Seiten (links/rechts) am einfachsten modelliert?
- Wie viel Rechnung übernimmt die App bei Progressionsvorschlägen (Regeln wie "2×20 Wdh erreicht → nächste Stufe")?
- Datenmigration aus der bestehenden Excel-Datei und Kürzel-Bereinigung (A4/A4.1 usw.).
