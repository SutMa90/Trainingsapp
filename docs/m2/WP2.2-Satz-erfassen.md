# WP2.2 – Satz erfassen (F5, F6)

Stand: 13.11.2026 · Status: ✅ abgenommen (0.2.3)

**Abnahmekriterium:** Tests: Satz-Nr. pro Gerät/Seite, kg aus lbs, assistiert = Körpergewicht − Eingabe, Umschalten ändert die Vorgabe, alte Sätze unverändert; am Handy: Kachel → Speichern = 2 Taps.

Grundlage: `DATENMODELL.md` R1.5, R1.6, R2.1, R2.5, R2.7 – keine Änderung am Datenmodell.

## Ablauf
1. In der laufenden Session stehen oben die **Gerätekacheln** des Standorts. Kacheln mit Sätzen von heute sind farbig und zeigen die Anzahl („2 ✓“).
2. Kachel antippen → **Erfassungsfenster**: Wdh und Gewicht sind mit den letzten Werten des Geräts vorbefüllt, Einheit = Vorgabe des Geräts.
3. **„Satz speichern“** → Bestätigung „✓ Satz 1 gespeichert“. Das Fenster bleibt offen, die Werte bleiben stehen → der nächste Satz ist **1 Tap**.
4. Wegwischen oder daneben tippen schliesst das Fenster. Unten in der Session stehen alle Sätze von heute, neueste zuerst.

## Kleinere technische Entscheide (Vorschlag, umgesetzt)
- **Kacheln** sortiert nach Kürzel „natürlich“ (A2 vor A10). Eine Reihenfolge nach Muskelgruppen bleibt Backlog I-11.
- **Fenster bleibt nach dem Speichern offen** (schneller bei mehreren Sätzen). Alternative auf Wunsch: Fenster schliesst nach jedem Satz.
- **Vorbefüllung** = letzter Satz des Geräts, egal aus welcher Session. War er in der anderen Einheit erfasst, wird er umgerechnet (1 Nachkommastelle) und mit „letzter Wert umgerechnet“ markiert. Ohne frühere Sätze bleiben die Felder leer.
- **kg/lbs-Schalter** rechnet den eingetragenen Wert um. Die neue Einheit wird beim Speichern die Vorgabe des Geräts (R2.1); der Hinweis „wird neue Vorgabe des Geräts“ zeigt das vorher an.
- **Unter den Feldern** steht die Umrechnung „= xx kg, yy lbs“ (R1.6), bei assistierten Geräten „effektiv = Körpergewicht − x kg“.
- **Antippen eines Zahlenfelds** markiert den Wert; Tippen ersetzt ihn direkt. Gewicht mit höchstens 1 Nachkommastelle, Komma oder Punkt (R2.5).
- **Links/rechts getrennt:** Auswahl Links/Rechts im Fenster, Start mit Links; nach dem Speichern wird die andere Seite vorgeschlagen. Satz-Nr. zählt pro Seite. Hat eine Seite noch keinen Wert, wird der letzte Wert der anderen Seite vorgeschlagen.
- **Assistiert ohne Körpergewicht** in der Session: Die App fragt beim Speichern danach und trägt es bei der Session ein.
- **Notiz** optional, wird nach dem Speichern geleert.
- Neue Geräte anlegen folgt in WP2.5; ein Standort ohne Geräte zeigt einen Hinweis.

## Aufbau
| Datei | Inhalt |
|---|---|
| `app/lib/data/db/satz_logik.dart` | Satz speichern, Satz-Nr., Vorbefüllung, Kacheln, Körpergewicht nachtragen |
| `app/lib/ui/satz_erfassen.dart` | Erfassungsfenster |
| `app/lib/ui/laufende_session.dart` | Kacheln + Sätze von heute |
| `app/lib/ui/eingabe_dialog.dart` | gemeinsamer Eingabedialog (Standort, Körpergewicht) |
| `app/test/satz_test.dart` | 9 Tests der Regeln |
| `app/test/satz_ui_test.dart` | ganzer Ablauf in der Oberfläche |

## Ergebnis
- `flutter test`: 43 von 43 grün (Zeitlimit pro Test). `flutter analyze`: keine Befunde. Android-Debug-Build erfolgreich.
- Der Oberflächentest fand einen Fehler im Eingabedialog (Feld zu früh aufgeräumt), der auch den Dialog „Neuer Standort“ aus WP2.1 betraf – behoben.
- Handy 0.2.2 (13.11.): Nutzer fand, dass die Android-Tasten unten den Speicherknopf beim ersten Satz eines Geräts teilweise verdecken und die Satzliste im Fenster überdecken; zusätzlich war der Inhalt farbiger Kacheln abgeschnitten.
  Ursache: Das Fenster liess unten keinen Platz für die Android-Tasten; der automatische Test lief mit einem grösseren Bildschirm ohne Android-Tasten.

## [Änderung 0.2.3] Korrekturen nach dem Handy-Test
- **Speicherknopf fest am unteren Rand** des Fensters, immer oberhalb der Android-Tasten bzw. der Tastatur; nur der Inhalt darüber scrollt.
- **✕ oben rechts** schliesst das Fenster (bei grosser Schrift ist das Fenster so hoch, dass „daneben tippen“ nicht mehr geht).
- **Kacheln:** Anzahl „2 ✓“ als Abzeichen oben rechts; Kürzel und Funktion werden bei Platzmangel verkleinert statt abgeschnitten.
- **Satzliste:** Gewicht/Umrechnung rechts bricht bei grosser Schrift um.
- **Test** simuliert jetzt das Handy des Nutzers (360 × 780, Android-Tasten, Schrift 130 %), prüft, dass der Speicherknopf beim ersten Satz frei liegt, und schlägt bei abgeschnittenem Inhalt fehl. 43 von 43 grün.
- Handy 0.2.3 (13.11.): Speicherknopf frei, ✕ funktioniert, Kacheln vollständig; Nutzer: „jetzt sieht alles gut aus“. ✅
