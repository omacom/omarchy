# Tastaturkürzel

Du kannst alle wichtigen Tastaturbindungen mit `Super + K` sehen (Tmux-Bindungen mit `Super + Alt + K` und Herdr-Bindungen mit `Super + Ctrl + K`).

## Wie Tastaturkürzel aufgebaut sind

Jeder Hotkey liegt auf einer Ebene, festgelegt durch seine Modifikatoren, und jede Ebene hat eine Aufgabe. Das verhindert, dass die Hotkeys ineinander verschwimmen, und es bedeutet, dass du meist erraten kannst, wo etwas liegt.

| Ebene | Was dort liegt | Beispiele |
| --- | --- | --- |
| `Super + key` | Das System: Fenster, Workspaces, Layouts und Hauptmenüs | `Super + Space` Omarchy-Menü, `Super + W` Fenster schließen, `Super + F` Vollbild |
| `Super + Shift + key` | Apps | `Super + Shift + B` Browser, `Super + Shift + E` E-Mail, `Super + Shift + N` Editor |
| `Super + Ctrl + key` | Panels und Systemmenüs | `Super + Ctrl + A` Audio, `Super + Ctrl + N` Netzwerk, `Super + Ctrl + C` Aufnahme-Menü |
| `Super + Ctrl + Alt + key` | Schnellaktionen und Hinweise | `Super + Ctrl + Alt + T` Zeit anzeigen, `Super + Ctrl + Alt + B` Akku, `Super + Ctrl + Alt + C` Screenshot |

`Alt` zu einem Hotkey hinzuzufügen ergibt eine Variante desselben, niemals etwas Unverbundenes:

- `Super + Shift + B` öffnet den Browser; `Super + Shift + Alt + B` öffnet ein privates Fenster
- `Super + Shift + E` öffnet E-Mail; `Super + Shift + Alt + E` beginnt eine neue
- `Super + F` geht in Vollbild; `Super + Alt + F` geht auf volle Breite
- `Super + Ctrl + C` öffnet das Aufnahme-Menü; `Super + Ctrl + Alt + C` überspringt das Menü und macht einen Screenshot

Beim Hinzufügen eines Hotkeys:

1. Wähle die Ebene danach, was er tut, dann wähle die Taste.
2. Verschiebe keinen bestehenden Hotkey, um Platz zu machen. Finde eine freie Taste auf der richtigen Ebene.
3. Verwende `Alt` nur für eine Variante des Hotkeys ohne es.

Einige Hotkeys brechen diese Regeln, weil sie praktisch sind. `Shift` mit einem Pfeil oder `Tab` verschiebt oder kehrt um, statt eine App zu öffnen, und `Print`, die Medientasten, `Alt + Tab` und `Ctrl + Alt + Del` funktionieren so wie überall sonst. Sie sind Ausnahmen, keine Muster zum Kopieren.

Wenn dir ein Standard nicht zusagt (sagen wir, du willst `Super + Shift + S` für Screenshots wie unter Windows), binde ihn in `~/.config/hypr/bindings.lua` neu.

