# Tastaturkürzel

Du siehst alle wichtigen Tastaturbelegungen mit `Super + K` (Tmux-Belegungen mit `Super + Alt + K` und Herdr-Belegungen mit `Super + Ctrl + K`).

## Wie Tastaturkürzel angeordnet sind

Jedes Tastaturkürzel liegt auf einer Ebene, die durch seine Modifikatoren bestimmt wird, und jede Ebene hat eine Aufgabe. So verschwimmen die Tastaturkürzel nicht miteinander, und du kannst meist erraten, wo etwas zu finden ist.

| Ebene | Was dort zu finden ist | Beispiele |
| --- | --- | --- |
| `Super + key` | Das System: Fenster, Workspaces, Layouts und Kernmenüs | `Super + Space` Omarchy-Menü, `Super + W` Fenster schließen, `Super + F` Vollbild |
| `Super + Shift + key` | Apps | `Super + Shift + B` Browser, `Super + Shift + E` E-Mail, `Super + Shift + N` Editor |
| `Super + Ctrl + key` | Panels und Systemmenüs | `Super + Ctrl + A` Audio, `Super + Ctrl + N` Netzwerk, `Super + Ctrl + C` Aufnahme-Menü |
| `Super + Ctrl + Alt + key` | Schnellaktionen und Hinweise | `Super + Ctrl + Alt + T` Uhrzeit anzeigen, `Super + Ctrl + Alt + B` Akku, `Super + Ctrl + Alt + C` Screenshot |

`Alt` zu einem Tastaturkürzel hinzuzufügen ergibt eine Variante desselben, nie etwas Unzusammenhängendes:

- `Super + Shift + B` öffnet den Browser; `Super + Shift + Alt + B` öffnet ein privates Fenster
- `Super + Shift + E` öffnet E-Mail; `Super + Shift + Alt + E` startet eine neue
- `Super + F` geht ins Vollbild; `Super + Alt + F` geht auf volle Breite
- `Super + Ctrl + C` öffnet das Aufnahme-Menü; `Super + Ctrl + Alt + C` überspringt das Menü und macht einen Screenshot

Beim Hinzufügen eines Tastaturkürzels:

1. Wähle die Ebene danach, was es tut, dann wähle die Taste.
2. Verschiebe kein bestehendes Tastaturkürzel, um Platz zu schaffen. Finde eine freie Taste auf der richtigen Ebene.
3. Nutze `Alt` nur für eine Variante des Tastaturkürzels ohne es.

Einige Tastaturkürzel brechen diese Regeln, weil sie praktisch sind. `Shift` mit einem Pfeil oder `Tab` bewegt oder kehrt um, statt eine App zu öffnen, und `Print`, die Medientasten, `Alt + Tab` und `Ctrl + Alt + Del` funktionieren so wie überall sonst. Das sind Ausnahmen, keine Muster zum Nachmachen.

Wenn dir ein Standard nicht zusagt (etwa wenn du wie unter Windows `Super + Shift + S` für Screenshots willst), belege es in `~/.config/hypr/bindings.lua` neu.

