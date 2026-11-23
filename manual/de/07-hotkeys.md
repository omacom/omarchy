# Tastenkürzel

Du kannst alle wichtigen Tastaturbelegungen mit `Super + K` anzeigen (Tmux-Belegungen mit `Super + Alt + K` und Herdr-Belegungen mit `Super + Ctrl + K`).

## Wie Tastenkürzel angeordnet sind

Jedes Tastenkürzel liegt auf einer Ebene, festgelegt durch seine Modifikatortasten, und jede Ebene hat eine Aufgabe. Das hält die Tastenkürzel klar getrennt, und es bedeutet, dass du normalerweise erraten kannst, wo etwas liegt.

| Ebene | Was dort liegt | Beispiele |
| --- | --- | --- |
| `Super + key` | Das System: Fenster, Arbeitsbereiche, Layouts und Kernmenüs | `Super + Space` Omarchy-Menü, `Super + W` Fenster schließen, `Super + F` Vollbild |
| `Super + Shift + key` | Apps | `Super + Shift + B` Browser, `Super + Shift + E` E-Mail, `Super + Shift + N` Editor |
| `Super + Ctrl + key` | Panels und Systemmenüs | `Super + Ctrl + A` Audio, `Super + Ctrl + N` Netzwerk, `Super + Ctrl + C` Aufnahme-Menü |
| `Super + Ctrl + Alt + key` | Schnellaktionen und Hinweise | `Super + Ctrl + Alt + T` Uhrzeit anzeigen, `Super + Ctrl + Alt + B` Akku, `Super + Ctrl + Alt + C` Screenshot |

`Alt` zu einem Tastenkürzel hinzuzufügen ergibt eine Variante desselben, nie etwas Unzusammenhängendes:

- `Super + Shift + B` öffnet den Browser; `Super + Shift + Alt + B` öffnet ein privates Fenster
- `Super + Shift + E` öffnet E-Mail; `Super + Shift + Alt + E` beginnt eine neue
- `Super + F` geht ins Vollbild; `Super + Alt + F` geht auf volle Breite
- `Super + Ctrl + C` öffnet das Aufnahme-Menü; `Super + Ctrl + Alt + C` überspringt das Menü und macht einen Screenshot

Beim Hinzufügen eines Tastenkürzels:

1. Wähle die Ebene nach dem, was es tut, dann wähle die Taste.
2. Verschiebe kein bestehendes Tastenkürzel, um Platz zu machen. Finde eine freie Taste auf der richtigen Ebene.
3. Verwende `Alt` nur für eine Variante des Tastenkürzels ohne es.

Ein paar Tastenkürzel brechen diese Regeln, weil sie praktisch sind. `Shift` mit einem Pfeil oder `Tab` bewegt oder kehrt um, statt eine App zu öffnen, und `Print`, die Medientasten, `Alt + Tab` und `Ctrl + Alt + Del` funktionieren so, wie sie es überall sonst tun. Sie sind Ausnahmen, keine Muster zum Kopieren.

Wenn dir ein Standard nicht zusagt (sagen wir, du willst `Super + Shift + S` für Screenshots wie unter Windows), binde es in `~/.config/hypr/bindings.lua` neu.

