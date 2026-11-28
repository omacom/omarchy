# Tastaturkürzel

Du siehst alle wichtigen Tastaturbelegungen mit `Super + K` (Tmux-Belegungen mit `Super + Alt + K` und Herdr-Belegungen mit `Super + Ctrl + K`).

## Wie Tastaturkürzel aufgebaut sind

Jedes Tastaturkürzel sitzt auf einer Ebene, festgelegt durch seine Modifier, und jede Ebene hat eine Aufgabe. Das verhindert, dass die Tastaturkürzel miteinander verschwimmen, und es bedeutet, dass du meist erraten kannst, wo etwas liegt.

| Ebene | Was dort liegt | Beispiele |
| --- | --- | --- |
| `Super + key` | Das System: Fenster, Workspaces, Layouts und Kernmenüs | `Super + Space` Omarchy-Menü, `Super + W` Fenster schließen, `Super + F` Vollbild |
| `Super + Shift + key` | Apps | `Super + Shift + B` Browser, `Super + Shift + E` E-Mail, `Super + Shift + N` Editor |
| `Super + Ctrl + key` | Panels und Systemmenüs | `Super + Ctrl + A` Audio, `Super + Ctrl + N` Netzwerk, `Super + Ctrl + C` Aufnahme-Menü |
| `Super + Ctrl + Alt + key` | Schnellaktionen und Hinweise | `Super + Ctrl + Alt + T` Zeit anzeigen, `Super + Ctrl + Alt + B` Akku, `Super + Ctrl + Alt + C` Screenshot |

`Alt` zu einem Tastaturkürzel hinzuzufügen gibt dir eine Variante derselben Sache, nie etwas Unzusammenhängendes:

- `Super + Shift + B` öffnet den Browser; `Super + Shift + Alt + B` öffnet ein privates Fenster
- `Super + Shift + E` öffnet E-Mail; `Super + Shift + Alt + E` startet eine neue
- `Super + F` geht ins Vollbild; `Super + Alt + F` geht auf volle Breite
- `Super + Ctrl + C` öffnet das Aufnahme-Menü; `Super + Ctrl + Alt + C` überspringt das Menü und macht einen Screenshot

Beim Hinzufügen eines Tastaturkürzels:

1. Wähle die Ebene danach, was es tut, dann wähle die Taste.
2. Verschiebe kein bestehendes Tastaturkürzel, um Platz zu machen. Finde eine freie Taste auf der richtigen Ebene.
3. Nutze `Alt` nur für eine Variante des Tastaturkürzels ohne `Alt`.

Ein paar Tastaturkürzel brechen diese Regeln, weil sie praktisch sind. `Shift` mit einem Pfeil oder `Tab` verschiebt oder kehrt um, statt eine App zu öffnen, und `Print`, die Medientasten, `Alt + Tab` und `Ctrl + Alt + Del` funktionieren so, wie sie es überall sonst auch tun. Sie sind Ausnahmen, keine Muster zum Kopieren.

Wenn dir ein Standard nicht zusagt (sagen wir, du willst `Super + Shift + S` für Screenshots wie unter Windows), belege ihn in `~/.config/hypr/bindings.lua` neu.