## Navigieren

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-Menü (Apps und alles andere)    |
| `Super + Alt + Space` | App-Übersicht |
| `Super + Escape` | Systemmenü (Ruhezustand, Neustart usw.)  |
| `Super + Ctrl + L` | Computer sperren |
| `Super + W` oder `Super + Q` | Fenster schließen             |
| `Ctrl + Alt + Del` | Alle Fenster schließen |
| `Super + T`               | Fenster zwischen Tiling/Floating umschalten             |
| `Super + J` | Fensterposition umschalten (horizontal/vertikal) |
| `Super + O`               | Fenster als sticky'n'floating herausheben umschalten |
| `Super + L`               | Durch die Layouts dwindle, scrolling und floating durchwechseln |
| `Super + Alt + L`         | Layouts in umgekehrter Reihenfolge durchwechseln |
| `Super + P`               | Pseudo-Fensterstil umschalten (natural vs. stretch) |
| `Super + F`                 | Vollbild              |
| `Super + Alt + F`                 | Volle Breite              |
| `Super + Ctrl + F`                 | Vollbild innerhalb des Fensters              |
| `Super + 1/2/3/4`         | Zu bestimmtem Workspace auf dem fokussierten Monitor springen |
| `Super + Tab` | Zum nächsten Workspace auf dem fokussierten Monitor springen |
| `Super + Shift + Tab` | Zum vorherigen Workspace auf dem fokussierten Monitor springen |
| `Super + Ctrl + Tab` | Zum früheren Workspace auf dem fokussierten Monitor springen |
| `Super + Shift + 1/2/3/4` | Fenster auf Workspace auf dem fokussierten Monitor verschieben |
| `Super + Shift + Alt + 1/2/3/4` | Fenster auf Workspace auf dem fokussierten Monitor verschieben, ohne zu folgen |
| `Super + S` | Volles Scratchpad umschalten |
| `Super + Alt + S` | Fenster ins volle Scratchpad verschieben |
| `Super + Grave` | Quake-Konsole umschalten |
| `Super + Shift + Grave` | Fenster in die Quake-Konsole verschieben |
| `Super + Shift + Ctrl + Arrows` | Fenster auf den Monitor in dieser Richtung verschieben |
| `Super + Shift + Alt + Arrows` | Workspace auf den Monitor in dieser Richtung verschieben |
| `Super + Arrow`  | Fokus auf Fenster in Pfeilrichtung bewegen, am Bildschirmrand auf den Monitor auf dieser Seite wechseln |
| `Super + Shift + Arrow`  | Fenster mit einem anderen in Pfeilrichtung tauschen, auch mit einem auf dem Monitor auf dieser Seite |
| `Super + Minus` | Fenster nach links erweitern |
| `Super + Equal` | Fenster nach links verkleinern |
| `Super + Shift + Minus` | Fenster nach oben verkleinern |
| `Super + Shift + Equal` | Fenster nach unten erweitern |
| `Super + Alt + Minus/Equal` | Gleiches Ändern der Größe in kleineren Schritten |
| `Super + Ctrl + Minus/Equal` | Gleiches Ändern der Größe in größeren Schritten |
| `Super + Alt + Home` | Fensterbreite speichern |
| `Super + Home` | Gespeicherte Fensterbreite wiederherstellen |
| `Super + Left Mouse` | Fenster herumziehen |
| `Super + Right Mouse` | Fenstergröße ändern |
| `Super + Scroll Wheel` | Durch Workspaces auf dem fokussierten Monitor scrollen |
| `Super + G`               | Fenstergruppierung umschalten      |
| `Super + Alt + G`               | Fenster aus der Gruppierung herausbewegen      |
| `Super + Alt + Tab`               | Zwischen Fenstern in der Gruppierung wechseln      |
| `Super + Alt + Shift + Tab`               | Rückwärts zwischen Fenstern in der Gruppierung wechseln      |
| `Super + Alt + Scroll Wheel` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + 1/2/3/4/5`               | Zu bestimmtem Fenster in der Gruppierung springen      |
| `Super + Alt + Arrow`  | Fenster in Pfeilrichtung in die Gruppierung bewegen, auch eines auf dem Monitor auf dieser Seite |
| `Super + Ctrl + Left/Right`  | Zwischen Fenstern innerhalb einer Tiling-Gruppe wechseln |
| `Super + Ctrl + Z` | Bildschirm heranzoomen (wiederholen für mehr Zoom) |
| `Super + Ctrl + Alt + Z` | Vollständig vom Bildschirm herauszoomen |
| `Super + /` | Schrittweise vorwärts durch die Monitor-Skalierungsoptionen |
| `Super + Alt + /` | Schrittweise rückwärts durch die Monitor-Skalierungsoptionen |
| `Alt + Tab` | Vorwärts durch Fenster auf dem aktiven Workspace wechseln |
| `Alt + Shift + Tab` | Rückwärts durch Fenster auf dem aktiven Workspace wechseln |
| `Ctrl + Alt + Tab`| Fokus vorwärts durch Monitore wechseln |
| `Ctrl + Alt + Shift + Tab`| Fokus rückwärts durch Monitore wechseln |

Tastaturkürzel zum Ändern der Größe nutzen die physischen Tasten `code:20` und `code:21` (XKB `<AE11>` und `<AE12>`), unabhängig von den auf der Tastatur aufgedruckten Zeichen. Auf US-Tastaturen sind diese Tasten `-` und `=`; auf japanischen (JIS) Tastaturen sind es `-` und `^`; auf spanischen Tastaturen sind es `'` und `¡`. Auf JIS ist `Super + ^` gleich `Super + Equal`, während `Super + Shift + -` (das `=` tippt) gleich `Super + Shift + Minus` ist.

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
| `Super + Ctrl + 1-9`           | Bar-Panel nach Position umschalten    |
| `Super + Ctrl + S` | Teilen-Menü (via LocalSend) |
| `Super + Ctrl + C` | Aufnahme-Steuerung (Screenshot/-Aufzeichnung/Auswahl) |
| `Super + Ctrl + O` | Menü umschalten |
| `Super + Ctrl + H` | Hardware-Menü |
| `Super + Ctrl + E` | Emoji-Auswahl |
| `Super + Ctrl + .` | Medien transkodieren |
| `Super + Shift + Ctrl + A` | Einen AI-Agent auswählen |

