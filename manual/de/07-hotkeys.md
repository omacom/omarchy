# Tastenkürzel

Du kannst alle wichtigen Tastaturbindings mit `Super + K` sehen (Tmux-Bindings mit `Super + Alt + K` und Herdr-Bindings mit `Super + Ctrl + K`).

## Wie Hotkeys aufgebaut sind

Jeder Hotkey liegt auf einer Ebene, festgelegt durch seine Modifier, und jede Ebene hat eine Aufgabe. Das sorgt dafür, dass die Hotkeys nicht miteinander verschwimmen, und es bedeutet, dass du meistens erraten kannst, wo etwas zu Hause ist.

| Ebene | Was dort zu Hause ist | Beispiele |
| --- | --- | --- |
| `Super + key` | Das System: Fenster, Workspaces, Layouts und Kernmenüs | `Super + Space` Omarchy-Menü, `Super + W` Fenster schließen, `Super + F` Vollbild |
| `Super + Shift + key` | Apps | `Super + Shift + B` Browser, `Super + Shift + E` E-Mail, `Super + Shift + N` Editor |
| `Super + Ctrl + key` | Panels und Systemmenüs | `Super + Ctrl + A` Audio, `Super + Ctrl + N` Netzwerk, `Super + Ctrl + C` Aufnahme-Menü |
| `Super + Ctrl + Alt + key` | Schnellaktionen und Hinweise | `Super + Ctrl + Alt + T` Zeit anzeigen, `Super + Ctrl + Alt + B` Akku, `Super + Ctrl + Alt + C` Screenshot |

Wenn du einem Hotkey `Alt` hinzufügst, bekommst du eine Variante derselben Sache, niemals etwas Unverbundenes:

- `Super + Shift + B` öffnet den Browser; `Super + Shift + Alt + B` öffnet ein privates Fenster
- `Super + Shift + E` öffnet E-Mail; `Super + Shift + Alt + E` beginnt eine neue
- `Super + F` geht ins Vollbild; `Super + Alt + F` geht auf volle Breite
- `Super + Ctrl + C` öffnet das Aufnahme-Menü; `Super + Ctrl + Alt + C` überspringt das Menü und macht einen Screenshot

Wenn du einen Hotkey hinzufügst:

1. Wähle die Ebene danach, was er tut, dann wähle die Taste.
2. Verschiebe keinen bestehenden Hotkey, um Platz zu machen. Finde eine freie Taste auf der richtigen Ebene.
3. Verwende `Alt` nur für eine Variante des Hotkeys ohne es.

Ein paar Hotkeys brechen diese Regeln, weil sie bequem sind. `Shift` mit einem Pfeil oder `Tab` verschiebt oder kehrt um, statt eine App zu öffnen, und `Print`, die Medientasten, `Alt + Tab` und `Ctrl + Alt + Del` funktionieren so wie überall sonst. Sie sind Ausnahmen, keine Muster zum Kopieren.

Wenn dir ein Standard nicht zusagt (etwa wenn du `Super + Shift + S` für Screenshots wie unter Windows willst), binde ihn in `~/.config/hypr/bindings.lua` neu.

