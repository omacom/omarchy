# Tastenkürzel

Du kannst alle wichtigen Tastaturbelegungen mit `Super + K` sehen (Tmux-Belegungen mit `Super + Alt + K` und Herdr-Belegungen mit `Super + Ctrl + K`).

## Wie die Tastenkürzel aufgebaut sind

Jedes Tastenkürzel liegt auf einer Ebene, festgelegt durch seine Modifikatortasten, und jede Ebene hat eine Aufgabe. Das verhindert, dass die Tastenkürzel ineinander verschwimmen, und du kannst meist erraten, wo etwas zu finden ist.

| Ebene | Was dort zu finden ist | Beispiele |
| --- | --- | --- |
| `Super + key` | Das System: Fenster, Workspaces, Layouts und Kernmenüs | `Super + Space` Omarchy-Menü, `Super + W` Fenster schließen, `Super + F` Vollbild |
| `Super + Shift + key` | Apps | `Super + Shift + B` Browser, `Super + Shift + E` E-Mail, `Super + Shift + N` Editor |
| `Super + Ctrl + key` | Panels und Systemmenüs | `Super + Ctrl + A` Audio, `Super + Ctrl + N` Netzwerk, `Super + Ctrl + C` Aufnahmemenü |
| `Super + Ctrl + Alt + key` | Schnellaktionen und Hinweise | `Super + Ctrl + Alt + T` Uhrzeit anzeigen, `Super + Ctrl + Alt + B` Akku, `Super + Ctrl + Alt + C` Screenshot |

Wenn du `Alt` zu einem Tastenkürzel hinzufügst, erhältst du eine Variante derselben Sache, niemals etwas Unzusammenhängendes:

- `Super + Shift + B` öffnet den Browser; `Super + Shift + Alt + B` öffnet ein privates Fenster
- `Super + Shift + E` öffnet E-Mail; `Super + Shift + Alt + E` beginnt eine neue
- `Super + F` geht ins Vollbild; `Super + Alt + F` geht auf volle Breite
- `Super + Ctrl + C` öffnet das Aufnahmemenü; `Super + Ctrl + Alt + C` überspringt das Menü und macht einen Screenshot

Wenn du ein Tastenkürzel hinzufügst:

1. Wähle die Ebene danach, was es tut, dann wähle die Taste.
2. Verschiebe kein bestehendes Tastenkürzel, um Platz zu machen. Finde eine freie Taste auf der richtigen Ebene.
3. Verwende `Alt` nur für eine Variante des Tastenkürzels ohne `Alt`.

Einige Tastenkürzel brechen diese Regeln, weil sie praktisch sind. `Shift` mit einer Pfeiltaste oder `Tab` verschiebt oder kehrt um, statt eine App zu öffnen, und `Print`, die Medientasten, `Alt + Tab` und `Ctrl + Alt + Del` funktionieren so wie überall sonst auch. Das sind Ausnahmen, keine Muster zum Nachahmen.

Wenn dir eine Voreinstellung nicht passt (sagen wir, du willst `Super + Shift + S` für Screenshots wie unter Windows), lege sie in `~/.config/hypr/bindings.lua` neu fest.

