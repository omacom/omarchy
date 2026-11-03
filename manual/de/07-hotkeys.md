# Tastenkombinationen

Du siehst alle wichtigen Tastenkombinationen mit `Super + K` (Tmux-Kombinationen mit `Super + Alt + K` und Herdr-Kombinationen mit `Super + Ctrl + K`).

## So sind die Tastenkombinationen aufgebaut

Jede Tastenkombination liegt auf einer Ebene, bestimmt durch ihre Modifikatoren, und jede Ebene hat genau eine Aufgabe. Das verhindert, dass die Tastenkombinationen ineinander verschwimmen, und du kannst meist schon erraten, wo etwas zu finden ist.

| Ebene | Was dort zu finden ist | Beispiele |
| --- | --- | --- |
| `Super + key` | Das System: Fenster, Arbeitsbereiche, Layouts und Kernmenüs | `Super + Space` Omarchy-Menü, `Super + W` Fenster schließen, `Super + F` Vollbild |
| `Super + Shift + key` | Apps | `Super + Shift + B` Browser, `Super + Shift + E` E-Mail, `Super + Shift + N` Editor |
| `Super + Ctrl + key` | Panels und Systemmenüs | `Super + Ctrl + A` Audio, `Super + Ctrl + N` Netzwerk, `Super + Ctrl + C` Aufnahme-Menü |
| `Super + Ctrl + Alt + key` | Schnellaktionen und Hinweise | `Super + Ctrl + Alt + T` Uhrzeit anzeigen, `Super + Ctrl + Alt + B` Akku, `Super + Ctrl + Alt + C` Screenshot |

Wenn du `Alt` zu einer Tastenkombination hinzufügst, bekommst du eine Variante derselben Sache, niemals etwas völlig anderes:

- `Super + Shift + B` öffnet den Browser; `Super + Shift + Alt + B` öffnet ein privates Fenster
- `Super + Shift + E` öffnet die E-Mail; `Super + Shift + Alt + E` beginnt eine neue
- `Super + F` schaltet auf Vollbild; `Super + Alt + F` schaltet auf volle Breite
- `Super + Ctrl + C` öffnet das Aufnahme-Menü; `Super + Ctrl + Alt + C` überspringt das Menü und macht einen Screenshot

Wenn du eine Tastenkombination hinzufügst:

1. Wähle die Ebene danach, was sie tut, und dann die Taste.
2. Verschiebe keine bestehende Tastenkombination, um Platz zu schaffen. Finde eine freie Taste auf der richtigen Ebene.
3. Verwende `Alt` nur für eine Variante der Tastenkombination ohne `Alt`.

Einige wenige Tastenkombinationen brechen diese Regeln, weil es praktisch ist. `Shift` mit einem Pfeil oder `Tab` verschiebt oder kehrt um, statt eine App zu öffnen, und `Print`, die Medientasten, `Alt + Tab` und `Ctrl + Alt + Del` funktionieren so wie überall sonst auch. Das sind Ausnahmen, keine Muster zum Nachmachen.

Wenn dir eine Voreinstellung nicht passt (sagen wir, du willst `Super + Shift + S` für Screenshots wie unter Windows), ändere die Zuweisung in `~/.config/hypr/bindings.lua`.