## Navigieren

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-Menü (Apps und alles andere) |
| `Super + Alt + Space` | App-Raster |
| `Super + Escape` | Systemmenü (Ruhezustand, Neustart usw.) |
| `Super + Ctrl + L` | Computer sperren |
| `Super + W` or `Super + Q` | Fenster schließen |
| `Ctrl + Alt + Del` | Alle Fenster schließen |
| `Super + K` | Alle Tastenkürzel anzeigen |
| `Super + Alt + K` | Tmux-Tastenkürzel anzeigen |
| `Super + Ctrl + K` | Herdr-Tastenkürzel anzeigen |
| `Super + M` | Fenster ins Dock minimieren |
| `Super + T` | Fenster zwischen Tiling/Floating umschalten |
| `Super + J` | Fensterposition umschalten (horizontal/vertikal) |
| `Super + O` | Umschalten, ob ein Fenster als sticky'n'floating herauspoppt |
| `Super + L` | Durch die Layouts dwindle, scrolling und floating durchwechseln |
| `Super + Alt + L` | Layouts in umgekehrter Reihenfolge durchwechseln |
| `Super + P` | Pseudo-Fensterstil umschalten (natural v stretch) |
| `Super + F` | Vollbild |
| `Super + Alt + F` | Volle Breite |
| `Super + Ctrl + F` | Vollbild innerhalb des Fensters |
| `Super + 1…9/0` | Zu einem bestimmten Arbeitsbereich springen (0 ist 10) auf dem fokussierten Monitor |
| `Super + Tab` | Zum nächsten Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Shift + Tab` | Zum vorherigen Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Ctrl + Tab` | Zum früheren Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Shift + 1…9/0` | Fenster zum Arbeitsbereich auf dem fokussierten Monitor verschieben |
| `Super + Shift + Alt + 1…9/0` | Fenster zum Arbeitsbereich auf dem fokussierten Monitor verschieben, ohne zu folgen |
| `Super + S` | Volles Scratchpad umschalten |
| `Super + Alt + S` | Fenster ins volle Scratchpad verschieben |
| `Super + the key above Tab` (Grave auf US-Layouts) | Quake-Konsole umschalten |
| `Super + Shift + the key above Tab` (Grave auf US-Layouts) | Fenster in die Quake-Konsole verschieben |
| `Super + Shift + Ctrl + Arrows` | Fenster zum Monitor in dieser Richtung verschieben |
| `Super + Shift + Alt + Arrows` | Arbeitsbereich zum Monitor in dieser Richtung verschieben |
| `Super + Arrow` | Fokus zum Fenster in Pfeilrichtung bewegen, am Bildschirmrand zum Monitor auf dieser Seite überwechseln |
| `Super + Shift + Arrow` | Fenster mit einem anderen in Pfeilrichtung tauschen, einschließlich eines auf dem Monitor auf dieser Seite |
| `Super + Minus` | Fenster nach links vergrößern |
| `Super + Equal` | Fenster nach links verkleinern |
| `Super + Shift + Minus` | Fenster nach oben verkleinern |
| `Super + Shift + Equal` | Fenster nach unten vergrößern |
| `Super + Alt + Minus/Equal` | Gleiches Vergrößern/Verkleinern in kleineren Schritten |
| `Super + Ctrl + Minus/Equal` | Gleiches Vergrößern/Verkleinern in größeren Schritten |
| `Super + Alt + Home` | Fensterbreite speichern |
| `Super + Home` | Gespeicherte Fensterbreite wiederherstellen |
| `Super + Left Mouse` | Fenster herumziehen |
| `Super + Right Mouse` | Fenstergröße ändern |
| `Super + Scroll Wheel` | Durch Arbeitsbereiche auf dem fokussierten Monitor scrollen |
| `Super + G` | Fenstergruppierung umschalten |
| `Super + Alt + G` | Fenster aus der Gruppierung herausbewegen |
| `Super + Alt + Tab` | Zwischen Fenstern in der Gruppierung durchwechseln |
| `Super + Alt + Shift + Tab` | Rückwärts zwischen Fenstern in der Gruppierung durchwechseln |
| `Super + Alt + Scroll Wheel` | Zwischen Fenstern in der Gruppierung durchwechseln |
| `Super + Alt + 1/2/3/4/5` | Zu einem bestimmten Fenster in der Gruppierung springen |
| `Super + Alt + Arrow` | Fenster in Pfeilrichtung in eine Gruppierung bewegen, einschließlich eines auf dem Monitor auf dieser Seite |
| `Super + Ctrl + Left/Right` | Zwischen Fenstern innerhalb einer Tiling-Gruppe wechseln |
| `Super + Ctrl + Z` | Auf dem Bildschirm hineinzoomen (wiederholen für mehr Zoom) |
| `Super + Ctrl + Alt + Z` | Vollständig vom Bildschirm herauszoomen |
| `Super + /` | Vorwärts durch Monitor-Skalierungsoptionen gehen |
| `Super + Alt + /` | Rückwärts durch Monitor-Skalierungsoptionen gehen |
| `Alt + Tab` | Vorwärts durch Fenster auf dem aktiven Arbeitsbereich wechseln |
| `Alt + Shift + Tab` | Rückwärts durch Fenster auf dem aktiven Arbeitsbereich wechseln |
| `Ctrl + Alt + Tab` | Fokus vorwärts durch Monitore wechseln |
| `Ctrl + Alt + Shift + Tab` | Fokus rückwärts durch Monitore wechseln |
| `Super + I` | Eingabesprache wechseln (mit mehr als einem Layout oder einer Eingabemethode) |
| `Super + Shift + I` | Eingabesprache zurückwechseln |

Auf einem Touchpad wechseln Drei- und Vier-Finger-Wischgesten Arbeitsbereiche, verschieben Fenster und öffnen das Menü und die Quake-Konsole; siehe [Tastatur, Maus und Trackpad](34-keyboard-mouse-trackpad.md) für die Gesten.

Das Vergrößern/Verkleinern verwendet die beiden Tasten rechts von 0, egal was deine Tastatur darauf gedruckt hat: `-` und `=` auf US-Tastaturen, `+` und `´` auf dänischen und schwedischen, `+` und `\` auf norwegischen, `ß` und `´` auf deutschen, `'` und `¡` auf spanischen und `-` und `^` auf japanischen (JIS). `Super + K` listet sie so auf, wie deine Tastatur sie druckt. Auf JIS ist `Super + ^` `Super + Equal`, während `Super + Shift + -` (das `=` tippt) `Super + Shift + Minus` ist. Monitor-Skalierung und der Passwortmanager verwenden `/`; auf Layouts, die `/` nur mit Shift tippen, wie die meisten europäischen, verwenden sie stattdessen die Taste links von der rechten Shift-Taste (`-` auf dänischen und deutschen).