## Anpassungen

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximale Bildschirmhelligkeit |
| `Shift + Brightness Down` | Minimale Bildschirmhelligkeit |
| `Alt + Brightness Up/Down` | Präzise Helligkeitsänderungen um 1% |
| `Alt + Volume Up/Down` | Präzise Lautstärkeänderungen um 1% |
| `Keyboard Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler |
| `Keyboard Backlight` | Tastaturbeleuchtungsstufen durchwechseln |
| `Alt + Play` | Nächster Titel |
| `Alt + Shift + Play` | Vorheriger Titel |

## Apps starten

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-Terminal |
| `Super + Ctrl + Return` | Herdr (Agent-Manager) |
| `Super + Shift + Return`           | Browser    |
| `Super + Shift + Alt + B`           | Browser (privat/Inkognito)    |
| `Super + Shift + F`           | Dateimanager    |
| `Super + Shift + Alt + F`           | Dateimanager im cwd des Terminals    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Passwortmanager (1password)    |
| `Super + Shift + Q`           | Rechner (Omacalc)    |
| `Super + Shift + T`           | Aktivität (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-Mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Neue E-Mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Messenger (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messenger (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messenger (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Schreiben (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Belegungen in `~/.config/hypr/bindings.lua` ändern/hinzufügen.

## Universelle Zwischenablage

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + A`           | Alles auswählen in Apps, die `Ctrl + A` unterstützen    |
| `Super + C`           | Kopieren    |
| `Super + X`           | Ausschneiden (nicht im Terminal)    |
| `Super + V`           | Einfügen    |
| `Super + Ctrl + V`           | Zwischenablage-Manager    |

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V`, um im Terminal zu kopieren und einzufügen, und `Ctrl + C/V`, um es überall sonst zu tun. Diese vereinheitlichten Omarchy-Zwischenablage-Tastaturkürzel funktionieren überall.

## Aufnahme

| Tastaturkürzel              | Funktion                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Screenshot                      |
| `Super + Ctrl + Alt + C`            | Screenshot (dieselbe Aufnahme, für Tastaturen ohne Print Screen-Taste) |
| `Super + Ctrl + C` | Aufnahme-Menü |
| `Alt + Print Screen`            | Bildschirmaufzeichnung                     |
| `Super + Shift + Ctrl + Alt + C` | Bildschirmaufzeichnung ohne Audio, Menü überspringen (erneut drücken zum Stoppen) |
| `Super + Print Screen` | Farbauswahl |
| `Super + Ctrl + Print Screen` | Textextraktion in die Zwischenablage |
| `Super + Alt + [` | Webcam-Overlay während der Aufnahme kleiner machen |
| `Super + Alt + ]` | Webcam-Overlay während der Aufnahme größer machen |
| `Alt + Shift + L` | Aktuelle URL aus Webapp oder Browser kopieren |
| `Alt + Shift + D` | Video auf der aktuellen Seite nach `~/Videos` herunterladen |
| `Alt + Space` | Diktieren starten/stoppen (erfordert _Setup > Defaults > Dictation_) |
| `Right Alt` | Gedrückt halten zum Diktieren (erfordert _Setup > Defaults > Dictation_) |

Bei Bildschirmaufzeichnungen fragt das Tastaturkürzel zuerst, welches Audio du willst, dann startet die Aufnahme. Drücke es erneut, um zu stoppen. Siehe [Screenshots und Aufzeichnung](12-screenshots-recording.md) für die Details.

Alle Aufnahmeoptionen sind auch unter _Trigger > Capture_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Benachrichtigungen

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + ,` | Auf neueste Benachrichtigung reagieren: sie öffnen oder ihren einzigen Button drücken, aus ihren Optionen wählen oder sie verwerfen, wenn sie keine hat  |
| `Super + Shift + ,` | Alle Benachrichtigungen verwerfen |
| `Super + Ctrl + ,` | Benachrichtigungen mit der Tastatur steuern  |
| `Super + Alt + ,` | Neueste Benachrichtigung verwerfen  |
| `Super + Shift + Alt + ,` | Benachrichtigungsverlauf öffnen  |
| `Super + Ctrl + Alt + ,` | Stummschalten von Benachrichtigungen umschalten  |