## Navigation

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-Menü (Apps und alles andere)    |
| `Super + Alt + Space` | App-Übersicht |
| `Super + Escape` | Systemmenü (Ruhezustand, Neustart usw.)  |
| `Super + Ctrl + L` | Computer sperren |
| `Super + W` oder `Super + Q` | Fenster schließen             |
| `Ctrl + Alt + Del` | Alle Fenster schließen |
| `Super + T`               | Fenster zwischen Tiling/Floating umschalten             |
| `Super + J` | Fensterposition umschalten (horizontal/vertikal) |
| `Super + O`               | Fenster in sticky'n'floating herauspoppen umschalten |
| `Super + L`               | Durch die Layouts dwindle, scrolling und floating wechseln |
| `Super + Alt + L`         | Layouts in umgekehrter Reihenfolge durchwechseln |
| `Super + P`               | Pseudo-Fensterstil umschalten (natural vs. stretch) |
| `Super + F`                 | Vollbild              |
| `Super + Alt + F`                 | Volle Breite              |
| `Super + Ctrl + F`                 | Vollbild innerhalb des Fensters              |
| `Super + 1/2/3/4`         | Zu einem bestimmten Workspace auf dem fokussierten Monitor springen |
| `Super + Tab` | Zum nächsten Workspace auf dem fokussierten Monitor springen |
| `Super + Shift + Tab` | Zum vorherigen Workspace auf dem fokussierten Monitor springen |
| `Super + Ctrl + Tab` | Zum früheren Workspace auf dem fokussierten Monitor springen |
| `Super + Shift + 1/2/3/4` | Fenster auf einen Workspace auf dem fokussierten Monitor verschieben |
| `Super + Shift + Alt + 1/2/3/4` | Fenster auf einen Workspace auf dem fokussierten Monitor verschieben, ohne ihm zu folgen |
| `Super + S` | Vollständiges Scratchpad umschalten |
| `Super + Alt + S` | Fenster in das vollständige Scratchpad verschieben |
| `Super + Grave` | Quake-Konsole umschalten |
| `Super + Shift + Grave` | Fenster in die Quake-Konsole verschieben |
| `Super + Shift + Ctrl + Arrows` | Fenster auf den Monitor in dieser Richtung verschieben |
| `Super + Shift + Alt + Arrows` | Workspace auf den Monitor in dieser Richtung verschieben |
| `Super + Arrow`  | Fokus auf das Fenster in Pfeilrichtung setzen, am Bildschirmrand auf den Monitor auf dieser Seite wechseln |
| `Super + Shift + Arrow`  | Fenster mit einem anderen in Pfeilrichtung tauschen, einschließlich eines auf dem Monitor auf dieser Seite |
| `Super + Minus` | Fenster nach links vergrößern |
| `Super + Equal` | Fenster nach links verkleinern |
| `Super + Shift + Minus` | Fenster nach oben verkleinern |
| `Super + Shift + Equal` | Fenster nach unten vergrößern |
| `Super + Alt + Minus/Equal` | Gleiche Größenänderung in kleineren Schritten |
| `Super + Ctrl + Minus/Equal` | Gleiche Größenänderung in größeren Schritten |
| `Super + Alt + Home` | Fensterbreite speichern |
| `Super + Home` | Gespeicherte Fensterbreite wiederherstellen |
| `Super + Left Mouse` | Fenster per Ziehen verschieben |
| `Super + Right Mouse` | Fenstergröße ändern |
| `Super + Scroll Wheel` | Durch die Workspaces auf dem fokussierten Monitor scrollen |
| `Super + G`               | Fenstergruppierung umschalten      |
| `Super + Alt + G`               | Fenster aus der Gruppierung heraus verschieben      |
| `Super + Alt + Tab`               | Zwischen Fenstern in der Gruppierung wechseln      |
| `Super + Alt + Shift + Tab`               | Rückwärts zwischen Fenstern in der Gruppierung wechseln      |
| `Super + Alt + Scroll Wheel` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + 1/2/3/4/5`               | Zu einem bestimmten Fenster in der Gruppierung springen      |
| `Super + Alt + Arrow`  | Fenster in Pfeilrichtung in eine Gruppierung verschieben, einschließlich einer auf dem Monitor auf dieser Seite |
| `Super + Ctrl + Left/Right`  | Zwischen Fenstern innerhalb einer Tiling-Gruppe wechseln |
| `Super + Ctrl + Z` | Bildschirm heranzoomen (für mehr Zoom wiederholen) |
| `Super + Ctrl + Alt + Z` | Vollständig vom Bildschirm herauszoomen |
| `Super + /` | Vorwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Super + Alt + /` | Rückwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Alt + Tab` | Vorwärts durch die Fenster auf dem aktiven Workspace wechseln |
| `Alt + Shift + Tab` | Rückwärts durch die Fenster auf dem aktiven Workspace wechseln |
| `Ctrl + Alt + Tab`| Fokus vorwärts durch die Monitore wechseln |
| `Ctrl + Alt + Shift + Tab`| Fokus rückwärts durch die Monitore wechseln |

Tastenkürzel zur Größenänderung verwenden die physischen Tasten `code:20` und `code:21` (XKB `<AE11>` und `<AE12>`), unabhängig von den auf der Tastatur aufgedruckten Zeichen. Auf US-Tastaturen sind diese Tasten `-` und `=`; auf japanischen (JIS) Tastaturen sind es `-` und `^`; auf spanischen Tastaturen sind es `'` und `¡`. Auf JIS ist `Super + ^` gleich `Super + Equal`, während `Super + Shift + -` (das `=` eingibt) gleich `Super + Shift + Minus` ist.