## Systemsteuerung

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audio-Panel |
| `Super + Ctrl + B` | Bluetooth-Panel |
| `Super + Ctrl + N` | Wi-Fi/Netzwerk-Panel |
| `Super + Ctrl + D` | Anzeige-Panel |
| `Super + Ctrl + P` | Energie-Panel |
| `Super + Ctrl + X` | Agenten-Panel |
| `Super + Ctrl + Alt + X` | Panel für lokale Modelle |
| `Super + Ctrl + Alt + D` | Kalender-Panel |
| `Super + Ctrl + Alt + E` | Weltuhr-Panel |
| `Super + Ctrl + 1-9` | Leisten-Panel nach Position umschalten |
| `Super + Ctrl + S` | Teilen-Menü (über LocalSend) |
| `Super + Ctrl + C` | Aufnahme-Steuerung (Screenshot/-Aufnahme/Picker) |
| `Super + Ctrl + O` | Menü umschalten |
| `Super + Ctrl + H` | Hardware-Menü |
| `Super + Ctrl + E` | Emoji-Auswahl |
| `Super + Ctrl + .` | Medien transkodieren |
| `Super + Shift + Ctrl + A` | Deinen Standard-Agenten starten |
| `Power` key | Systemmenü |
| `Super + Shift + Copilot` key | Omarchy-Menü |

## Anpassungen

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximale Bildschirmhelligkeit |
| `Shift + Brightness Down` | Minimale Bildschirmhelligkeit |
| `Alt + Brightness Up/Down` | Präzise Helligkeitsänderungen um 1% |
| `Alt + Volume Up/Down` | Präzise Lautstärkeänderungen um 1% |
| `Keyboard Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler |
| `Keyboard Backlight` | Stufen der Tastaturbeleuchtung durchwechseln |
| `Ctrl + Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler, bei Tastaturen ohne eigene Tasten dafür |
| `Mic Mute` | Das Mikrofon stumm schalten |
| `Shift + Mute` | Audioausgabe wechseln |
| `Touchpad Toggle` | Das Touchpad ein- oder ausschalten |
| `Display` key | Das Arbeitsbereich-Layout durchwechseln |
| `Alt + Play` | Nächster Titel |
| `Alt + Shift + Play` | Vorheriger Titel |

