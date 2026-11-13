# Die obere Leiste

Der Streifen am oberen Rand deines Bildschirms ist die Omarchy-Leiste. Sie ist keine aufgesetzte Statusleiste, sondern Teil der Omarchy-Shell, des einzigen langlaufenden Quickshell-Prozesses, der auch das Menü, die Benachrichtigungen, die OSD-Popups und den Sperrbildschirm zeichnet. Deshalb passt ihr Theme perfekt zu allem anderen und deshalb öffnet sich ein Panel sofort, statt eine neue App zu starten.

Sie ist auch das einzige Stück des Desktops, das immer auf dem Bildschirm ist, also lohnt es sich zu wissen, was all diese kleinen Glyphen tun.

## Was standardmäßig darauf ist

Die Leiste hat drei Bereiche. Links sitzen das Omarchy-Logo (der Menü-Launcher) und die Workspace-Anzeigen. In der Mitte bekommst du die Statusanzeigen, die Uhr, Elsewhen (eine Weltuhr), das Wetter und ein Omarchy-Update-Badge. Rechts: der System-Tray, das Tastaturlayout (wenn mehr als eines konfiguriert ist), Agents, Bluetooth, Netzwerk, Audio, Display und Power.

Einige davon tauchen nur auf, wenn sie etwas zu sagen haben. Das Tastaturlayout erscheint nur, wenn du mehr als ein Layout konfiguriert hast. Das Update-Badge erscheint nur, wenn ein Omarchy-Update wartet. Und das Agents-Symbol erscheint, sobald Omarchy zum ersten Mal KI-Coding-Nutzung auf dem Rechner findet (siehe [KI](17-ai.md)).

## Herumklicken

Fast jedes Widget tut etwas bei Links-, Rechts- und Mittelklick, und mehrere reagieren auf Scrollen. Das ist der Teil, den die Leute übersehen — hinter der rechten und mittleren Taste versteckt sich ein Großteil der guten Sachen.

| Widget | Links | Rechts | Mitte / Scrollen |
| --- | --- | --- | --- |
| Menü | Omarchy-Menü | Neues Terminal | — |
| Workspaces | Diesen Workspace auf diesem Monitor fokussieren | — | Scrollen: nächster/vorheriger Workspace |
| Uhr | Kalender-Popup | Label-Format durchwechseln | Mitte: Zeitzonen-Auswahl |
| Wetter | Vorhersage-Popup | Vollständiges Wetter als Benachrichtigung | Mitte: aktualisieren |
| Audio | Audio-Panel | Stummschalten | Mitte: Panel · Scrollen: Lautstärke |
| Mikrofon | Mikro stummschalten | — | Mitte: Audio-Panel · Scrollen: Eingabelautstärke |
| Netzwerk | Netzwerk-Panel | — | — |
| Bluetooth | Bluetooth-Panel | Funk ein-/ausschalten | — |
| Display | Display-Panel | — | Scrollen: Helligkeit |
| Power | Power-Panel | Akku-Prozentanzeige ein-/ausschalten | — |
| Medien | Abspielen/Pausieren | Cover-Art-Popup | Mitte: weiter · Scrollen: zurück/weiter |
| Agents | Agents-Panel | Deinen Agent starten | Mitte: nächstes Abonnement |
| Tray | Darüberfahren, um die Schublade zu zeigen | Rechtsklick auf das Chevron, um sie zu verwalten | — |
| Omarchy-Update | Update ausführen | — | — |

Nicht alles in dieser Tabelle ist von Haus aus auf deiner Leiste. Das Medien-Widget (MPRIS Now-Playing, mit scrollendem Track und Künstler) und das Mikrofon-Widget sind beide eingebaut, aber standardmäßig aus — füge sie hinzu, wenn du sie willst, wie unten beschrieben.

## Die Panels

Ein Klick auf ein Leistensymbol öffnet ein Panel, also ein richtiges Popup mit Schiebereglern, Listen und Tastaturnavigation statt eines Tooltips. Jedes hat auch einen Hotkey, damit du nie auf eine 16-Pixel-Glyphe zielen musst:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

Die Panels sind keine reinen Anzeigen. In ihnen erledigst du die Sache tatsächlich:

- **Audio** hat einen Master-Lautstärkeregler, eine Auswahl für das Ausgabegerät und einen Mixer pro App, damit du diesen einen Browser-Tab leiser drehen kannst, ohne alles andere anzufassen.
- **Network** sucht nach Wi-Fi, zeigt die Signalstärke, verbindet und lässt dich einen DNS-Anbieter auswählen.
- **Bluetooth** listet deine Geräte mit Verbinden/Trennen und Akkuständen auf.
- **Power** zeigt Akkustatistiken, wechselt Power-Profile (es merkt sich eine separate Wahl für Akku und AC) und gibt einige Systeminfos aus.
- **Display** bringt einen Helligkeitsregler, Textgröße, Presets für die Monitor-Skalierung und — wenn du mehr als einen Bildschirm hast — Steuerungen pro Monitor mit. Siehe [Monitore](33-monitors.md) für die ausführlichere Geschichte.
- **Clock** öffnet ein Monatsraster mit ISO-Wochennummern und Monatsschritten.
- **World clock** hält eine Zeile pro Stadt, mit ihrem Wetter und wie ihr Tag gerade läuft. Die Suche findet Orte ebenso wie Zeitzonen, also ist Fort Lauderdale Fort Lauderdale und nicht New York. Wenn die Zeile oben die falsche Stadt nennt, klicke sie an und sage, wo du bist; wähle einen Ort in einer anderen Zeitzone, und die Systemuhr zieht ebenfalls dorthin um, was auf Reisen praktisch ist. Fahre über eine Stadt und klicke auf den Personen-Button, um zu sagen, wer dort lebt — einfache Namen oder `@` GitHub-Handles, um ihre Gesichter mitzubringen.

Jedes Panel nimmt ebenso die Tastatur wie die Maus: Pfeile bewegen, Return aktiviert, Tab springt zum benachbarten Panel, und Escape schließt.

`Super + Ctrl + 1-9` zählt die Panels im rechten Bereich von links nach rechts und überspringt dabei den Tray, da er kein eigenes Panel hat. Die Zahl entspricht also dem Symbol, auf das du zeigen würdest.

### Tailscale und Dropbox

Zwei weitere Widgets erscheinen auf der Leiste erst, sobald du den passenden Dienst unter **Install → Service** installierst, und beide sollte man kennen, weil sie mehr tun, als nur Status zu melden.

Das **Tailscale**-Panel verbindet und trennt das Tailnet, wechselt zwischen Konten und wählt einen Exit Node (deine eigenen Rechner und Mullvad-Regionen tauchen beide in dieser Liste auf). Es durchsucht auch deine Rechner — und mit einem ausgewählten Rechner sendet `s` Dateien über Taildrop an ihn, was der schnellste Weg ist, eine Datei auf dein Handy oder einen anderen Laptop zu bewegen. `c` kopiert die IP des Rechners, `n` seinen Namen und `d` seinen vollständigen DNS-Namen. Auf jeder Rechnerzeile gibt es auch einen Senden-Button, falls du lieber klickst. Dasselbe vom Terminal aus ist `omarchy tailscale send <machine> [file...]`.

Das **Dropbox**-Panel kümmert sich um die Anmeldung, zeigt, wie viel Speicher du verbraucht hast, und listet kürzlich synchronisierte Dateien auf.

Das Entfernen eines der beiden Dienste nimmt sein Widget wieder von der Leiste.

## Indikatoren

Der kleine Cluster in der Mitte ist das Indikatoren-Widget. Das sind Statusglyphen für Modi, die du eingeschaltet hast: Nicht stören, Nachtlicht, eine eingereihte [Erinnerung](09-reminders.md), eine aktive Bildschirmaufnahme, Wach bleiben und [Diktat](11-text-extraction-dictation.md). Sie leuchten auf, wenn der Modus aktiv ist, und halten sich sonst aus dem Weg — fahre knapp daneben, wo die inaktiven sitzen würden, um einen Blick auf sie zu werfen. Ein Klick auf einen Indikator schaltet diesen Modus um. Einer mehr ist nur Status: Eine Remote-Sitzung leuchtet rot, solange jemand über gliff mit diesem Rechner verbunden ist.

Wenn sie bei dir lieber immer sichtbar sein sollen, setze `alwaysShow` auf dem Widget auf `true`. Und wenn dich nur einige davon interessieren, liste die gewünschten in `items` auf: `["Dnd", "Reminder", "NightLight"]`. Du kannst mehr als ein Indikatoren-Widget haben, sodass verschiedene Bereiche verschiedene Teilmengen zeigen können.

## Die Leiste neu anordnen

Die Leiste konfiguriert sich selbst. Du musst keine Konfigurationsdatei öffnen, um Dinge zu verschieben.

