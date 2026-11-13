# Startdatenbank

Hier legt das Umwandlungsskript `startdb.sqlite` ab (`dart run tool/import_excel/main.dart` im Ordner `app/`).
Die Datei enthält persönliche Trainingsdaten und ist deshalb per `.gitignore` vom Repository ausgeschlossen.

Die App übernimmt sie beim **allerersten Start** als ihre Datenbank. Fehlt die Datei beim Bauen, startet die App leer.
