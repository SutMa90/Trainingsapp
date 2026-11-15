# WP2.6 – Rückübertragung App → Excel (Backlog I-21)

Stand: 15.11.2026 · Status: 🔄 in Umsetzung (zweite Fragenrunde 15.11. entschieden)

**Zweck:** Datensicherung, solange die App die Quelle ist – falls die App Daten aus unbekannten Gründen nicht behält. Abgrenzung: allgemeiner Export bleibt I-15 (V2).

**Abnahmekriterium:** Test mit Testdaten: Import → 2 Sessions in der App ergänzen (lbs, assistiert, L/R, neues Gerät) → Rückübertragung: bestehende Zeilen byte-gleich, Sicherung vorhanden, 2. Lauf ergänzt 0 Zeilen, erneuter Import des Ergebnisses = dieselben Sätze wie in der App.

## Entscheidungen des Nutzers (13.11.2026)

| # | Punkt | Entscheid |
|---|---|---|
| 1 | Weg | **A: USB-Kabel + Doppelklick am PC** (`Rueckuebertragung.bat`). Weg B (in der App „Sicherung teilen“) → Backlog I-22. |
| 2 | Format | wie bisher (siehe unten), inkl. Auto-Notizen; neue Geräte werden im Tab Geräte angehängt |
| 3 | Lücken | **keine Lücken**: die vorbereiteten leeren Zeilen am Ende des Logs (nur Volumen-Formel, keine Daten) werden mit den neuen Sätzen gefüllt; danach wird angehängt |
| 4 | Benennung der Sicherungen | Datum der **letzten Trainings-Session** im Dateinamen (Nutzervorschlag): `Sicherungen/Krafttraining_Log_Stand_JJJJ-MM-TT.xlsx` = letzte Session, die *vor* dem Schreiben in der Excel stand; `Sicherungen/App-Datenbank_Stand_JJJJ-MM-TT.sqlite` = letzte Session in der App. Gibt es den Namen schon, wird `_2`, `_3` … angehängt – nie überschrieben. |
| 5 | Prio | **soll** (Nutzer, 13.11.2026) |
| 6 | Welche Sessions | nur **beendete** Sessions (siehe `DATENMODELL.md` R1.4 [Änderung M2]); eine laufende Session wird im Bericht als „läuft noch“ gemeldet |

## [Änderung M2] Entscheidungen des Nutzers (15.11.2026, zweite Fragenrunde)
| # | Punkt | Entscheid |
|---|---|---|
| 7 | Abnahme | automatische Tests mit `testdaten/` **und** Probelauf am PC mit dem Handy: Doppelklick schreibt nur in eine **Kopie** der echten Excel (`Sicherungen/Probe/`), der Nutzer prüft die Kopie in Excel. Die echte Excel bleibt bis WP2.7 unberührt. Test-Session und Testgeräte hat der Nutzer am Handy gelöscht. |
| 8 | Muskelgruppe | **[Änderung M2] Excel-Format:** Tab Geräte bekommt die Spalte **K „Muskelgruppe“**. Die Rückübertragung füllt sie bei neuen Geräten; das Umwandlungsskript liest sie (vor der Zuordnung über die Entscheidungsdatei). Mehrere Haupt- und Hilfsmuskelgruppen pro Gerät → Backlog I-24. |
| 9 | Assistiert in lbs | **bleibt erlaubt.** Das Körpergewicht wird im Hintergrund in die Eingabeeinheit umgerechnet, die Unterstützung abgezogen; das effektive Trainingsgewicht steht in beiden Einheiten (Spalten E und F). Die Auto-Notiz nennt die Einheit der Eingabe, das Umwandlungsskript liest beides. |
| 10 | Notizen | Auto-Notiz zuerst, eigene Notiz danach, getrennt mit „; “ (z. B. „Eingabe: 70 lbs; Sitz 4“) |
| 11 | Neue Geräte im Tab Geräte | Spalten wie bisher + K; assistiert → Notiz „assistiertes Gerät - Gewicht = Körpergewicht minus Eingabewert“, links/rechts → Notiz „links/rechts getrennt“; bestehende Geräte unverändert |
| 12 | Bericht | im Fenster und als Datei `Sicherungen/Rueckuebertragung_JJJJ-MM-TT.txt` (nie im Repository); nennt auch Geräte, die nur in der App geändert wurden. **Jeder Abbruch erklärt, warum, und was zu tun ist**; das Fenster bleibt offen, bis eine Taste gedrückt wird. |