## Apps starten

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux-Terminal |
| `Super + Ctrl + Return` | Herdr (Agenten-Manager) |
| `Super + Shift + Return` or `Super + Shift + B` | Browser |
| `Super + Shift + Alt + B` | Browser (privat/Inkognito) |
| `Super + Shift + F` | Dateimanager |
| `Super + Shift + Alt + F` | Dateimanager im cwd des Terminals |
| `Super + Shift + M` | Musik (Spotify) |
| `Super + Shift + Alt + M` | Musik (cliamp) |
| `Super + Shift + /` | Passwortmanager (1password) |
| `Super + Shift + Q` or `Calculator` key | Taschenrechner (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, nach der Installation) |
| `Super + Shift + T` | Aktivität (btop) |
| `Super + Shift + N` | Editor (Plain oder dein gewählter Standard) |
| `Super + Shift + C` | Kalender ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-Mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Neue E-Mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Dein Standard-Agent oder ChatGPT, bis du einen auswählst |
| `Super + Shift + Alt + A` | KI (Grok) |
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

Belegungen in `~/.config/hypr/bindings.lua` ändern/hinzufügen.

## Universelle Zwischenablage

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + A` | Alles auswählen in Apps, die `Ctrl + A` unterstützen |
| `Super + C` | Kopieren |
| `Super + X` | Ausschneiden (nicht im Terminal) |
| `Super + V` | Einfügen |
| `Super + Ctrl + V` | Zwischenablage-Manager |

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V` zum Kopieren und Einfügen im Terminal und `Ctrl + C/V`, um es überall sonst zu tun. Diese vereinheitlichten Zwischenablage-Tastenkürzel von Omarchy funktionieren überall.

## Aufnahme

| Tastenkürzel | Funktion |
| ------------------- | ------------------------------ |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot (dieselbe Aufnahme, für Tastaturen ohne Print Screen-Taste) |
| `Super + Ctrl + C` | Aufnahme-Menü |
| `Alt + Print Screen` | Bildschirmaufnahme |
| `Super + Shift + Ctrl + Alt + C` | Bildschirmaufnahme ohne Audio, Menü überspringen (erneut drücken zum Stoppen) |
| `Super + Print Screen` | Farbauswahl |
| `Super + Ctrl + Print Screen` | Textextraktion in die Zwischenablage |
| `Super + Alt + [` | Webcam-Overlay während der Aufnahme kleiner machen |
| `Super + Alt + ]` | Webcam-Overlay während der Aufnahme größer machen |
| `Alt + Shift + L` | Aktuelle URL aus Webapp oder Browser kopieren |
| `Alt + Shift + D` | Das Video auf der aktuellen Seite nach `~/Videos` herunterladen |
| `Alt + Space` | Diktat starten/stoppen (erfordert _Setup > Defaults > Dictation_) |
| `Right Alt` | Halten zum Diktieren (erfordert _Setup > Defaults > Dictation_) |

Bei Bildschirmaufnahmen fragt das Tastenkürzel zuerst, welchen Ton du willst, dann startet die Aufnahme. Drücke es erneut zum Stoppen. Siehe [Screenshots und Aufnahme](12-screenshots-recording.md) für die Details.

