# Tastenkombinationen

Du kannst alle wichtigen Tastaturkürzel mit `Super + K` sehen (Tmux-Bindings mit `Super + Alt + K` und Herdr-Bindings mit `Super + Ctrl + K`).

## Wie Tastenkombinationen angeordnet sind

Jede Tastenkombination liegt auf einer Ebene, die durch ihre Modifikatortasten festgelegt wird, und jede Ebene hat eine Aufgabe. Das sorgt dafür, dass die Tastenkombinationen nicht miteinander verschwimmen, und es bedeutet, dass du meist erraten kannst, wo etwas zu finden ist.

| Ebene | Was dort zu finden ist | Beispiele |
| --- | --- | --- |
| `Super + key` | Das System: Fenster, Arbeitsbereiche, Layouts und Kernmenüs | `Super + Space` Omarchy-Menü, `Super + W` Fenster schließen, `Super + F` Vollbild |
| `Super + Shift + key` | Apps | `Super + Shift + B` Browser, `Super + Shift + E` E-Mail, `Super + Shift + N` Editor |
| `Super + Ctrl + key` | Bedienfelder und Systemmenüs | `Super + Ctrl + A` Audio, `Super + Ctrl + N` Netzwerk, `Super + Ctrl + C` Aufnahmemenü |
| `Super + Ctrl + Alt + key` | Schnellaktionen und Hinweise | `Super + Ctrl + Alt + T` Zeit anzeigen, `Super + Ctrl + Alt + B` Akku, `Super + Ctrl + Alt + C` Screenshot |

`Alt` zu einer Tastenkombination hinzuzufügen gibt dir eine Variante derselben Sache, niemals etwas Unzusammenhängendes:

- `Super + Shift + B` öffnet den Browser; `Super + Shift + Alt + B` öffnet ein privates Fenster
- `Super + Shift + E` öffnet E-Mail; `Super + Shift + Alt + E` startet eine neue
- `Super + F` wechselt in den Vollbildmodus; `Super + Alt + F` wechselt auf volle Breite
- `Super + Ctrl + C` öffnet das Aufnahmemenü; `Super + Ctrl + Alt + C` überspringt das Menü und macht einen Screenshot

Beim Hinzufügen einer Tastenkombination:

1. Wähle die Ebene danach, was sie tut, und dann die Taste.
2. Verschiebe keine vorhandene Tastenkombination, um Platz zu machen. Finde eine freie Taste auf der richtigen Ebene.
3. Verwende `Alt` nur für eine Variante der Tastenkombination ohne `Alt`.

Einige wenige Tastenkombinationen brechen diese Regeln, weil es praktisch ist. `Shift` mit einem Pfeil oder `Tab` verschiebt oder kehrt um, statt eine App zu öffnen, und `Print`, die Medientasten, `Alt + Tab` und `Ctrl + Alt + Del` funktionieren so wie überall sonst auch. Das sind Ausnahmen, keine Muster zum Nachmachen.

Wenn dir ein Standard nicht zusagt (sagen wir, du willst wie unter Windows `Super + Shift + S` für Screenshots), binde ihn in `~/.config/hypr/bindings.lua` neu.