## Stil

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Neues Theme auswählen (auch `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Theme-Hintergrund auswählen (auch `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparenz bei einem Fenster umschalten |
| `Super + Ctrl + Backspace` | Quadratisches Seitenverhältnis für einzelnes Fenster umschalten |

Zusätzliche Hintergrundbilder liegen in `~/.config/omarchy/backgrounds/<theme name>`. Auch verfügbar über _Install > Style > Background_ im Omarchy-Menü.

Alle Stiloptionen sind auch unter _Style_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Umschalten

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Sperren bei Leerlauf umschalten |
| `Super + Ctrl + Delete` | Laptop-Display ein-/ausschalten |
| `Super + Ctrl + Alt + Delete` | Laptop-Display-Spiegelung umschalten |
| `Super + Shift + Space` | Obere Leiste umschalten  |
| `Shift + Mute` | Zum nächsten Audioausgang wechseln |
| `Shift + Play` | Zur nächsten Medienquelle wechseln |
| `Super + Shift + Backspace` | Fensterabstände umschalten |
| `Super + Ctrl + Alt + F` | Vollbild-Desktop umschalten (obere Leiste + Fensterabstände) |

## Erinnerungen

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Erinnerung erstellen  |
| `Super + Ctrl + Alt + R` | Alle Erinnerungen anzeigen  |
| `Super + Ctrl + Shift + R` | Alle Erinnerungen löschen  |

## Hinweise

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Uhrzeit als Benachrichtigung anzeigen  |
| `Super + Ctrl + Alt + B` | Akku als Benachrichtigung anzeigen  |
| `Super + Ctrl + Alt + W` | Wetter als Benachrichtigung umschalten  |

## Tmux

Die Prefix-Taste ist `Ctrl + Space` (`Ctrl + B` funktioniert auch). Du kannst diese Belegungen in `~/.config/tmux/tmux.conf` ändern.

### Bereiche

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + v` | Bereich daneben teilen (vertikal) |
| `Prefix + h` | Bereich darunter teilen (horizontal) |
| `Prefix + x` | Bereich beenden |
| `Prefix + z` | Bereich-Zoom umschalten (Vollbild) |
| `Alt + Enter` | Bereich darunter teilen (kein Prefix) |
| `Alt + Shift + Enter` | Bereich daneben teilen (kein Prefix) |
| `Alt + Escape` | Bereich beenden (kein Prefix) |
| `Ctrl + Alt + Arrows` | Zwischen Bereichen wechseln |
| `Ctrl + Alt + Shift + Arrows` | Größe der Bereiche ändern |

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

### Kopiermodus (vi-Stil)

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
| `Prefix + :` | Befehlsaufforderung |

### Tmux-Layout-Funktionen

Diese Funktionen müssen innerhalb einer Tmux-Sitzung ausgeführt werden.

| Befehl | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-Layout mit Editor, AI und Terminal erstellen |
| `tdlm <ai> [<second_ai>]` | Dev-Layout pro Unterverzeichnis erstellen |
| `tsl <count> <command>` | Schwarm-Layout mit mehreren Bereichen erstellen |

## Ghostty Terminal

Das Ghostty-Terminal wird mit _Install > Terminal_ über das Omarchy-Menü installiert.

| Tastaturkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Neue Teilung darunter |
| `Ctrl + Shift + O` | Neue Teilung daneben |
| `Ctrl + Alt + Arrows` | Zwischen Teilungen wechseln |
| `Super + Ctrl + Shift + Arrows` | Größe der Teilung um 10 Zeilen ändern |
| `Super + Ctrl + Shift + Alt + Arrows` | Größe der Teilung um 100 Zeilen ändern |
| `Ctrl + Shift + T` | Neuer Tab  |
| `Ctrl + Shift + Arrows` | Zwischen Tabs wechseln |
| `Alt + Numbers` | Zu bestimmtem Tab gehen |
| `Shift + Pg Up/Down` | Verlauf scrollen |
| `Ctrl + Left mouse` | Link im Browser öffnen |

## Dateimanager

| Tastaturkürzel              | Funktion                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Zu Pfad gehen                     |
| `Space`               | Dateivorschau (Pfeile navigieren) |
| `Alt + Up`       | Zum übergeordneten Ordner hochgehen        |

## Neovim (mit lazyvim)

### Navigation

| Tastaturkürzel                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Befehlsoptionen anzeigen            |
| `Space Space`              | Datei per Fuzzy-Suche öffnen      |
| `Space E`                  | Seitenleiste umschalten                  |
| `Space G G`                | Git-Steuerung anzeigen               |
| `Space S G`                | Dateiinhalt durchsuchen             |
| `Ctrl + W W`               | Zwischen Seitenleiste und Editor springen |
| `Ctrl + Left/right arrow`  | Größe der Seitenleiste ändern          |
| `Shift + H`                      | Zum linken Dateitab gehen             |
| `Shift + L`                      | Zum rechten Dateitab gehen            |
| `Space B D`                | Dateitab schließen                  |

### In der Seitenleiste

| Tastaturkürzel                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `A`                        | Neue Datei im übergeordneten Verzeichnis hinzufügen      |
| `Shift + A`                | Neues Unterverzeichnis im übergeordneten Verzeichnis hinzufügen    |
| `D`                        | Hervorgehobene Datei/Verzeichnis löschen     |
| `M`                        | Hervorgehobene Datei/Verzeichnis verschieben       |
| `R`                        | Hervorgehobene Datei/Verzeichnis umbenennen     |
| `?`                        | Hilfe für alle Befehle anzeigen      |

[Siehe alle von LazyVim konfigurierten Neovim-Tastaturkürzel](https://www.lazyvim.org/keymaps).

## Schnelle Emojis

Du kannst `Super + Ctrl + E` nutzen, um eine vollständige Emoji-Auswahl anzuzeigen, die die Auswahl in die Zwischenablage legt, oder du kannst diese Schnellzugriffsoptionen nutzen.

| Tastaturkürzel       | EM | Hinweis       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile      |
| `Shift + CapsLock M C` | 😂 | cry        |
| `Shift + CapsLock M L` | 😍 | love       |
| `Shift + CapsLock M V` | ✌️ | victory    |
| `Shift + CapsLock M H` | ❤️ | heart      |
| `Shift + CapsLock M Y` | 👍 | yes        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | wish       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kiss       |
| `Shift + CapsLock M E` | 🙄 | eyeroll    |
| `Shift + CapsLock M I` | 😉 | wink       |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool      |
| `Shift + CapsLock M M` | 💰 | money      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Schnelle Vervollständigungen

| Tastaturkürzel       | Vervollständigung       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Dein Name (wie bei der Einrichtung eingegeben)  |
| `Shift + CapsLock Space E` | Deine E-Mail (wie bei der Einrichtung eingegeben)  |

Du kannst weitere eigene hinzufügen, indem du `~/.XCompose` bearbeitest und dann `omarchy-restart-xcompose` im Terminal ausführst, damit die Änderungen übernommen werden.
