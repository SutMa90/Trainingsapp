# Glossar

Begriffe, wie sie in App, Doku und Code verwendet werden. Neue Begriffe werden laufend ergänzt.

| Begriff | Bedeutung |
|---|---|
| **Gymi** | Name der Trainings-App (gesprochen wie „Jimmy“), seit 14.11.2026. Nur Anzeigename; die interne Android-Kennung `com.sutma90.trainingsapp` bleibt. |
| **Standort** | Studio, in dem trainiert wird (z. B. Dielsdorf, Grüze). Eigene Tabelle, erweiterbar. |
| **Gerät** | Eine Übung an einem Standort, eindeutig über Standort + Kürzel. Ein physisches Gerät mit zwei Übungen sind zwei Geräte (R2.2). |
| **Kürzel** | Kurzname eines Geräts am Standort, z. B. `A4`. Gleiches Kürzel an anderem Standort = anderes Gerät. |
| **Doppel-Kürzel** | Zwei Kürzel für dieselbe Übung am selben Standort, die nur wegen der Einheit getrennt geführt wurden (z. B. `A4` / `A4.1`). Werden beim Import zusammengeführt (R2.1). |
| **Session** | Ein Trainingsbesuch: Datum, Standort, Körpergewicht des Tages. |
| **Satz** | Ein Satz an einem Gerät: Satz-Nr., Seite, Wiederholungen, Eingabewert + Eingabeeinheit, Gewicht kg, Notiz. |
| **Eingabewert / Eingabeeinheit** | Was tatsächlich eingegeben wurde, z. B. `70` + `lbs`. Bleibt pro Satz unverändert erhalten. |
| **Gewicht kg** | Intern gespeichertes Gewicht in kg, berechnet aus dem Eingabewert (1 lbs = 0,4536 kg); bei assistierten Geräten Körpergewicht − Eingabe. |
| **Vorgabe-Einheit** | Einheit eines Geräts, mit der neue Sätze vorbelegt werden. Umschaltbar, ändert alte Sätze nicht. |
| **assistiert** | Geräteeigenschaft: Das Gerät nimmt Gewicht ab (z. B. assistierte Klimmzüge). Effektives Gewicht = Körpergewicht − Eingabe. |
| **links/rechts getrennt** | Geräteeigenschaft: Sätze werden pro Seite (L/R) gezählt. |
| **Muskelgruppe** | Hauptmuskelgruppe eines Geräts aus einer erweiterbaren Liste (R2.4). |
| **Umwandlungsskript** | Einmaliges Programm auf dem PC, das die Trainings-Excel in die Startdatenbank umwandelt. Nicht Teil der App. |
| **Startdatenbank** | Vom Umwandlungsskript erzeugte Datenbankdatei, die die App beim allerersten Start übernimmt. Nie im Repository. |
| **Prüfbericht** | Ausgabe des Umwandlungsskripts: Zählungen, Fehler (nicht importiert) und Warnungen (importiert, aber auffällig). |
| **Fehler / Warnung** (Import) | *Fehler:* Zeile ist nicht eindeutig und wird **nicht** importiert. *Warnung:* Zeile wird importiert, ist aber auffällig und wird gemeldet. |
| **Entscheidungsdatei** | Datei mit den Entscheidungen des Nutzers zu gemeldeten Fällen (z. B. Doppel-Kürzel). Für Testdaten im Repo, für echte Daten nur lokal. |
| **Testdaten** | Synthetische Excel `testdaten/Testlog.xlsx` mit erfundenen Werten und allen bekannten Sonderfällen; Grundlage der automatischen Tests. |
| **Stichprobe** | Session, die Satz für Satz zwischen Excel und App verglichen wird (Abnahme M1). |
| **Rückübertragung** | Skript auf dem PC, das in der App erfasste Sessions im bisherigen Format in die Excel ergänzt (Datensicherung, I-21). Bestehende Zeilen bleiben unverändert. |
| **Sicherungskopie** | Kopie der Excel bzw. der App-Datenbank, die vor jedem Schreiben angelegt und nie gelöscht wird. Der Dateiname trägt das Datum der letzten Trainings-Session. |
| **Probelauf** | Rückübertragung, die nur zeigt, was ergänzt würde, ohne zu schreiben. |
| **Stichtag / Umstieg** | Moment, ab dem die App die Quelle ist: letzter Import aus der Excel, danach nie mehr deinstallieren. |
