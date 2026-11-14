# WP2.4 – Sätze korrigieren und löschen (F8), Session löschen, App-Version

Stand: 14.11.2026 · Status: ✅ abgenommen (0.2.5)

**Abnahmekriterium:** Satz ändern und löschen am Handy; nach dem Löschen Satz-Nr. lückenlos (R2.7); [Änderung M2] Test-Session löschen am Handy, importierte Session nicht löschbar; Liste zeigt App-Version bzw. „imp“; Tests grün.

## Entscheidungen des Nutzers (14.11.2026)
| # | Punkt | Entscheid |
|---|---|---|
| 1 | App-Version pro Session | neues Feld (DB-Version 3) → `DATENMODELL.md` R1.4 [Änderung M2]; Version beim Anlegen; leer = importiert, Anzeige „imp“; nicht in die Excel |
| 2 | Prio App-Version | **soll**, zumindest in der Testphase |
| 3 | Session löschen | **muss**; Rückfrage mit Datum, Ort, Anzahl Sätze; endgültig |
| 4 | Welche Sessions | nur von der App erzeugte; **importierte geschützt** – bis auf Widerruf |
| 5 | Wo korrigieren | laufende Session und Sessions **von heute** |
| 6 | Rückübertragung | Korrekturen/Löschungen nach der Übertragung werden nicht in die Excel geschrieben, nur gemeldet → `WP2.6` |

## Bedienung
- **Satz korrigieren:** In der laufenden Session (Liste unten) oder im Erfassungsfenster („Heute an diesem Gerät“, mit ✎) einen Satz antippen → „Satz bearbeiten“: Wdh, Gewicht, Einheit, Seite (L/R), Notiz → „Änderung speichern“.
- **Satz löschen:** im selben Fenster „Satz löschen“ → Rückfrage → die übrigen Sätze werden neu nummeriert.
- **Session löschen:** in der laufenden Session oder in der Session-Ansicht oben rechts ⋮ → „Session löschen“ → Rückfrage „Endgültig löschen?“. Bei importierten Sessions gibt es das Menü nicht.
- **App-Version:** Session-Liste „Grüze · 0.2.5“ bzw. „Dielsdorf · imp“; Session-Ansicht „… · App 0.2.5“.

## Kleinere technische Entscheide (Vorschlag, umgesetzt)
- **Einheit beim Korrigieren wird nicht umgerechnet** (anders als beim Erfassen): meist war die Zahl richtig und nur die Einheit falsch. Hinweis „Zahl bleibt, nur die Einheit ändert“. Die neue Einheit wird – wie beim Erfassen – Vorgabe des Geräts (R2.1).
- Gewicht kg wird nach jeder Korrektur neu berechnet (assistiert: mit dem Körpergewicht der Session).
- Wird die Seite eines Satzes geändert, vergibt die App die Satz-Nr. pro Seite neu.
- Sessions, die schon vor 0.2.5 auf dem Handy lagen (Test-Session vom 13.11.), zeigen „imp“, weil ihre Version nicht gespeichert wurde; sie werden beim Umstieg ersetzt.
- Datenbank-Umstellung 2 → 3 automatisch beim ersten Start; ein Test prüft, dass eine laufende Session dabei laufend bleibt.

## Aufbau
| Datei | Inhalt |
|---|---|
| `app/lib/data/db/tabellen.dart`, `datenbank.dart` | Feld `appVersion`, Version 3, Umstellungsschritt |
| `app/lib/data/db/session_logik.dart` | Version beim Anlegen, `loescheSession` (importierte geschützt) |
| `app/lib/data/db/satz_logik.dart` | `aendereSatz`, `loescheSatz`, `nummeriereNeu` (nur Sessions von heute) |
| `app/lib/ui/satz_bearbeiten.dart` | Fenster „Satz bearbeiten“ |
| `app/lib/ui/session_loeschen.dart` | Rückfrage „Session löschen“, Anzeige Version / „imp“ |
| `app/test/korrektur_test.dart` | 7 Tests der Regeln |
| `app/test/korrektur_ui_test.dart` | ganzer Ablauf in der Oberfläche |
| `app/test/session_test.dart` | Umstellung 1 → 3 und 2 → 3 |

## Ergebnis
- `flutter test`: 60 von 60 grün (Zeitlimit pro Test). `flutter analyze`: keine Befunde. Android-Debug-Build erfolgreich.
- Handy 0.2.5 (14.11.): DB-Umstellung 2 → 3 ohne Verlust; Satz ändern/löschen, Session löschen, „imp“-Schutz vom Nutzer geprüft – „alles passt“. ✅
- Befund: Die beiden Test-Sessions vom 13.11. (vor 0.2.5 erzeugt) zeigen „imp“ und sind dadurch geschützt. Nutzerauftrag 14.11.: vor der nächsten Installation direkt in der Handy-Datenbank löschen (mit Sicherung vorher).