## Navigieren

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-Menü (Apps und alles andere)    |
| `Super + Alt + Space` | App-Übersicht |
| `Super + Escape` | Systemmenü (Ruhezustand, Neustart usw.)  |
| `Super + Ctrl + L` | Computer sperren |
| `Super + W` or `Super + Q` | Fenster schließen             |
| `Ctrl + Alt + Del` | Alle Fenster schließen |
| `Super + K` | Alle Hotkeys anzeigen |
| `Super + Alt + K` | tmux-Hotkeys anzeigen |
| `Super + Ctrl + K` | herdr-Hotkeys anzeigen |
| `Super + M` | Fenster ins Dock minimieren |
| `Super + T`               | Fenster zwischen Tiling/Floating umschalten             |
| `Super + J` | Fensterposition umschalten (horizontal/vertikal) |
| `Super + O`               | Fenster in sticky'n'floating umschalten |
| `Super + L`               | Durch die Layouts dwindle, scrolling und floating wechseln |
| `Super + Alt + L`         | Die Layouts in umgekehrter Reihenfolge durchwechseln |
| `Super + P`               | Pseudo-Fensterstil umschalten (natürlich vs. gestreckt) |
| `Super + F`                 | In den Vollbildmodus wechseln              |
| `Super + Alt + F`                 | Auf volle Breite wechseln              |
| `Super + Ctrl + F`                 | Innerhalb des Fensters in den Vollbildmodus wechseln              |
| `Super + 1…9/0`         | Zu einem bestimmten Workspace auf dem fokussierten Monitor springen (0 ist 10) |
| `Super + Tab` | Zum nächsten Workspace auf dem fokussierten Monitor springen |
| `Super + Shift + Tab` | Zum vorherigen Workspace auf dem fokussierten Monitor springen |
| `Super + Ctrl + Tab` | Zum früheren Workspace auf dem fokussierten Monitor springen |
| `Super + Shift + 1…9/0` | Fenster zu einem Workspace auf dem fokussierten Monitor verschieben |
| `Super + Shift + Alt + 1…9/0` | Fenster zu einem Workspace auf dem fokussierten Monitor verschieben, ohne zu folgen |
| `Super + S` | Vollständiges Scratchpad umschalten |
| `Super + Alt + S` | Fenster ins vollständige Scratchpad verschieben |
| `Super + the key above Tab` (grave on US layouts) | Quake-Konsole umschalten |
| `Super + Shift + the key above Tab` (grave on US layouts) | Fenster in die Quake-Konsole verschieben |
| `Super + Shift + Ctrl + Arrows` | Fenster auf den Monitor in dieser Richtung verschieben |
| `Super + Shift + Alt + Arrows` | Workspace auf den Monitor in dieser Richtung verschieben |
| `Super + Arrow`  | Fokus auf das Fenster in Pfeilrichtung verschieben, am Bildschirmrand auf den Monitor auf dieser Seite wechseln |
| `Super + Shift + Arrow`  | Fenster mit einem anderen in Pfeilrichtung tauschen, einschließlich eines auf dem Monitor auf dieser Seite |
| `Super + Minus` | Fenster nach links erweitern |
| `Super + Equal` | Fenster nach links verkleinern |
| `Super + Shift + Minus` | Fenster nach oben verkleinern |
| `Super + Shift + Equal` | Fenster nach unten erweitern |
| `Super + Alt + Minus/Equal` | Dasselbe Ändern der Größe in kleineren Schritten |
| `Super + Ctrl + Minus/Equal` | Dasselbe Ändern der Größe in größeren Schritten |
| `Super + Alt + Home` | Fensterbreite speichern |
| `Super + Home` | Gespeicherte Fensterbreite wiederherstellen |
| `Super + Left Mouse` | Fenster herumziehen |
| `Super + Right Mouse` | Fenstergröße ändern |
| `Super + Scroll Wheel` | Durch Workspaces auf dem fokussierten Monitor scrollen |
| `Super + G`               | Fenstergruppierung umschalten      |
| `Super + Alt + G`               | Fenster aus der Gruppierung herausverschieben      |
| `Super + Alt + Tab`               | Zwischen Fenstern in der Gruppierung wechseln      |
| `Super + Alt + Shift + Tab`               | Rückwärts zwischen Fenstern in der Gruppierung wechseln      |
| `Super + Alt + Scroll Wheel` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + 1/2/3/4/5`               | Zu einem bestimmten Fenster in der Gruppierung springen      |
| `Super + Alt + Arrow`  | Fenster in Pfeilrichtung in die Gruppierung verschieben, einschließlich eines auf dem Monitor auf dieser Seite |
| `Super + Ctrl + Left/Right`  | Zwischen Fenstern innerhalb einer Tiling-Gruppe wechseln |
| `Super + Ctrl + Z` | In den Bildschirm hineinzoomen (wiederholen für mehr Zoom) |
| `Super + Ctrl + Alt + Z` | Vollständig aus dem Bildschirm herauszoomen |
| `Super + /` | Schrittweise vorwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Super + Alt + /` | Schrittweise rückwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Alt + Tab` | Vorwärts durch Fenster auf dem aktiven Workspace wechseln |
| `Alt + Shift + Tab` | Rückwärts durch Fenster auf dem aktiven Workspace wechseln |
| `Ctrl + Alt + Tab`| Fokus vorwärts durch Monitore wechseln |
| `Ctrl + Alt + Shift + Tab`| Fokus rückwärts durch Monitore wechseln |
| `Super + I` | Eingabesprache wechseln (mit mehr als einem Layout oder einer Eingabemethode) |
| `Super + Shift + I` | Eingabesprache zurückwechseln |

Auf einem Touchpad wechseln Wischgesten mit drei und vier Fingern Workspaces, verschieben Fenster und öffnen das Menü und die Quake-Konsole; die Gesten findest du unter [Tastatur, Maus und Trackpad](34-keyboard-mouse-trackpad.md).

Zum Ändern der Größe dienen die beiden Tasten rechts von der 0, was auch immer deine Tastatur darauf druckt: `-` und `=` auf US-Tastaturen, `+` und `´` auf dänischen und schwedischen, `+` und `\` auf norwegischen, `ß` und `´` auf deutschen, `'` und `¡` auf spanischen und `-` und `^` auf japanischen (JIS). `Super + K` listet sie so auf, wie sie auf deiner Tastatur aufgedruckt sind. Auf JIS ist `Super + ^` gleich `Super + Equal`, während `Super + Shift + -` (das `=` tippt) gleich `Super + Shift + Minus` ist. Die Monitor-Skalierung und der Passwortmanager verwenden `/`; auf Layouts, die `/` nur mit Shift tippen, wie die meisten europäischen, verwenden sie stattdessen die Taste links vom rechten Shift (`-` auf Dänisch und Deutsch).

