# Die obere Leiste

Der Streifen am oberen Rand deines Bildschirms ist die Omarchy-Leiste. Sie ist keine drangeschraubte Statusleiste, sondern Teil der Omarchy-Shell, des einen, langlaufenden Quickshell-Prozesses, der auch das Menü, die Benachrichtigungen, die OSD-Popups und den Sperrbildschirm zeichnet. Darum passt ihr Theme perfekt zu allem anderen und darum öffnet sich ein Panel sofort, statt eine neue App zu starten.

Sie ist auch das einzige Desktop-Element, das immer auf dem Bildschirm ist, also lohnt es sich zu wissen, was all diese kleinen Glyphen tun.

## Was standardmäßig darauf ist

Die Leiste hat drei Abschnitte. Links sitzt das Omarchy-Logo (der Menü-Launcher) und die Arbeitsbereichsanzeigen. In der Mitte bekommst du die Statusanzeigen, die Uhr, Elsewhen (eine Weltuhr), das Wetter und ein Omarchy-Update-Badge. Rechts: die Systemablage, das Tastaturlayout (wenn mehr als ein Layout oder eine Eingabemethode konfiguriert ist), Agenten, Bluetooth, Netzwerk, Audio, Anzeige und Energie.

Einige davon erscheinen nur, wenn sie etwas zu sagen haben. Das Tastaturlayout erscheint nur, wenn du mehr als ein Layout oder eine Eingabemethode konfiguriert hast. Das Update-Badge erscheint nur, wenn ein Omarchy-Update wartet.

## Herumklicken

Fast jedes Widget tut etwas bei Links-, Rechts- und Mittelklick, und mehrere reagieren auf Scrollen. Das ist der Teil, den die Leute übersehen — hinter der rechten und mittleren Taste versteckt sich viel von dem guten Zeug.

| Widget | Links | Rechts | Mitte / Scrollen |
| --- | --- | --- | --- |
| Menü | Omarchy-Menü | Neues Terminal | — |
| Arbeitsbereiche | Diesen Arbeitsbereich auf diesem Monitor fokussieren | — | Scrollen: nächster/vorheriger Arbeitsbereich |
| Uhr | Kalender-Popup | Anzeigeformat durchschalten | Mitte: Zeitzonenauswahl |
| Weltuhr | Weltuhr-Panel | Aktualisieren | Mitte: aktualisieren |
| Wetter | Vorhersage-Popup | Vollständiges Wetter als Benachrichtigung | Mitte: aktualisieren |
| Audio | Audio-Panel | Stummschalten | Mitte: Panel · Scrollen: Lautstärke |
| Mikrofon | Mikrofon stummschalten | — | Mitte: Audio-Panel · Scrollen: Eingabelautstärke |
| Netzwerk | Netzwerk-Panel | — | — |
| Bluetooth | Bluetooth-Panel | Funk umschalten | — |
| Anzeige | Anzeige-Panel | — | Scrollen: Helligkeit |
| Energie | Energie-Panel | Batterieprozentsatz umschalten | — |
| Medien | Wiedergabe/Pause | Cover-Art-Popup | Mitte: weiter · Scrollen: zurück/weiter |
| Agenten | Agenten-Panel | Deinen Agenten starten | Mitte: Nutzung aktualisieren |
| Systemablage | Darüberfahren, um die Schublade zu enthüllen | Rechtsklick auf den Chevron, um zu verwalten | — |
| Omarchy-Update | Das Update ausführen | — | — |

Nicht alles in dieser Tabelle ist von Haus aus auf deiner Leiste. Das Medien-Widget (MPRIS Now-Playing, mit scrollendem Track und Künstler) und das Mikrofon-Widget sind beide eingebaut, aber standardmäßig aus — füge sie hinzu, wenn du sie willst, wie unten beschrieben.

## Die Panels

Ein Klick auf ein Leisten-Symbol öffnet ein Panel, also ein richtiges Popup mit Schiebereglern, Listen und Tastaturnavigation statt eines Tooltips. Jedes hat auch ein Tastenkürzel, sodass du nie auf eine 16-Pixel-Glyphe zielen musst:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

Die Panels sind keine reinen Anzeigen. Dort erledigst du die Sache tatsächlich:

- **Audio** hat einen Hauptlautstärke-Regler, eine Auswahl für das Ausgabegerät und einen Mixer pro App, sodass du diesen einen Browser-Tab leiser drehen kannst, ohne alles andere anzufassen.
- **Network** sucht nach Wi-Fi, zeigt die Signalstärke, verbindet und lässt dich einen DNS-Anbieter wählen.
- **Bluetooth** listet deine Geräte mit Verbinden/Trennen und Akkuständen.
- **Power** zeigt Akkustatistiken, wechselt Energieprofile (es merkt sich eine separate Wahl für Akku und AC) und gibt einige Systeminfos aus.
- **Display** bringt einen Helligkeitsregler, Textgröße, Presets für Monitor-Skalierung und — wenn du mehr als einen Bildschirm hast — Steuerungen pro Monitor. Siehe [Monitore](33-monitors.md) für die ausführlichere Geschichte.
- **Clock** öffnet ein Monatsraster mit ISO-Wochennummern und Monatsschritten.
- **World clock** hält eine Zeile pro Stadt, mit ihrem Wetter und wie ihr Tag so läuft. Die Suche findet Städte ebenso wie Zeitzonen, also ist Fort Lauderdale Fort Lauderdale und nicht New York. Wenn die Zeile oben die falsche Stadt nennt, klicke sie an und sag, wo du bist; wähle einen Ort in einer anderen Zeitzone und die Systemuhr zieht dorthin mit, was praktisch ist, wenn du reist. Fahre mit der Maus über eine Stadt und klicke auf den Personen-Button, um zu sagen, wer dort lebt — einfache Namen, oder `@` GitHub-Handles, um ihre Gesichter mitzubringen.

Jedes Panel nimmt ebenso die Tastatur wie die Maus: Pfeile bewegen, Return aktiviert, Tab springt zum benachbarten Panel, und Escape schließt.

`Super + Ctrl + 1-9` zählt Panels von links nach rechts im rechten Abschnitt und überspringt die Systemablage, weil sie kein eigenes Panel hat. Also entspricht die Zahl dem Symbol, auf das du zeigen würdest.

### Tailscale und Dropbox

Zwei weitere Widgets erscheinen auf der Leiste erst, sobald du den passenden Dienst aus **Install → Service** installierst, und beide lohnen sich zu kennen, weil sie mehr tun, als nur Status zu melden.

Das **Tailscale**-Panel verbindet und trennt das Tailnet, wechselt zwischen Konten und wählt einen Exit-Node (deine eigenen Maschinen und Mullvad-Regionen tauchen beide in dieser Liste auf). Es durchsucht auch deine Maschinen — und mit einer ausgewählten sendet `s` Dateien per Taildrop an sie, was der schnellste Weg ist, eine Datei auf dein Telefon oder einen anderen Laptop zu bewegen. `c` kopiert die IP der Maschine, `n` ihren Namen und `d` ihren vollständigen DNS-Namen. Auf jeder Maschinenzeile gibt es auch einen Senden-Button, falls du lieber klickst. Dasselbe aus dem Terminal ist `omarchy tailscale send <machine> [file...]`.

Das **Dropbox**-Panel übernimmt den Login, zeigt, wie viel Speicher du verbraucht hast, und listet kürzlich synchronisierte Dateien.

Entfernst du einen der beiden Dienste, verschwindet sein Widget wieder von der Leiste.

## Indikatoren

Der kleine Cluster in der Mitte ist das Indikatoren-Widget. Das sind Statusglyphen für Modi, die du eingeschaltet hast: Nicht stören, Nachtlicht, eine eingereihte [Erinnerung](09-reminders.md), eine aktive Bildschirmaufnahme und Wach bleiben, plus Warnungen, solange passwortloses sudo an ist oder jemand mit einer Remote-Sitzung verbunden ist. Sie leuchten, wenn der Modus aktiv ist, und halten sich sonst aus dem Weg — fahre mit der Maus direkt daneben, dorthin, wo die inaktiven sitzen würden, um einen Blick auf sie zu werfen. Ein Klick auf einen Indikator schaltet diesen Modus um. Einer mehr ist nur Status: Eine Remote-Sitzung leuchtet rot, solange jemand über gliff mit dieser Maschine verbunden ist.

Wenn du sie lieber immer sichtbar hättest, setze `alwaysShow` auf dem Widget auf `true`. Und wenn dich nur einige davon interessieren, liste die gewünschten in `items` auf: `["Dnd", "Reminder", "NightLight"]`. Du kannst mehr als ein Indikatoren-Widget haben, sodass verschiedene Abschnitte verschiedene Teilmengen zeigen können.

## Die Leiste umsortieren

Die Leiste konfiguriert sich selbst. Du musst keine Konfigurationsdatei öffnen, um Dinge zu verschieben.