## Navigation

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-Menü (Apps und alles andere) |
| `Super + Alt + Space` | App-Raster |
| `Super + Escape` | Systemmenü (Energie sparen, Neustart usw.) |
| `Super + Ctrl + L` | Computer sperren |
| `Super + W` oder `Super + Q` | Fenster schließen |
| `Ctrl + Alt + Del` | Alle Fenster schließen |
| `Super + T` | Fenster zwischen Tiling/Floating umschalten |
| `Super + J` | Fensterposition umschalten (horizontal/vertikal) |
| `Super + O` | Fenster als sticky'n'floating herauslösen ein-/ausschalten |
| `Super + L` | Durch die Layouts dwindle, scrolling und floating wechseln |
| `Super + Alt + L` | Layouts in umgekehrter Reihenfolge durchwechseln |
| `Super + P` | Pseudo-Fensterstil umschalten (natural v stretch) |
| `Super + F` | In den Vollbildmodus wechseln |
| `Super + Alt + F` | Auf volle Breite wechseln |
| `Super + Ctrl + F` | In den Vollbildmodus innerhalb des Fensters wechseln |
| `Super + 1/2/3/4` | Zu einem bestimmten Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Tab` | Zum nächsten Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Shift + Tab` | Zum vorherigen Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Ctrl + Tab` | Zum früheren Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Shift + 1/2/3/4` | Fenster zu einem Arbeitsbereich auf dem fokussierten Monitor verschieben |
| `Super + Shift + Alt + 1/2/3/4` | Fenster zu einem Arbeitsbereich auf dem fokussierten Monitor verschieben, ohne zu folgen |
| `Super + S` | Vollständiges Scratchpad ein-/ausblenden |
| `Super + Alt + S` | Fenster in das vollständige Scratchpad verschieben |
| `Super + Grave` | Quake-Konsole ein-/ausblenden |
| `Super + Shift + Grave` | Fenster in die Quake-Konsole verschieben |
| `Super + Shift + Ctrl + Arrows` | Fenster auf den Monitor in dieser Richtung verschieben |
| `Super + Shift + Alt + Arrows` | Arbeitsbereich auf den Monitor in dieser Richtung verschieben |
| `Super + Arrow` | Fokus auf das Fenster in Pfeilrichtung verschieben, am Bildschirmrand auf den Monitor auf dieser Seite wechseln |
| `Super + Shift + Arrow` | Fenster mit einem anderen in Pfeilrichtung tauschen, einschließlich eines auf dem Monitor auf dieser Seite |
| `Super + Minus` | Fenster nach links vergrößern |
| `Super + Equal` | Fenster nach links verkleinern |
| `Super + Shift + Minus` | Fenster nach oben verkleinern |
| `Super + Shift + Equal` | Fenster nach unten vergrößern |
| `Super + Alt + Minus/Equal` | Gleiche Größenänderung in kleineren Schritten |
| `Super + Ctrl + Minus/Equal` | Gleiche Größenänderung in größeren Schritten |
| `Super + Alt + Home` | Fensterbreite speichern |
| `Super + Home` | Gespeicherte Fensterbreite wiederherstellen |
| `Super + Left Mouse` | Fenster ziehen |
| `Super + Right Mouse` | Fenstergröße ändern |
| `Super + Scroll Wheel` | Durch Arbeitsbereiche auf dem fokussierten Monitor scrollen |
| `Super + G` | Fenstergruppierung ein-/ausschalten |
| `Super + Alt + G` | Fenster aus der Gruppierung heraus verschieben |
| `Super + Alt + Tab` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + Shift + Tab` | Rückwärts zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + Scroll Wheel` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + 1/2/3/4/5` | Zu einem bestimmten Fenster in der Gruppierung springen |
| `Super + Alt + Arrow` | Fenster in Pfeilrichtung in eine Gruppierung verschieben, einschließlich eines auf dem Monitor auf dieser Seite |
| `Super + Ctrl + Left/Right` | Zwischen Fenstern innerhalb einer Tiling-Gruppe wechseln |
| `Super + Ctrl + Z` | Bildschirm heranzoomen (wiederholen für mehr Zoom) |
| `Super + Ctrl + Alt + Z` | Bildschirm vollständig herauszoomen |
| `Super + /` | Vorwärts durch die Optionen für die Monitorskalierung gehen |
| `Super + Alt + /` | Rückwärts durch die Optionen für die Monitorskalierung gehen |
| `Alt + Tab` | Vorwärts durch Fenster auf dem aktiven Arbeitsbereich wechseln |
| `Alt + Shift + Tab` | Rückwärts durch Fenster auf dem aktiven Arbeitsbereich wechseln |
| `Ctrl + Alt + Tab` | Fokus vorwärts durch Monitore wechseln |
| `Ctrl + Alt + Shift + Tab` | Fokus rückwärts durch Monitore wechseln |

Tastenkombinationen zur Größenänderung verwenden die physischen Tasten `code:20` und `code:21` (XKB `<AE11>` und `<AE12>`), unabhängig von den auf der Tastatur aufgedruckten Zeichen. Auf US-Tastaturen sind diese Tasten `-` und `=`; auf japanischen (JIS) Tastaturen sind sie `-` und `^`; auf spanischen Tastaturen sind sie `'` und `¡`. Auf JIS ist `Super + ^` gleich `Super + Equal`, während `Super + Shift + -` (das `=` eingibt) gleich `Super + Shift + Minus` ist.