## Navigieren

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-Menü (Apps und alles andere) |
| `Super + Alt + Space` | App-Übersicht |
| `Super + Escape` | Systemmenü (Ruhezustand, Neustart usw.) |
| `Super + Ctrl + L` | Computer sperren |
| `Super + W` oder `Super + Q` | Fenster schließen |
| `Ctrl + Alt + Del` | Alle Fenster schließen |
| `Super + T` | Fenster zwischen Tiling und Floating umschalten |
| `Super + J` | Fensterposition umschalten (horizontal/vertikal) |
| `Super + O` | Fenster in sticky'n'floating umschalten |
| `Super + L` | Durch die Layouts Dwindle, Scrolling und Floating durchwechseln |
| `Super + Alt + L` | Durch die Layouts in umgekehrter Reihenfolge durchwechseln |
| `Super + P` | Pseudo-Fensterstil umschalten (natürlich vs. gestreckt) |
| `Super + F` | Vollbild aktivieren |
| `Super + Alt + F` | Volle Breite aktivieren |
| `Super + Ctrl + F` | Vollbild innerhalb des Fensters aktivieren |
| `Super + 1/2/3/4` | Zu bestimmtem Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Tab` | Zum nächsten Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Shift + Tab` | Zum vorherigen Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Ctrl + Tab` | Zum früheren Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Shift + 1/2/3/4` | Fenster zu Arbeitsbereich auf dem fokussierten Monitor verschieben |
| `Super + Shift + Alt + 1/2/3/4` | Fenster zu Arbeitsbereich auf dem fokussierten Monitor verschieben, ohne zu folgen |
| `Super + S` | Vollständiges Scratchpad ein-/ausblenden |
| `Super + Alt + S` | Fenster ins vollständige Scratchpad verschieben |
| `Super + Grave` | Quake-Konsole ein-/ausblenden |
| `Super + Shift + Grave` | Fenster in die Quake-Konsole verschieben |
| `Super + Shift + Ctrl + Arrows` | Fenster auf den Monitor in dieser Richtung verschieben |
| `Super + Shift + Alt + Arrows` | Arbeitsbereich auf den Monitor in dieser Richtung verschieben |
| `Super + Arrow` | Fokus auf Fenster in Pfeilrichtung setzen, am Bildschirmrand auf den Monitor auf dieser Seite wechseln |
| `Super + Shift + Arrow` | Fenster mit einem anderen in Pfeilrichtung tauschen, auch mit einem auf dem Monitor auf dieser Seite |
| `Super + Minus` | Fenster nach links vergrößern |
| `Super + Equal` | Fenster nach links verkleinern |
| `Super + Shift + Minus` | Fenster nach oben verkleinern |
| `Super + Shift + Equal` | Fenster nach unten vergrößern |
| `Super + Alt + Minus/Equal` | Gleiches Vergrößern/Verkleinern in kleineren Schritten |
| `Super + Ctrl + Minus/Equal` | Gleiches Vergrößern/Verkleinern in größeren Schritten |
| `Super + Alt + Home` | Fensterbreite speichern |
| `Super + Home` | Gespeicherte Fensterbreite wiederherstellen |
| `Super + Left Mouse` | Fenster ziehen |
| `Super + Right Mouse` | Fenstergröße ändern |
| `Super + Scroll Wheel` | Durch Arbeitsbereiche auf dem fokussierten Monitor scrollen |
| `Super + G` | Fenstergruppierung ein-/ausschalten |
| `Super + Alt + G` | Fenster aus der Gruppierung herausbewegen |
| `Super + Alt + Tab` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + Shift + Tab` | Rückwärts zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + Scroll Wheel` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + 1/2/3/4/5` | Zu bestimmtem Fenster in der Gruppierung springen |
| `Super + Alt + Arrow` | Fenster in Pfeilrichtung in eine Gruppierung bewegen, auch eines auf dem Monitor auf dieser Seite |
| `Super + Ctrl + Left/Right` | Zwischen Fenstern innerhalb einer Tiling-Gruppe wechseln |
| `Super + Ctrl + Z` | Bildschirm heranzoomen (wiederholen für mehr Zoom) |
| `Super + Ctrl + Alt + Z` | Bildschirm vollständig herauszoomen |
| `Super + /` | Vorwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Super + Alt + /` | Rückwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Alt + Tab` | Vorwärts durch Fenster auf dem aktiven Arbeitsbereich wechseln |
| `Alt + Shift + Tab` | Rückwärts durch Fenster auf dem aktiven Arbeitsbereich wechseln |
| `Ctrl + Alt + Tab` | Fokus vorwärts durch Monitore wechseln |
| `Ctrl + Alt + Shift + Tab` | Fokus rückwärts durch Monitore wechseln |

Die Kürzel zum Ändern der Größe verwenden die physischen Tasten `code:20` und `code:21` (XKB `<AE11>` und `<AE12>`), unabhängig von den auf der Tastatur aufgedruckten Zeichen. Auf US-Tastaturen sind diese Tasten `-` und `=`; auf japanischen (JIS) Tastaturen sind es `-` und `^`; auf spanischen Tastaturen sind es `'` und `¡`. Auf JIS ist `Super + ^` gleich `Super + Equal`, während `Super + Shift + -` (was `=` eingibt) gleich `Super + Shift + Minus` ist.