## Navigieren

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-Menü (Apps und alles andere) |
| `Super + Alt + Space` | App-Raster |
| `Super + Escape` | Systemmenü (Ruhezustand, Neustart usw.) |
| `Super + Ctrl + L` | Computer sperren |
| `Super + W` or `Super + Q` | Fenster schließen |
| `Ctrl + Alt + Del` | Alle Fenster schließen |
| `Super + K` | Alle Hotkeys anzeigen |
| `Super + Alt + K` | Tmux-Hotkeys anzeigen |
| `Super + Ctrl + K` | Herdr-Hotkeys anzeigen |
| `Super + M` | Fenster in das Dock minimieren |
| `Super + T` | Fenster zwischen Tiling/Floating umschalten |
| `Super + J` | Fensterposition umschalten (horizontal/vertikal) |
| `Super + O` | Herausgelöstes Fenster in sticky'n'floating umschalten |
| `Super + L` | Durch die Layouts Dwindle, Scrolling und Floating wechseln |
| `Super + Alt + L` | Durch die Layouts in umgekehrter Reihenfolge wechseln |
| `Super + P` | Pseudo-Fensterstil umschalten (natürlich vs. gestreckt) |
| `Super + F` | Vollbild |
| `Super + Alt + F` | Volle Breite |
| `Super + Ctrl + F` | Vollbild innerhalb des Fensters |
| `Super + 1…9/0` | Zu bestimmtem Workspace auf dem fokussierten Monitor springen (0 ist 10) |
| `Super + Tab` | Zum nächsten Workspace auf dem fokussierten Monitor springen |
| `Super + Shift + Tab` | Zum vorherigen Workspace auf dem fokussierten Monitor springen |
| `Super + Ctrl + Tab` | Zum früheren Workspace auf dem fokussierten Monitor springen |
| `Super + Shift + 1…9/0` | Fenster zum Workspace auf dem fokussierten Monitor verschieben |
| `Super + Shift + Alt + 1…9/0` | Fenster zum Workspace auf dem fokussierten Monitor verschieben, ohne zu folgen |
| `Super + S` | Vollständiges Scratchpad umschalten |
| `Super + Alt + S` | Fenster in vollständiges Scratchpad verschieben |
| `Super + Grave` | Quake-Konsole umschalten |
| `Super + Shift + Grave` | Fenster zur Quake-Konsole verschieben |
| `Super + Shift + Ctrl + Arrows` | Fenster auf den Monitor in dieser Richtung verschieben |
| `Super + Shift + Alt + Arrows` | Workspace auf den Monitor in dieser Richtung verschieben |
| `Super + Arrow` | Fokus auf Fenster in Pfeilrichtung verschieben, am Bildschirmrand auf den Monitor auf dieser Seite wechseln |
| `Super + Shift + Arrow` | Fenster mit einem anderen in Pfeilrichtung tauschen, einschließlich einem auf dem Monitor auf dieser Seite |
| `Super + Minus` | Fenster nach links erweitern |
| `Super + Equal` | Fenster nach links verkleinern |
| `Super + Shift + Minus` | Fenster nach oben verkleinern |
| `Super + Shift + Equal` | Fenster nach unten erweitern |
| `Super + Alt + Minus/Equal` | Gleiches Vergrößern/Verkleinern in kleineren Schritten |
| `Super + Ctrl + Minus/Equal` | Gleiches Vergrößern/Verkleinern in größeren Schritten |
| `Super + Alt + Home` | Fensterbreite speichern |
| `Super + Home` | Gespeicherte Fensterbreite wiederherstellen |
| `Super + Left Mouse` | Fenster ziehen |
| `Super + Right Mouse` | Fenstergröße ändern |
| `Super + Scroll Wheel` | Durch Workspaces auf dem fokussierten Monitor scrollen |
| `Super + G` | Fenstergruppierung umschalten |
| `Super + Alt + G` | Fenster aus Gruppierung heraus verschieben |
| `Super + Alt + Tab` | Zwischen Fenstern in Gruppierung wechseln |
| `Super + Alt + Shift + Tab` | Rückwärts zwischen Fenstern in Gruppierung wechseln |
| `Super + Alt + Scroll Wheel` | Zwischen Fenstern in Gruppierung wechseln |
| `Super + Alt + 1/2/3/4/5` | Zu bestimmtem Fenster in Gruppierung springen |
| `Super + Alt + Arrow` | Fenster in Pfeilrichtung in Gruppierung verschieben, einschließlich einem auf dem Monitor auf dieser Seite |
| `Super + Ctrl + Left/Right` | Zwischen Fenstern innerhalb einer Tiling-Gruppe wechseln |
| `Super + Ctrl + Z` | Auf Bildschirm hineinzoomen (wiederholen für mehr Zoom) |
| `Super + Ctrl + Alt + Z` | Vollständig vom Bildschirm herauszoomen |
| `Super + /` | Schrittweise vorwärts durch Monitor-Skalierungsoptionen |
| `Super + Alt + /` | Schrittweise rückwärts durch Monitor-Skalierungsoptionen |
| `Alt + Tab` | Vorwärts durch Fenster auf dem aktiven Workspace wechseln |
| `Alt + Shift + Tab` | Rückwärts durch Fenster auf dem aktiven Workspace wechseln |
| `Ctrl + Alt + Tab` | Fokus vorwärts durch Monitore wechseln |
| `Ctrl + Alt + Shift + Tab` | Fokus rückwärts durch Monitore wechseln |
| `Super + I` | Eingabesprache wechseln (mit mehr als einem Layout oder einer Eingabemethode) |
| `Super + Shift + I` | Eingabesprache zurückwechseln |