## Navigation

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-Menü (Apps und alles andere)    |
| `Super + Alt + Space` | App-Raster |
| `Super + Escape` | Systemmenü (Energie sparen, Neustart usw.)  |
| `Super + Ctrl + L` | Computer sperren |
| `Super + W` or `Super + Q` | Fenster schließen             |
| `Ctrl + Alt + Del` | Alle Fenster schließen |
| `Super + K` | Alle Tastaturkürzel anzeigen |
| `Super + Alt + K` | Tmux-Tastaturkürzel anzeigen |
| `Super + Ctrl + K` | Herdr-Tastaturkürzel anzeigen |
| `Super + M` | Fenster ins Dock minimieren |
| `Super + T`               | Fenster zwischen Tiling/Floating umschalten             |
| `Super + J` | Fensterposition umschalten (horizontal/vertikal) |
| `Super + O`               | Fenster in sticky'n'floating umschalten |
| `Super + L`               | Durch die Layouts dwindle, scrolling und floating durchschalten |
| `Super + Alt + L`         | Durch die Layouts in umgekehrter Reihenfolge durchschalten |
| `Super + P`               | Pseudo-Fensterstil umschalten (natural v stretch) |
| `Super + F`                 | Vollbild              |
| `Super + Alt + F`                 | Volle Breite              |
| `Super + Ctrl + F`                 | Vollbild innerhalb des Fensters              |
| `Super + 1…9/0`         | Zu bestimmtem Workspace springen (0 ist 10) auf dem fokussierten Monitor |
| `Super + Tab` | Zum nächsten Workspace auf dem fokussierten Monitor springen |
| `Super + Shift + Tab` | Zum vorherigen Workspace auf dem fokussierten Monitor springen |
| `Super + Ctrl + Tab` | Zum zuvor genutzten Workspace auf dem fokussierten Monitor springen |
| `Super + Shift + 1…9/0` | Fenster auf Workspace auf dem fokussierten Monitor verschieben |
| `Super + Shift + Alt + 1…9/0` | Fenster auf Workspace auf dem fokussierten Monitor verschieben, ohne zu folgen |
| `Super + S` | Vollständiges Scratchpad umschalten |
| `Super + Alt + S` | Fenster ins vollständige Scratchpad verschieben |
| `Super + the key above Tab` (grave on US layouts) | Quake-Konsole umschalten |
| `Super + Shift + the key above Tab` (grave on US layouts) | Fenster in die Quake-Konsole verschieben |
| `Super + Shift + Ctrl + Arrows` | Fenster auf den Monitor in dieser Richtung verschieben |
| `Super + Shift + Alt + Arrows` | Workspace auf den Monitor in dieser Richtung verschieben |
| `Super + Arrow`  | Fokus auf Fenster in Pfeilrichtung setzen, an der Bildschirmkante auf den Monitor auf dieser Seite wechseln |
| `Super + Shift + Arrow`  | Fenster mit einem anderen in Pfeilrichtung tauschen, einschließlich einem auf dem Monitor auf dieser Seite |
| `Super + Minus` | Fenster nach links vergrößern |
| `Super + Equal` | Fenster von links verkleinern |
| `Super + Shift + Minus` | Fenster nach oben verkleinern |
| `Super + Shift + Equal` | Fenster nach unten vergrößern |
| `Super + Alt + Minus/Equal` | Gleiche Größenänderung in kleineren Schritten |
| `Super + Ctrl + Minus/Equal` | Gleiche Größenänderung in größeren Schritten |
| `Super + Alt + Home` | Fensterbreite speichern |
| `Super + Home` | Gespeicherte Fensterbreite wiederherstellen |
| `Super + Left Mouse` | Fenster ziehen |
| `Super + Right Mouse` | Fenstergröße ändern |
| `Super + Scroll Wheel` | Durch Workspaces auf dem fokussierten Monitor scrollen |
| `Super + G`               | Fenstergruppierung umschalten      |
| `Super + Alt + G`               | Fenster aus der Gruppierung herausnehmen      |
| `Super + Alt + Tab`               | Zwischen Fenstern in der Gruppierung durchschalten      |
| `Super + Alt + Shift + Tab`               | Rückwärts zwischen Fenstern in der Gruppierung durchschalten      |
| `Super + Alt + Scroll Wheel` | Zwischen Fenstern in der Gruppierung durchschalten |
| `Super + Alt + 1/2/3/4/5`               | Zu bestimmtem Fenster in der Gruppierung springen      |
| `Super + Alt + Arrow`  | Fenster in Pfeilrichtung in die Gruppierung verschieben, einschließlich einem auf dem Monitor auf dieser Seite |
| `Super + Ctrl + Left/Right`  | Zwischen Fenstern innerhalb einer Tiling-Gruppe wechseln |
| `Super + Ctrl + Z` | In den Bildschirm hineinzoomen (für mehr Zoom wiederholen) |
| `Super + Ctrl + Alt + Z` | Vollständig aus dem Bildschirm herauszoomen |
| `Super + /` | Vorwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Super + Alt + /` | Rückwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Alt + Tab` | Vorwärts durch Fenster auf dem aktiven Workspace durchschalten |
| `Alt + Shift + Tab` | Rückwärts durch Fenster auf dem aktiven Workspace durchschalten |
| `Ctrl + Alt + Tab`| Fokus vorwärts durch Monitore durchschalten |
| `Ctrl + Alt + Shift + Tab`| Fokus rückwärts durch Monitore durchschalten |
| `Super + I` | Eingabesprache wechseln (bei mehr als einem Layout oder einer Eingabemethode) |
| `Super + Shift + I` | Eingabesprache zurückwechseln |