## Systemsteuerung

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio-Panel    |
| `Super + Ctrl + B`           | Bluetooth-Panel    |
| `Super + Ctrl + N`           | Wi-Fi/Netzwerk-Panel    |
| `Super + Ctrl + D`           | Anzeige-Panel    |
| `Super + Ctrl + P`           | Energie-Panel    |
| `Super + Ctrl + X`           | Agenten-Panel    |
| `Super + Ctrl + Alt + D`           | Kalender-Panel    |
| `Super + Ctrl + Alt + E`           | Weltuhr-Panel    |
| `Super + Ctrl + 1-9`           | Leisten-Panel nach Position umschalten    |
| `Super + Ctrl + S` | Teilen-Menü (über LocalSend) |
| `Super + Ctrl + C` | Aufnahme-Steuerelemente (Screenshot/-aufnahme/Picker) |
| `Super + Ctrl + O` | Umschalter-Menü |
| `Super + Ctrl + H` | Hardware-Menü |
| `Super + Ctrl + E` | Emoji-Auswahl |
| `Super + Ctrl + .` | Medien transkodieren |
| `Super + Shift + Ctrl + A` | Einen KI-Agenten auswählen |

## Anpassungen

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximale Bildschirmhelligkeit |
| `Shift + Brightness Down` | Minimale Bildschirmhelligkeit |
| `Alt + Brightness Up/Down` | Präzise Helligkeitsänderungen um 1 % |
| `Alt + Volume Up/Down` | Präzise Lautstärkeänderungen um 1 % |
| `Keyboard Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler |
| `Keyboard Backlight` | Stufen der Tastaturbeleuchtung durchwechseln |
| `Alt + Play` | Nächster Titel |
| `Alt + Shift + Play` | Vorheriger Titel |

## Apps starten

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-Terminal |
| `Super + Ctrl + Return` | Herdr (Agenten-Manager) |
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
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Belegungen in `~/.config/hypr/bindings.lua` ändern/hinzufügen.

## Universelle Zwischenablage

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + A`           | In Apps, die `Ctrl + A` unterstützen, alles auswählen    |
| `Super + C`           | Kopieren    |
| `Super + X`           | Ausschneiden (nicht im Terminal)    |
| `Super + V`           | Einfügen    |
| `Super + Ctrl + V`           | Zwischenablage-Manager    |

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V`, um im Terminal zu kopieren und einzufügen, und `Ctrl + C/V`, um es überall sonst zu tun. Diese einheitlichen Omarchy-Tastenkürzel für die Zwischenablage funktionieren überall.

## Aufnahme

| Tastenkürzel              | Funktion                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Screenshot                      |
| `Super + Ctrl + Alt + C`            | Screenshot (dieselbe Aufnahme, für Tastaturen ohne Print Screen-Taste) |
| `Super + Ctrl + C` | Aufnahmemenü |
| `Alt + Print Screen`            | Bildschirmaufzeichnung                     |
| `Super + Print Screen` | Farbauswahl |
| `Super + Ctrl + Print Screen` | Text in die Zwischenablage auslesen |
| `Super + Alt + [` | Webcam-Overlay während der Aufnahme kleiner machen |
| `Super + Alt + ]` | Webcam-Overlay während der Aufnahme größer machen |
| `Alt + Shift + L` | Aktuelle URL aus der Webapp oder Chromium kopieren |
| `Alt + Shift + D` | Das Video auf der aktuellen Seite nach `~/Videos` herunterladen |
| `Alt + Space` | Diktat starten/stoppen (erfordert _Setup > Defaults > Dictation_) |
| `Right Alt` | Gedrückt halten zum Diktieren (erfordert _Setup > Defaults > Dictation_) |

Bei Bildschirmaufzeichnungen fragt das Tastenkürzel zuerst, welchen Ton du willst, und startet dann die Aufnahme. Drücke es erneut, um zu stoppen. Siehe [Screenshots und Aufnahme](12-screenshots-recording.md) für die Details.

Alle Aufnahmeoptionen sind auch unter _Trigger > Capture_ im Omarchy-Menü (`Super + Space`) verfügbar.

## Benachrichtigungen

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + ,` | Auf die neueste Benachrichtigung reagieren: sie öffnen oder ihre einzige Schaltfläche drücken, aus ihren Optionen wählen oder sie verwerfen, wenn sie keine hat  |
| `Super + Shift + ,` | Alle Benachrichtigungen verwerfen |
| `Super + Ctrl + ,` | Benachrichtigungen mit der Tastatur steuern  |
| `Super + Alt + ,` | Neueste Benachrichtigung verwerfen  |
| `Super + Shift + Alt + ,` | Benachrichtigungsverlauf öffnen  |
| `Super + Ctrl + Alt + ,` | Stummschalten von Benachrichtigungen umschalten  |

