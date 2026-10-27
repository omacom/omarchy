# Die obere Leiste

Der Streifen am oberen Rand deines Bildschirms ist die Omarchy-Leiste. Sie ist keine aufgeschraubte Statusleiste, sondern Teil der Omarchy-Shell, des einen, lang laufenden Quickshell-Prozesses, der auch das Menü, die Benachrichtigungen, die OSD-Popups und den Sperrbildschirm zeichnet. Deshalb passt sie thematisch perfekt zu allem anderen und deshalb öffnet sich ein Panel sofort, statt eine neue App zu starten.

Sie ist auch das einzige Stück des Desktops, das immer auf dem Bildschirm ist, also lohnt es sich zu wissen, was all diese kleinen Glyphen tun.

## Was standardmäßig darauf ist

Die Leiste hat drei Abschnitte. Links sitzen das Omarchy-Logo (der Menü-Launcher) und die Arbeitsbereich-Anzeigen. In der Mitte bekommst du die Statusanzeigen, die Uhr, Elsewhen (eine Weltuhr), das Wetter und ein Omarchy-Update-Abzeichen. Rechts: die Systemablage, das Tastaturlayout (wenn mehr als eines konfiguriert ist), Agents, Bluetooth, Netzwerk, Audio, Display und Power.

Einige davon tauchen nur auf, wenn sie etwas zu sagen haben. Das Tastaturlayout erscheint nur, wenn du mehr als ein Layout konfiguriert hast. Das Update-Abzeichen erscheint nur, wenn ein Omarchy-Update wartet. Und das Agents-Icon erscheint, sobald Omarchy zum ersten Mal AI-Coding-Nutzung auf der Maschine findet (siehe [KI](17-ai.md)).

## Herumklicken

Fast jedes Widget tut etwas bei Links-, Rechts- und Mittelklick, und mehrere reagieren auf Scrollen. Das ist der Teil, den Leute übersehen — hinter der rechten und mittleren Taste versteckt sich viel von dem guten Zeug.

| Widget | Links | Rechts | Mitte / Scrollen |
| --- | --- | --- | --- |
| Menu | Omarchy-Menü | Neues Terminal | — |
| Workspaces | Diesen Arbeitsbereich auf diesem Monitor fokussieren | — | Scrollen: nächster/vorheriger Arbeitsbereich |
| Clock | Kalender-Popup | Das Label-Format durchschalten | Mitte: Zeitzonen-Auswahl |
| Weather | Vorhersage-Popup | Vollständiges Wetter als Benachrichtigung | Mitte: aktualisieren |
| Audio | Audio-Panel | Stummschalten | Mitte: Panel · Scrollen: Lautstärke |
| Microphone | Das Mikrofon stummschalten | — | Mitte: Audio-Panel · Scrollen: Eingabelautstärke |
| Network | Netzwerk-Panel | — | — |
| Bluetooth | Bluetooth-Panel | Den Funk ein-/ausschalten | — |
| Display | Display-Panel | — | Scrollen: Helligkeit |
| Power | Power-Panel | Den Batterieprozentsatz ein-/ausschalten | — |
| Media | Wiedergabe/Pause | Cover-Art-Popup | Mitte: weiter · Scrollen: zurück/weiter |
| Agents | Agents-Panel | Deinen Agent starten | Mitte: nächstes Abonnement |
| Tray | Darüberfahren, um die Schublade zu zeigen | Rechtsklick auf den Chevron, um zu verwalten | — |
| Omarchy update | Das Update ausführen | — | — |

Nicht alles in dieser Tabelle ist von Haus aus auf deiner Leiste. Das Media-Widget (MPRIS Now-Playing, mit scrollendem Track und Künstler) und das Mikrofon-Widget sind beide eingebaut, aber standardmäßig aus — füge sie hinzu, wenn du sie willst, wie unten beschrieben.

## Die Panels

Ein Klick auf ein Leisten-Icon öffnet ein Panel, also ein richtiges Popup mit Reglern, Listen und Tastaturnavigation statt eines Tooltips. Jedes hat auch eine Tastenkombination, sodass du nie auf eine 16-Pixel-Glyphe zielen musst:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | Das n-te Panel im rechten Abschnitt ein-/ausschalten |

Die Panels sind keine reinen Anzeigen. In ihnen erledigst du die Sache tatsächlich:

- **Audio** hat einen Master-Lautstärkeregler, eine Auswahl für das Ausgabegerät und einen Mixer pro App, sodass du diesen einen Browser-Tab leiser machen kannst, ohne alles andere anzufassen.
- **Network** sucht nach Wi-Fi, zeigt die Signalstärke, verbindet und lässt dich einen DNS-Anbieter auswählen.
- **Bluetooth** listet deine Geräte mit Verbinden/Trennen und Akkuständen.
- **Power** zeigt Akku-Statistiken, schaltet Energieprofile um (es merkt sich eine separate Wahl für Akku und AC) und gibt einige Systeminformationen aus.
- **Display** bringt einen Helligkeitsregler, Textgröße, Presets für die Monitor-Skalierung und — wenn du mehr als einen Bildschirm hast — Steuerungen pro Monitor mit. Siehe [Monitore](33-monitors.md) für die ausführlichere Geschichte.
- **Clock** öffnet ein Monatsraster mit ISO-Wochennummern und Monatsschritten.
- **World clock** hält eine Zeile pro Stadt, mit ihrem Wetter und wie ihr Tag gerade läuft. Die Suche findet Orte ebenso wie Zeitzonen, also ist Fort Lauderdale Fort Lauderdale und nicht New York. Wenn die Zeile oben die falsche Stadt nennt, klicke sie an und sage, wo du bist; wähle einen Ort in einer anderen Zeitzone und die Systemuhr zieht auch dorthin um, was praktisch ist, wenn du reist. Fahre über eine Stadt und klicke auf den Personen-Button, um zu sagen, wer dort lebt — einfache Namen, oder `@` GitHub-Handles, um ihre Gesichter mitzubringen.

Jedes Panel nimmt ebenso die Tastatur wie die Maus: Pfeile bewegen, Return aktiviert, Tab springt zum benachbarten Panel und Escape schließt.

`Super + Ctrl + 1-9` zählt die Panels von links nach rechts im rechten Abschnitt und überspringt dabei die Systemablage, da sie kein eigenes Panel hat. Also entspricht die Zahl dem Icon, auf das du zeigen würdest.

### Tailscale und Dropbox

Zwei weitere Widgets erscheinen erst auf der Leiste, wenn du den passenden Dienst unter **Install → Service** installierst, und beide sollte man kennen, weil sie mehr tun, als nur den Status zu melden.

Das **Tailscale**-Panel verbindet und trennt das Tailnet, wechselt zwischen Konten und wählt einen Exit Node (deine eigenen Maschinen und Mullvad-Regionen tauchen beide in dieser Liste auf). Es durchstöbert auch deine Maschinen — und wenn eine ausgewählt ist, sendet `s` Dateien per Taildrop an sie, was der schnellste Weg ist, eine Datei auf dein Telefon oder einen anderen Laptop zu bewegen. `c` kopiert die IP der Maschine, `n` ihren Namen und `d` ihren vollständigen DNS-Namen. Auf jeder Maschinenzeile gibt es auch einen Senden-Button, wenn du lieber klickst. Dasselbe vom Terminal aus ist `omarchy tailscale send <machine> [file...]`.

Das **Dropbox**-Panel übernimmt den Login, zeigt, wie viel Speicher du verbraucht hast, und listet kürzlich synchronisierte Dateien.

Entfernst du einen der beiden Dienste, verschwindet sein Widget wieder von der Leiste.

## Indikatoren

Der kleine Cluster in der Mitte ist das Indikatoren-Widget. Das sind Status-Glyphen für Modi, die du eingeschaltet hast: Nicht stören, Nachtlicht, eine eingereihte [Erinnerung](09-reminders.md), eine aktive Bildschirmaufnahme, wach bleiben und [Diktieren](11-text-extraction-dictation.md). Sie leuchten auf, wenn der Modus aktiv ist, und halten sich sonst zurück — fahre irgendwo über die Leiste, um einen Blick auf die inaktiven zu werfen. Ein Klick auf einen Indikator schaltet diesen Modus um. Einer mehr ist nur Status: Eine Remote-Sitzung leuchtet rot, solange jemand über gliff mit dieser Maschine verbunden ist.

Wenn sie lieber immer sichtbar sein sollen, setze `alwaysShow` auf dem Widget auf `true`. Und wenn dich nur einige davon interessieren, liste die gewünschten in `items` auf: `["Dnd", "Reminder", "NightLight"]`. Du kannst mehr als ein Indikatoren-Widget haben, sodass verschiedene Abschnitte verschiedene Teilmengen zeigen können.

## Die Leiste neu anordnen

Die Leiste konfiguriert sich selbst. Du musst keine Konfigurationsdatei öffnen, um Dinge zu verschieben.

