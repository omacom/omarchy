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

Klicke mit der rechten Maustaste auf die Uhr in der Leiste, um durch die gängigen Formate zu wechseln, einschließlich der 12-Stunden-Formate. Du kannst das Format auch direkt festlegen:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dadurch wird Sonntag 10:55 AM angezeigt.

### Wie ändere ich meine Zeitzone?

Führe im Omarchy-Menü _Setup > Region > Timezone_ aus und wähle aus der Liste aus. Wenn die Zeitzone stimmt, aber die Uhr selbst abgewichen ist, startet _Update > Time_ die Zeitsynchronisierung für dich neu.

### Wie ändere ich meinen DNS, teile mein Wi-Fi oder prüfe meine Verbindungsgeschwindigkeit?

Das findest du alles unter [Netzwerk](35-networking.md).

### Wie prüfe ich, wie schnell meine Festplatte ist?

_Trigger > Speed Test > Disk Speed Test_ misst die Live-Lese- und Schreibgeschwindigkeit deiner Festplatte, oder `omarchy disk speedtest` vom Terminal aus.

### Wie füge ich einen Drucker hinzu?

Drucken ist sofort einsatzbereit eingerichtet und läuft, und du fügst jeden Drucker selbst über _Print Settings_ im App-Launcher (`Super + Alt + Space`) hinzu.

Wähle _Add_ und gib ihm einen Moment Zeit zum Suchen: Ein über USB angeschlossener Drucker und die meisten Netzwerkdrucker werden für dich gefunden. Wenn deiner nicht in der Liste ist, wähle _Network Printer > Internet Printing Protocol (ipp)_ und gib seine Adresse ein — das Display des Druckers selbst oder seine Webseite verrät dir, wie diese lautet, normalerweise so etwas wie `192.168.1.50` mit einer Warteschlange von `ipp/print`. _Forward_ bietet dann einen Treiber an, wobei ein moderner Drucker am besten mit dem treiberlosen Profil _IPP Everywhere_ funktioniert und ein älterer den eigenen Treiber des Modells möchte.

Klicke mit der rechten Maustaste auf einen Drucker und wähle _Set as Default_, um festzulegen, welchen deine Apps zuerst verwenden, und _Properties_, um Papiergröße, Duplex und Qualität festzulegen.

Die automatische Erkennung, bei der Drucker im Netzwerk erscheinen, ohne hinzugefügt zu werden, ist vorübergehend abgeschaltet, während sie überarbeitet wird, weshalb der erste Schritt oben deiner ist und nicht automatisch erfolgt. Das Drucken in eine PDF-Datei funktioniert ganz ohne Drucker.

### Wie ändere ich, wo Screenshots oder Bildschirmaufnahmen gespeichert werden?

Gespeicherte Screenshots landen standardmäßig in `~/Pictures/Screenshots`. Um ein anderes Verzeichnis zu verwenden, füge dies zu einer Datei unter `~/.config/uwsm/env.d/` hinzu (wie `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Dasselbe kannst du für Bildschirmaufnahmen mit `OMARCHY_SCREENRECORD_DIR` tun.

Omasnap erstellt sein Screenshot-Verzeichnis automatisch. Erstelle das Verzeichnis für Bildschirmaufnahmen selbst und starte dann Omarchy neu, damit eine der beiden Umgebungsänderungen wirksam wird.

### Wie bekomme ich die Lautsprecher + Webcam an meinem Apple Studio Display zum Laufen?

Man sollte meinen, dass alles einfach durch Einstecken von USB C funktionieren sollte, aber leider ist das nicht der Fall. Die Lösung, die ich gefunden habe, damit es zuverlässig funktioniert, ist [das WJESOG DisplayPort + USB-A => USB-C Kabel](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Dann funktionieren Lautsprecher und Webcam wunderbar.

Denke daran, dass du in Omarchy eine integrierte Helligkeitssteuerung für die Apple Displays (sowohl Studio als auch XDR) hast, und zwar über die regulären Tastaturtasten für die Helligkeit.

### Wie werde ich all die zusätzliche Software los?

Wenn du Programme wie Obsidian oder LibreOffice oder den anderen vorinstallierten Kram nicht willst, kannst du ihn ganz einfach entfernen.

Führe _Remove > Package_ aus, um jedes Paket zu sehen, das installiert ist. Dann kannst du mit Tab jedes Paket auswählen, das du entfernen möchtest, und mit Return beginnen, alles Ausgewählte zu entfernen.

Und du kannst _Remove > Web App_ im Omarchy-Menü verwenden, um jede der vorinstallierten Web-Apps zu entfernen, die du nicht willst.

Oder führe _Remove > Preinstalls_ aus, um alle vorinstallierten Extras — Web-Apps, TUIs und optionale Anwendungen — in einem Durchgang zu entfernen. Die Hotkeys, die sie gestartet haben, verschwinden mit ihnen, sodass du eine saubere Ausgangsbasis an Tastenkombinationen behältst, die du in `~/.config/hypr/bindings.lua` mit deinen eigenen füllen kannst.

---

Für Fehler und defekte Stellen siehe [den Abschnitt zur Fehlerbehebung](45-troubleshooting.md).