## Systemsteuerung

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audio-Panel |
| `Super + Ctrl + B` | Bluetooth-Panel |
| `Super + Ctrl + N` | Wi-Fi/Netzwerk-Panel |
| `Super + Ctrl + D` | Display-Panel |
| `Super + Ctrl + P` | Power-Panel |
| `Super + Ctrl + X` | Agents-Panel |
| `Super + Ctrl + Alt + D` | Kalender-Panel |
| `Super + Ctrl + Alt + E` | Weltuhr-Panel |
| `Super + Ctrl + 1-9` | Leisten-Panel nach Position umschalten |
| `Super + Ctrl + S` | Teilen-Menü (über LocalSend) |
| `Super + Ctrl + C` | Aufnahmesteuerung (Screenshot/-aufzeichnung/Picker) |
| `Super + Ctrl + O` | Menü umschalten |
| `Super + Ctrl + H` | Hardware-Menü |
| `Super + Ctrl + E` | Emoji-Auswahl |
| `Super + Ctrl + .` | Medien transkodieren |
| `Super + Shift + Ctrl + A` | Einen AI-Agenten auswählen |

## Anpassungen

| Tastenkombination | Funktion |
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

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux-Terminal |
| `Super + Ctrl + Return` | Herdr (Agent-Manager) |
| `Super + Shift + Return` | Browser |
| `Super + Shift + Alt + B` | Browser (privat/Inkognito) |
| `Super + Shift + F` | Dateimanager |
| `Super + Shift + Alt + F` | Dateimanager im cwd des Terminals |
| `Super + Shift + M` | Musik (Spotify) |
| `Super + Shift + Alt + M` | Musik (cliamp) |
| `Super + Shift + /` | Passwortmanager (1password) |
| `Super + Shift + Q` | Taschenrechner (Omacalc) |
| `Super + Shift + T` | Aktivität (btop) |
| `Super + Shift + N` | Editor (Neovim) |
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
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Bindings in `~/.config/hypr/bindings.lua` ändern/hinzufügen.

## Universelle Zwischenablage

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + A` | In Apps, die `Ctrl + A` unterstützen, alles auswählen |
| `Super + C` | Kopieren |
| `Super + X` | Ausschneiden (nicht im Terminal) |
| `Super + V` | Einfügen |
| `Super + Ctrl + V` | Zwischenablage-Manager |

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V`, um im Terminal zu kopieren und einzufügen, und `Ctrl + C/V`, um es überall sonst zu tun. Diese vereinheitlichten Zwischenablage-Tastenkombinationen von Omarchy funktionieren überall.

## Aufnahme

| Tastenkombination | Funktion |
| ------------------- | ------------------------------ |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot (die gleiche Aufnahme, für Tastaturen ohne Print Screen-Taste) |
| `Super + Ctrl + C` | Aufnahmemenü |
| `Alt + Print Screen` | Bildschirmaufzeichnung |
| `Super + Print Screen` | Farbauswahl |
| `Super + Ctrl + Print Screen` | Textextraktion in die Zwischenablage |
| `Super + Alt + [` | Webcam-Overlay während der Aufzeichnung verkleinern |
| `Super + Alt + ]` | Webcam-Overlay während der Aufzeichnung vergrößern |
| `Alt + Shift + L` | Aktuelle URL aus Webapp oder Browser kopieren |
| `Alt + Shift + D` | Das Video auf der aktuellen Seite nach `~/Videos` herunterladen |
| `Alt + Space` | Diktat starten/stoppen (erfordert _Setup > Defaults > Dictation_) |
| `Right Alt` | Zum Diktieren gedrückt halten (erfordert _Setup > Defaults > Dictation_) |