## Systemsteuerung

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audio-Panel |
| `Super + Ctrl + B` | Bluetooth-Panel |
| `Super + Ctrl + N` | Wi-Fi/Netzwerk-Panel |
| `Super + Ctrl + D` | Anzeige-Panel |
| `Super + Ctrl + P` | Energie-Panel |
| `Super + Ctrl + Alt + D` | Kalender-Panel |
| `Super + Ctrl + Alt + E` | Weltuhr-Panel |
| `Super + Ctrl + 1-9` | Leisten-Panel nach Position ein-/ausblenden |
| `Super + Ctrl + S` | Teilen-Menü (via LocalSend) |
| `Super + Ctrl + C` | Aufnahme-Steuerung (Screenshot/-Aufzeichnung/-Auswahl) |
| `Super + Ctrl + O` | Menü ein-/ausblenden |
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
| `Keyboard Brightness Up/Down` | Tastatur-Hintergrundbeleuchtung heller/dunkler |
| `Keyboard Backlight` | Stufen der Tastatur-Hintergrundbeleuchtung durchwechseln |
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
| `Super + Shift + /` | Passwort-Manager (1password) |
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

Ändere Zuweisungen in `~/.config/hypr/bindings.lua` oder füge dort welche hinzu.

## Universelle Zwischenablage

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + A` | Alles auswählen in Apps, die `Ctrl + A` unterstützen |
| `Super + C` | Kopieren |
| `Super + X` | Ausschneiden (nicht im Terminal) |
| `Super + V` | Einfügen |
| `Super + Ctrl + V` | Zwischenablage-Manager |

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V`, um im Terminal zu kopieren und einzufügen, und `Ctrl + C/V`, um es überall sonst zu tun. Diese vereinheitlichten Omarchy-Tastenkombinationen für die Zwischenablage funktionieren überall.

## Aufnahme

| Tastenkombination | Funktion |
| ------------------- | ------------------------------ |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot (derselbe Screenshot, für Tastaturen ohne Print Screen-Taste) |
| `Super + Ctrl + C` | Aufnahme-Menü |
| `Alt + Print Screen` | Bildschirmaufzeichnung |
| `Super + Print Screen` | Farbauswahl |
| `Super + Ctrl + Print Screen` | Textextraktion in die Zwischenablage |
| `Super + Alt + [` | Webcam-Overlay während der Aufzeichnung kleiner machen |
| `Super + Alt + ]` | Webcam-Overlay während der Aufzeichnung größer machen |
| `Alt + Shift + L` | Aktuelle URL aus Webapp oder Chromium kopieren |
| `Alt + Shift + D` | Das Video auf der aktuellen Seite nach `~/Videos` herunterladen |
| `Alt + Space` | Diktat starten/stoppen (erfordert _Setup > Defaults > Dictation_) |
| `Right Alt` | Gedrückt halten zum Diktieren (erfordert _Setup > Defaults > Dictation_) |

Bei Bildschirmaufzeichnungen fragt die Tastenkombination zuerst, welches Audio du willst, und startet dann die Aufzeichnung. Drücke sie erneut, um zu stoppen. Siehe [Screenshots und Aufzeichnung](12-screenshots-recording.md) für die Details.

Alle Aufnahme-Optionen sind auch unter _Trigger > Capture_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Benachrichtigungen

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + ,` | Auf neueste Benachrichtigung reagieren: sie öffnen oder ihre einzige Schaltfläche drücken, aus ihren Optionen wählen oder sie verwerfen, wenn sie keine hat |
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
| `Super + Ctrl + Backspace` | Quadratisches Seitenverhältnis für einzelnes Fenster ein-/ausschalten |

Zusätzliche Hintergrundbilder liegen in `~/.config/omarchy/backgrounds/<theme name>`. Auch verfügbar über _Install > Style > Background_ im Omarchy-Menü.

Alle Stil-Optionen sind auch unter _Style_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Umschalter

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Sperren bei Inaktivität ein-/ausschalten |
| `Super + Ctrl + Delete` | Laptop-Display ein-/ausschalten |
| `Super + Ctrl + Alt + Delete` | Spiegeln des Laptop-Displays ein-/ausschalten |
| `Super + Shift + Space` | Oberste Leiste ein-/ausblenden |
| `Shift + Mute` | Zum nächsten Audio-Ausgang wechseln |
| `Shift + Play` | Zur nächsten Medienquelle wechseln |
| `Super + Shift + Backspace` | Fensterabstände ein-/ausschalten |
| `Super + Ctrl + Alt + F` | Vollbild-Desktop umschalten (oberste Leiste + Fensterabstände) |

## Erinnerungen

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Erinnerung setzen |
| `Super + Ctrl + Alt + R` | Alle Erinnerungen anzeigen |
| `Super + Ctrl + Shift + R` | Alle Erinnerungen löschen |

## Hinweise

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Uhrzeit als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + B` | Akku als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + W` | Wetter als Benachrichtigung ein-/ausblenden |

## Tmux

Die Prefix-Taste ist `Ctrl + Space` (`Ctrl + B` funktioniert auch). Du kannst diese Zuweisungen in `~/.config/tmux/tmux.conf` ändern.

### Bereiche

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Prefix + v` | Bereich daneben teilen (vertikal) |
| `Prefix + h` | Bereich darunter teilen (horizontal) |
| `Prefix + x` | Bereich beenden |
| `Prefix + z` | Pane-Zoom umschalten (Vollbild) |
| `Alt + Enter` | Bereich darunter teilen (ohne Prefix) |
| `Alt + Shift + Enter` | Bereich daneben teilen (ohne Prefix) |
| `Alt + Escape` | Bereich beenden (ohne Prefix) |
| `Ctrl + Alt + Arrows` | Zwischen Bereichen wechseln |
| `Ctrl + Alt + Shift + Arrows` | Größe der Bereiche ändern |

