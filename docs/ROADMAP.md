# Trainings-App – Roadmap

Stand: 13.11.2026 · Status: **M0 und M1 abgeschlossen – M2 (Erfassung) läuft, siehe `docs/M2.md`**

## Rahmen [Änderung M0]
- **[Änderung M2] Name:** Die App heisst **Gymi** (gesprochen wie „Jimmy“, Nutzerentscheid 14.11.2026). Nur der Anzeigename ändert sich; die Android-Kennung `com.sutma90.trainingsapp`, der Datenbankname und die Ordner-/Repository-Namen bleiben – eine neue Kennung wäre für Android eine andere App, die Daten wären weg.
- **Tech-Stack:** Flutter (Android), lokale SQLite-Datenbank, VS Code, GitHub-Repository – analog Bierbrau-App.
- **Werkzeuge:** Claude Code für Code, Build und Git; Cowork für Doku und Konzept.
- **Führende Quelle:** Sobald das Repository steht, wandern ROADMAP und Backlog nach `docs/` im Repository. Der Ordner bleibt nur Arbeitskopie.
- **Keine KI** bis auf Weiteres; Auswertungen regelbasiert, als Text **und** Grafik.
- **[Änderung M2] Versionierung bis V1:** `0.<Meilenstein>.<Testinstallation>` (z. B. `0.2.1`) – jede Testinstallation bekommt eine neue Nummer, sichtbar in der App; `1.0.0` = Version 1 fertig (Nutzerwunsch 13.11.2026).
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
| M1 ✅ | GitHub-Repository + Flutter-Grundgerüst, Datenbank, Umwandlungsskript Excel → Startdatenbank, Kürzel-Bereinigung | Claude Code | App startet auf dem Handy mit allen alten Log-Zeilen; 5 Stichproben-Sessions stimmen mit der Excel überein → **erfüllt 13.11.2026** |
| M2 🔄 | Erfassung: Session, Gerätekacheln, Satz-Eingabe, Korrektur, neues Gerät; Rückübertragung in die Excel (I-21) [Änderung M2] | Claude Code | Eine echte Session im Gym ohne Chat erfasst; ein Satz mit Vorbefüllung in ≤ 5 Sekunden; Rückübertragung ergänzt die Session vollständig in der echten Excel [Änderung M2] |
| M3 | Session-Report (Text + Grafik) [Änderung M0: Export gestrichen] | Claude Code | Report einer echten Session deckt sich inhaltlich mit der bisherigen Chat-Auswertung |
| M4 | Praxistest 2–3 Wochen, Fehler beheben, Retrospektive | Gym + Code | 6 Sessions ohne Datenverlust und ohne Rückgriff auf den Chat → **V1 fertig** |

Nach jedem Meilenstein: kurze Retrospektive (gut / holprig + Ursache / Maßnahmen) und Backlog-Durchsicht.

## Offene Entscheidungen (M0)
- [x] Tech-Stack: Flutter + SQLite, VS Code, GitHub
- [x] KI: keine bis auf Weiteres; Auswertung als Text + Grafik
- [x] V1-Umfang: F1–F9, Export später, Import per Skript
- [x] Datenmodell (Runde 1 + 2 abgestimmt) → `DATENMODELL.md`
- [x] Anzeigeformat letzter Werte: immer beide Einheiten „xx kg, yy lbs“ (siehe `DATENMODELL.md` R1.6) [Änderung M1: Haken nachgetragen]
- [x] Freigabe M0 → Start M1 in Claude Code (11.11.2026)

## M1 – Zusammenfassung (abgeschlossen 13.11.2026)
Details: `docs/M1.md` und `docs/m1/`.