## Systemsteuerung

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio-Panel    |
| `Super + Ctrl + B`           | Bluetooth-Panel    |
| `Super + Ctrl + N`           | Wifi/Netzwerk-Panel    |
| `Super + Ctrl + D`           | Anzeige-Panel    |
| `Super + Ctrl + P`           | Power-Panel    |
| `Super + Ctrl + X`           | Agents-Panel    |
| `Super + Ctrl + Alt + D`           | Kalender-Panel    |
| `Super + Ctrl + Alt + E`           | Weltuhr-Panel    |
| `Super + Ctrl + 1-9`           | Leisten-Panel nach Position umschalten    |
| `Super + Ctrl + S` | Teilen-Menü (über LocalSend) |
| `Super + Ctrl + C` | Aufnahme-Steuerung (Screenshot/-Aufzeichnung/Picker) |
| `Super + Ctrl + O` | Menü umschalten |
| `Super + Ctrl + H` | Hardware-Menü |
| `Super + Ctrl + E` | Emoji-Auswahl |
| `Super + Ctrl + .` | Medien transkodieren |
| `Super + Shift + Ctrl + A` | Deinen Standard-Agent starten |
| `Power` key | Systemmenü |
| `Super + Shift + Copilot` key | Omarchy-Menü |

## Anpassungen

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximale Bildschirmhelligkeit |
| `Shift + Brightness Down` | Minimale Bildschirmhelligkeit |
| `Alt + Brightness Up/Down` | Präzise Helligkeitsänderungen um 1 % |
| `Alt + Volume Up/Down` | Präzise Lautstärkeänderungen um 1 % |
| `Keyboard Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler |
| `Keyboard Backlight` | Die Stufen der Tastaturbeleuchtung durchwechseln |
| `Ctrl + Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler, auf Tastaturen ohne eigene Tasten dafür |
| `Mic Mute` | Das Mikrofon stummschalten |
| `Shift + Mute` | Audioausgabe wechseln |
| `Touchpad Toggle` | Das Touchpad ein- oder ausschalten |
| `Display` key | Das Workspace-Layout durchwechseln |
| `Alt + Play` | Nächster Titel |
| `Alt + Shift + Play` | Vorheriger Titel |

