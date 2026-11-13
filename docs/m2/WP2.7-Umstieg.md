# WP2.7 – Umstieg: App wird die Quelle

Stand: 13.11.2026 · Status: Plan abgestimmt, Umsetzung nach WP2.6

**Abnahmekriterium:** Sessions/Sätze in der App = Excel; Probelauf der Rückübertragung auf der echten Excel meldet 0 neue Sessions, Datei unverändert.

## Ausgangslage (13.11.2026)
- Führende Excel ist bis zum Stichtag der Chat-Download; eine Kopie mit Stand heute liegt als `Krafttraining_Log.xlsx` im Projektordner (nicht im Repo). Letzte Session darin: 11.11.
- Auf dem Handy: Stand M1-Import. Bis zum Stichtag sind Testeinträge am Handy erlaubt; sie werden beim Umstieg ersetzt. Deinstallieren ist bis dahin erlaubt.

## Ablauf
1. **Während WP2.1–2.6:** Tests am Handy mit der vorhandenen App-Datenbank (Wegwerf-Einträge).
2. **Stichtag** (vor dem ersten Gym-Training mit der App): Nutzer legt die aktuelle Excel als `Krafttraining_Log.xlsx` in den Projektordner. Umwandlungsskript → Prüfbericht → Nutzer entscheidet über neue Meldungen.
3. **Letzte Deinstallation**, Neuinstallation mit frischer Startdatenbank; Zählung Sessions/Sätze App = Excel.
4. **Probelauf** der Rückübertragung auf der echten Excel: muss „0 neue Sessions“ melden und nichts ändern.
5. **Ab dann:** Die App ist die Quelle, die Excel wird nur noch per Rückübertragung ergänzt. **App nie mehr deinstallieren** (löscht die Datenbank), Updates nur „drüber“ installieren.
   Fällt die App im Gym aus: Session wie früher in die Excel eintragen; die Rückübertragung erkennt Datum + Ort und legt nichts doppelt an.
6. Erste echte Gym-Session mit Rückübertragung = Abnahme M2 (WP2.8).
