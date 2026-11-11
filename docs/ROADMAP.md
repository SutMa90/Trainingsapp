# Trainings-App – Roadmap

Stand: 11.11.2026 · Status: **V1-Umfang, Tech-Stack und Datenmodell abgestimmt – M0 kurz vor Abschluss**

## Rahmen [Änderung M0]
- **Tech-Stack:** Flutter (Android), lokale SQLite-Datenbank, VS Code, GitHub-Repository – analog Bierbrau-App.
- **Werkzeuge:** Claude Code für Code, Build und Git; Cowork für Doku und Konzept.
- **Führende Quelle:** Sobald das Repository steht, wandern ROADMAP und Backlog nach `docs/` im Repository. Der Ordner bleibt nur Arbeitskopie.
- **Keine KI** bis auf Weiteres; Auswertungen regelbasiert, als Text **und** Grafik.
Grundlage: `Trainings-App_Logikzusammenfassung.md`
Ideen außerhalb von V1: siehe `IDEEN-BACKLOG.md`

## Ziel Version 1
Das Training komplett ohne Chat erfassen und auswerten – schneller als heute und mit den bestehenden Daten.

## Umfang V1 [Änderung M0: abgestimmt 11.11.2026; Verschieben in spätere Versionen bleibt jederzeit möglich]

| # | Funktion | Prio |
|---|---|---|
| F1 | Lokale Datenbank, offline-fähig (kein Empfang im Gym nötig) | muss |
| F2 | Übernahme der bestehenden Excel-Daten (Log + Geräte, ca. 277 Zeilen) **per einmaligem Umwandlungsskript außerhalb der App** (Excel → Startdatenbank) | muss |
| F3 | Geräteverwaltung pro Standort: Kürzel, Funktion/Muskelgruppe, Einheit kg/lbs, Typ (normal / assistiert / links-rechts getrennt); Neuanlage per Kurzformular bei erster Nutzung, Vorschläge für Hersteller/Modell aus bestehenden Einträgen [Änderung M0] | muss |
| F4 | Session starten (Standort, letzter vorausgewählt, Datum automatisch) und beenden | muss |
| F5 | Satz erfassen: Gerät als Kachel wählen, Wdh + Gewicht als Zahlenfelder (1 Nachkommastelle) mit letzten Werten vorbefüllt, kg/lbs-Schalter [Änderung M0], Button „wie letztes Mal“, optionale Notiz | muss |
| F6 | Anzeige in der Einheit des Geräts, intern immer kg; assistiert = Körpergewicht − Eingabe | muss |
| F7 | Beim Gerät: letzte Werte am selben Standort + letzte Werte überhaupt | muss |
| F8 | Live-Liste der heutigen Sätze; Satz bearbeiten / löschen | muss |
| F9 | Session-Report: Vergleich pro Gerät mit letzter Session am selben Standort (Fortschritt / stabil / Rückgang), Tage seit letzter Session, nicht gemachte Geräte – als kurzer Text **und** Grafik (z. B. Balken heute vs. letztes Mal pro Gerät) | muss (Text) / soll (Grafik) |

**Bewusst nicht in V1:** Export (→ I-15), Verlaufsdiagramme über Wochen, Progressionsvorschläge, Muskelgruppen-Analyse, KI, GPS-Standorterkennung, Pausentimer, Cloud-Sync, Verknüpfung „gleiche Übung“ (A4/A4.1). → Backlog.

**Risiko ohne Export:** Die Daten liegen nur auf dem Handy. Vorschlag: in M4 mindestens eine einfache Sicherung prüfen (Android-Backup oder Datenbankdatei kopieren).

## Meilensteine

| MS | Inhalt | Werkzeug | Abnahmekriterium (prüfbar) |
|---|---|---|---|
| M0 | Konzept: Tech-Stack, Datenmodell (in Runden à 5–7 Punkte), V1-Umfang final | Chat / Cowork | Datenmodell-Dokument und V1-Liste vom Nutzer freigegeben |
| M1 | GitHub-Repository + Flutter-Grundgerüst, Datenbank, Umwandlungsskript Excel → Startdatenbank, Kürzel-Bereinigung | Claude Code | App startet auf dem Handy mit allen alten Log-Zeilen; 5 Stichproben-Sessions stimmen mit der Excel überein |
| M2 | Erfassung: Session, Gerätekacheln, Satz-Eingabe, Korrektur, neues Gerät | Claude Code | Eine echte Session im Gym ohne Chat erfasst; ein Satz mit Vorbefüllung in ≤ 5 Sekunden |
| M3 | Session-Report (Text + Grafik) [Änderung M0: Export gestrichen] | Claude Code | Report einer echten Session deckt sich inhaltlich mit der bisherigen Chat-Auswertung |
| M4 | Praxistest 2–3 Wochen, Fehler beheben, Retrospektive | Gym + Code | 6 Sessions ohne Datenverlust und ohne Rückgriff auf den Chat → **V1 fertig** |

Nach jedem Meilenstein: kurze Retrospektive (gut / holprig + Ursache / Maßnahmen) und Backlog-Durchsicht.

## Offene Entscheidungen (M0)
- [x] Tech-Stack: Flutter + SQLite, VS Code, GitHub
- [x] KI: keine bis auf Weiteres; Auswertung als Text + Grafik
- [x] V1-Umfang: F1–F9, Export später, Import per Skript
- [x] Datenmodell (Runde 1 + 2 abgestimmt) → `DATENMODELL.md`
- [ ] Anzeigeformat letzter Werte „31,8 kg (70 lbs)“ bestätigen
- [ ] Freigabe M0 → Start M1 in Claude Code
