HEINRICHOS_KCD2 – P02J-VORBEREITUNG 01 / ASSET-ORDNUNG
Stand: 2026-06-28 07:30:04

Zweck:
Diese Kopie bereitet P02J vor. Sie integriert noch keine App-Logik.
Keine f116_data.js-Änderung, keine Cheats, keine IDs, keine Datenlogik.

Prinzip:
- P02I bleibt als Ausgangsbasis erhalten.
- Bestehende P02I-Pfade in app/02_ASSETS/ui/v11_final/ wurden NICHT gelöscht.
- Zusätzlich wurden saubere Zielordner erstellt und mit sortierten Kopien befüllt.
- CHARGE01–05 wurden nur aus echten transparenten Einzel-PNGs befüllt.
- Kontaktbögen, Previews, Dark/Parchment-Varianten wurden NICHT als App-Assets kopiert.

Zielstruktur:
02_ASSETS/ui/v11_final              = große finale UI-Bauteile / Panels / Header / Footer / Rahmen
02_ASSETS/ui/v11_controls           = Copy, Spoiler, Filter, Suchfeld, Buttons, Tabs, Scrollbars
02_ASSETS/ui/v11_runtime_light      = wiederholte Elemente: Cards, Rows, Nav-Buttons, Quickbuttons
02_ASSETS/icons/v11_categories      = Kategorie-/Navigations-/Subkategorie-Icons
02_ASSETS/icons/v11_quickaccess     = Schnellzugriff-Icons
02_ASSETS/icons/v11_status          = Status-/Warn-/Erfolg-/Fehler-/Locked-Icons
02_ASSETS/items/v11_objects         = größere Objekt-/Itembilder, falls nicht als Icon zugeordnet

Manifest:
app/05_NOTIZEN/P02J_ASSET_MANIFEST_01.csv
app/05_NOTIZEN/P02J_ASSET_MANIFEST_01.json

Zählung:
{
  "ui/v11_final": 22,
  "ui/v11_controls": 34,
  "ui/v11_runtime_light": 6,
  "icons/v11_status": 6,
  "icons/v11_categories": 36,
  "items/v11_objects": 1,
  "icons/v11_quickaccess": 21
}

Geschützte Dateien unverändert:
{
  "app/01_HTML/app.js": true,
  "app/01_HTML/f116_data.js": true,
  "app/01_HTML/index.html": true
}