Packe eine leere Stelle der Leiste um die Mitte herum und ziehe sie zu einer anderen Bildschirmkante, und die Leiste zieht dorthin — links, rechts, oben oder unten funktioniert alles, und jedes Widget passt sich an (vertikale Leisten fallen auf kompakte Formen nur mit Symbolen zurück). Klicken und Halten startet denselben Ziehvorgang. Doppelklicke mit der linken Taste auf dieselbe leere Stelle, um den Leistenhintergrund von klar zu glasig zu undurchsichtig durchzuschalten. Und ziehe irgendein Widget, um es umzusortieren oder in einen anderen Abschnitt zu werfen; die anderen Widgets rutschen auseinander, um Platz zu machen, wo es landen wird.

Die Mitte der Leiste ist eine Box: Was auch immer darin ist, bleibt als eine Gruppe zentriert, und die Widgets auf beiden Seiten hängen an ihren Kanten. Während du ein Widget ziehst, zeigt sich die Box als Umriss, oder als Linie quer über die Leiste, wenn sie leer ist, und du kannst in sie hinein oder daneben ablegen. Wenn ein Ablegen in der Box landen würde, wächst die Box, um das Widget aufzunehmen.

Ein Widget, das du in der Nähe haben, aber nicht immer im Blick haben willst, kann in die Schublade der Systemablage: Ziehe es auf die Systemablage, und die Schublade öffnet sich, um es aufzunehmen. Es sitzt dort hinter den App-Symbolen, erscheint, wann immer die Schublade es tut, und hält seine Schublade offen, solange sein Panel oben ist. Ziehe es zurück auf die Leiste, um es zurückzulegen.

Wenn du lieber aus einem Menü wählst, hat **Appearance → Menu Bar** die Position, und **Bar Background** wählt, wie die Leiste gezeichnet wird: **Opaque Bar**, **Glassy Bar** (durchsichtig, mit verschwommenem Hintergrund dahinter) oder **Clear Bar**.

Dasselbe gibt es als Befehle, was du für ein [dotfiles](31-dotfiles.md)-Setup willst:

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

## Die Leiste verstecken

`Super + Shift + Space` schaltet die Leiste aus und wieder ein, ohne die Shell zu killen — Panels und Tastenkürzel funktionieren weiter, du bekommst nur die Pixel zurück. Es steht auch im Menü unter **Appearance → Menu Bar → Hide Bar**.

## Die Konfigurationsdatei

Das alles wird in `~/.config/omarchy/shell.json` unter dem `bar`-Key gespeichert. Hier ist eine gekürzte Version:

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

Jedes Widget ist ein Eintrag in einem der fünf Layout-Arrays, und seine Einstellungen sitzen inline auf diesem Eintrag — es gibt keine separate Einstellungsdatei und kein `config`-Unterobjekt. `format`, `formatAlt` (wohin der Rechtsklick durchschaltet) und `verticalFormat` der Uhr leben alle direkt dort auf `{ "id": "omarchy.clock" }`.

`center` ist die Box in der Mitte der Leiste: Alles darin wird als eine Gruppe auf dem Bildschirm zentriert. `centerBegin` und `centerEnd` hängen an beiden Seiten der Box, wodurch die Uhr exakt in der Mitte bleibt, auch wenn Wetter und Update-Badge kommen und gehen. Stecke mehr als ein Widget in `center`, und sie werden zusammen zentriert; lass es leer, und `centerBegin` und `centerEnd` treffen sich in der Mitte der Leiste.

Eine Regel, die es wert ist, verinnerlicht zu werden: **Sobald du deine eigene `shell.json` hast, ist sie kanonisch**. Bis du irgendetwas anpasst, liest die Shell Omarchys Standarddatei. In dem Moment, in dem du ein Widget ziehst, `omarchy bar` ausführst oder die Datei selbst bearbeitest, gehört sie dir — es gibt kein Deep-Merge, also werden neue Standard-Widgets in künftigen Omarchy-Releases nicht automatisch auf deiner Leiste erscheinen. `omarchy bar defaults` stellt das ausgelieferte Layout wieder her, wann immer du eine saubere Ausgangslage willst.

Dieselbe Datei hält auch deine Leerlauf-Zeiten auf oberster Ebene, außerhalb des `bar`-Keys: `idle.screensaver` und `idle.lock`, beide in Sekunden, seit du inaktiv bist. Also setzt der Standard-Bildschirmschoner bei 150 Sekunden ein und die Sperre bei 300.