Bei Bildschirmaufzeichnungen fragt die Tastenkombination zuerst, welches Audio du willst, und startet dann die Aufzeichnung. Drücke sie erneut, um zu stoppen. Siehe [Screenshots und Aufzeichnung](12-screenshots-recording.md) für die Details.

Alle Aufnahmeoptionen sind auch unter _Trigger > Capture_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Benachrichtigungen

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + ,` | Auf die neueste Benachrichtigung reagieren: sie öffnen oder ihre einzige Schaltfläche drücken, aus ihren Optionen wählen oder sie verwerfen, wenn sie keine hat |
| `Super + Shift + ,` | Alle Benachrichtigungen verwerfen |
| `Super + Ctrl + ,` | Benachrichtigungen mit der Tastatur steuern |
| `Super + Alt + ,` | Neueste Benachrichtigung verwerfen |
| `Super + Shift + Alt + ,` | Benachrichtigungsverlauf öffnen |
| `Super + Ctrl + Alt + ,` | Stummschalten von Benachrichtigungen ein-/ausschalten |

## Stil

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Ein neues Theme auswählen (auch `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Theme-Hintergrund auswählen (auch `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparenz bei einem Fenster ein-/ausschalten |
| `Super + Ctrl + Backspace` | Quadratisches Seitenverhältnis für ein einzelnes Fenster ein-/ausschalten |

Zusätzliche Hintergrundbilder liegen in `~/.config/omarchy/backgrounds/<theme name>`. Auch verfügbar über _Install > Style > Background_ im Omarchy-Menü.

Alle Stiloptionen sind auch unter _Style_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Umschalter

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Sperren bei Leerlauf ein-/ausschalten |
| `Super + Ctrl + Delete` | Laptop-Display ein-/ausschalten |
| `Super + Ctrl + Alt + Delete` | Spiegeln des Laptop-Displays ein-/ausschalten |
| `Super + Shift + Space` | Obere Leiste ein-/ausblenden |
| `Shift + Mute` | Zum nächsten Audioausgang wechseln |
| `Shift + Play` | Zur nächsten Medienquelle wechseln |
| `Super + Shift + Backspace` | Fensterabstände ein-/ausschalten |
| `Super + Ctrl + Alt + F` | Vollbild-Desktop ein-/ausschalten (obere Leiste + Fensterabstände) |

## Erinnerungen

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eine Erinnerung einstellen |
| `Super + Ctrl + Alt + R` | Alle Erinnerungen anzeigen |
| `Super + Ctrl + Shift + R` | Alle Erinnerungen löschen |

## Hinweise

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Zeit als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + B` | Akku als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + W` | Wetter als Benachrichtigung ein-/ausschalten |

## Tmux

Die Präfix-Taste ist `Ctrl + Space` (`Ctrl + B` funktioniert auch). Du kannst diese Bindings in `~/.config/tmux/tmux.conf` ändern.

### Panes

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Prefix + v` | Pane daneben teilen (vertikal) |
| `Prefix + h` | Pane darunter teilen (horizontal) |
| `Prefix + x` | Pane schließen |
| `Prefix + z` | Pane-Zoom umschalten (Vollbild) |
| `Alt + Enter` | Pane darunter teilen (ohne Präfix) |
| `Alt + Shift + Enter` | Pane daneben teilen (ohne Präfix) |
| `Alt + Escape` | Pane schließen (ohne Präfix) |
| `Ctrl + Alt + Arrows` | Zwischen Panes wechseln |
| `Ctrl + Alt + Shift + Arrows` | Panes in der Größe ändern |

### Fenster

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Prefix + c` | Neues Fenster |
| `Prefix + k` | Fenster schließen |
| `Prefix + r` | Fenster umbenennen |
| `Alt + 1-9` | Zu einem bestimmten Fenster gehen |
| `Alt + Arrow Left/Right` | Zwischen Fenstern wechseln |
| `Alt + Shift + Arrow Left/Right` | Fenster nach links/rechts verschieben |

### Sitzungen

| Tastenkombination | Funktion |
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

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopiermodus betreten |
| `v` | Auswahl beginnen (im Kopiermodus) |
| `y` | Auswahl kopieren (im Kopiermodus) |

### Allgemein

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguration neu laden |
| `Prefix + ?` | Tmux-Tastaturkürzel anzeigen |
| `Prefix + :` | Befehlsaufforderung |

### Tmux-Layoutfunktionen

Diese Funktionen müssen innerhalb einer Tmux-Sitzung ausgeführt werden.

| Befehl | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-Layout mit Editor, AI und Terminal erstellen |
| `tdlm <ai> [<second_ai>]` | Dev-Layout pro Unterverzeichnis erstellen |
| `tsl <count> <command>` | Multi-Pane-Schwarm-Layout erstellen |

## Ghostty-Terminal

Das Ghostty-Terminal wird mit _Install > Terminal_ über das Omarchy-Menü installiert.

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Neue Teilung darunter |
| `Ctrl + Shift + O` | Neue Teilung daneben |
| `Ctrl + Alt + Arrows` | Zwischen Splits wechseln |
| `Super + Ctrl + Shift + Arrows` | Split um 10 Zeilen in der Größe ändern |
| `Super + Ctrl + Shift + Alt + Arrows` | Split um 100 Zeilen in der Größe ändern |
| `Ctrl + Shift + T` | Neuer Tab |
| `Ctrl + Shift + Arrows` | Zwischen Tabs wechseln |
| `Alt + Numbers` | Zu einem bestimmten Tab gehen |
| `Shift + Pg Up/Down` | Durch den Verlauf scrollen |
| `Ctrl + Left mouse` | Link im Browser öffnen |

## Dateimanager

| Tastenkombination | Funktion |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Zu Pfad gehen |
| `Space` | Dateivorschau (Pfeile navigieren) |
| `Alt + Up` | Zum übergeordneten Ordner hochgehen |

## Neovim (mit lazyvim)

### Navigation

| Tastenkombination | Funktion |
| ------------------------ | ------------------------------- |
| `Space` | Befehlsoptionen anzeigen |
| `Space Space` | Datei über Fuzzy-Suche öffnen |
| `Space E` | Seitenleiste ein-/ausblenden |
| `Space G G` | Git-Steuerung anzeigen |
| `Space S G` | Dateiinhalt durchsuchen |
| `Ctrl + W W` | Zwischen Seitenleiste und Editor springen |
| `Ctrl + Left/right arrow` | Größe der Seitenleiste ändern |
| `Shift + H` | Zum linken Dateitab gehen |
| `Shift + L` | Zum rechten Dateitab gehen |
| `Space B D` | Dateitab schließen |

### In der Seitenleiste

| Tastenkombination | Funktion |
| ------------------------ | ------------------------------- |
| `A` | Neue Datei im übergeordneten Verzeichnis hinzufügen |
| `Shift + A` | Neues Unterverzeichnis im übergeordneten Verzeichnis hinzufügen |
| `D` | Markierte Datei/markiertes Verzeichnis löschen |
| `M` | Markierte Datei/markiertes Verzeichnis verschieben |
| `R` | Markierte Datei/markiertes Verzeichnis umbenennen |
| `?` | Hilfe für alle Befehle anzeigen |

[Siehe alle von LazyVim konfigurierten Neovim-Tastenkombinationen](https://www.lazyvim.org/keymaps).

## Schnelle Emojis

Du kannst mit `Super + Ctrl + E` eine vollständige Emoji-Auswahl anzeigen, die die Auswahl in die Zwischenablage legt, oder du kannst diese Schnellzugriffsoptionen verwenden.

| Tastenkombination | EM | Hinweis |
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
| `Shift + CapsLock M B` |🤯 | blowing |

## Schnelle Vervollständigungen

| Tastenkombination | Vervollständigung |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (Gedankenstrich) |
| `Shift + CapsLock Space N` | Dein Name (wie bei der Einrichtung eingegeben) |
| `Shift + CapsLock Space E` | Deine E-Mail (wie bei der Einrichtung eingegeben) |

Du kannst eigene hinzufügen, indem du `~/.XCompose` bearbeitest und dann `omarchy-restart-xcompose` im Terminal ausführst, damit die Änderungen übernommen werden.