Auf einem Touchpad wechseln Drei- und Vier-Finger-Wischgesten Workspaces, verschieben Fenster und öffnen das Menü und die Quake-Konsole; siehe [Tastatur, Maus und Trackpad](34-keyboard-mouse-trackpad.md) für die Gesten.

Die Größenänderung nutzt die beiden Tasten rechts von 0, egal was deine Tastatur darauf druckt: `-` und `=` auf US-Tastaturen, `+` und `´` auf dänischen und schwedischen, `+` und `\\` auf norwegischen, `ß` und `´` auf deutschen, `'` und `¡` auf spanischen und `-` und `^` auf japanischen (JIS). `Super + K` listet sie so, wie deine Tastatur sie bedruckt. Auf JIS ist `Super + ^` `Super + Equal`, während `Super + Shift + -` (was `=` tippt) `Super + Shift + Minus` ist. Monitor-Skalierung und der Passwortmanager nutzen `/`; auf Layouts, die `/` nur mit Shift tippen, wie die meisten europäischen, nutzen sie stattdessen die Taste links von der rechten Shift-Taste (`-` auf dänischen und deutschen).

## Systemsteuerung

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio-Panel    |
| `Super + Ctrl + B`           | Bluetooth-Panel    |
| `Super + Ctrl + N`           | Wi-Fi/Netzwerk-Panel    |
| `Super + Ctrl + D`           | Display-Panel    |
| `Super + Ctrl + P`           | Power-Panel    |
| `Super + Ctrl + X`           | Agents-Panel    |
| `Super + Ctrl + Alt + D`           | Kalender-Panel    |
| `Super + Ctrl + Alt + E`           | Weltuhr-Panel    |
| `Super + Ctrl + 1-9`           | Panel der Leiste nach Position umschalten    |
| `Super + Ctrl + S` | Teilen-Menü (über LocalSend) |
| `Super + Ctrl + C` | Aufnahme-Steuerung (Screenshot/-Aufzeichnung/Picker) |
| `Super + Ctrl + O` | Menü umschalten |
| `Super + Ctrl + H` | Hardware-Menü |
| `Super + Ctrl + E` | Emoji-Auswahl |
| `Super + Ctrl + .` | Medien transkodieren |
| `Super + Shift + Ctrl + A` | Deinen Standard-Agenten starten |
| `Power` key | Systemmenü |
| `Super + Shift + Copilot` key | Omarchy-Menü |

## Anpassungen

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximale Bildschirmhelligkeit |
| `Shift + Brightness Down` | Minimale Bildschirmhelligkeit |
| `Alt + Brightness Up/Down` | Präzise Helligkeitsänderungen um 1% |
| `Alt + Volume Up/Down` | Präzise Lautstärkeänderungen um 1% |
| `Keyboard Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler |
| `Keyboard Backlight` | Durch die Stufen der Tastaturbeleuchtung schalten |
| `Ctrl + Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler, auf Tastaturen ohne eigene Tasten |
| `Mic Mute` | Mikrofon stummschalten |
| `Shift + Mute` | Audioausgabe wechseln |
| `Touchpad Toggle` | Touchpad ein- oder ausschalten |
| `Display` key | Durch das Workspace-Layout schalten |
| `Alt + Play` | Nächster Titel |
| `Alt + Shift + Play` | Vorheriger Titel |

