# Die Menüleiste

Der Streifen am oberen Rand deines Bildschirms ist die Omarchy-Leiste. Sie ist keine aufgeschraubte Statusleiste, sondern Teil der Omarchy-Shell, des einen lang laufenden Quickshell-Prozesses, der auch das Menü, die Benachrichtigungen, die OSD-Popups und den Sperrbildschirm zeichnet. Deshalb passt sie thematisch perfekt zu allem anderen und deshalb öffnet sich ein Panel sofort, anstatt eine neue App zu starten.

Sie ist auch das eine Stück des Desktops, das immer auf dem Bildschirm ist, also lohnt es sich zu wissen, was all diese kleinen Glyphen tun.

## Was standardmäßig darauf ist

Die Leiste hat drei Abschnitte. Auf der linken Seite sitzen das Omarchy-Logo (der Menü-Launcher) und die Arbeitsflächenanzeigen. In der Mitte bekommst du die Statusanzeigen, die Uhr, Elsewhen (eine Weltuhr), das Wetter und ein Omarchy-Aktualisierungsabzeichen. Auf der rechten Seite: das Tastaturlayout (wenn mehr als eines konfiguriert ist), die Taskleiste, Agenten, Bluetooth, Netzwerk, Audio, Display und Stromversorgung.

Einige davon erscheinen nur, wenn sie etwas zu sagen haben. Das Tastaturlayout erscheint nur, wenn du mehr als ein Layout konfiguriert hast. Das Aktualisierungsabzeichen erscheint nur, wenn eine Omarchy-Aktualisierung wartet. Und das Agenten-Symbol erscheint das erste Mal, wenn Omarchy KI-Coding-Nutzung auf der Maschine findet (siehe [KI](17-ai.md)).

## Herumklicken

Fast jedes Widget tut etwas bei Links-, Rechts- und Mittelklick, und mehrere reagieren auf Scrollen. Das ist der Teil, den die Leute übersehen — die rechte und die mittlere Taste sind die Stellen, an denen sich viele der guten Sachen verstecken.

| Widget | Links | Rechts | Mitte / Scrollen |
| --- | --- | --- | --- |
| Menü | Omarchy-Menü | Neues Terminal | — |
| Arbeitsflächen | Diese Arbeitsfläche fokussieren | — | Scrollen: nächste/vorherige Arbeitsfläche |
| Uhr | Kalender-Popup | Das Bezeichnungsformat wechseln | Mitte: Zeitzonenauswahl |
| Wetter | Vorhersage-Popup | Vollständiges Wetter als Benachrichtigung | Mitte: aktualisieren |
| Audio | Audio-Panel | Stumm schalten | Mitte: Panel · Scrollen: Lautstärke |
| Mikrofon | Mikrofon stumm schalten | — | Mitte: Audio-Panel · Scrollen: Eingangslautstärke |
| Netzwerk | Netzwerk-Panel | — | — |
| Bluetooth | Bluetooth-Panel | Funk umschalten | — |
| Display | Display-Panel | — | Scrollen: Helligkeit |
| Stromversorgung | Strom-Panel | Akkuprozentsatz umschalten | — |
| Medien | Abspielen/Pausieren | Cover-Art-Popup | Mitte: weiter · Scrollen: zurück/weiter |
| Agenten | Agenten-Panel | Deinen Agenten starten | Mitte: nächstes Abonnement |
| Tray | Darüberfahren, um die Schublade zu enthüllen | Rechts auf dem Chevron zum Verwalten | — |
| Omarchy-Aktualisierung | Die Aktualisierung ausführen | — | — |

Nicht alles in dieser Tabelle ist sofort einsatzbereit auf deiner Leiste. Das Medien-Widget (MPRIS Now-Playing, mit scrollendem Track und Künstler) und das Mikrofon-Widget sind beide eingebaut, aber standardmäßig ausgeschaltet — füge sie hinzu, wenn du sie willst, wie unten beschrieben.

## Die Panels

Ein Klick auf ein Leistensymbol öffnet ein Panel, das ein richtiges Popup mit Schiebereglern, Listen und Tastaturnavigation ist, statt eines Tooltips. Jedes hat auch ein Tastenkürzel, sodass du nie auf eine 16-Pixel-Glyphe zielen musst:

| Tastenkürzel | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + W` | Netzwerk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Stromversorgung |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Weltuhr |
| `Super + Ctrl + 1-9` | Das n-te Panel im rechten Abschnitt umschalten |

Die Panels sind keine Anzeigen zum Ablesen. Sie sind der Ort, an dem du die Sache tatsächlich tust:

- **Audio** hat einen Master-Lautstärke-Schieberegler, eine Auswahl für das Ausgabegerät und einen Mixer pro App, sodass du diesen einen Browser-Tab leiser stellen kannst, ohne alles andere zu berühren.
- **Netzwerk** sucht nach Wi-Fi, zeigt die Signalstärke, verbindet und lässt dich einen DNS-Anbieter wählen.
- **Bluetooth** listet deine Geräte mit Verbinden/Trennen und Akkuständen.
- **Stromversorgung** zeigt Akku-Statistiken, wechselt Stromprofile (es merkt sich eine separate Wahl für Akku und Netzstrom) und gibt einige Systeminformationen aus.
- **Display** trägt einen Helligkeits-Schieberegler, Textgröße, Monitor-Skalierungs-Presets und — wenn du mehr als einen Bildschirm hast — Steuerungen pro Monitor. Siehe [Monitore](33-monitors.md) für die tiefere Geschichte.
- **Uhr** öffnet ein Monatsraster mit ISO-Kalenderwochen und Monatswechseln.

Jedes Panel nimmt die Tastatur genauso wie die Maus: Pfeile bewegen, Return aktiviert, Tab springt zum benachbarten Panel und Escape schließt.

`Super + Ctrl + 1-9` zählt Panels von links nach rechts im rechten Abschnitt und überspringt den Tray, da dieser kein eigenes Panel hat. So entspricht die Zahl dem Symbol, auf das du zeigen würdest.

### Tailscale und Dropbox

Zwei weitere Widgets erscheinen auf der Leiste erst, wenn du den passenden Dienst unter **Installieren → Dienst** installierst, und beide sind es wert, dass man von ihnen weiß, weil sie mehr tun als nur den Status zu melden.

Das **Tailscale**-Panel verbindet und trennt das Tailnet, wechselt zwischen Konten und wählt einen Exit-Node (deine eigenen Maschinen und Mullvad-Regionen tauchen beide in dieser Liste auf). Es durchsucht auch deine Maschinen — und mit einer ausgewählten schickt `s` Dateien über Taildrop an sie, was der schnellste Weg ist, eine Datei auf dein Telefon oder einen anderen Laptop zu bewegen. `c` kopiert die IP der Maschine, `n` ihren Namen und `d` ihren vollständigen DNS-Namen. Auf jeder Maschinenzeile gibt es auch eine Senden-Schaltfläche, wenn du lieber klickst. Dasselbe vom Terminal aus ist `omarchy tailscale send <machine> [file...]`.

Das **Dropbox**-Panel übernimmt die Anmeldung, zeigt, wie viel Speicherplatz du verwendet hast, und listet kürzlich synchronisierte Dateien.

Das Entfernen eines der beiden Dienste nimmt sein Widget wieder von der Leiste.

## Anzeigen

Der kleine Cluster in der Mitte ist das Anzeigen-Widget. Das sind Status-Glyphen für Modi, die du eingeschaltet hast: Nicht stören, Nachtlicht, eine ausstehende [Erinnerung](09-reminders.md), eine aktive Bildschirmaufnahme, Wach bleiben und [Diktat](11-text-extraction-dictation.md). Sie leuchten auf, wenn der Modus aktiv ist, und bleiben sonst aus dem Weg — fahre links von der Uhr (bei einer vertikalen Leiste darüber) darüber, um einen Blick auf die inaktiven zu werfen. Ein Klick auf eine Anzeige schaltet diesen Modus um. Eine weitere ist nur Status: Eine Remote-Sitzung leuchtet rot, während jemand über gliff mit dieser Maschine verbunden ist.

Wenn du lieber hättest, dass sie immer sichtbar sind, setze `alwaysShow` auf dem Widget auf `true`. Und wenn dich nur einige von ihnen interessieren, liste die gewünschten in `items`: `["Dnd", "Reminder", "NightLight"]`. Du kannst mehr als ein Anzeigen-Widget haben, sodass verschiedene Abschnitte verschiedene Teilmengen zeigen können.

## Die Leiste neu anordnen

Die Leiste konfiguriert sich selbst. Du musst keine Konfigurationsdatei öffnen, um Dinge zu verschieben.

Greife eine leere Stelle der Leiste rund um die Mitte und ziehe sie zu einer anderen Bildschirmkante, und die Leiste bewegt sich dorthin — links, rechts, oben oder unten funktionieren alle, und jedes Widget passt sich an (vertikale Leisten fallen auf kompakte Nur-Symbol-Formen zurück). Ein Klicken und Halten startet dasselbe Ziehen. Doppel-Linksklicke auf denselben leeren Bereich, um den Leistenhintergrund von klar zu glasig zu deckend zu wechseln. Und ziehe ein beliebiges Widget, um es neu anzuordnen oder in einen anderen Abschnitt zu werfen.

Ein Widget, das du griffbereit haben willst, aber nicht immer im Blick, kann in die Schublade des Trays: Ziehe es auf den Tray, und die Schublade öffnet sich, um es aufzunehmen. Es sitzt dort hinter den App-Symbolen, erscheint, wann immer die Schublade erscheint, und hält die Schublade offen, solange sein Panel geöffnet ist. Ziehe es wieder heraus auf die Leiste, um es zurückzubringen.

Wenn du lieber aus einem Menü wählen willst, hat **Auslösen → Aussehen → Menüleiste** die Position, und **Leistenhintergrund** wählt, wie die Leiste gezeichnet wird: **Deckende Leiste**, **Glasleiste** (durchsichtig, wobei das Dahinter unscharf ist) oder **Klare Leiste**.

Dieselben Dinge haben Befehle, was du für ein [Dotfiles](31-dotfiles.md)-Setup willst:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Um ein Widget vollständig hinzuzufügen oder zu entfernen, verwende die Plugin-Befehle. `omarchy plugin list` gibt jedes Widget aus, das die Shell kennt, mit seiner ID, und dann:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Die Leiste ausblenden

`Super + Shift + Space` schaltet die Leiste aus und wieder ein, ohne die Shell zu beenden — Panels und Tastenkürzel funktionieren weiter, du bekommst nur die Pixel zurück. Es ist auch im Menü unter **Auslösen → Aussehen → Menüleiste → Leiste ausblenden**.

## Die Konfigurationsdatei

All das wird in `~/.config/omarchy/shell.json` unter dem Schlüssel `bar` gespeichert. Hier ist eine gekürzte Version:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Jedes Widget ist ein Eintrag in einem der drei Layout-Arrays, und seine Einstellungen sitzen inline auf diesem Eintrag — es gibt keine separate Einstellungsdatei und kein `config`-Unterobjekt. Das `format`, `formatAlt` (wohin der Rechtsklick wechselt) und `verticalFormat` der Uhr leben alle direkt dort auf `{ "id": "omarchy.clock" }`.

`centerAnchor` benennt das eine mittlere Widget, das an der exakten Mitte des Bildschirms angeheftet wird, während die anderen es flankieren. So bleibt die Uhr genau in der Mitte, selbst wenn das Wetter und das Aktualisierungsabzeichen kommen und gehen. Setze es auf einen leeren String, und die mittlere Liste wird stattdessen einfach als Gruppe zentriert.

Eine Regel, die es wert ist, verinnerlicht zu werden: **Sobald du deine eigene `shell.json` hast, ist sie kanonisch**. Bis du irgendetwas anpasst, liest die Shell Omarchys Standarddatei. In dem Moment, in dem du ein Widget ziehst, `omarchy bar` ausführst oder die Datei selbst bearbeitest, gehört sie dir — es gibt kein tiefes Zusammenführen, sodass neue Standard-Widgets in zukünftigen Omarchy-Versionen nicht automatisch auf deiner Leiste erscheinen werden. `omarchy bar defaults` stellt das ausgelieferte Layout wieder her, wann immer du einen sauberen Start willst.

Dieselbe Datei enthält auch deine Leerlauf-Zeiten auf oberster Ebene, außerhalb des Schlüssels `bar`: `idle.screensaver` und `idle.lock`, beide in Sekunden seit deinem Leerlaufbeginn. So setzt der Standard-Bildschirmschoner bei 150 Sekunden ein und die Sperre bei 300.