### Fenster

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Prefix + c` | Neues Fenster |
| `Prefix + k` | Fenster beenden |
| `Prefix + r` | Fenster umbenennen |
| `Alt + 1-9` | Zu bestimmtem Fenster gehen |
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
| `Prefix + ?` | Tmux-Tastenkombinationen anzeigen |
| `Prefix + :` | Befehlsaufforderung |

### Tmux-Layout-Funktionen

Diese Funktionen müssen innerhalb einer Tmux-Sitzung ausgeführt werden.

| Befehl | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-Layout mit Editor, AI und Terminal erstellen |
| `tdlm <ai> [<second_ai>]` | Dev-Layout pro Unterverzeichnis erstellen |
| `tsl <count> <command>` | Multi-Pane-Schwarm-Layout erstellen |

## Ghostty Terminal

Das Ghostty-Terminal wird mit _Install > Terminal_ über das Omarchy-Menü installiert.

| Tastenkombination | Funktion |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Neuer Split darunter |
| `Ctrl + Shift + O` | Neuer Split daneben |
| `Ctrl + Alt + Arrows` | Zwischen Splits wechseln |
| `Super + Ctrl + Shift + Arrows` | Split-Größe um 10 Zeilen ändern |
| `Super + Ctrl + Shift + Alt + Arrows` | Split-Größe um 100 Zeilen ändern |
| `Ctrl + Shift + T` | Neuer Tab |
| `Ctrl + Shift + Arrows` | Zwischen Tabs wechseln |
| `Alt + Numbers` | Zu bestimmtem Tab gehen |
| `Shift + Pg Up/Down` | Durch den Verlauf scrollen |
| `Ctrl + Left mouse` | Link im Browser öffnen |

## Dateimanager

| Tastenkombination | Funktion |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Zum Pfad gehen |
| `Space` | Dateivorschau (Pfeile navigieren) |
| `Alt + Up` | Nach oben in den übergeordneten Ordner gehen |

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
| `D` | Hervorgehobene Datei/Verzeichnis löschen |
| `M` | Hervorgehobene Datei/Verzeichnis verschieben |
| `R` | Hervorgehobene Datei/Verzeichnis umbenennen |
| `?` | Hilfe für alle Befehle anzeigen |

[Siehe alle von LazyVim konfigurierten Neovim-Tastenkombinationen](https://www.lazyvim.org/keymaps).

## Schnelle Emojis

Du kannst `Super + Ctrl + E` verwenden, um eine vollständige Emoji-Auswahl anzuzeigen, die die Auswahl in die Zwischenablage legt, oder du kannst diese Schnellzugriff-Optionen verwenden.

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
| `Shift + CapsLock M B` |🤯 | explodierend |

## Schnelle Vervollständigungen

| Tastenkombination | Vervollständigung |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (Gedankenstrich) |
| `Shift + CapsLock Space N` | Dein Name (wie bei der Einrichtung eingegeben) |
| `Shift + CapsLock Space E` | Deine E-Mail (wie bei der Einrichtung eingegeben) |

Du kannst eigene hinzufügen, indem du `~/.XCompose` bearbeitest und dann `omarchy-restart-xcompose` im Terminal ausführst, damit die Änderungen übernommen werden.