## Apps starten

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-Terminal |
| `Super + Ctrl + Return` | Herdr (agent manager) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privat/incognito)    |
| `Super + Shift + F`           | Dateimanager    |
| `Super + Shift + Alt + F`           | Dateimanager im cwd des Terminals    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Passwortmanager (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Taschenrechner (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, once installed)    |
| `Super + Shift + T`           | Aktivität (btop)    |
| `Super + Shift + N`           | Editor (Plain, or your chosen default)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-Mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Neue E-Mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | KI (ChatGPT)  |
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

Ändere/ergänze Belegungen in `~/.config/hypr/bindings.lua`.

## Universelle Zwischenablage

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + A`           | In Apps, die `Ctrl + A` unterstützen, alles auswählen    |
| `Super + C`           | Kopieren    |
| `Super + X`           | Ausschneiden (nicht im Terminal)    |
| `Super + V`           | Einfügen    |
| `Super + Ctrl + V`           | Zwischenablagen-Manager    |

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V`, um im Terminal zu kopieren und einzufügen, und `Ctrl + C/V`, um es überall sonst zu tun. Diese vereinheitlichten Tastaturkürzel für die Zwischenablage von Omarchy funktionieren überall.

## Aufnahme

| Tastaturkürzel              | Funktion                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Screenshot                      |
| `Super + Ctrl + Alt + C`            | Screenshot (derselbe Shot, für Tastaturen ohne Print Screen-Taste) |
| `Super + Ctrl + C` | Aufnahme-Menü |
| `Alt + Print Screen`            | Bildschirmaufzeichnung                     |
| `Super + Shift + Ctrl + Alt + C` | Bildschirmaufzeichnung ohne Audio, ohne Menü (erneut drücken zum Stoppen) |
| `Super + Print Screen` | Farbauswahl |
| `Super + Ctrl + Print Screen` | Textextraktion in die Zwischenablage |
| `Super + Alt + [` | Webcam-Overlay während der Aufnahme kleiner machen |
| `Super + Alt + ]` | Webcam-Overlay während der Aufnahme größer machen |
| `Alt + Shift + L` | Aktuelle URL aus Webapp oder Browser kopieren |
| `Alt + Shift + D` | Das Video auf der aktuellen Seite nach `~/Videos` herunterladen |
| `Alt + Space` | Diktieren starten/stoppen (erfordert _Setup > Defaults > Dictation_) |
| `Right Alt` | Zum Diktieren gedrückt halten (erfordert _Setup > Defaults > Dictation_) |

Bei Bildschirmaufzeichnungen fragt das Tastaturkürzel zuerst, welchen Ton du willst, dann startet die Aufnahme. Drücke es erneut zum Stoppen. Siehe [Screenshots und Aufzeichnung](12-screenshots-recording.md) für die Details.

Alle Aufnahmeoptionen sind auch unter _Trigger > Capture_ im Omarchy-Menü (`Super + Space`) erreichbar.

## Benachrichtigungen

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + ,` | Auf neueste Benachrichtigung reagieren: sie öffnen oder ihren einzigen Button drücken, aus ihren Optionen wählen oder sie verwerfen, wenn sie keine hat  |
| `Super + Shift + ,` | Alle Benachrichtigungen verwerfen |
| `Super + Ctrl + ,` | Benachrichtigungen mit der Tastatur steuern  |
| `Super + Alt + ,` | Neueste Benachrichtigung verwerfen  |
| `Super + Shift + Alt + ,` | Benachrichtigungsverlauf öffnen  |
| `Super + Ctrl + Alt + ,` | Stummschaltung von Benachrichtigungen umschalten  |

## Stil

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Neues Theme auswählen (auch `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Theme-Hintergrund auswählen (auch `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparenz bei einem Fenster umschalten |
| `Super + Ctrl + Backspace` | Quadratisches Seitenverhältnis für einzelnes Fenster umschalten |

Zusätzliche Hintergrundbilder liegen in `~/.config/omarchy/backgrounds/<theme name>`. Auch verfügbar über _Install > Style > Background_ im Omarchy-Menü.

Alle Stiloptionen sind auch unter _Appearance_ im Omarchy-Menü (`Super + Space`) erreichbar.

## Umschalter

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Sperren bei Leerlauf umschalten |
| `Super + Ctrl + Delete` | Laptop-Display ein-/ausschalten |
| `Super + Ctrl + Alt + Delete` | Spiegelung des Laptop-Displays umschalten |
| `Super + Shift + Space` | Obere Leiste umschalten  |
| `Shift + Mute` | Zum nächsten Audioausgang wechseln |
| `Shift + Play` | Zur nächsten Medienquelle wechseln |
| `Super + Shift + Backspace` | Fensterabstände umschalten |
| `Super + Ctrl + Alt + F` | Vollbild-Desktop umschalten (obere Leiste + Fensterabstände) |

## Erinnerungen

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Erinnerung erstellen  |
| `Super + Ctrl + Alt + R` | Alle Erinnerungen ansehen  |
| `Super + Ctrl + Shift + R` | Alle Erinnerungen löschen  |

## Hinweise

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Zeit als Benachrichtigung anzeigen  |
| `Super + Ctrl + Alt + B` | Akku als Benachrichtigung anzeigen  |
| `Super + Ctrl + Alt + W` | Wetter als Benachrichtigung umschalten  |

## Tmux

Die Präfix-Taste ist `Ctrl + Space` (`Ctrl + B` funktioniert auch). Du kannst diese Belegungen in `~/.config/tmux/tmux.conf` ändern.

### Panes

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + v` | Pane daneben teilen (vertikal) |
| `Prefix + h` | Pane darunter teilen (horizontal) |
| `Prefix + x` | Pane beenden |
| `Prefix + z` | Pane-Zoom umschalten (Vollbild) |
| `Alt + Enter` | Pane darunter teilen (ohne Präfix) |
| `Alt + Shift + Enter` | Pane daneben teilen (ohne Präfix) |
| `Alt + Escape` | Pane beenden (ohne Präfix) |
| `Ctrl + Alt + Arrows` | Zwischen Panes wechseln |
| `Ctrl + Alt + Shift + Arrows` | Pane-Größe ändern |

### Fenster

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + c` | Neues Fenster |
| `Prefix + k` | Fenster beenden |
| `Prefix + r` | Fenster umbenennen |
| `Alt + 1-9` | Zu bestimmtem Fenster gehen |
| `Alt + Arrow Left/Right` | Zwischen Fenstern wechseln |
| `Alt + Shift + Arrow Left/Right` | Fenster nach links/rechts verschieben |

### Sitzungen

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + C` | Neue Sitzung |
| `Prefix + K` | Sitzung beenden |
| `Prefix + R` | Sitzung umbenennen |
| `Prefix + N` | Nächste Sitzung |
| `Prefix + P` | Vorherige Sitzung |
| `Alt + Arrow Up/Down` | Zwischen Sitzungen wechseln |
| `Prefix + s` | Sitzungen auflisten |
| `Prefix + d` | Von Sitzung trennen |

### Kopiermodus (vi-style)

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopiermodus betreten |
| `v` | Auswahl beginnen (im Kopiermodus) |
| `y` | Auswahl kopieren (im Kopiermodus) |

### Allgemein

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguration neu laden |
| `Prefix + ?` | Tmux-Tastaturbelegungen anzeigen |
| `Prefix + :` | Befehlsprompt |

### Tmux-Layout-Funktionen

Diese Funktionen müssen innerhalb einer Tmux-Sitzung ausgeführt werden.

| Befehl | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-Layout mit Editor, KI und Terminal erstellen |
| `tdlm <ai> [<second_ai>]` | Dev-Layout pro Unterverzeichnis erstellen |
| `tsl <count> <command>` | Multi-Pane-Schwarm-Layout erstellen |

## Ghostty Terminal

Das Ghostty-Terminal wird mit _Install > Terminal_ über das Omarchy-Menü installiert.

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Neuer Split darunter |
| `Ctrl + Shift + O` | Neuer Split daneben |
| `Ctrl + Alt + Arrows` | Zwischen Splits wechseln |
| `Super + Ctrl + Shift + Arrows` | Split-Größe um 10 Zeilen ändern |
| `Super + Ctrl + Shift + Alt + Arrows` | Split-Größe um 100 Zeilen ändern |
| `Ctrl + Shift + T` | Neuer Tab  |
| `Ctrl + Shift + Arrows` | Zwischen Tabs wechseln |
| `Alt + Numbers` | Zu bestimmtem Tab gehen |
| `Shift + Pg Up/Down` | Verlauf scrollen |
| `Ctrl + Left mouse` | Link im Browser öffnen |

## Dateimanager

| Tastaturkürzel              | Funktion                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Zum Pfad gehen                     |
| `Space`               | Dateivorschau (Pfeile navigieren) |
| `Alt + Up`       | Zum übergeordneten Ordner hochgehen        |

## Neovim (w/ lazyvim)

### Navigation

| Tastaturkürzel                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Befehlsoptionen anzeigen            |
| `Space Space`              | Datei per Fuzzy-Suche öffnen      |
| `Space E`                  | Seitenleiste umschalten                  |
| `Space G G`                | Git-Steuerung anzeigen               |
| `Space S G`                | Dateiinhalte durchsuchen             |
| `Ctrl + W W`               | Zwischen Seitenleiste und Editor springen |
| `Ctrl + Left/right arrow`  | Größe der Seitenleiste ändern          |
| `Shift + H`                      | Zum linken Datei-Tab gehen             |
| `Shift + L`                      | Zum rechten Datei-Tab gehen            |
| `Space B D`                | Datei-Tab schließen                  |

### In der Seitenleiste

| Tastaturkürzel                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `A`                        | Neue Datei im übergeordneten Verzeichnis hinzufügen      |
| `Shift + A`                | Neues Unterverzeichnis im übergeordneten Verzeichnis hinzufügen    |
| `D`                        | Markierte Datei/Verzeichnis löschen     |
| `M`                        | Markierte Datei/Verzeichnis verschieben       |
| `R`                        | Markierte Datei/Verzeichnis umbenennen     |
| `?`                        | Hilfe für alle Befehle anzeigen      |

[Siehe alle von LazyVim konfigurierten Neovim-Tastaturkürzel](https://www.lazyvim.org/keymaps).

## Schnelle Emojis

Du kannst `Super + Ctrl + E` nutzen, um eine vollständige Emoji-Auswahl anzuzeigen, die die Auswahl in die Zwischenablage legt, oder du kannst diese Schnellzugriffsoptionen nutzen.

| Tastaturkürzel       | EM | Hinweis       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | Lächeln      |
| `Shift + CapsLock M C` | 😂 | Weinen        |
| `Shift + CapsLock M L` | 😍 | Liebe       |
| `Shift + CapsLock M V` | ✌️ | Sieg    |
| `Shift + CapsLock M H` | ❤️ | Herz      |
| `Shift + CapsLock M Y` | 👍 | Ja        |
| `Shift + CapsLock M N` | 👎 | Nein         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | Wunsch       |
| `Shift + CapsLock M R` | 🤘 | Rock       |
| `Shift + CapsLock M K` | 😘 | Kuss       |
| `Shift + CapsLock M E` | 🙄 | Augenrollen    |
| `Shift + CapsLock M I` | 😉 | Zwinkern       |
| `Shift + CapsLock M P` | 🙏 | Beten |
| `Shift + CapsLock M D` | 🤤 | Sabbern      |
| `Shift + CapsLock M M` | 💰 | Geld      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | Toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | Begrüßung |
| `Shift + CapsLock M A` |💪 | Arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Schnelle Vervollständigungen

| Tastaturkürzel       | Vervollständigung       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Dein Name (wie bei der Einrichtung eingegeben)  |
| `Shift + CapsLock Space E` | Deine E-Mail (wie bei der Einrichtung eingegeben)  |

Du kannst weitere eigene hinzufügen, indem du `~/.XCompose` bearbeitest und dann `omarchy restart xcompose` im Terminal ausführst, damit die Änderungen übernommen werden.