**Ergebnis**
- GitHub-Repository mit Doku in `docs/` (führende Quelle), Glossar, M1-Übersicht und je einem Dokument pro Arbeitspaket.
- Flutter-App (Android) mit lokaler Datenbank (drift/SQLite): Standorte, Muskelgruppen, Geräte, Sessions, Sätze gemäss Datenmodell V1.
- Umwandlungsskript Excel → Startdatenbank (Dart, läuft auf dem PC) mit Prüfbericht; Trainingsdaten werden unverändert übernommen, Auffälliges nur gemeldet.
- Synthetische Testdaten mit allen bekannten Sonderfällen; 23 automatische Tests, alle grün.
- Auf dem Handy: alle 276 Log-Zeilen in 13 Sessions, 31 Geräte (A4/A4.1 und A5/A5.1 zusammengeführt); Session-Liste und Satz-Detailansicht; 5 von 5 Stichproben stimmen.

**Retrospektive**
- *Gut:* Synthetische Testdaten (Idee des Nutzers) → Tests im öffentlichen Repo ohne persönliche Daten; sie haben das Skript abgesichert, bevor echte Daten im Spiel waren. Datenanalyse *vor* dem Import hat Sonderfälle früh sichtbar gemacht (Session 18.08., A5/A5.1 mit verschiedenen Herstellern). Test auf dem echten Handy mit Screenshots per USB.
- *Holprig 1:* Falscher Pfad in `.gitignore` (`tools/` statt `app/tool/`) – der Prüfbericht mit echten Werten wäre fast ins Repo gelangt. Ursache: Prozessfehler – `.gitignore` vor der Festlegung der Ordnerstruktur geschrieben und danach nicht nachgeprüft. Vor dem Commit bemerkt.
- *Holprig 2:* Ein UI-Test hing über 4 Minuten und blockierte danach eine Datei. Ursache: eigener Fehler beim Testaufbau (Datenbank in der simulierten Test-Zeit geöffnet), dazu kein Zeitlimit.
- *Holprig 3:* Unterbrüche am Handy (USB-Freigabe, Kabel getrennt, Bildschirm gesperrt). Ursache: Werkzeug/Umgebung, Schritte am Gerät nicht vorab angekündigt.
- *Holprig 4:* Die erste Klärungsliste war zu lang (> 10 Punkte gemischt); die Antworten kamen in mehreren Runden. Ursache: Prozessfehler – Regel „5–7 Punkte pro Runde“ nicht eingehalten.

**Massnahmen für M2**
1. Vor jedem Commit prüfen, dass keine echten Daten erfasst sind (`git check-ignore` / `git ls-files`), besonders nach neuen Ordnern.
2. Jeder UI-Test mit Zeitlimit; Datenbank in Tests immer ausserhalb der simulierten Zeit anlegen.
3. Vor Handy-Schritten ankündigen: Handy entsperrt, USB verbunden, Bildschirm an (Entwickleroptionen → „Aktiv lassen“ beim Laden).
4. Fragen an den Nutzer in Runden à höchstens 5–7 nummerierten Punkten.

**Offene Punkte nach M1**
- **Datenpflege** in der Geräteverwaltung (M2, Backlog I-19): Muskelgruppe T1/T2/C3, Vorgabe-Einheit D1 Dielsdorf.
- **Achtung Datenverlust:** Ab der ersten echten Erfassung in M2 darf die App **nicht mehr deinstalliert** werden (Deinstallieren löscht die Datenbank). Updates nur noch „drüber“ installieren. Sicherung siehe M4 / I-13.
- Bis M2 abgenommen ist, bleibt die Excel die Referenz; neue Sessions bis dahin weiter wie bisher erfassen und vor M2 neu importieren (Skript erneut laufen lassen).
- Android-Lizenzen auf dem PC noch nicht akzeptiert (`flutter doctor --android-licenses`) – stört den Build bisher nicht.
- App läuft als Debug-Version; eine signierte Release-Version ist für V1 noch zu klären (spätestens M4).
- **[Änderung nach M1, 13.11.2026] Neuer Nutzerwunsch für M2:** In der App erfasste Sessions sollen bis auf Weiteres zurück in die Excel auf dem PC übertragen werden (Datensicherung) → Backlog I-21. Weg und Format werden in M2 vorgeschlagen und freigegeben.
