# WP2.6 – Rückübertragung App → Excel (Backlog I-21)

Stand: 15.11.2026 · Status: ✅ abgenommen (0.2.9, Probelauf auf einer Kopie)

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

## [Änderung M2] Umsetzung (15.11.2026)

### Bedienung (Probelauf, WP2.6)
1. Am Handy eine Session beenden (nur beendete Sessions werden übertragen); Gymi danach ganz schliessen.
2. Handy per USB verbinden und entsperren.
3. Im Projektordner **`Rueckuebertragung_Probe.bat`** doppelklicken.
4. Das Fenster zeigt die Vorschau; **J** + Enter überträgt, alles andere bricht ab.
5. Ergebnis: Kopie `Sicherungen/Probe/Krafttraining_Log_Probe_JJJJ-MM-TT.xlsx`, dazu Sicherungen und Bericht im selben Ordner. Die echte Excel bleibt unverändert.
- Die Doppelklick-Datei für die echte Excel (`Rueckuebertragung.bat`) folgt mit WP2.7.

### Abbrüche (immer mit Grund und „Was tun“, Excel unverändert)
Excel nicht gefunden · Excel in Excel geöffnet (auch kurz vor dem Schreiben nochmals geprüft) · adb fehlt · kein Handy / Zugriff nicht erlaubt / offline / mehrere Geräte · Gymi-Datenbank fehlt oder Gymi schreibt gerade · Kopie unvollständig oder beschädigt · Datenbank-Version passt nicht · Excel nicht lesbar oder ohne die nötigen Spalten · gemeinsame Excel-Formel in einer vorbereiteten Zeile · Prüfung nach dem Schreiben findet Unterschiede · Antwort nicht „J“. Unerwartete Fehler: Text an Claude weitergeben.

### Kleinere technische Entscheide (Vorschlag, umgesetzt)
- **Nur App-Sessions werden verglichen.** Importierte Sessions („imp“) stammen aus der Excel und werden übersprungen (der Import fasst z. B. A4.1 und A4 zusammen – ein Vergleich würde sonst überall „abweichend“ melden).
- **„Abweichend“** = gleiche Session (Datum + Ort) in der Excel, aber andere Sätze (Gerät, Satz-Nr., Einheit, Wdh, kg).
- **Neue Geräte:** alle Geräte der App, deren Standort + Kürzel im Tab Geräte fehlt – auch ohne Sätze.
- **Geräte nur in der App geändert:** Funktion, Hersteller, Modell, Vorgabe-Einheit, Einstellungen, assistiert; Muskelgruppe nur, wo die Excel in Spalte K schon eine hat.
- **Schreiben:** Text in den Tabellenblättern wird direkt eingesetzt (Zellen als Text, wie die bisherige Datei); kg/lbs mit 2 Stellen, Eingabe in ihrer Einheit fett, umgerechneter Wert grau kursiv (Formatierung von der letzten kg-Zeile übernommen); Volumen als Formel mit Wert.
- **Sicher ersetzen:** neue Datei zuerst als `….xlsx.neu`, prüfen (alle bisherigen Werte gleich, Anzahl neuer Zeilen stimmt), dann erst ersetzen.
- **Handy-Kopie:** zuerst in einen Arbeitsordner, Prüfung auf Vollständigkeit und Datenbank-Version, bevor sie geöffnet wird; die Sicherung in `Sicherungen/` bleibt unverändert.
- Umwandlungsskript: Spalte „Muskelgruppe“ hat Vorrang vor der Entscheidungsdatei; unbekannte Muskelgruppen werden angelegt; „links/rechts getrennt“ in der Geräte-Notiz markiert das Gerät. Mit der echten Excel weiterhin 276 Sätze, 13 Sessions, 31 Geräte, 0 Fehler.
- **App 0.2.9:** Bei assistierten Geräten zeigt das Erfassungsfenster „effektiv = 176,37 − 66,1 lbs = 50,02 kg, 110,27 lbs“ (Körpergewicht in der Eingabeeinheit, Ergebnis in beiden Einheiten).

### Aufbau
| Datei | Inhalt |
|---|---|
| `Rueckuebertragung_Probe.bat` | Doppelklick, Probelauf auf einer Kopie |
| `app/tool/rueckuebertragung/main.dart` | Ablauf: Handy-Kopie, Sicherungen, Vorschau, J/N, Schreiben, Bericht, Abbrüche |
| `app/tool/rueckuebertragung/abgleich.dart` | Was ist neu, schon da, abweichend; Zeilen im Excel-Format |
| `app/tool/rueckuebertragung/xlsx_schreiber.dart` | Zeilen einsetzen, Spalte K, Prüfung nach dem Schreiben |
| `app/tool/rueckuebertragung/dateien.dart` | Dateinamen der Sicherungen (nie überschreiben) |
| `app/tool/import_excel/…` | liest Spalte K, assistiert in lbs, L/R aus Geräte-Notiz |
| `app/test/rueckuebertragung_test.dart` | Abnahmetest mit `testdaten/` (7 Tests) |

### Ergebnis
- `flutter test`: 77 von 77 grün; `flutter analyze`: keine Befunde. Abnahmetest: 2 Sessions (lbs, assistiert kg + lbs, L/R, neues Gerät mit neuer Muskelgruppe, Notizen) → bestehende Zeilen byte-gleich, übrige Teile der Datei gleich, vorbereitete Zeilen gefüllt, erneuter Import = dieselben Sätze wie in der App (inkl. Körpergewicht), 2. Lauf ergänzt nichts, spätere Korrektur nur gemeldet.
- Am PC geprüft: Probelauf mit dem Handy (nichts zu übertragen), Schreiblauf mit Testdaten inkl. Sicherung, 2. Lauf, Abbruch bei geöffneter Excel.
- Probelauf durch den Nutzer (15.11., App 0.2.9): Test-Session am Handy erfasst, Doppelklick → Vorschau 1 Session mit 12 Sätzen und 1 neues Gerät → „J“ → Kopie in Excel geprüft; Nutzer: „Probelauf passt“. ✅
- Gegenprobe: Die Probe-Kopie lässt sich wieder importieren – 288 Sätze (276 + 12), 14 Sessions, 32 Geräte, 0 Fehler.