## Apps starten

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-Terminal |
| `Super + Ctrl + Return` | Herdr (Agent-Manager) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privat/Inkognito)    |
| `Super + Shift + F`           | Dateimanager    |
| `Super + Shift + Alt + F`           | Dateimanager im cwd des Terminals    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Passwortmanager (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Taschenrechner (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, sobald installiert)    |
| `Super + Shift + T`           | Aktivität (btop)    |
| `Super + Shift + N`           | Editor (Plain oder dein gewählter Standard)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-Mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Neue E-Mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Dein Standard-Agent oder ChatGPT, bis du einen auswählst |
| `Super + Shift + Alt + A`           | KI (Grok)  |
| `Super + Shift + G`           | Messenger (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messenger (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messenger (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Schreiben (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (neuer Beitrag) |
| `Super + Shift + Y`           | YouTube |

Bindings in `~/.config/hypr/bindings.lua` ändern/hinzufügen.

## Universelle Zwischenablage

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + A`           | In Apps, die `Ctrl + A` unterstützen, alles auswählen    |
| `Super + C`           | Kopieren    |
| `Super + X`           | Ausschneiden (nicht im Terminal)    |
| `Super + V`           | Einfügen    |
| `Super + Ctrl + V`           | Zwischenablage-Manager    |

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V`, um im Terminal zu kopieren und einzufügen, und `Ctrl + C/V`, um es überall sonst zu tun. Diese einheitlichen Zwischenablage-Hotkeys von Omarchy funktionieren überall.

## Aufnahme

| Hotkey              | Funktion                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Screenshot                      |
| `Super + Ctrl + Alt + C`            | Screenshot (derselbe Schnappschuss, für Tastaturen ohne Print Screen-Taste) |
| `Super + Ctrl + C` | Aufnahme-Menü |
| `Alt + Print Screen`            | Bildschirmaufzeichnung                     |
| `Super + Shift + Ctrl + Alt + C` | Bildschirmaufzeichnung ohne Audio, ohne Menü (erneut drücken zum Stoppen) |
| `Super + Print Screen` | Farbauswahl |
| `Super + Ctrl + Print Screen` | Textextraktion in die Zwischenablage |
| `Super + Alt + [` | Webcam-Overlay während der Aufnahme verkleinern |
| `Super + Alt + ]` | Webcam-Overlay während der Aufnahme vergrößern |
| `Alt + Shift + L` | Aktuelle URL aus Webapp oder Browser kopieren |
| `Alt + Shift + D` | Das Video auf der aktuellen Seite nach `~/Videos` herunterladen |
| `Alt + Space` | Diktieren starten/stoppen (erfordert _Setup > Standardwerte > Diktieren_) |
| `Right Alt` | Gedrückt halten zum Diktieren (erfordert _Setup > Standardwerte > Diktieren_) |

Bei Bildschirmaufzeichnungen fragt der Hotkey zuerst, welches Audio du willst, und startet dann die Aufnahme. Drück ihn erneut, um zu stoppen. Die Details findest du unter [Screenshots und Aufnahme](12-screenshots-recording.md).

Alle Aufnahmeoptionen sind auch unter _Auslöser > Aufnahme_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Benachrichtigungen

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + ,` | Auf die neueste Benachrichtigung reagieren: sie öffnen oder ihren einzigen Button drücken, aus ihren Optionen wählen oder sie verwerfen, wenn sie keine hat  |
| `Super + Shift + ,` | Alle Benachrichtigungen verwerfen |
| `Super + Ctrl + ,` | Benachrichtigungen mit der Tastatur steuern  |
| `Super + Alt + ,` | Neueste Benachrichtigung verwerfen  |
| `Super + Shift + Alt + ,` | Benachrichtigungsverlauf öffnen  |
| `Super + Ctrl + Alt + ,` | Stummschalten von Benachrichtigungen umschalten  |

## Stil

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Ein neues Theme auswählen (auch `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Theme-Hintergrund auswählen (auch `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparenz eines Fensters umschalten |
| `Super + Ctrl + Backspace` | Quadratisches Seitenverhältnis für ein einzelnes Fenster umschalten |

Zusätzliche Hintergrundbilder liegen in `~/.config/omarchy/backgrounds/<theme name>`. Auch über _Installieren > Stil > Hintergrund_ im Omarchy-Menü verfügbar.

Alle Stiloptionen sind auch unter _Darstellung_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Umschalten

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Sperren bei Inaktivität umschalten |
| `Super + Ctrl + Delete` | Laptop-Display ein-/ausschalten |
| `Super + Ctrl + Alt + Delete` | Spiegeln des Laptop-Displays umschalten |
| `Super + Shift + Space` | Die obere Leiste umschalten  |
| `Shift + Mute` | Zur nächsten Audioausgabe wechseln |
| `Shift + Play` | Zur nächsten Medienquelle wechseln |
| `Super + Shift + Backspace` | Fensterabstände umschalten |
| `Super + Ctrl + Alt + F` | Vollbild-Desktop umschalten (obere Leiste + Fensterabstände) |

## Erinnerungen

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eine Erinnerung setzen  |
| `Super + Ctrl + Alt + R` | Alle Erinnerungen ansehen  |
| `Super + Ctrl + Shift + R` | Alle Erinnerungen löschen  |

## Hinweise

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Zeit als Benachrichtigung anzeigen  |
| `Super + Ctrl + Alt + B` | Akku als Benachrichtigung anzeigen  |
| `Super + Ctrl + Alt + W` | Wetter als Benachrichtigung umschalten  |

## Tmux

Die Prefix-Taste ist `Ctrl + Space` (`Ctrl + B` funktioniert auch). Du kannst diese Bindings in `~/.config/tmux/tmux.conf` ändern.

### Panes

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + v` | Pane daneben teilen (vertikal) |
| `Prefix + h` | Pane darunter teilen (horizontal) |
| `Prefix + x` | Pane beenden |
| `Prefix + z` | Pane-Zoom umschalten (Vollbild) |
| `Alt + Enter` | Pane darunter teilen (ohne Prefix) |
| `Alt + Shift + Enter` | Pane daneben teilen (ohne Prefix) |
| `Alt + Escape` | Pane beenden (ohne Prefix) |
| `Ctrl + Alt + Arrows` | Zwischen Panes wechseln |
| `Ctrl + Alt + Shift + Arrows` | Pane-Größe ändern |

### Fenster

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + c` | Neues Fenster |
| `Prefix + k` | Fenster beenden |
| `Prefix + r` | Fenster umbenennen |
| `Alt + 1-9` | Zu einem bestimmten Fenster wechseln |
| `Alt + Arrow Left/Right` | Zwischen Fenstern wechseln |
| `Alt + Shift + Arrow Left/Right` | Fenster nach links/rechts verschieben |

### Sitzungen

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + C` | Neue Sitzung |
| `Prefix + K` | Sitzung beenden |
| `Prefix + R` | Sitzung umbenennen |
| `Prefix + N` | Nächste Sitzung |
| `Prefix + P` | Vorherige Sitzung |
| `Alt + Arrow Up/Down` | Zwischen Sitzungen wechseln |
| `Prefix + s` | Sitzungen auflisten |
| `Prefix + d` | Von Sitzung lösen |

### Kopiermodus (vi-Stil)

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopiermodus betreten |
| `v` | Auswahl beginnen (im Kopiermodus) |
| `y` | Auswahl kopieren (im Kopiermodus) |

### Allgemein

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguration neu laden |
| `Prefix + ?` | Tmux-Tastenkombinationen anzeigen |
| `Prefix + :` | Befehlseingabe |

### Tmux-Layout-Funktionen

Diese Funktionen müssen innerhalb einer Tmux-Sitzung ausgeführt werden.

| Befehl | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-Layout mit Editor, KI und Terminal erstellen |
| `tdlm <ai> [<second_ai>]` | Dev-Layout pro Unterverzeichnis erstellen |
| `tsl <count> <command>` | Multi-Pane-Schwarm-Layout erstellen |

## Ghostty-Terminal

Das Ghostty-Terminal wird über _Installieren > Terminal_ im Omarchy-Menü installiert.

| Hotkey                  | Funktion              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Neue Teilung darunter |
| `Ctrl + Shift + O` | Neue Teilung daneben |
| `Ctrl + Alt + Arrows` | Zwischen Teilungen wechseln |
| `Super + Ctrl + Shift + Arrows` | Größe der Teilung um 10 Zeilen ändern |
| `Super + Ctrl + Shift + Alt + Arrows` | Größe der Teilung um 100 Zeilen ändern |
| `Ctrl + Shift + T` | Neuer Tab  |
| `Ctrl + Shift + Arrows` | Zwischen Tabs wechseln |
| `Alt + Numbers` | Zu einem bestimmten Tab wechseln |
| `Shift + Pg Up/Down` | Durch den Verlauf scrollen |
| `Ctrl + Left mouse` | Link im Browser öffnen |

## Dateimanager

| Hotkey              | Funktion                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Zu einem Pfad gehen                     |
| `Space`               | Dateivorschau (Pfeile navigieren) |
| `Alt + Up`       | Zum übergeordneten Ordner hochgehen        |

## Neovim (mit lazyvim)

### Navigation

| Hotkey                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Befehlsoptionen anzeigen            |
| `Space Space`              | Datei per Fuzzy-Suche öffnen      |
| `Space E`                  | Seitenleiste umschalten                  |
| `Space G G`                | Git-Steuerung anzeigen               |
| `Space S G`                | Dateiinhalte durchsuchen             |
| `Ctrl + W W`               | Zwischen Seitenleiste und Editor springen |
| `Ctrl + Left/right arrow`  | Größe der Seitenleiste ändern          |
| `Shift + H`                      | Zum linken Datei-Tab wechseln             |
| `Shift + L`                      | Zum rechten Datei-Tab wechseln            |
| `Space B D`                | Datei-Tab schließen                  |

### In der Seitenleiste

| Hotkey                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `A`                        | Neue Datei im übergeordneten Verzeichnis hinzufügen      |
| `Shift + A`                | Neues Unterverzeichnis im übergeordneten Verzeichnis hinzufügen    |
| `D`                        | Markierte Datei/markiertes Verzeichnis löschen     |
| `M`                        | Markierte Datei/markiertes Verzeichnis verschieben       |
| `R`                        | Markierte Datei/markiertes Verzeichnis umbenennen     |
| `?`                        | Hilfe für alle Befehle anzeigen      |

[Sieh dir alle von LazyVim konfigurierten Neovim-Hotkeys an](https://www.lazyvim.org/keymaps).

## Schnelle Emojis

Du kannst mit `Super + Ctrl + E` eine vollständige Emoji-Auswahl anzeigen, die die Auswahl in die Zwischenablage legt, oder du kannst diese Schnellzugriffsoptionen verwenden.

| Hotkey       | EM | Hinweis       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | lächeln      |
| `Shift + CapsLock M C` | 😂 | weinen        |
| `Shift + CapsLock M L` | 😍 | Liebe       |
| `Shift + CapsLock M V` | ✌️ | Sieg    |
| `Shift + CapsLock M H` | ❤️ | Herz      |
| `Shift + CapsLock M Y` | 👍 | ja        |
| `Shift + CapsLock M N` | 👎 | nein         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | Wunsch       |
| `Shift + CapsLock M R` | 🤘 | Rock       |
| `Shift + CapsLock M K` | 😘 | Kuss       |
| `Shift + CapsLock M E` | 🙄 | Augenrollen    |
| `Shift + CapsLock M I` | 😉 | Zwinkern       |
| `Shift + CapsLock M P` | 🙏 | beten |
| `Shift + CapsLock M D` | 🤤 | sabbern      |
| `Shift + CapsLock M M` | 💰 | Geld      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | Toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | Begrüßung |
| `Shift + CapsLock M A` |💪 | Arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Schnelle Vervollständigungen

| Hotkey       | Vervollständigung       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (Geviertstrich)   |
| `Shift + CapsLock Space N` | Dein Name (wie bei der Einrichtung eingegeben)  |
| `Shift + CapsLock Space E` | Deine E-Mail (wie bei der Einrichtung eingegeben)  |

Du kannst eigene hinzufügen, indem du `~/.XCompose` bearbeitest und dann `omarchy restart xcompose` im Terminal ausführst, damit die Änderungen übernommen werden.