Auf einem Touchpad wechseln Drei- und Vier-Finger-Wischgesten Workspaces, verschieben Fenster und öffnen das Menü und die Quake-Konsole; siehe [Tastatur, Maus und Trackpad](34-keyboard-mouse-trackpad.md) für die Gesten.

Tastenkürzel zur Größenänderung verwenden die physischen Tasten `code:20` und `code:21` (XKB `<AE11>` und `<AE12>`), unabhängig von den auf der Tastatur aufgedruckten Zeichen. Auf US-Tastaturen sind diese Tasten `-` und `=`; auf japanischen (JIS) Tastaturen sind sie `-` und `^`; auf spanischen Tastaturen sind sie `'` und `¡`. Auf JIS ist `Super + ^` `Super + Equal`, während `Super + Shift + -` (das `=` tippt) `Super + Shift + Minus` ist.

## Systemsteuerung

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audio-Panel |
| `Super + Ctrl + B` | Bluetooth-Panel |
| `Super + Ctrl + N` | WLAN/Netzwerk-Panel |
| `Super + Ctrl + D` | Anzeige-Panel |
| `Super + Ctrl + P` | Energie-Panel |
| `Super + Ctrl + X` | Agents-Panel |
| `Super + Ctrl + Alt + X` | Panel für lokale Modelle |
| `Super + Ctrl + Alt + D` | Kalender-Panel |
| `Super + Ctrl + Alt + E` | Weltuhr-Panel |
| `Super + Ctrl + 1-9` | Leisten-Panel nach Position umschalten |
| `Super + Ctrl + S` | Teilen-Menü (über LocalSend) |
| `Super + Ctrl + C` | Aufnahmesteuerung (Screenshot/-Aufnahme/Picker) |
| `Super + Ctrl + O` | Menü umschalten |
| `Super + Ctrl + H` | Hardware-Menü |
| `Super + Ctrl + E` | Emoji-Auswahl |
| `Super + Ctrl + .` | Medien transkodieren |
| `Super + Shift + Ctrl + A` | Einen AI-Agent auswählen |
| `Power` key | Systemmenü |
| `Super + Shift + Copilot` key | Omarchy-Menü |

## Anpassungen

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximale Bildschirmhelligkeit |
| `Shift + Brightness Down` | Minimale Bildschirmhelligkeit |
| `Alt + Brightness Up/Down` | Präzise Helligkeitsänderungen um 1 % |
| `Alt + Volume Up/Down` | Präzise Lautstärkeänderungen um 1 % |
| `Keyboard Brightness Up/Down` | Tastaturhintergrundbeleuchtung heller/dunkler |
| `Keyboard Backlight` | Die Stufen der Tastaturhintergrundbeleuchtung durchwechseln |
| `Ctrl + Brightness Up/Down` | Tastaturhintergrundbeleuchtung heller/dunkler, auf Tastaturen ohne eigene Tasten |
| `Mic Mute` | Das Mikrofon stummschalten |
| `Shift + Mute` | Audioausgabe wechseln |
| `Touchpad Toggle` | Das Touchpad ein- oder ausschalten |
| `Display` key | Das Workspace-Layout durchwechseln |
| `Alt + Play` | Nächster Titel |
| `Alt + Shift + Play` | Vorheriger Titel |