Greife eine leere Stelle der Leiste um die Mitte herum und ziehe sie zu einer anderen Bildschirmkante, und die Leiste bewegt sich dorthin — links, rechts, oben oder unten funktionieren alle, und jedes Widget passt sich an (vertikale Leisten fallen auf kompakte, reine Icon-Formen zurück). Ein Klicken-und-Halten startet denselben Zug. Doppel-Linksklicke dieselbe leere Stelle, um den Leistenhintergrund von klar zu glasig zu undurchsichtig durchzuschalten. Und ziehe irgendein Widget, um es neu anzuordnen oder in einen anderen Abschnitt zu werfen; die anderen Widgets rücken auseinander, um Platz zu machen, wo es landen wird.

Die Mitte der Leiste ist eine Box: Was darin ist, bleibt als eine Gruppe zentriert, und die Widgets auf beiden Seiten davon hängen an ihren Kanten. Während du ein Widget ziehst, zeigt sich die Box als Umriss, oder als Linie quer über die Leiste, wenn sie leer ist, und du kannst hinein oder daneben fallen lassen. Wenn ein Fallenlassen in der Box landen würde, wächst die Box, um das Widget aufzunehmen.

Ein Widget, das du in der Nähe haben, aber nicht immer sehen willst, kann in der Schublade der Systemablage landen: Ziehe es auf die Systemablage, und die Schublade öffnet sich, um es aufzunehmen. Es sitzt dort hinter den App-Icons, taucht auf, wann immer die Schublade es tut, und hält seine Schublade offen, solange sein Panel oben ist. Ziehe es zurück auf die Leiste, um es zurückzulegen.

Wenn du lieber aus einem Menü wählst, hat **Appearance → Menu Bar** die Position, und **Bar Background** wählt, wie die Leiste gezeichnet wird: **Opaque Bar**, **Glassy Bar** (durchsichtig, mit dem, was dahinter ist, verschwommen) oder **Clear Bar**.

Dieselben Dinge haben Befehle, was du für ein [Dotfiles](31-dotfiles.md)-Setup willst:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Um ein Widget ganz hinzuzufügen oder zu entfernen, benutze die Plugin-Befehle. `omarchy plugin list` gibt jedes Widget aus, das die Shell kennt, mit seiner id, und dann:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Die Leiste ausblenden

`Super + Shift + Space` schaltet die Leiste aus und wieder an, ohne die Shell zu töten — Panels und Tastenkombinationen funktionieren weiter, du bekommst nur die Pixel zurück. Es steht auch im Menü unter **Appearance → Menu Bar → Hide Bar**.

## Die Konfigurationsdatei

All das wird in `~/.config/omarchy/shell.json` gespeichert, unter dem Schlüssel `bar`. Hier ist eine gekürzte Version:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Jedes Widget ist ein Eintrag in einem der fünf Layout-Arrays, und seine Einstellungen sitzen inline auf diesem Eintrag — es gibt keine separate Einstellungsdatei und kein `config`-Unterobjekt. Das `format`, `formatAlt` (wohin der Rechtsklick weiterschaltet) und `verticalFormat` der Uhr leben alle genau dort auf `{ "id": "omarchy.clock" }`.

`center` ist die Box in der Mitte der Leiste: Alles darin wird als eine Gruppe auf dem Bildschirm zentriert. `centerBegin` und `centerEnd` hängen auf beiden Seiten der Box, und so bleibt die Uhr exakt in der Mitte, selbst wenn Wetter und Update-Abzeichen kommen und gehen. Lege mehr als ein Widget in `center` und sie werden zusammen zentriert; lasse es leer und `centerBegin` und `centerEnd` treffen sich in der Mitte der Leiste.

Eine Regel, die es wert ist, verinnerlicht zu werden: **Sobald du deine eigene `shell.json` hast, ist sie kanonisch**. Bis du irgendetwas anpasst, liest die Shell Omarchys Standarddatei. In dem Moment, in dem du ein Widget ziehst, `omarchy bar` ausführst oder die Datei selbst bearbeitest, gehört sie dir — es gibt kein Deep Merge, also werden neue Standard-Widgets in zukünftigen Omarchy-Versionen nicht automatisch auf deiner Leiste erscheinen. `omarchy bar defaults` legt das mitgelieferte Layout zurück, wann immer du eine saubere Ausgangslage willst.

Dieselbe Datei hält auch deine Idle-Zeiten auf der obersten Ebene, außerhalb des Schlüssels `bar`: `idle.screensaver` und `idle.lock`, beide in Sekunden seit du idle gegangen bist. Also setzt der Standard-Bildschirmschoner bei 150 Sekunden ein und die Sperre bei 300.
