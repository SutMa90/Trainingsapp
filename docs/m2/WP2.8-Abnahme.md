# WP2.8 – Abnahme im Gym und Abschluss M2

Stand: 25.11.2026 · Status: 🔄 läuft (erstes echtes Training mit Gymi am 22.11.)

**Abnahmekriterium:** Echte Session ohne Chat erfasst; Satz mit Vorbefüllung ≤ 5 s (Stoppuhr: Kachel antippen bis gespeichert); Rückübertragung ergänzt in der echten Excel genau so viele Zeilen wie Sätze, Sicherung vorhanden, 2. Lauf ergänzt nichts; [Änderung M2] Datenpflege I-19 in den ersten echten Sessions vom Nutzer in der App nachgetragen; Zusammenfassung + Retrospektive in `ROADMAP.md`, Backlog durchgesehen.

Datenschutz: hier nur Befunde und Entscheidungen, keine Trainingswerte.

## Befunde aus dem Training

### 22.11.2026 (Dielsdorf) – hängender Tastaturbereich
- **Beobachtung (Screenshots des Nutzers):** In der laufenden Session endeten die Kacheln etwa in der Bildschirmmitte, darunter war nichts mehr zu sehen (Kachel „＋ Neu“ und Satzliste verdeckt), „Session beenden“ lag unter den Android-Tasten. Im Erfassungsfenster war „Satz speichern“ weit nach oben geschoben. Keine Tastatur sichtbar, kein Feld angewählt.
- **Ursache (sehr wahrscheinlich):** Android meldete der App unten noch einen Tastaturbereich, obwohl die Tastatur zu war; beide Bilder enden auf derselben Höhe. Meldet Android eine Tastatur, entfällt auch der Platz für die Android-Tasten – darum rutschte „Session beenden“ darunter. Auslöser vermutlich Bildschirm aus oder App-Wechsel (Spotify) bei offener Tastatur; noch nicht bestätigt, der Nutzer beobachtet weiter.
- **[Änderung 0.2.11] Korrektur (Vorschlag, vom Nutzer gewünscht):** Tastatur-Wächter für die ganze App (`app/lib/ui/tastatur_waechter.dart`):
  - Gymi geht in den Hintergrund → Feldauswahl aufheben, Tastatur schliessen.
  - Gymi kommt zurück → Tastatur schliessen, wenn kein Feld angewählt ist (Android meldet den Bereich dann neu).
  - Tipp neben ein Eingabefeld schliesst die Tastatur; Knöpfe und Felder reagieren wie bisher.
- **Tests:** `app/test/tastatur_test.dart` (Hintergrund/Rückkehr, Tipp daneben, Knopf weiterhin auslösbar; Handy-Simulation). `flutter test`: 82 von 82 grün, `flutter analyze` ohne Befunde.
- **Grenze:** Der Fehler entsteht in Android selbst; ob die Korrektur ihn ganz verhindert, zeigt erst der Test am Handy im Training.
