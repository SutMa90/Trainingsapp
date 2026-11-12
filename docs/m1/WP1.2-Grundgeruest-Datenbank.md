# WP1.2 – Flutter-Grundgerüst und Datenbank

Stand: 12.11.2026 · Status: ✅ abgenommen

**Abnahmekriterium:** App startet auf dem Handy; automatischer Test schreibt in alle 5 Tabellen und liest zurück; 9 Start-Muskelgruppen vorhanden.

## Entscheidungen (vom Nutzer freigegeben 12.11.2026)
- **Datenbank-Paket: drift** – typsichere Tabellen in Dart, Prüfung beim Bauen, eingebaute Migrationen, Live-Abfragen (für F8 in M2).
- **Umwandlungsskript in Dart**, nutzt dieselben Tabellendefinitionen (`lib/data/db/`) wie die App.
- **Ordnerstruktur:** Flutter-App in `app/`, Skript in `app/tool/import_excel/`, Startdatenbank in `app/assets/db/` (nicht im Repo).

## Kleinere technische Entscheidungen (Vorschlag, umgesetzt)
- **Android-Paketname** `com.sutma90.trainingsapp` (aus dem GitHub-Namen abgeleitet).
- **Datum der Session** als Text `JJJJ-MM-TT` – ein Kalendertag ohne Uhrzeit, keine Zeitzonen-Effekte.
- **Wiederholungen** als ganze Zahl; **Gewichte** (Eingabewert, kg) als Kommazahl mit voller Genauigkeit, gerundet wird nur in der Anzeige.
- **Reihenfolge der Sätze** = Reihenfolge der internen Nummer (`id`); kein eigenes Feld nötig.
- **Einheit und Seite** als feste Werte (`kg`/`lbs`, `L`/`R`) gespeichert.
- **Fremdschlüssel aktiv:** ein Satz kann nur auf ein existierendes Gerät und eine existierende Session zeigen; Löschen einer Session löscht ihre Sätze mit.
- **Kein Zusatzpaket für Zustandsverwaltung** in M1 – die Live-Abfragen von drift reichen.
- Der von drift erzeugte Code (`datenbank.g.dart`) liegt im Repository, damit die App ohne Generatorlauf baut.

## Aufbau
| Datei | Inhalt |
|---|---|
| `app/lib/domain/einheiten.dart` | Einheit, Seite, Umrechnung 1 lbs = 0,4536 kg, Gewicht bei assistierten Geräten |
| `app/lib/data/db/tabellen.dart` | Tabellen Standorte, Muskelgruppen, Geraete, Sessions, Saetze (gemäss DATENMODELL) |
| `app/lib/data/db/datenbank.dart` | Datenbank, Start-Muskelgruppen, Abfragen für Session-Liste und Satz-Liste |
| `app/lib/data/db/verbindung.dart` | Öffnen der Datenbankdatei auf dem Handy |
| `app/lib/ui/` | Session-Liste (Kontrollansicht), Anzeigeformate |
| `app/test/datenbank_test.dart` | automatische Tests (5 Stück) |

## Ergebnis
- `flutter test`: 5 von 5 Tests grün (alle Tabellen, Eindeutigkeit Standort + Kürzel, Fremdschlüssel, Umrechnung, 9 Muskelgruppen).
- `flutter analyze`: keine Befunde.
- Android-Debug-Build erfolgreich.
- Handy (Samsung, Android): App installiert und gestartet, zeigt „Noch keine Sessions. Die Datenbank ist bereit.“; Datenbankdatei vom Handy enthält die 9 Start-Muskelgruppen.
