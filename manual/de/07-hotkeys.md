# Tastaturkürzel

Du kannst alle wichtigen Tastaturbindungen mit `Super + K` sehen (Tmux-Bindungen mit `Super + Alt + K` und Herdr-Bindungen mit `Super + Ctrl + K`).

## Wie Tastaturkürzel aufgebaut sind

Jedes Tastaturkürzel liegt auf einer Ebene, festgelegt durch seine Modifikatortasten, und jede Ebene hat eine Aufgabe. Das hält die Tastaturkürzel auseinander, und es bedeutet, dass du normalerweise erraten kannst, wo etwas zu finden ist.

| Ebene | Was dort zu finden ist | Beispiele |
| --- | --- | --- |
| `Super + key` | Das System: Fenster, Arbeitsbereiche, Layouts und Kernmenüs | `Super + Space` Omarchy-Menü, `Super + W` Fenster schließen, `Super + F` Vollbild |
| `Super + Shift + key` | Apps | `Super + Shift + B` Browser, `Super + Shift + E` E-Mail, `Super + Shift + N` Editor |
| `Super + Ctrl + key` | Bedienfelder und Systemmenüs | `Super + Ctrl + A` Audio, `Super + Ctrl + N` Netzwerk, `Super + Ctrl + C` Aufnahmemenü |
| `Super + Ctrl + Alt + key` | Schnellaktionen und Hinweise | `Super + Ctrl + Alt + T` Uhrzeit anzeigen, `Super + Ctrl + Alt + B` Akku, `Super + Ctrl + Alt + C` Screenshot |

`Alt` zu einem Tastaturkürzel hinzuzufügen gibt dir eine Variante derselben Sache, niemals etwas Unverbundenes:

- `Super + Shift + B` öffnet den Browser; `Super + Shift + Alt + B` öffnet ein privates Fenster
- `Super + Shift + E` öffnet E-Mail; `Super + Shift + Alt + E` beginnt eine neue
- `Super + F` geht in den Vollbildmodus; `Super + Alt + F` geht auf volle Breite
- `Super + Ctrl + C` öffnet das Aufnahmemenü; `Super + Ctrl + Alt + C` überspringt das Menü und macht einen Screenshot

Beim Hinzufügen eines Tastaturkürzels:

1. Wähle die Ebene danach, was es tut, dann wähle die Taste.
2. Verschiebe kein bestehendes Tastaturkürzel, um Platz zu machen. Finde eine freie Taste auf der richtigen Ebene.
3. Verwende `Alt` nur für eine Variante des Tastaturkürzels ohne es.

Einige wenige Tastaturkürzel brechen diese Regeln, weil es praktisch ist. `Shift` mit einem Pfeil oder `Tab` bewegt oder kehrt um, statt eine App zu öffnen, und `Print`, die Medientasten, `Alt + Tab` und `Ctrl + Alt + Del` funktionieren so, wie sie es überall sonst tun. Sie sind Ausnahmen, keine Muster zum Nachahmen.

Wenn dir ein Standard nicht zusagt (sagen wir, du willst `Super + Shift + S` für Screenshots wie unter Windows), binde ihn in `~/.config/hypr/bindings.lua` neu.