## Apps starten

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux-Terminal |
| `Super + Ctrl + Return` | Herdr (Agent-Manager) |
| `Super + Shift + Return` or `Super + Shift + B` | Browser |
| `Super + Shift + Alt + B` | Browser (privat/Inkognito) |
| `Super + Shift + F` | Dateimanager |
| `Super + Shift + Alt + F` | Dateimanager im cwd des Terminals |
| `Super + Shift + M` | Musik (Spotify) |
| `Super + Shift + Alt + M` | Musik (cliamp) |
| `Super + Shift + /` | Passwortmanager (1password) |
| `Super + Shift + Q` or `Calculator` key | Taschenrechner (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, sobald installiert) |
| `Super + Shift + T` | Aktivität (btop) |
| `Super + Shift + N` | Editor (Plain, oder dein gewählter Standard) |
| `Super + Shift + C` | Kalender ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-Mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Neue E-Mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Messenger (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Messenger (WhatsApp) |
| `Super + Shift + Ctrl + G` | Messenger (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Schreiben (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (neuer Beitrag) |
| `Super + Shift + Y` | YouTube |

Bindungen in `~/.config/hypr/bindings.lua` ändern/hinzufügen.

## Universelle Zwischenablage

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Super + A` | Alles auswählen in Apps, die `Ctrl + A` unterstützen |
| `Super + C` | Kopieren |
| `Super + X` | Ausschneiden (nicht im Terminal) |
| `Super + V` | Einfügen |
| `Super + Ctrl + V` | Zwischenablage-Manager |

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V`, um im Terminal zu kopieren und einzufügen, und `Ctrl + C/V`, um es überall sonst zu tun. Diese vereinheitlichten Omarchy-Zwischenablage-Hotkeys funktionieren überall.

## Aufnahme

| Hotkey | Funktion |
| ------------------- | ------------------------------ |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot (derselbe Shot, für Tastaturen ohne Print Screen-Taste) |
| `Super + Ctrl + C` | Aufnahme-Menü |
| `Alt + Print Screen` | Bildschirmaufnahme |
| `Super + Shift + Ctrl + Alt + C` | Bildschirmaufnahme ohne Audio, Menü überspringen (erneut drücken zum Stoppen) |
| `Super + Print Screen` | Farbauswahl |
| `Super + Ctrl + Print Screen` | Textextraktion in Zwischenablage |
| `Super + Alt + [` | Webcam-Overlay während der Aufnahme kleiner machen |
| `Super + Alt + ]` | Webcam-Overlay während der Aufnahme größer machen |
| `Alt + Shift + L` | Aktuelle URL aus Webapp oder Browser kopieren |
| `Alt + Shift + D` | Das Video auf der aktuellen Seite nach `~/Videos` herunterladen |
| `Alt + Space` | Diktat starten/stoppen (erfordert _Setup > Defaults > Dictation_) |
| `Right Alt` | Gedrückt halten zum Diktieren (erfordert _Setup > Defaults > Dictation_) |

Bei Bildschirmaufnahmen fragt der Hotkey zuerst, welchen Ton du willst, dann startet er die Aufnahme. Drücke ihn erneut zum Stoppen. Siehe [Screenshots und Aufnahme](12-screenshots-recording.md) für die Details.

Alle Aufnahmeoptionen sind auch unter _Trigger > Capture_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Benachrichtigungen

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Super + ,` | Auf neueste Benachrichtigung reagieren: sie öffnen oder ihren einzigen Button drücken, aus ihren Optionen wählen oder sie verwerfen, wenn sie keine hat |
| `Super + Shift + ,` | Alle Benachrichtigungen verwerfen |
| `Super + Ctrl + ,` | Benachrichtigungen mit der Tastatur steuern |
| `Super + Alt + ,` | Neueste Benachrichtigung verwerfen |
| `Super + Shift + Alt + ,` | Benachrichtigungsverlauf öffnen |
| `Super + Ctrl + Alt + ,` | Stummschalten von Benachrichtigungen umschalten |

## Stil

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Neues Theme auswählen (auch `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Theme-Hintergrund auswählen (auch `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparenz bei einem Fenster umschalten |
| `Super + Ctrl + Backspace` | Quadratisches Seitenverhältnis für einzelnes Fenster umschalten |

Zusätzliche Hintergrundbilder liegen in `~/.config/omarchy/backgrounds/<theme name>`. Auch verfügbar über _Install > Style > Background_ im Omarchy-Menü.

Alle Stiloptionen sind auch unter _Appearance_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Umschalter

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Sperren bei Inaktivität umschalten |
| `Super + Ctrl + Delete` | Laptop-Anzeige ein/aus umschalten |
| `Super + Ctrl + Alt + Delete` | Spiegelung der Laptop-Anzeige umschalten |
| `Super + Shift + Space` | Die obere Leiste umschalten |
| `Shift + Mute` | Zur nächsten Audioausgabe wechseln |
| `Shift + Play` | Zur nächsten Medienquelle wechseln |
| `Super + Shift + Backspace` | Fensterabstände umschalten |
| `Super + Ctrl + Alt + F` | Vollbild-Desktop umschalten (obere Leiste + Fensterabstände) |

## Erinnerungen

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eine Erinnerung erstellen |
| `Super + Ctrl + Alt + R` | Alle Erinnerungen ansehen |
| `Super + Ctrl + Shift + R` | Alle Erinnerungen löschen |

## Hinweise

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Zeit als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + B` | Akku als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + W` | Wetter als Benachrichtigung umschalten |

## Tmux

Die Prefix-Taste ist `Ctrl + Space` (`Ctrl + B` funktioniert auch). Du kannst diese Bindungen in `~/.config/tmux/tmux.conf` ändern.

### Panes

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Prefix + v` | Pane daneben teilen (vertikal) |
| `Prefix + h` | Pane darunter teilen (horizontal) |
| `Prefix + x` | Pane killen |
| `Prefix + z` | Pane-Zoom umschalten (Vollbild) |
| `Alt + Enter` | Pane darunter teilen (ohne Prefix) |
| `Alt + Shift + Enter` | Pane daneben teilen (ohne Prefix) |
| `Alt + Escape` | Pane killen (ohne Prefix) |
| `Ctrl + Alt + Arrows` | Zwischen Panes wechseln |
| `Ctrl + Alt + Shift + Arrows` | Größe der Panes ändern |

### Fenster

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Prefix + c` | Neues Fenster |
| `Prefix + k` | Fenster killen |
| `Prefix + r` | Fenster umbenennen |
| `Alt + 1-9` | Zu bestimmtem Fenster gehen |
| `Alt + Arrow Left/Right` | Zwischen Fenstern wechseln |
| `Alt + Shift + Arrow Left/Right` | Fenster nach links/rechts verschieben |

### Sitzungen

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Prefix + C` | Neue Sitzung |
| `Prefix + K` | Sitzung killen |
| `Prefix + R` | Sitzung umbenennen |
| `Prefix + N` | Nächste Sitzung |
| `Prefix + P` | Vorherige Sitzung |
| `Alt + Arrow Up/Down` | Zwischen Sitzungen wechseln |
| `Prefix + s` | Sitzungen auflisten |
| `Prefix + d` | Von Sitzung trennen |

### Kopiermodus (vi-Stil)

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopiermodus betreten |
| `v` | Auswahl beginnen (im Kopiermodus) |
| `y` | Auswahl kopieren (im Kopiermodus) |

### Allgemein

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguration neu laden |
| `Prefix + ?` | Tmux-Tastenbindungen anzeigen |
| `Prefix + :` | Kommandoeingabe |

### Tmux-Layoutfunktionen

Diese Funktionen müssen innerhalb einer Tmux-Sitzung ausgeführt werden.

| Befehl | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-Layout mit Editor, AI und Terminal erstellen |
| `tdlm <ai> [<second_ai>]` | Dev-Layout pro Unterverzeichnis erstellen |
| `tsl <count> <command>` | Multi-Pane-Schwarm-Layout erstellen |

## Ghostty-Terminal

Das Ghostty-Terminal wird mit _Install > Terminal_ über das Omarchy-Menü installiert.

| Hotkey | Funktion |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Neue Teilung darunter |
| `Ctrl + Shift + O` | Neue Teilung daneben |
| `Ctrl + Alt + Arrows` | Zwischen Teilungen wechseln |
| `Super + Ctrl + Shift + Arrows` | Größe der Teilung um 10 Zeilen ändern |
| `Super + Ctrl + Shift + Alt + Arrows` | Größe der Teilung um 100 Zeilen ändern |
| `Ctrl + Shift + T` | Neuer Tab |
| `Ctrl + Shift + Arrows` | Zwischen Tabs wechseln |
| `Alt + Numbers` | Zu bestimmtem Tab gehen |
| `Shift + Pg Up/Down` | Den Verlauf scrollen |
| `Ctrl + Left mouse` | Link im Browser öffnen |

## Dateimanager

| Hotkey | Funktion |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Zu Pfad gehen |
| `Space` | Dateivorschau (Pfeile navigieren) |
| `Alt + Up` | Zum übergeordneten Ordner hochgehen |

## Neovim (mit lazyvim)

### Navigation

| Hotkey | Funktion |
| ------------------------ | ------------------------------- |
| `Space` | Befehlsoptionen anzeigen |
| `Space Space` | Datei über Fuzzy-Suche öffnen |
| `Space E` | Seitenleiste umschalten |
| `Space G G` | Git-Steuerung anzeigen |
| `Space S G` | Dateiinhalt durchsuchen |
| `Ctrl + W W` | Zwischen Seitenleiste und Editor springen |
| `Ctrl + Left/right arrow` | Größe der Seitenleiste ändern |
| `Shift + H` | Zum linken Datei-Tab gehen |
| `Shift + L` | Zum rechten Datei-Tab gehen |
| `Space B D` | Datei-Tab schließen |

### In der Seitenleiste

| Hotkey | Funktion |
| ------------------------ | ------------------------------- |
| `A` | Neue Datei im übergeordneten Verzeichnis hinzufügen |
| `Shift + A` | Neues Unterverzeichnis im übergeordneten Verzeichnis hinzufügen |
| `D` | Markierte Datei/Verzeichnis löschen |
| `M` | Markierte Datei/Verzeichnis verschieben |
| `R` | Markierte Datei/Verzeichnis umbenennen |
| `?` | Hilfe für alle Befehle anzeigen |

[Siehe alle von LazyVim konfigurierten Neovim-Hotkeys](https://www.lazyvim.org/keymaps).

## Schnelle Emojis

Du kannst `Super + Ctrl + E` verwenden, um eine vollständige Emoji-Auswahl anzuzeigen, die die Auswahl in die Zwischenablage legt, oder du kannst diese Schnellzugriffsoptionen verwenden.

| Hotkey | EM | Hinweis |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | Lächeln |
| `Shift + CapsLock M C` | 😂 | Weinen |
| `Shift + CapsLock M L` | 😍 | Liebe |
| `Shift + CapsLock M V` | ✌️ | Sieg |
| `Shift + CapsLock M H` | ❤️ | Herz |
| `Shift + CapsLock M Y` | 👍 | Ja |
| `Shift + CapsLock M N` | 👎 | Nein |
| `Shift + CapsLock M F` | 🖕 | Fuck |
| `Shift + CapsLock M W` | 🤞 | Wunsch |
| `Shift + CapsLock M R` | 🤘 | Rock |
| `Shift + CapsLock M K` | 😘 | Kuss |
| `Shift + CapsLock M E` | 🙄 | Augenrollen |
| `Shift + CapsLock M I` | 😉 | Zwinkern |
| `Shift + CapsLock M P` | 🙏 | Beten |
| `Shift + CapsLock M D` | 🤤 | Sabbern |
| `Shift + CapsLock M M` | 💰 | Geld |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | Toast |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | Begrüßung |
| `Shift + CapsLock M A` |💪 | Arm |
| `Shift + CapsLock M B` |🤯 | weggeblasen |

## Schnelle Vervollständigungen

| Hotkey | Vervollständigung |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (Geviertstrich) |
| `Shift + CapsLock Space N` | Dein Name (wie bei der Einrichtung eingegeben) |
| `Shift + CapsLock Space E` | Deine E-Mail (wie bei der Einrichtung eingegeben) |

Du kannst weitere eigene hinzufügen, indem du `~/.XCompose` bearbeitest und dann `omarchy restart xcompose` im Terminal ausführst, damit die Änderungen übernommen werden.
