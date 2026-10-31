# Häufige Fragen

### Wie wechsle ich zwischen Tastaturlayouts?

Bearbeite deine Datei `~/.config/hypr/input.lua` und füge das hinzu, um mit `Left Alt + Right Alt` zwischen Layouts zu wechseln:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Die Leiste zeigt dein aktuelles Tastaturlayout automatisch an, sobald du mehrere Layouts konfiguriert hast (und du kannst auch darauf klicken, um zu wechseln).

### Wie stelle ich das Uhrformat auf 12 Stunden?

Klicke mit der rechten Maustaste auf die Uhr in der Leiste, um durch die gängigen Formate zu wechseln, einschließlich der 12-Stunden-Formate. Du kannst das Format auch direkt setzen:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Das zeigt Sunday 10:55 AM an.

### Wie ändere ich meine Zeitzone?

Starte _Aktualisieren > Timezone_ im Omarchy-Menü und wähle aus der Liste. Wenn die Zeitzone stimmt, aber die Uhr selbst abgewichen ist, startet _Aktualisieren > Time_ die Zeitsynchronisierung für dich neu.

### Wie ändere ich mein DNS, teile mein WLAN oder prüfe meine Verbindungsgeschwindigkeit?

Das alles findest du unter [Netzwerk](35-networking.md).

### Wie prüfe ich, wie schnell meine Platte ist?

_Auslösen > Geschwindigkeitstest > Plattentest_ misst die laufende Lese- und Schreibgeschwindigkeit deines Laufwerks, oder `omarchy disk speedtest` im Terminal.

### Warum kann ich mich in Chromium nicht bei meinem Google-Konto anmelden?

Die reine Open-Source-Version von Chromium bringt die OAuth-Zugangsdaten nicht mit, die Google für die Kontoanmeldung verlangt. Starte _Installieren > Service > Chromium Account_ im Omarchy-Menü, um sie hinzuzufügen, starte den Browser neu, und die Anmeldung geht durch.

### Wie füge ich einen Drucker hinzu?

Drucken ist von Anfang an eingerichtet und läuft, und jeden Drucker fügst du selbst aus den _Print Settings_ im App-Launcher (`Super + Space`) hinzu.

Wähle _Add_ und gib ihm einen Moment zum Suchen: Ein per USB angeschlossener Drucker und die meisten Netzwerkdrucker werden für dich gefunden. Wenn deiner nicht in der Liste ist, wähle _Network Printer > Internet Printing Protocol (ipp)_ und gib seine Adresse ein — das Display des Druckers oder seine Website sagt dir, was das ist, meist etwas wie `192.168.1.50` mit einer Warteschlange `ipp/print`. _Forward_ bietet dann einen Treiber an, wobei ein moderner Drucker am besten mit dem treiberlosen Profil _IPP Everywhere_ läuft und ein älterer den eigenen Treiber des Modells will.

Klicke mit der rechten Maustaste auf einen Drucker und wähle _Set as Default_, um zu bestimmen, welchen deine Apps zuerst nutzen, und _Properties_, um Papierformat, Duplex und Qualität zu setzen.

Die automatische Erkennung, bei der Drucker im Netzwerk erscheinen, ohne hinzugefügt zu werden, ist vorübergehend ausgeschaltet, solange sie überarbeitet wird. Deshalb ist der erste Schritt oben deiner statt automatisch. In eine PDF-Datei zu drucken funktioniert ganz ohne Drucker.

### Wie ändere ich, wo Screenshots oder Bildschirmaufnahmen gespeichert werden?

Gespeicherte Screenshots landen standardmäßig in `~/Pictures/Screenshots`. Um ein anderes Verzeichnis zu verwenden, füge das in eine Datei unter `~/.config/uwsm/env.d/` ein (zum Beispiel `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Dasselbe kannst du für Bildschirmaufnahmen mit `OMARCHY_SCREENRECORD_DIR` tun.

Omasnap erstellt sein Screenshot-Verzeichnis automatisch. Das Verzeichnis für Bildschirmaufnahmen erstellst du selbst und startest dann Omarchy neu, damit eine der beiden Umgebungsänderungen wirkt.

### Wie bringe ich Lautsprecher und Webcam an meinem Apple Studio Display zum Laufen?

Man sollte meinen, es müsste alles einfach per USB-C funktionieren, aber leider ist das nicht der Fall. Die Lösung, die ich für zuverlässiges Funktionieren gefunden habe, ist [das WJESOG DisplayPort + USB-A => USB-C Kabel](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Dann funktionieren Lautsprecher und Webcam wie ein Zauber.

Vergiss nicht, dass du in Omarchy für die Apple Displays (sowohl Studio als auch XDR) eine eingebaute Helligkeitssteuerung über die normalen Helligkeitstasten der Tastatur hast.

### Wie werde ich die ganze zusätzliche Software los?

Wenn du Programme wie Obsidian oder LibreOffice oder irgendetwas anderes Vorinstalliertes nicht willst, kannst du es ganz leicht entfernen.

Starte _Entfernen > Package_, um jedes installierte Paket zu sehen. Dann kannst du jedes Paket, das du entfernen willst, mit Tab auswählen und mit Return beginnen, alles Ausgewählte zu entfernen.

Und mit _Entfernen > Web App_ aus dem Omarchy-Menü entfernst du jede der vorinstallierten Web-Apps, die du nicht willst.

Oder starte _Entfernen > Preinstalls_, um alle vorinstallierten Extras — Web-Apps, TUIs und optionale Anwendungen — in einem Zug hinauszuwerfen. Die Hotkeys, die sie gestartet haben, verschwinden mit ihnen, sodass du eine saubere Tafel von Tastenkürzeln hast, die du in `~/.config/hypr/bindings.lua` mit eigenen füllen kannst.

---

Für Fehler und kaputte Teile siehe [den Abschnitt zur Fehlerbehebung](45-troubleshooting.md).