## Navigieren

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-Menü (Apps und alles andere) |
| `Super + Alt + Space` | App-Raster |
| `Super + Escape` | Systemmenü (Ruhezustand, Neustart usw.) |
| `Super + Ctrl + L` | Computer sperren |
| `Super + W` or `Super + Q` | Fenster schließen |
| `Ctrl + Alt + Del` | Alle Fenster schließen |
| `Super + K` | Alle Tastaturkürzel anzeigen |
| `Super + Alt + K` | tmux-Tastaturkürzel anzeigen |
| `Super + Ctrl + K` | herdr-Tastaturkürzel anzeigen |
| `Super + M` | Fenster ins Dock minimieren |
| `Super + T` | Fenster zwischen Tiling/Floating umschalten |
| `Super + J` | Fensterposition umschalten (horizontal/vertikal) |
| `Super + O` | Hervorgehobenes Fenster als sticky'n'floating umschalten |
| `Super + L` | Durch die Layouts dwindle, scrolling und floating wechseln |
| `Super + Alt + L` | Durch die Layouts in umgekehrter Reihenfolge wechseln |
| `Super + P` | Pseudo-Fensterstil umschalten (natürlich vs. gestreckt) |
| `Super + F` | In den Vollbildmodus gehen |
| `Super + Alt + F` | Auf volle Breite gehen |
| `Super + Ctrl + F` | In den Vollbildmodus innerhalb des Fensters gehen |
| `Super + 1…9/0` | Zu einem bestimmten Arbeitsbereich (0 ist 10) auf dem fokussierten Monitor springen |
| `Super + Tab` | Zum nächsten Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Shift + Tab` | Zum vorherigen Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Ctrl + Tab` | Zum früheren Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Shift + 1…9/0` | Fenster zu einem Arbeitsbereich auf dem fokussierten Monitor verschieben |
| `Super + Shift + Alt + 1…9/0` | Fenster zu einem Arbeitsbereich auf dem fokussierten Monitor verschieben, ohne zu folgen |
| `Super + S` | Vollständiges Scratchpad umschalten |
| `Super + Alt + S` | Fenster ins vollständige Scratchpad verschieben |
| `Super + Grave` | Quake-Konsole umschalten |
| `Super + Shift + Grave` | Fenster zur Quake-Konsole verschieben |
| `Super + Shift + Ctrl + Arrows` | Fenster auf den Monitor in dieser Richtung verschieben |
| `Super + Shift + Alt + Arrows` | Arbeitsbereich auf den Monitor in dieser Richtung verschieben |
| `Super + Arrow` | Fokus zum Fenster in Richtung des Pfeils bewegen, an der Kante des Bildschirms zum Monitor auf dieser Seite überwechseln |
| `Super + Shift + Arrow` | Fenster mit einem anderen in Richtung des Pfeils tauschen, einschließlich eines auf dem Monitor auf dieser Seite |
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
| `Super + Scroll Wheel` | Durch Arbeitsbereiche auf dem fokussierten Monitor scrollen |
| `Super + G` | Fenstergruppierung umschalten |
| `Super + Alt + G` | Fenster aus der Gruppierung herausbewegen |
| `Super + Alt + Tab` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + Shift + Tab` | Rückwärts zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + Scroll Wheel` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + 1/2/3/4/5` | Zu einem bestimmten Fenster in der Gruppierung springen |
| `Super + Alt + Arrow` | Fenster in Richtung des Pfeils in eine Gruppierung bewegen, einschließlich eines auf dem Monitor auf dieser Seite |
| `Super + Ctrl + Left/Right` | Zwischen Fenstern innerhalb einer Tiling-Gruppe bewegen |
| `Super + Ctrl + Z` | Auf dem Bildschirm heranzoomen (für mehr Zoom wiederholen) |
| `Super + Ctrl + Alt + Z` | Vollständig vom Bildschirm herauszoomen |
| `Super + /` | Schrittweise vorwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Super + Alt + /` | Schrittweise rückwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Alt + Tab` | Vorwärts durch Fenster auf dem aktiven Arbeitsbereich wechseln |
| `Alt + Shift + Tab` | Rückwärts durch Fenster auf dem aktiven Arbeitsbereich wechseln |
| `Ctrl + Alt + Tab` | Fokus vorwärts durch Monitore wechseln |
| `Ctrl + Alt + Shift + Tab` | Fokus rückwärts durch Monitore wechseln |
| `Super + I` | Eingabesprache wechseln (bei mehr als einem Layout oder einer Eingabemethode) |
| `Super + Shift + I` | Eingabesprache zurück wechseln |

Auf einem Touchpad wechseln Wischgesten mit drei und vier Fingern Arbeitsbereiche, bewegen Fenster und öffnen das Menü und die Quake-Konsole; siehe [Tastatur, Maus und Trackpad](34-keyboard-mouse-trackpad.md) für die Gesten.

Tastaturkürzel zum Ändern der Größe verwenden die physischen Tasten `code:20` und `code:21` (XKB `<AE11>` und `<AE12>`), unabhängig von den auf der Tastatur aufgedruckten Zeichen. Auf US-Tastaturen sind diese Tasten `-` und `=`; auf japanischen (JIS) Tastaturen sind sie `-` und `^`; auf spanischen Tastaturen sind sie `'` und `¡`. Auf JIS ist `Super + ^` gleich `Super + Equal`, während `Super + Shift + -` (das `=` eingibt) gleich `Super + Shift + Minus` ist.

