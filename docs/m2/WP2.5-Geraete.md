# WP2.5 – Geräteverwaltung und neues Gerät (F3), Datenpflege I-19

Stand: 14.11.2026 · Status: 🔄 gebaut (0.2.6), Abnahme am Handy offen

**Abnahmekriterium:** Neues Gerät in ≤ 30 s angelegt und sofort als Kachel da; der Nutzer hat T1/T2/C3 (Muskelgruppe), D1 Dielsdorf (Vorgabe-Einheit) und B3/C1 Grüze (Funktion) selbst in der App nachgetragen.

Grundlage: `DATENMODELL.md` R1.2, R1.3, R1.6, R2.2, R2.4. Keine neue Datenbank-Version: Die Tabelle Geräte hat schon alle Felder.

## Entscheidungen des Nutzers (14.11.2026, Fragenrunde: alle Vorschläge OK)
| # | Punkt | Entscheid |
|---|---|---|
| 1 | Wo erreichbar | Startseite ⋮ → „Geräte“: Standort wählen, Liste nach Kürzel, Gerät antippen = bearbeiten; zusätzlich **langer Druck auf eine Kachel** in der laufenden Session = Gerät bearbeiten |
| 2 | Neues Gerät in der Session | letzte Kachel **„＋ Neu“**; nach dem Speichern ist die Kachel sofort da und das Fenster für den ersten Satz öffnet sich direkt |
| 3 | Felder | sichtbar: Kürzel (Pflicht, pro Standort eindeutig), Funktion, Muskelgruppe (Liste + „Neue“, R2.4), Einheit (Vorgabe kg), assistiert, links/rechts getrennt; unter „Mehr“: Hersteller, Modell, Einstellung 1–3, Notiz. Vorschläge: Hersteller von allen Standorten, Modell nur zum gewählten Hersteller (R2.2) |
| 4 | Kürzel umbenennen | nur, solange das Gerät **keine Sätze** hat (sonst zwei Geräte nach Rückübertragung + Import) → `DATENMODELL.md` R1.6 [Änderung M2] |
| 5 | Löschen | nur Geräte **ohne Sätze**, mit Rückfrage. „Ausblenden“ braucht ein neues Feld → Backlog I-23 |
| 6 | assistiert, L/R, Einheit bei Geräten mit Sätzen | änderbar, gilt nur für neue Sätze; alte Sätze bleiben unverändert (Hinweis im Formular) |
| 7 | Datenpflege I-19 und Umstieg | jetzt am Handy nachtragen (Abnahme), nach dem Umstieg nochmals → `WP2.7-Umstieg.md` Schritt 3a |
| – | Prio | Kurzformular mit Vorschlägen und Bearbeiten **muss**, langer Druck **soll**, Löschen **soll**, Ausblenden **Backlog** |
| – | Name | [Änderung M2] Die App heisst **Gymi**: Anzeigename am Handy, App-Titel, Titel der Startseite. Android-Kennung, Datenbank- und Ordnernamen bleiben |

## Bedienung
- **Neues Gerät im Gym:** laufende Session → Kachel „＋ Neu“ → Kürzel, Funktion, Muskelgruppe antippen → „Gerät speichern“ → das Erfassungsfenster des neuen Geräts ist offen.
- **Gerät bearbeiten:** lange auf die Kachel drücken, oder Startseite ⋮ → „Geräte“ → Gerät antippen → „Änderung speichern“.
- **Geräteliste:** markiert fehlende Angaben rot („Funktion fehlt“, „Muskelgruppe fehlt“) – hilft bei der Datenpflege. Unten rechts „Neues Gerät“ für den gewählten Standort.
- **Gerät löschen:** im Formular oben rechts 🗑 (nur sichtbar, wenn das Gerät keine Sätze hat).

## Kleinere technische Entscheide (Vorschlag, umgesetzt)
- **Kürzel** wird ohne Leerzeichen aussen und in Grossbuchstaben gespeichert (`x9` → `X9`); „gibt es hier schon“ gilt unabhängig von Gross-/Kleinschreibung.
- **Leere Felder** werden als „nicht angegeben“ gespeichert, nicht als leerer Text.
- **Vorschläge** ohne Doppelte: gleiche Angabe in anderer Schreibweise (Gross-/Kleinschreibung, Leerzeichen) zählt als eine; angezeigt wird die häufigste Schreibweise. Ohne Eingabe erscheinen alle Vorschläge, beim Tippen die passenden.
- **Neue Muskelgruppe** kommt ans Ende der Liste; gibt es den Namen schon, wird die bestehende gewählt.
- **Muskelgruppe** als Auswahlknöpfe (ein Tipp, alles sichtbar) statt Ausklappliste; nochmals antippen hebt die Auswahl auf.
- **Formular als eigene Seite** mit dem Speicherknopf fest unten, über Tastatur und Android-Tasten.
- **Vorauswahl Standort** in der Geräteverwaltung: Standort der laufenden Session, sonst der zuletzt besuchte.

## Aufbau
| Datei | Inhalt |
|---|---|
| `app/lib/data/db/geraete_logik.dart` | anlegen, ändern (Kürzel gesperrt bei Sätzen), löschen (nur ohne Sätze), Vorschläge Hersteller/Modell, Muskelgruppe ergänzen, Geräteliste |
| `app/lib/ui/geraet_formular.dart` | Kurzformular „Neues Gerät“ / „Gerät bearbeiten“, Feld mit Vorschlägen |
| `app/lib/ui/geraete_verwaltung.dart` | Geräteverwaltung pro Standort |
| `app/lib/ui/laufende_session.dart` | Kachel „＋ Neu“, langer Druck = bearbeiten |
| `app/lib/ui/session_liste.dart` | Menü ⋮ → „Geräte“; Titel „Gymi“ |
| `app/test/geraete_test.dart` | 9 Tests der Regeln |
| `app/test/geraete_ui_test.dart` | ganzer Ablauf in der Oberfläche (Handy-Simulation) |

## Ergebnis
- `flutter test`: 70 von 70 grün (Zeitlimit pro Test, Handy-Simulation 360 × 780 mit Android-Tasten und Schrift 130 %, verfehlte Tipps lassen Tests scheitern). `flutter analyze`: keine Befunde.
- Der Oberflächentest fand, dass Felder weiter unten im Formular bei grosser Schrift noch nicht aufgebaut waren (Liste baut nur Sichtbares) – Formular baut jetzt alle Felder.
- Handy 0.2.6: offen.
