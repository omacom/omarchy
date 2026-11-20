# FAQ

### Wie wechsle ich zwischen Tastaturlayouts?

Bearbeite deine Datei `~/.config/hypr/input.lua` und füge dies hinzu, um mit `Left Alt + Right Alt` zwischen Layouts zu wechseln:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Die Leiste zeigt automatisch dein aktuelles Tastaturlayout an, sobald du mehrere Layouts konfiguriert hast (und du kannst auch darauf klicken, um zu wechseln).

### Wie ändere ich das Uhrformat auf 12 Stunden?

Klicke mit der rechten Maustaste auf die Uhr in der Leiste, um durch die gängigen Formate zu blättern, einschließlich der 12-Stunden-Formate. Du kannst das Format auch direkt festlegen:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dadurch wird Sonntag 10:55 AM angezeigt.

### Wie ändere ich meine Zeitzone?

Führe im Omarchy-Menü _Einrichten > Region > Zeitzone_ aus und wähle aus der Liste aus. Wenn die Zeitzone stimmt, die Uhr selbst aber abweicht, startet _Aktualisieren > Zeit_ die Zeitsynchronisierung für dich neu.

### Wie ändere ich meinen DNS, teile mein Wi-Fi oder prüfe meine Verbindungsgeschwindigkeit?

Das findest du alles unter [Netzwerk](35-networking.md).

### Wie prüfe ich, wie schnell mein Laufwerk ist?

_Auslöser > Geschwindigkeitstest > Laufwerksgeschwindigkeitstest_ misst die Live-Lese- und Schreibgeschwindigkeit deines Laufwerks, oder `omarchy disk speedtest` aus dem Terminal.

### Wie füge ich einen Drucker hinzu?

Drucken ist sofort einsatzbereit eingerichtet und läuft, und du fügst jeden Drucker selbst über _Druckeinstellungen_ im App-Launcher hinzu (`Super + Space`).

Wähle _Hinzufügen_ und gib ihm einen Moment Zeit zum Suchen: Ein über USB angeschlossener Drucker und die meisten Netzwerkdrucker werden für dich gefunden. Wenn deiner nicht in der Liste ist, wähle _Netzwerkdrucker > Internet Printing Protocol (ipp)_ und gib seine Adresse ein — das eigene Display des Druckers oder seine Webseite sagt dir, welche das ist, normalerweise so etwas wie `192.168.1.50` mit einer Warteschlange von `ipp/print`. _Weiter_ bietet dir dann einen Treiber an, wobei ein moderner Drucker am besten mit dem treiberlosen Profil _IPP Everywhere_ funktioniert und ein älterer den eigenen Treiber des Modells will.

Klicke mit der rechten Maustaste auf einen Drucker und wähle _Als Standard festlegen_, um zu bestimmen, welchen deine Apps zuerst verwenden, und _Eigenschaften_, um Papierformat, Duplex und Qualität festzulegen.

Die automatische Erkennung, bei der Drucker im Netzwerk erscheinen, ohne hinzugefügt zu werden, ist vorübergehend ausgeschaltet, während sie überarbeitet wird, weshalb der erste Schritt oben dir überlassen bleibt, statt automatisch zu erfolgen. In eine PDF-Datei zu drucken funktioniert ganz ohne Drucker.

### Wie ändere ich, wo Screenshots oder Bildschirmaufnahmen gespeichert werden?

Gespeicherte Screenshots landen standardmäßig in `~/Pictures/Screenshots`. Um ein anderes Verzeichnis zu verwenden, füge dies zu einer Datei unter `~/.config/uwsm/env.d/` hinzu (wie `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Dasselbe kannst du für Bildschirmaufnahmen mit `OMARCHY_SCREENRECORD_DIR` machen.

Omasnap erstellt sein Screenshot-Verzeichnis automatisch. Erstelle das Verzeichnis für Bildschirmaufnahmen selbst und starte dann Omarchy neu, damit jede der beiden Umgebungsänderungen wirksam wird.

### Wie bekomme ich die Lautsprecher + Webcam an meinem Apple Studio Display zum Laufen?

Man sollte meinen, dass alles einfach durch Einstecken von USB C funktionieren sollte, aber leider ist das nicht der Fall. Die Lösung, die ich gefunden habe, damit es zuverlässig funktioniert, ist [das WJESOG DisplayPort + USB-A => USB-C Kabel](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Dann funktionieren Lautsprecher und Webcam einwandfrei.

Denk daran, dass du in Omarchy eine eingebaute Helligkeitssteuerung für die Apple Displays (sowohl Studio als auch XDR) über die normalen Helligkeitstasten der Tastatur hast.

### Wie werde ich die ganze zusätzliche Software los?

Wenn du Programme wie Obsidian oder LibreOffice oder den anderen vorinstallierten Kram nicht willst, kannst du ihn ganz einfach entfernen.

Führe _Entfernen > Paket_ aus, um jedes installierte Paket zu sehen. Dann kannst du mit Tab jedes Paket auswählen, das du entfernen möchtest, und mit Return damit beginnen, alles zu entfernen, was du ausgewählt hast.

Und mit _Entfernen > Web-App_ aus dem Omarchy-Menü kannst du alle vorinstallierten Web-Apps entfernen, die du nicht willst.

Oder führe _Entfernen > Vorinstallationen_ aus, um alle vorinstallierten Extras — Web-Apps, TUIs und optionale Anwendungen — in einem Rutsch zu entfernen. Die Tastenkürzel, mit denen sie gestartet wurden, verschwinden mit ihnen, sodass dir eine saubere Ausgangsbasis an Tastenbelegungen bleibt, die du in `~/.config/hypr/bindings.lua` mit deinen eigenen füllen kannst.

---

Bei Fehlern und kaputten Stellen siehe [Abschnitt zur Fehlerbehebung](45-troubleshooting.md).
