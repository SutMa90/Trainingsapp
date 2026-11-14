/// Versionsnummer der App, sichtbar auf der Startseite.
///
/// Schema bis V1: `0.<Meilenstein>.<Testinstallation>`; `1.0.0` = V1 fertig.
/// Muss mit `version:` in `pubspec.yaml` übereinstimmen (ein Test prüft das).
/// Die Build-Nummer hinter dem `+` in `pubspec.yaml` steigt bei jeder
/// Installation, sonst lässt sich die App nicht „drüber“ installieren.
library;

const appVersion = '0.2.5';