## Systemsteuerung

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audio-Bedienfeld |
| `Super + Ctrl + B` | Bluetooth-Bedienfeld |
| `Super + Ctrl + N` | Wi-Fi/Netzwerk-Bedienfeld |
| `Super + Ctrl + D` | Anzeige-Bedienfeld |
| `Super + Ctrl + P` | Energie-Bedienfeld |
| `Super + Ctrl + X` | Agents-Bedienfeld |
| `Super + Ctrl + Shift + X` | Bedienfeld für lokale Modelle |
| `Super + Ctrl + Alt + D` | Kalender-Bedienfeld |
| `Super + Ctrl + Alt + E` | Weltuhr-Bedienfeld |
| `Super + Ctrl + 1-9` | Leisten-Bedienfeld nach Position umschalten |
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

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximale Bildschirmhelligkeit |
| `Shift + Brightness Down` | Minimale Bildschirmhelligkeit |
| `Alt + Brightness Up/Down` | Präzise Helligkeitsänderungen um 1 % |
| `Alt + Volume Up/Down` | Präzise Lautstärkeänderungen um 1 % |
| `Keyboard Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler |
| `Keyboard Backlight` | Die Stufen der Tastaturbeleuchtung durchwechseln |
| `Ctrl + Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler, auf Tastaturen ohne eigene Tasten |
| `Mic Mute` | Das Mikrofon stummschalten |
| `Shift + Mute` | Audioausgabe wechseln |
| `Touchpad Toggle` | Das Touchpad ein- oder ausschalten |
| `Display` key | Das Arbeitsbereichs-Layout durchwechseln |
| `Alt + Play` | Nächster Titel |
| `Alt + Shift + Play` | Vorheriger Titel |

## Apps starten

| Tastaturkürzel | Funktion |
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
| `Super + Shift + Q` or `Calculator` key | Rechner (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, sobald installiert) |
| `Super + Shift + T` | Aktivität (btop) |
| `Super + Shift + N` | Editor (Plain oder dein gewählter Standard) |
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

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + A` | Alles auswählen in Apps, die `Ctrl + A` unterstützen |
| `Super + C` | Kopieren |
| `Super + X` | Ausschneiden (nicht im Terminal) |
| `Super + V` | Einfügen |
| `Super + Ctrl + V` | Zwischenablage-Manager |

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V` zum Kopieren und Einfügen im Terminal und `Ctrl + C/V`, um es überall sonst zu tun. Diese vereinheitlichten Tastaturkürzel für die Zwischenablage von Omarchy funktionieren überall.

## Aufnahme

| Tastaturkürzel | Funktion |
| ------------------- | ------------------------------ |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot (dieselbe Aufnahme, für Tastaturen ohne Print Screen-Taste) |
| `Super + Ctrl + C` | Aufnahmemenü |
| `Alt + Print Screen` | Bildschirmaufnahme |
| `Super + Shift + Ctrl + Alt + C` | Bildschirmaufnahme ohne Audio, ohne Menü (erneut drücken zum Stoppen) |
| `Super + Print Screen` | Farbauswahl |
| `Super + Ctrl + Print Screen` | Textextraktion in die Zwischenablage |
| `Super + Alt + [` | Webcam-Overlay während der Aufnahme kleiner machen |
| `Super + Alt + ]` | Webcam-Overlay während der Aufnahme größer machen |
| `Alt + Shift + L` | Aktuelle URL aus Webapp oder Browser kopieren |
| `Alt + Shift + D` | Das Video auf der aktuellen Seite nach `~/Videos` herunterladen |
| `Alt + Space` | Diktieren starten/stoppen (erfordert _Setup > Defaults > Dictation_) |
| `Right Alt` | Gedrückt halten zum Diktieren (erfordert _Setup > Defaults > Dictation_) |

Bei Bildschirmaufnahmen fragt das Tastaturkürzel zuerst, welches Audio du willst, und startet dann die Aufnahme. Drücke es erneut, um zu stoppen. Siehe [Screenshots und Aufnahme](12-screenshots-recording.md) für die Details.

Alle Aufnahmeoptionen sind auch unter _Trigger > Capture_ im Omarchy-Menü (`Super + Space`) verfügbar.