Alle Aufnahmeoptionen sind auch unter _Trigger > Capture_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Benachrichtigungen

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + ,` | Auf die neueste Benachrichtigung reagieren: sie öffnen oder ihre einzige Schaltfläche drücken, aus ihren Optionen wählen oder sie verwerfen, wenn sie keine hat |
| `Super + Shift + ,` | Alle Benachrichtigungen verwerfen |
| `Super + Ctrl + ,` | Benachrichtigungen mit der Tastatur steuern |
| `Super + Alt + ,` | Neueste Benachrichtigung verwerfen |
| `Super + Shift + Alt + ,` | Benachrichtigungsverlauf öffnen |
| `Super + Ctrl + Alt + ,` | Stummschalten von Benachrichtigungen umschalten |

## Stil

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Ein neues Theme auswählen (auch `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Theme-Hintergrund auswählen (auch `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparenz bei einem Fenster umschalten |
| `Super + Ctrl + Backspace` | Quadratisches Seitenverhältnis für ein einzelnes Fenster umschalten |

Zusätzliche Hintergrundbilder liegen in `~/.config/omarchy/backgrounds/<theme name>`. Auch verfügbar über _Install > Style > Background_ im Omarchy-Menü.

Alle Stiloptionen sind auch unter _Appearance_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Umschalten

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Sperren bei Inaktivität umschalten |
| `Super + Ctrl + Delete` | Laptop-Display ein-/ausschalten |
| `Super + Ctrl + Alt + Delete` | Spiegeln des Laptop-Displays umschalten |
| `Super + Shift + Space` | Die obere Leiste umschalten |
| `Shift + Mute` | Zum nächsten Audioausgang wechseln |
| `Shift + Play` | Zur nächsten Medienquelle wechseln |
| `Super + Shift + Backspace` | Fensterabstände umschalten |
| `Super + Ctrl + Alt + F` | Vollbild-Desktop umschalten (obere Leiste + Fensterabstände) |

## Erinnerungen

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eine Erinnerung erstellen |
| `Super + Ctrl + Alt + R` | Alle Erinnerungen anzeigen |
| `Super + Ctrl + Shift + R` | Alle Erinnerungen löschen |

## Hinweise

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Uhrzeit als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + B` | Akku als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + W` | Wetter als Benachrichtigung umschalten |

## Tmux

Die Prefix-Taste ist `Ctrl + Space` (`Ctrl + B` funktioniert auch). Du kannst diese Belegungen in `~/.config/tmux/tmux.conf` ändern.

### Panes

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Prefix + v` | Pane daneben teilen (vertikal) |
| `Prefix + h` | Pane darunter teilen (horizontal) |
| `Prefix + x` | Pane beenden |
| `Prefix + z` | Pane-Zoom umschalten (Vollbild) |
| `Alt + Enter` | Pane darunter teilen (ohne Prefix) |
| `Alt + Shift + Enter` | Pane daneben teilen (ohne Prefix) |
| `Alt + Escape` | Pane beenden (ohne Prefix) |
| `Ctrl + Alt + Arrows` | Zwischen Panes wechseln |
| `Ctrl + Alt + Shift + Arrows` | Größe von Panes ändern |

### Fenster

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Prefix + c` | Neues Fenster |
| `Prefix + k` | Fenster beenden |
| `Prefix + r` | Fenster umbenennen |
| `Alt + 1-9` | Zu einem bestimmten Fenster gehen |
| `Alt + Arrow Left/Right` | Zwischen Fenstern wechseln |
| `Alt + Shift + Arrow Left/Right` | Fenster nach links/rechts verschieben |

### Sitzungen

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Prefix + C` | Neue Sitzung |
| `Prefix + K` | Sitzung beenden |
| `Prefix + R` | Sitzung umbenennen |
| `Prefix + N` | Nächste Sitzung |
| `Prefix + P` | Vorherige Sitzung |
| `Alt + Arrow Up/Down` | Zwischen Sitzungen wechseln |
| `Prefix + s` | Sitzungen auflisten |
| `Prefix + d` | Von der Sitzung trennen |

### Kopiermodus (vi-Stil)

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopiermodus betreten |
| `v` | Auswahl beginnen (im Kopiermodus) |
| `y` | Auswahl kopieren (im Kopiermodus) |

### Allgemein

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguration neu laden |
| `Prefix + ?` | Tmux-Tastaturbelegungen anzeigen |
| `Prefix + :` | Eingabeaufforderung für Befehle |

### Tmux-Layout-Funktionen

Diese Funktionen müssen innerhalb einer Tmux-Sitzung ausgeführt werden.

| Befehl | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-Layout mit Editor, KI und Terminal erstellen |
| `tdlm <ai> [<second_ai>]` | Dev-Layout pro Unterverzeichnis erstellen |
| `tsl <count> <command>` | Multi-Pane-Schwarm-Layout erstellen |

## Ghostty Terminal

Das Ghostty-Terminal wird über _Install > Terminal_ im Omarchy-Menü installiert.

| Tastenkürzel | Funktion |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Neue Aufteilung darunter |
| `Ctrl + Shift + O` | Neue Aufteilung daneben |
| `Ctrl + Alt + Arrows` | Zwischen Aufteilungen wechseln |
| `Super + Ctrl + Shift + Arrows` | Aufteilung um 10 Zeilen in der Größe ändern |
| `Super + Ctrl + Shift + Alt + Arrows` | Aufteilung um 100 Zeilen in der Größe ändern |
| `Ctrl + Shift + T` | Neuer Tab |
| `Ctrl + Shift + Arrows` | Zwischen Tabs wechseln |
| `Alt + Numbers` | Zu einem bestimmten Tab gehen |
| `Shift + Pg Up/Down` | Den Verlauf scrollen |
| `Ctrl + Left mouse` | Link im Browser öffnen |

## Dateimanager

| Tastenkürzel | Funktion |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Zu einem Pfad gehen |
| `Space` | Datei-Vorschau (Pfeile navigieren) |
| `Alt + Up` | Zum übergeordneten Ordner hochgehen |

## Neovim (w/ lazyvim)

### Navigation

| Tastenkürzel | Funktion |
| ------------------------ | ------------------------------- |
| `Space` | Befehlsoptionen anzeigen |
| `Space Space` | Datei per Fuzzy-Suche öffnen |
| `Space E` | Seitenleiste umschalten |
| `Space G G` | Git-Steuerung anzeigen |
| `Space S G` | Dateiinhalte durchsuchen |
| `Ctrl + W W` | Zwischen Seitenleiste und Editor springen |
| `Ctrl + Left/right arrow` | Größe der Seitenleiste ändern |
| `Shift + H` | Zum linken Datei-Tab gehen |
| `Shift + L` | Zum rechten Datei-Tab gehen |
| `Space B D` | Datei-Tab schließen |

### In der Seitenleiste

| Tastenkürzel | Funktion |
| ------------------------ | ------------------------------- |
| `A` | Neue Datei im übergeordneten Verzeichnis hinzufügen |
| `Shift + A` | Neues Unterverzeichnis im übergeordneten Verzeichnis hinzufügen |
| `D` | Markierte Datei/Verzeichnis löschen |
| `M` | Markierte Datei/Verzeichnis verschieben |
| `R` | Markierte Datei/Verzeichnis umbenennen |
| `?` | Hilfe für alle Befehle anzeigen |

[Siehe alle Neovim-Tastenkürzel, die von LazyVim konfiguriert werden](https://www.lazyvim.org/keymaps).

## Schnelle Emojis

Du kannst `Super + Ctrl + E` verwenden, um eine vollständige Emoji-Auswahl anzuzeigen, die die Auswahl in die Zwischenablage legt, oder du kannst diese Schnellzugriffsoptionen verwenden.

| Tastenkürzel | EM | Hinweis |
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
| `Shift + CapsLock M B` |🤯 | Explodieren |

## Schnelle Vervollständigungen

| Tastenkürzel | Vervollständigung |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (Gedankenstrich) |
| `Shift + CapsLock Space N` | Dein Name (wie bei der Einrichtung eingegeben) |
| `Shift + CapsLock Space E` | Deine E-Mail (wie bei der Einrichtung eingegeben) |

Du kannst eigene hinzufügen, indem du `~/.XCompose` bearbeitest und dann `omarchy restart xcompose` im Terminal ausführst, damit die Änderungen übernommen werden.