## Stil

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Ein neues Theme auswählen (auch `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Theme-Hintergrund auswählen (auch `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparenz eines Fensters umschalten |
| `Super + Ctrl + Backspace` | Quadratisches Seitenverhältnis für ein einzelnes Fenster umschalten |

Zusätzliche Hintergrundbilder liegen in `~/.config/omarchy/backgrounds/<theme name>`. Auch über _Install > Style > Background_ im Omarchy-Menü verfügbar.

Alle Stiloptionen sind auch unter _Style_ im Omarchy-Menü (`Super + Space`) verfügbar.

## Umschalter

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Sperren bei Inaktivität umschalten |
| `Super + Ctrl + Delete` | Laptop-Display ein-/ausschalten |
| `Super + Ctrl + Alt + Delete` | Spiegeln des Laptop-Displays umschalten |
| `Super + Shift + Space` | Obere Leiste umschalten  |
| `Shift + Mute` | Zum nächsten Audioausgang wechseln |
| `Shift + Play` | Zur nächsten Medienquelle wechseln |
| `Super + Shift + Backspace` | Fensterabstände umschalten |
| `Super + Ctrl + Alt + F` | Vollbild-Desktop umschalten (obere Leiste + Fensterabstände) |

## Erinnerungen

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eine Erinnerung setzen  |
| `Super + Ctrl + Alt + R` | Alle Erinnerungen anzeigen  |
| `Super + Ctrl + Shift + R` | Alle Erinnerungen löschen  |

## Hinweise

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Uhrzeit als Benachrichtigung anzeigen  |
| `Super + Ctrl + Alt + B` | Akku als Benachrichtigung anzeigen  |
| `Super + Ctrl + Alt + W` | Wetter als Benachrichtigung umschalten  |

## Tmux

Die Prefix-Taste ist `Ctrl + Space` (`Ctrl + B` funktioniert auch). Du kannst diese Belegungen in `~/.config/tmux/tmux.conf` ändern.

### Teilfenster

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + v` | Teilfenster daneben teilen (vertikal) |
| `Prefix + h` | Teilfenster darunter teilen (horizontal) |
| `Prefix + x` | Teilfenster beenden |
| `Prefix + z` | Zoom des Teilfensters umschalten (Vollbild) |
| `Alt + Enter` | Teilfenster darunter teilen (ohne Prefix) |
| `Alt + Shift + Enter` | Teilfenster daneben teilen (ohne Prefix) |
| `Alt + Escape` | Teilfenster beenden (ohne Prefix) |
| `Ctrl + Alt + Arrows` | Zwischen Teilfenstern wechseln |
| `Ctrl + Alt + Shift + Arrows` | Größe der Teilfenster ändern |

### Fenster

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + c` | Neues Fenster |
| `Prefix + k` | Fenster beenden |
| `Prefix + r` | Fenster umbenennen |
| `Alt + 1-9` | Zu einem bestimmten Fenster gehen |
| `Alt + Arrow Left/Right` | Zwischen Fenstern wechseln |
| `Alt + Shift + Arrow Left/Right` | Fenster nach links/rechts verschieben |

### Sitzungen

| Tastenkürzel                  | Funktion              |
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

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopiermodus betreten |
| `v` | Auswahl beginnen (im Kopiermodus) |
| `y` | Auswahl kopieren (im Kopiermodus) |

### Allgemein

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguration neu laden |
| `Prefix + ?` | Tmux-Tastaturbelegungen anzeigen |
| `Prefix + :` | Befehlsaufforderung |

### Tmux-Layoutfunktionen

Diese Funktionen müssen innerhalb einer Tmux-Sitzung ausgeführt werden.

| Befehl | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-Layout mit Editor, KI und Terminal erstellen |
| `tdlm <ai> [<second_ai>]` | Dev-Layout pro Unterverzeichnis erstellen |
| `tsl <count> <command>` | Multi-Pane-Schwarm-Layout erstellen |

## Ghostty-Terminal

Das Ghostty-Terminal wird über _Install > Terminal_ im Omarchy-Menü installiert.

| Tastenkürzel                  | Funktion              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Neue Teilung darunter |
| `Ctrl + Shift + O` | Neue Teilung daneben |
| `Ctrl + Alt + Arrows` | Zwischen Teilungen wechseln |
| `Super + Ctrl + Shift + Arrows` | Größe der Teilung um 10 Zeilen ändern |
| `Super + Ctrl + Shift + Alt + Arrows` | Größe der Teilung um 100 Zeilen ändern |
| `Ctrl + Shift + T` | Neuer Tab  |
| `Ctrl + Shift + Arrows` | Zwischen Tabs wechseln |
| `Alt + Numbers` | Zu einem bestimmten Tab gehen |
| `Shift + Pg Up/Down` | Durch den Verlauf scrollen |
| `Ctrl + Left mouse` | Link im Browser öffnen |

## Dateimanager

| Tastenkürzel              | Funktion                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Zu einem Pfad gehen                     |
| `Space`               | Dateivorschau (Pfeile navigieren) |
| `Alt + Up`       | Zum übergeordneten Ordner hochgehen        |

## Neovim (mit lazyvim)

### Navigation

| Tastenkürzel                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Befehlsoptionen anzeigen            |
| `Space Space`              | Datei per Fuzzy-Suche öffnen      |
| `Space E`                  | Seitenleiste umschalten                  |
| `Space G G`                | Git-Steuerelemente anzeigen               |
| `Space S G`                | Dateiinhalte durchsuchen             |
| `Ctrl + W W`               | Zwischen Seitenleiste und Editor springen |
| `Ctrl + Left/right arrow`  | Größe der Seitenleiste ändern          |
| `Shift + H`                      | Zum linken Datei-Tab gehen             |
| `Shift + L`                      | Zum rechten Datei-Tab gehen            |
| `Space B D`                | Datei-Tab schließen                  |

### In der Seitenleiste

| Tastenkürzel                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `A`                        | Neue Datei im übergeordneten Verzeichnis hinzufügen      |
| `Shift + A`                | Neues Unterverzeichnis im übergeordneten Verzeichnis hinzufügen    |
| `D`                        | Hervorgehobene Datei/Verzeichnis löschen     |
| `M`                        | Hervorgehobene Datei/Verzeichnis verschieben       |
| `R`                        | Hervorgehobene Datei/Verzeichnis umbenennen     |
| `?`                        | Hilfe für alle Befehle anzeigen      |

[Siehe alle von LazyVim konfigurierten Neovim-Tastenkürzel](https://www.lazyvim.org/keymaps).

## Schnelle Emojis

Du kannst `Super + Ctrl + E` verwenden, um eine vollständige Emoji-Auswahl anzuzeigen, die die Auswahl in die Zwischenablage legt, oder du kannst diese Schnellzugriffsoptionen verwenden.

| Tastenkürzel       | EM | Hinweis       |
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
| `Shift + CapsLock M T` | 🥂 | Anstoßen      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | Gruß |
| `Shift + CapsLock M A` |💪 | Arm |
| `Shift + CapsLock M B` |🤯 | umgehauen |

## Schnelle Vervollständigungen

| Tastenkürzel       | Vervollständigung       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (Geviertstrich)   |
| `Shift + CapsLock Space N` | Dein Name (wie bei der Einrichtung eingegeben)  |
| `Shift + CapsLock Space E` | Deine E-Mail (wie bei der Einrichtung eingegeben)  |

Du kannst eigene hinzufügen, indem du `~/.XCompose` bearbeitest und dann `omarchy-restart-xcompose` im Terminal ausführst, damit die Änderungen übernommen werden.