Greife eine leere Stelle der Leiste um die Mitte herum und ziehe sie zu einem anderen Bildschirmrand, und die Leiste zieht dorthin — links, rechts, oben oder unten funktionieren alle, und jedes Widget passt sich an (vertikale Leisten fallen auf kompakte Formen nur mit Symbolen zurück). Ein Klicken und Halten startet denselben Drag. Mache einen Doppel-Linksklick auf dieselbe leere Stelle, um den Leistenhintergrund von durchsichtig über glasig bis deckend durchzuwechseln. Und ziehe ein beliebiges Widget, um es neu anzuordnen oder in einen anderen Bereich zu werfen; die anderen Widgets rutschen auseinander, um Platz zu machen, wo es landen wird.

Die Mitte der Leiste ist eine Box: Was darin ist, bleibt als eine Gruppe zentriert, und die Widgets auf beiden Seiten hängen an ihren Rändern. Während du ein Widget ziehst, zeigt sich die Box als Umriss oder, wenn sie leer ist, als Linie quer über die Leiste, und du kannst in sie hinein oder daneben ablegen. Wenn ein Ablegen in der Box landen würde, wächst die Box, um das Widget aufzunehmen.

Ein Widget, das du in der Nähe haben, aber nicht immer sehen willst, kann in die Schublade des Trays: Ziehe es auf den Tray, und die Schublade öffnet sich, um es aufzunehmen. Es sitzt dort hinter den App-Symbolen, taucht immer auf, wenn die Schublade es tut, und hält seine Schublade offen, solange sein Panel oben ist. Ziehe es zurück auf die Leiste, um es zurückzulegen.

Wenn du lieber aus einem Menü wählst, hat **Appearance → Menu Bar** die Position, und **Bar Background** wählt, wie die Leiste gezeichnet wird: **Opaque Bar**, **Glassy Bar** (durchsichtig, mit verschwommenem Hintergrund) oder **Clear Bar**.

Dieselben Dinge haben Befehle, was du für ein [Dotfiles](31-dotfiles.md)-Setup willst:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Um ein Widget ganz hinzuzufügen oder zu entfernen, nutze die Plugin-Befehle. `omarchy plugin list` gibt jedes Widget aus, das die Shell kennt, mit seiner id, und dann:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Die Leiste ausblenden

`Super + Shift + Space` schaltet die Leiste aus und wieder ein, ohne die Shell zu beenden — Panels und Hotkeys funktionieren weiter, du bekommst nur die Pixel zurück. Es steht auch im Menü unter **Appearance → Menu Bar → Hide Bar**.

## Die Konfigurationsdatei

All das wird in `~/.config/omarchy/shell.json` gespeichert, unter dem `bar`-Key. Hier ist eine gekürzte Version:

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

Jedes Widget ist ein Eintrag in einem der fünf Layout-Arrays, und seine Einstellungen sitzen inline auf diesem Eintrag — es gibt keine separate Einstellungsdatei und kein `config`-Unterobjekt. Das `format`, `formatAlt` (wohin der Rechtsklick wechselt) und `verticalFormat` der Uhr leben alle direkt dort auf `{ "id": "omarchy.clock" }`.

`center` ist die Box in der Mitte der Leiste: Alles darin wird als eine Gruppe auf dem Bildschirm zentriert. `centerBegin` und `centerEnd` hängen auf beiden Seiten der Box, wodurch die Uhr genau in der Mitte bleibt, auch wenn Wetter und Update-Badge kommen und gehen. Lege mehr als ein Widget in `center`, und sie werden gemeinsam zentriert; lasse es leer, und `centerBegin` und `centerEnd` treffen sich in der Mitte der Leiste.

Eine Regel, die es wert ist, verinnerlicht zu werden: **Sobald du deine eigene `shell.json` hast, ist sie kanonisch**. Bis du irgendetwas anpasst, liest die Shell Omarchys Standarddatei. In dem Moment, in dem du ein Widget ziehst, `omarchy bar` ausführst oder die Datei selbst bearbeitest, gehört sie dir — es gibt kein tiefes Mergen, also werden neue Standard-Widgets in zukünftigen Omarchy-Releases nicht automatisch auf deiner Leiste erscheinen. `omarchy bar defaults` legt das ausgelieferte Layout zurück, wann immer du eine saubere Ausgangslage willst.

Dieselbe Datei hält auf der obersten Ebene, außerhalb des `bar`-Keys, auch deine Leerlaufzeiten: `idle.screensaver` und `idle.lock`, beide in Sekunden seit du in den Leerlauf gegangen bist. Der Standard-Bildschirmschoner springt also bei 150 Sekunden an und die Sperre bei 300.
