# WP2.7 – Umstieg: App wird die Quelle

Stand: 15.11.2026 · Status: 🔄 in Umsetzung (Fragenrunde 15.11. entschieden)

**Abnahmekriterium:** Sessions/Sätze in der App = Excel; Probelauf der Rückübertragung auf der echten Excel meldet 0 neue Sessions, Datei unverändert.

## Ausgangslage (13.11.2026)
- Führende Excel ist bis zum Stichtag der Chat-Download; eine Kopie mit Stand heute liegt als `Krafttraining_Log.xlsx` im Projektordner (nicht im Repo). Letzte Session darin: 11.11.
- Auf dem Handy: Stand M1-Import. Bis zum Stichtag sind Testeinträge am Handy erlaubt; sie werden beim Umstieg ersetzt. Deinstallieren ist bis dahin erlaubt.

## [Änderung M2] Entscheidungen des Nutzers (15.11.2026)
| # | Punkt | Entscheid |
|---|---|---|
| 1 | Stichtag | **jetzt**: Die letzte echte Session war am 11.11.; der Termin des nächsten Trainings ist offen. |
| 2 | Excel | `Krafttraining_Log.xlsx` im Projektordner ist die letzte Version (letzte Session 11.11.); alles danach am Handy waren Test-Sessions. Die Chat-Version wird nicht mehr gepflegt. |
| 3 | Meldungen | Der Import meldet **0 Fehler** (276 von 276 Sätzen). Die 20 Warnungen (kg-Eingaben auf Geräten mit Vorgabe lbs) sind dieselben wie in M1 und bleiben unverändert. Geräte ohne Muskelgruppe bekommen einen **Vorschlag, als solcher markiert** – der Nutzer bestätigt oder ändert ihn im Training. |
| 4 | Datenbasis | Die neue Datenbank beruht nur auf der Excel (Session 11.11. und alles davor). Neuere Sessions und Geräte am Handy (Tests) werden gelöscht. |
| 5 | Probelauf / Doppelklick | Probelauf mit `Rueckuebertragung.bat` auf der echten Excel: 0 neue Sessions, Datei per Prüfsumme unverändert. `Rueckuebertragung_Probe.bat` bleibt für Tests. |
| 6 | Routine | Der Nutzer sichert, wenn er kann; zwischen zwei Sicherungen können mehrere Sessions liegen, nach V1 eher seltener. Die Rückübertragung überträgt alle neuen beendeten Sessions auf einmal. Erinnerung an die Sicherung → Backlog I-25. |

### Muskelgruppen-Vorschläge (markiert, Nutzer bestätigt im Training)
| Gerät | Vorschlag | Grundlage |
|---|---|---|
| Dielsdorf T1 | Rücken | assistiert, ohne Funktion – vermutlich assistierte Klimmzüge |
| Dielsdorf T2 | Trizeps | assistiert, ohne Funktion – vermutlich assistierte Dips |
| Grüze C3 | Rücken | ohne Funktion, links/rechts getrennt – unsicher (z. B. Kabelzug einarmig) |

Umsetzung (Vorschlag): Die Entscheidungsdatei hat neu „muskelgruppeVorschlag“. Der Import setzt die Muskelgruppe und ergänzt die Geräte-Notiz um die Marke „Muskelgruppe ist ein Vorschlag – bitte bestätigen“. Die App zeigt das in der Geräteliste („Rücken (Vorschlag)“) und im Formular mit dem Knopf „Bestätigen“; wählt der Nutzer eine andere Muskelgruppe oder bestätigt, verschwindet die Marke. Keine Änderung am Datenmodell.

## Ablauf
1. **Während WP2.1–2.6:** Tests am Handy mit der vorhandenen App-Datenbank (Wegwerf-Einträge).
2. **Stichtag** (vor dem ersten Gym-Training mit der App): Nutzer legt die aktuelle Excel als `Krafttraining_Log.xlsx` in den Projektordner. Umwandlungsskript → Prüfbericht → Nutzer entscheidet über neue Meldungen.
3. **Letzte Deinstallation**, Neuinstallation mit frischer Startdatenbank; Zählung Sessions/Sätze App = Excel.
   3a. **[Änderung M2] Datenpflege I-19 erst nach dem Umstieg** (14.11.2026, WP2.5): Die Neuinstallation übernimmt die Geräte aus der Excel; was vorher am Handy nachgetragen wurde, wäre weg. Darum trägt der Nutzer erst in den ersten echten Sessions am jeweiligen Ort nach (lange auf die Kachel drücken oder ⋮ → Geräte; Abnahme WP2.8): Muskelgruppe T1/T2 Dielsdorf und C3 Grüze, Vorgabe-Einheit D1 Dielsdorf, Funktion B3/C1 Grüze. Alternative: vor dem Stichtag im Tab Geräte der Excel nachtragen, dann bringt der Import es mit.
4. **Probelauf** der Rückübertragung auf der echten Excel: muss „0 neue Sessions“ melden und nichts ändern.
5. **Ab dann:** Die App ist die Quelle, die Excel wird nur noch per Rückübertragung ergänzt. **App nie mehr deinstallieren** (löscht die Datenbank), Updates nur „drüber“ installieren.
   Fällt die App im Gym aus: Session wie früher in die Excel eintragen; die Rückübertragung erkennt Datum + Ort und legt nichts doppelt an.
6. Erste echte Gym-Session mit Rückübertragung = Abnahme M2 (WP2.8).
