# WP1.3 – Kürzel-Bereinigung und Klärungsliste

Stand: 12.11.2026 · Status: ✅ abgeschlossen

**Abnahmekriterium:** Liste vom Nutzer bestätigt; Entscheidungen dokumentiert.

Grundlage: Analyse der echten Trainings-Excel (276 Log-Zeilen, 13 Sessions, 33 Geräte-Einträge) am 11.11.2026. Trainingswerte stehen hier bewusst nicht (öffentliches Repository).

## Entscheidungen des Nutzers (12.11.2026)

| # | Fall | Entscheid |
|---|---|---|
| 1 | Doppel-Kürzel in Grüze: **A4 + A4.1**, **A5 + A5.1** | beide zusammenführen; der kg/lbs-Schalter (R2.1) deckt die Einheit ab. A5/A5.1 trotz verschiedener Hersteller. → `DATENMODELL.md` R2.1 [Änderung M1] |
| 2 | Session 18.08. Grüze: lbs-Geräte als kg erfasst, Werte entsprechen lbs × 0,45 | **nicht anpassen** – „hier bauen wir nur die App“ |
| 3 | D1 Dielsdorf 22.08.: einmalig in lbs erfasst | **nicht anpassen**; Vorgabe-Einheit des Geräts bleibt wie im Tab Geräte |
| 4 | Muskelgruppe von T1, T2 (Dielsdorf) und C3 (Grüze) unbekannt | vorerst **leer** lassen |
| 5 | B3 und C1 Grüze ohne Funktion | Muskelgruppe **Rücken** bzw. **Core** (analog Dielsdorf); Funktion bleibt leer |
| 6 | Zuordnung Funktion → Muskelgruppe | wie vorgeschlagen (siehe `app/tool/import_excel/entscheidungen.json`) |
| 7 | Automatische Notizen („Eingabe: 70 lbs“, „assistiert: …“, „gleiches Gerät wie …“) | entfallen, wenn sie zu Eingabewert/Einheit passen; echte Notizen bleiben |

**Grundsatz daraus:** Das Umwandlungsskript verändert keine Trainingsdaten. Eingabewert und Eingabeeinheit werden 1:1 übernommen; Auffälliges wird im Prüfbericht gemeldet. Datenpflege (z. B. Muskelgruppen nachtragen, Vorgabe-Einheit D1 Dielsdorf) geschieht später in der App (→ Backlog I-19).

## Weitere Befunde (ohne Handlungsbedarf)
- 15 leere Zeilen am Ende des Logs (nur Formel) werden ignoriert.
- E2 Grüze wurde am 27.09. in der Funktion korrigiert; alte Sätze bleiben bei E2.
- Gleiche Kürzel an beiden Standorten sind verschiedene Geräte (z. B. E1/E2 mit vertauschter Funktion).