## Benachrichtigungen

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + ,` | Auf die neueste Benachrichtigung reagieren: sie öffnen oder ihre einzige Schaltfläche drücken, aus ihren Optionen auswählen oder sie verwerfen, wenn sie keine hat |
| `Super + Shift + ,` | Alle Benachrichtigungen verwerfen |
| `Super + Ctrl + ,` | Benachrichtigungen mit der Tastatur steuern |
| `Super + Alt + ,` | Neueste Benachrichtigung verwerfen |
| `Super + Shift + Alt + ,` | Benachrichtigungsverlauf öffnen |
| `Super + Ctrl + Alt + ,` | Stummschalten von Benachrichtigungen umschalten |

## Stil

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Ein neues Theme auswählen (auch `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Theme-Hintergrund auswählen (auch `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparenz bei einem Fenster umschalten |
| `Super + Ctrl + Backspace` | Quadratisches Seitenverhältnis für ein einzelnes Fenster umschalten |

Zusätzliche Hintergrundbilder liegen in `~/.config/omarchy/backgrounds/<theme name>`. Auch über _Install > Style > Background_ im Omarchy-Menü verfügbar.

Alle Stiloptionen sind auch unter _Appearance_ im Omarchy-Menü (`Super + Space`) verfügbar.

## Schalter

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Sperren bei Leerlauf umschalten |
| `Super + Ctrl + Delete` | Laptop-Display ein-/ausschalten |
| `Super + Ctrl + Alt + Delete` | Spiegeln des Laptop-Displays umschalten |
| `Super + Shift + Space` | Die obere Leiste umschalten |
| `Shift + Mute` | Zur nächsten Audioausgabe wechseln |
| `Shift + Play` | Zur nächsten Medienquelle wechseln |
| `Super + Shift + Backspace` | Fensterabstände umschalten |
| `Super + Ctrl + Alt + F` | Vollbild-Desktop umschalten (obere Leiste + Fensterabstände) |

## Erinnerungen

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eine Erinnerung erstellen |
| `Super + Ctrl + Alt + R` | Alle Erinnerungen anzeigen |
| `Super + Ctrl + Shift + R` | Alle Erinnerungen löschen |

## Hinweise

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Uhrzeit als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + B` | Akku als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + W` | Wetter als Benachrichtigung umschalten |

## Tmux

Die Prefix-Taste ist `Ctrl + Space` (`Ctrl + B` funktioniert auch). Du kannst diese Bindungen in `~/.config/tmux/tmux.conf` ändern.

### Bereiche

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Prefix + v` | Bereich daneben teilen (vertikal) |
| `Prefix + h` | Bereich darunter teilen (horizontal) |
| `Prefix + x` | Bereich beenden |
| `Prefix + z` | Bereichs-Zoom umschalten (Vollbild) |
| `Alt + Enter` | Bereich darunter teilen (ohne Prefix) |
| `Alt + Shift + Enter` | Bereich daneben teilen (ohne Prefix) |
| `Alt + Escape` | Bereich beenden (ohne Prefix) |
| `Ctrl + Alt + Arrows` | Zwischen Bereichen bewegen |
| `Ctrl + Alt + Shift + Arrows` | Bereichsgröße ändern |

### Fenster

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Prefix + c` | Neues Fenster |
| `Prefix + k` | Fenster beenden |
| `Prefix + r` | Fenster umbenennen |
| `Alt + 1-9` | Zu einem bestimmten Fenster gehen |
| `Alt + Arrow Left/Right` | Zwischen Fenstern bewegen |
| `Alt + Shift + Arrow Left/Right` | Fenster nach links/rechts bewegen |

### Sitzungen

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Prefix + C` | Neue Sitzung |
| `Prefix + K` | Sitzung beenden |
| `Prefix + R` | Sitzung umbenennen |
| `Prefix + N` | Nächste Sitzung |
| `Prefix + P` | Vorherige Sitzung |
| `Alt + Arrow Up/Down` | Zwischen Sitzungen bewegen |
| `Prefix + s` | Sitzungen auflisten |
| `Prefix + d` | Von Sitzung trennen |

### Kopiermodus (vi-Stil)

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Prefix + [` | In den Kopiermodus wechseln |
| `v` | Auswahl beginnen (im Kopiermodus) |
| `y` | Auswahl kopieren (im Kopiermodus) |

### Allgemein

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguration neu laden |
| `Prefix + ?` | Tmux-Tastaturbindungen anzeigen |
| `Prefix + :` | Befehlseingabe |

### Tmux-Layout-Funktionen

Diese Funktionen müssen innerhalb einer Tmux-Sitzung ausgeführt werden.

| Befehl | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-Layout mit Editor, AI und Terminal erstellen |
| `tdlm <ai> [<second_ai>]` | Dev-Layout pro Unterverzeichnis erstellen |
| `tsl <count> <command>` | Schwarm-Layout mit mehreren Bereichen erstellen |

## Ghostty Terminal

Das Ghostty-Terminal wird mit _Install > Terminal_ über das Omarchy-Menü installiert.

| Tastaturkürzel | Funktion |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Neue Teilung darunter |
| `Ctrl + Shift + O` | Neue Teilung daneben |
| `Ctrl + Alt + Arrows` | Zwischen Teilungen bewegen |
| `Super + Ctrl + Shift + Arrows` | Größe der Teilung um 10 Zeilen ändern |
| `Super + Ctrl + Shift + Alt + Arrows` | Größe der Teilung um 100 Zeilen ändern |
| `Ctrl + Shift + T` | Neuer Tab |
| `Ctrl + Shift + Arrows` | Zwischen Tabs bewegen |
| `Alt + Numbers` | Zu einem bestimmten Tab gehen |
| `Shift + Pg Up/Down` | Durch den Verlauf scrollen |
| `Ctrl + Left mouse` | Link im Browser öffnen |

## Dateimanager

| Tastaturkürzel | Funktion |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Zu einem Pfad gehen |
| `Space` | Datei in der Vorschau ansehen (Pfeile navigieren) |
| `Alt + Up` | Zum übergeordneten Ordner hochgehen |

## Neovim (mit lazyvim)

### Navigation

| Tastaturkürzel | Funktion |
| ------------------------ | ------------------------------- |
| `Space` | Befehlsoptionen anzeigen |
| `Space Space` | Datei über Fuzzy-Suche öffnen |
| `Space E` | Seitenleiste umschalten |
| `Space G G` | Git-Steuerung anzeigen |
| `Space S G` | Dateiinhalte durchsuchen |
| `Ctrl + W W` | Zwischen Seitenleiste und Editor springen |
| `Ctrl + Left/right arrow` | Größe der Seitenleiste ändern |
| `Shift + H` | Zum linken Datei-Tab gehen |
| `Shift + L` | Zum rechten Datei-Tab gehen |
| `Space B D` | Datei-Tab schließen |

### In der Seitenleiste

| Tastaturkürzel | Funktion |
| ------------------------ | ------------------------------- |
| `A` | Neue Datei im übergeordneten Verzeichnis hinzufügen |
| `Shift + A` | Neues Unterverzeichnis im übergeordneten Verzeichnis hinzufügen |
| `D` | Markierte Datei/markiertes Verzeichnis löschen |
| `M` | Markierte Datei/markiertes Verzeichnis verschieben |
| `R` | Markierte Datei/markiertes Verzeichnis umbenennen |
| `?` | Hilfe für alle Befehle anzeigen |

[Siehe alle von LazyVim konfigurierten Neovim-Tastaturkürzel](https://www.lazyvim.org/keymaps).

## Schnelle Emojis

Du kannst `Super + Ctrl + E` verwenden, um eine vollständige Emoji-Auswahl anzuzeigen, die die Auswahl in die Zwischenablage legt, oder du kannst diese Schnellzugriffsoptionen verwenden.

| Tastaturkürzel | EM | Hinweis |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | Lächeln |
| `Shift + CapsLock M C` | 😂 | Weinen |
| `Shift + CapsLock M L` | 😍 | Liebe |
| `Shift + CapsLock M V` | ✌️ | Sieg |
| `Shift + CapsLock M H` | ❤️ | Herz |
| `Shift + CapsLock M Y` | 👍 | ja |
| `Shift + CapsLock M N` | 👎 | nein |
| `Shift + CapsLock M F` | 🖕 | fuck |
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
| `Shift + CapsLock M B` |🤯 | umwerfend |

## Schnelle Vervollständigungen

| Tastaturkürzel | Vervollständigung |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (Geviertstrich) |
| `Shift + CapsLock Space N` | Dein Name (wie bei der Einrichtung eingegeben) |
| `Shift + CapsLock Space E` | Deine E-Mail (wie bei der Einrichtung eingegeben) |

Du kannst weitere eigene hinzufügen, indem du `~/.XCompose` bearbeitest und dann `omarchy restart xcompose` im Terminal ausführst, damit die Änderungen übernommen werden.