## Ablauf (Weg A)
1. Handy per USB verbunden und entsperrt; am PC `Rueckuebertragung.bat` doppelklicken.
2. Das Skript holt eine **Kopie der App-Datenbank** vom Handy (adb, Debug-Version) und legt sie lokal ab – selbst schon eine vollständige Sicherung. Nie im Repository.
3. **Sicherungskopie der Excel** vor jedem Schreiben; Sicherungen werden nie gelöscht oder überschrieben.
4. **Vorschau** („2 neue Sessions, 38 Sätze: … Übertragen? J/N“), erst nach „J“ wird geschrieben.
5. Bericht: übertragen / schon vorhanden / abweichend (nicht übertragen).

## Format im Tab Log (eine Zeile pro Satz)
Datum (Text `JJJJ-MM-TT`), Ort, Gerät (Kürzel; bei links/rechts `C3-links` / `C3-rechts`), Satz-Nr., Gewicht (kg), Gewicht (lbs), Einheit (Eingabe), Wiederholungen, Volumen (Formel `E*H`), RPE (leer), Notiz.
- Eingabe fett, berechneter Wert grau kursiv – wie bisher.
- Auto-Notizen wie bisher: „Eingabe: 70 lbs“ bei lbs-Eingaben, „assistiert: KG - X kg Eingabe“ bei assistierten Geräten. So bleibt die Excel jederzeit wieder importierbar.
- **[Änderung M2] 15.11.:** Assistiert mit lbs-Eingabe: „assistiert: 80 kg - 20 lbs Eingabe“ (Körpergewicht immer in kg, Eingabe mit ihrer Einheit); E/F = effektives Gewicht in kg/lbs, G = lbs, F fett. Die bisherige Form „assistiert: 80 - 40 kg Eingabe“ gilt weiter.
- **[Änderung M2] 15.11.:** Tab Geräte, Spalte K „Muskelgruppe“ (Überschrift fett wie die anderen). Bestehende Geräte bekommen keinen Eintrag in K (bestehende Zeilen bleiben unverändert); einzige Änderung an einer bestehenden Zeile ist die neue Überschrift K1.
- Geänderte Geräteangaben (z. B. Datenpflege I-19) werden **nicht** zurückgeschrieben – bestehende Zeilen bleiben unverändert.

## Erkennung bereits übertragener Sessions
- Eine Session gilt als übertragen, wenn das Log schon Zeilen mit **gleichem Datum + Ort** hat. Die Excel ist selbst der Nachweis; in der App wird nichts vermerkt.
- Weicht eine bereits übertragene Session ab (z. B. nachträglich in der App korrigiert), wird **nichts geschrieben**, nur im Bericht gemeldet.
- Bekannte Grenze: Wird eine Session nach der Rückübertragung am selben Tag wieder aufgenommen und ergänzt, fehlen die neuen Sätze in der Excel; der Bericht meldet die Session als abweichend.
- **[Änderung M2] 14.11.:** Wird eine schon übertragene Session in der App korrigiert oder gelöscht, bleibt sie in der Excel unverändert; der Bericht meldet „abweichend“ bzw. „in der Excel, in der App gelöscht“ (Nutzer OK).

## Kleinere technische Entscheide (Vorschlag)
- Nur die neuen Zeilen werden in die Datei geschrieben; alles andere bleibt Byte für Byte gleich (automatischer Test prüft das).
- Ist die Excel gerade in Excel geöffnet, bricht das Skript ab.
- Umsetzung in Dart neben dem Umwandlungsskript (`app/tool/`), nutzt dieselben Tabellen und denselben Excel-Leser.
- Ordner `Sicherungen/` neben der Excel, zusätzlich ausdrücklich in `.gitignore`.
- Reihenfolge: zuerst nur mit `testdaten/`, erst danach mit der echten Excel (WP2.7).
