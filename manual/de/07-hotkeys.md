# Tastenkürzel

Du siehst alle wichtigen Tastaturbelegungen mit `Super + K` (Tmux-Belegungen mit `Super + Alt + K` und Herdr-Belegungen mit `Super + Ctrl + K`).

## Wie Tastenkürzel aufgebaut sind

Jedes Tastenkürzel liegt auf einer Ebene, die durch seine Modifikatortasten festgelegt wird, und jede Ebene hat eine Aufgabe. Das hält die Tastenkürzel auseinander und bedeutet, dass du meist erraten kannst, wo etwas zu finden ist.

| Ebene | Was dort zu finden ist | Beispiele |
| --- | --- | --- |
| `Super + key` | Das System: Fenster, Arbeitsbereiche, Layouts und Kernmenüs | `Super + Space` Omarchy-Menü, `Super + W` Fenster schließen, `Super + F` Vollbild |
| `Super + Shift + key` | Apps | `Super + Shift + B` Browser, `Super + Shift + E` E-Mail, `Super + Shift + N` Editor |
| `Super + Ctrl + key` | Bedienfelder und Systemmenüs | `Super + Ctrl + A` Audio, `Super + Ctrl + N` Netzwerk, `Super + Ctrl + C` Aufnahmemenü |
| `Super + Ctrl + Alt + key` | Schnellaktionen und Hinweise | `Super + Ctrl + Alt + T` Zeit anzeigen, `Super + Ctrl + Alt + B` Akku, `Super + Ctrl + Alt + C` Screenshot |

Wenn du `Alt` zu einem Tastenkürzel hinzufügst, erhältst du eine Variante desselben Dings, niemals etwas Unzusammenhängendes:

- `Super + Shift + B` öffnet den Browser; `Super + Shift + Alt + B` öffnet ein privates Fenster
- `Super + Shift + E` öffnet die E-Mail; `Super + Shift + Alt + E` beginnt eine neue
- `Super + F` geht ins Vollbild; `Super + Alt + F` geht auf volle Breite
- `Super + Ctrl + C` öffnet das Aufnahmemenü; `Super + Ctrl + Alt + C` überspringt das Menü und macht einen Screenshot

Beim Hinzufügen eines Tastenkürzels:

1. Wähle die Ebene nach dem, was es tut, dann wähle die Taste.
2. Verschiebe kein bestehendes Tastenkürzel, um Platz zu machen. Finde eine freie Taste auf der richtigen Ebene.
3. Verwende `Alt` nur für eine Variante des Tastenkürzels ohne diese Taste.

Einige Tastenkürzel brechen diese Regeln, weil sie praktisch sind. `Shift` mit einem Pfeil oder `Tab` verschiebt oder kehrt um, statt eine App zu öffnen, und `Print`, die Medientasten, `Alt + Tab` und `Ctrl + Alt + Del` funktionieren so wie überall sonst. Sie sind Ausnahmen, keine Muster zum Kopieren.

Wenn dir eine Standardeinstellung nicht zusagt (sagen wir, du willst `Super + Shift + S` für Screenshots wie unter Windows), belege sie in `~/.config/hypr/bindings.lua` neu.

## Navigation

| Tastenkürzel | Funktion |
| --- | --- |
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
| `Super + T` | Fenster zwischen Kachel-/Schwebemodus umschalten |
| `Super + J` | Fensterposition umschalten (horizontal/vertikal) |
| `Super + O` | Fenster in sticky'n'floating ein- und ausrasten lassen |
| `Super + L` | Durch die Layouts Dwindle, Scrolling und Floating wechseln |
| `Super + Alt + L` | Durch die Layouts in umgekehrter Reihenfolge wechseln |
| `Super + P` | Pseudo-Fensterstil umschalten (natürlich vs. gestreckt) |
| `Super + F` | Ins Vollbild gehen |
| `Super + Alt + F` | Auf volle Breite gehen |
| `Super + Ctrl + F` | Ins Vollbild innerhalb des Fensters gehen |
| `Super + 1…9/0` | Zu einem bestimmten Arbeitsbereich springen (0 ist 10) auf dem fokussierten Monitor |
| `Super + Tab` | Zum nächsten Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Shift + Tab` | Zum vorherigen Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Ctrl + Tab` | Zum früheren Arbeitsbereich auf dem fokussierten Monitor springen |
| `Super + Shift + 1…9/0` | Fenster auf einen Arbeitsbereich auf dem fokussierten Monitor verschieben |
| `Super + Shift + Alt + 1…9/0` | Fenster auf einen Arbeitsbereich auf dem fokussierten Monitor verschieben, ohne zu folgen |
| `Super + S` | Vollständiges Scratchpad umschalten |
| `Super + Alt + S` | Fenster ins vollständige Scratchpad verschieben |
| `Super + Grave` | Quake-Konsole umschalten |
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
| `Super + G` | Fenstergruppierung umschalten |
| `Super + Alt + G` | Fenster aus der Gruppierung bewegen |
| `Super + Alt + Tab` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + Shift + Tab` | Rückwärts zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + Scroll Wheel` | Zwischen Fenstern in der Gruppierung wechseln |
| `Super + Alt + 1/2/3/4/5` | Zu einem bestimmten Fenster in der Gruppierung springen |
| `Super + Alt + Arrow` | Fenster in Pfeilrichtung in eine Gruppierung bewegen, einschließlich eines auf dem Monitor auf dieser Seite |
| `Super + Ctrl + Left/Right` | Zwischen Fenstern innerhalb einer Kachelgruppe bewegen |
| `Super + Ctrl + Z` | Auf dem Bildschirm hineinzoomen (wiederholen für mehr Zoom) |
| `Super + Ctrl + Alt + Z` | Vollständig vom Bildschirm herauszoomen |
| `Super + /` | Schrittweise vorwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Super + Alt + /` | Schrittweise rückwärts durch die Optionen für die Monitor-Skalierung gehen |
| `Alt + Tab` | Vorwärts durch Fenster auf dem aktiven Arbeitsbereich wechseln |
| `Alt + Shift + Tab` | Rückwärts durch Fenster auf dem aktiven Arbeitsbereich wechseln |
| `Ctrl + Alt + Tab` | Fokus vorwärts durch Monitore wechseln |
| `Ctrl + Alt + Shift + Tab` | Fokus rückwärts durch Monitore wechseln |
| `Super + I` | Eingabesprache wechseln (mit mehr als einem Layout oder einer Eingabemethode) |
| `Super + Shift + I` | Eingabesprache zurückwechseln |

Auf einem Touchpad wechseln Drei- und Vier-Finger-Wischgesten Arbeitsbereiche, verschieben Fenster und öffnen das Menü und die Quake-Konsole; siehe [Tastatur, Maus und Trackpad](34-keyboard-mouse-trackpad.md) für die Gesten.

Tastenkürzel zur Größenänderung verwenden die physischen Tasten `code:20` und `code:21` (XKB `<AE11>` und `<AE12>`), unabhängig von den auf der Tastatur aufgedruckten Zeichen. Auf US-Tastaturen sind diese Tasten `-` und `=`; auf japanischen (JIS) Tastaturen sind sie `-` und `^`; auf spanischen Tastaturen sind sie `'` und `¡`. Auf JIS ist `Super + ^` gleich `Super + Equal`, während `Super + Shift + -` (das `=` eingibt) gleich `Super + Shift + Minus` ist.

## Systemsteuerung

| Tastenkürzel | Funktion |
| --- | --- |
| `Super + Ctrl + A` | Audio-Bedienfeld |
| `Super + Ctrl + B` | Bluetooth-Bedienfeld |
| `Super + Ctrl + N` | Wi-Fi/Netzwerk-Bedienfeld |
| `Super + Ctrl + D` | Anzeige-Bedienfeld |
| `Super + Ctrl + P` | Energie-Bedienfeld |
| `Super + Ctrl + X` | Agenten-Bedienfeld |
| `Super + Ctrl + Alt + D` | Kalender-Bedienfeld |
| `Super + Ctrl + Alt + E` | Weltuhr-Bedienfeld |
| `Super + Ctrl + 1-9` | Leisten-Bedienfeld nach Position umschalten |
| `Super + Ctrl + S` | Teilen-Menü (über LocalSend) |
| `Super + Ctrl + C` | Aufnahmesteuerung (Screenshot/-Aufzeichnung/Picker) |
| `Super + Ctrl + O` | Menü umschalten |
| `Super + Ctrl + H` | Hardware-Menü |
| `Super + Ctrl + E` | Emoji-Auswahl |
| `Super + Ctrl + .` | Medien transkodieren |
| `Super + Shift + Ctrl + A` | Einen KI-Agenten auswählen |
| `Power` Taste | Systemmenü |
| `Super + Shift + Copilot` Taste | Omarchy-Menü |

## Anpassungen

| Tastenkürzel | Funktion |
| --- | --- |
| `Shift + Brightness Up` | Maximale Bildschirmhelligkeit |
| `Shift + Brightness Down` | Minimale Bildschirmhelligkeit |
| `Alt + Brightness Up/Down` | Präzise Helligkeitsänderungen um 1 % |
| `Alt + Volume Up/Down` | Präzise Lautstärkeänderungen um 1 % |
| `Keyboard Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler |
| `Keyboard Backlight` | Durch die Stufen der Tastaturbeleuchtung wechseln |
| `Ctrl + Brightness Up/Down` | Tastaturbeleuchtung heller/dunkler, auf Tastaturen ohne eigene Tasten |
| `Mic Mute` | Mikrofon stumm schalten |
| `Shift + Mute` | Audioausgabe wechseln |
| `Touchpad Toggle` | Touchpad ein- oder ausschalten |
| `Display` Taste | Durch das Arbeitsbereich-Layout wechseln |
| `Alt + Play` | Nächster Titel |
| `Alt + Shift + Play` | Vorheriger Titel |

## Apps starten

| Tastenkürzel | Funktion |
| --- | --- |
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
| `Super + Shift + Q` or `Calculator` Taste | Rechner (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, nach der Installation) |
| `Super + Shift + T` | Aktivität (btop) |
| `Super + Shift + N` | Editor (Plain oder dein gewählter Standard) |
| `Super + Shift + C` | Kalender ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-Mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Neue E-Mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | KI (ChatGPT) |
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
| --- | --- |
| `Super + A` | In Apps, die `Ctrl + A` unterstützen, alles auswählen |
| `Super + C` | Kopieren |
| `Super + X` | Ausschneiden (nicht im Terminal) |
| `Super + V` | Einfügen |
| `Super + Ctrl + V` | Zwischenablage-Manager |

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V`, um im Terminal zu kopieren und einzufügen, und `Ctrl + C/V`, um es überall sonst zu tun. Diese vereinheitlichten Omarchy-Tastenkürzel für die Zwischenablage funktionieren überall.

## Aufnahme

| Tastenkürzel | Funktion |
| --- | --- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot (dieselbe Aufnahme, für Tastaturen ohne Print Screen-Taste) |
| `Super + Ctrl + C` | Aufnahmemenü |
| `Alt + Print Screen` | Bildschirmaufzeichnung |
| `Super + Shift + Ctrl + Alt + C` | Bildschirmaufzeichnung ohne Audio, ohne Menü (erneut drücken zum Stoppen) |
| `Super + Print Screen` | Farbauswahl |
| `Super + Ctrl + Print Screen` | Textextraktion in die Zwischenablage |
| `Super + Alt + [` | Webcam-Overlay während der Aufzeichnung verkleinern |
| `Super + Alt + ]` | Webcam-Overlay während der Aufzeichnung vergrößern |
| `Alt + Shift + L` | Aktuelle URL aus Webapp oder Browser kopieren |
| `Alt + Shift + D` | Das Video auf der aktuellen Seite nach `~/Videos` herunterladen |
| `Alt + Space` | Diktieren starten/stoppen (erfordert _Setup > Defaults > Dictation_) |
| `Right Alt` | Gedrückt halten zum Diktieren (erfordert _Setup > Defaults > Dictation_) |

Bei Bildschirmaufzeichnungen fragt das Tastenkürzel zuerst, welchen Ton du willst, und startet dann die Aufzeichnung. Drücke es erneut, um zu stoppen. Siehe [Screenshots und Aufzeichnung](12-screenshots-recording.md) für die Details.

Alle Aufnahmeoptionen sind auch unter _Trigger > Capture_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Benachrichtigungen

| Tastenkürzel | Funktion |
| --- | --- |
| `Super + ,` | Auf die neueste Benachrichtigung reagieren: sie öffnen oder ihre einzige Schaltfläche drücken, aus ihren Optionen wählen oder sie verwerfen, wenn sie keine hat |
| `Super + Shift + ,` | Alle Benachrichtigungen verwerfen |
| `Super + Ctrl + ,` | Benachrichtigungen mit der Tastatur steuern |
| `Super + Alt + ,` | Neueste Benachrichtigung verwerfen |
| `Super + Shift + Alt + ,` | Benachrichtigungsverlauf öffnen |
| `Super + Ctrl + Alt + ,` | Stummschalten von Benachrichtigungen umschalten |

## Stil

| Tastenkürzel | Funktion |
| --- | --- |
| `Super + Ctrl + T` | Ein neues Theme auswählen (auch `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Theme-Hintergrund auswählen (auch `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparenz eines Fensters umschalten |
| `Super + Ctrl + Backspace` | Quadratisches Seitenverhältnis für ein einzelnes Fenster umschalten |

Zusätzliche Hintergrundbilder liegen in `~/.config/omarchy/backgrounds/<theme name>`. Auch verfügbar über _Install > Style > Background_ im Omarchy-Menü.

Alle Stiloptionen sind auch unter _Appearance_ im Omarchy-Menü (`Super + Space`) zugänglich.

## Umschalter

| Tastenkürzel | Funktion |
| --- | --- |
| `Super + Ctrl + I` | Sperren bei Inaktivität umschalten |
| `Super + Ctrl + Delete` | Laptop-Display ein-/ausschalten |
| `Super + Ctrl + Alt + Delete` | Spiegeln des Laptop-Displays umschalten |
| `Super + Shift + Space` | Obere Leiste umschalten |
| `Shift + Mute` | Zur nächsten Audioausgabe wechseln |
| `Shift + Play` | Zur nächsten Medienquelle wechseln |
| `Super + Shift + Backspace` | Fensterabstände umschalten |
| `Super + Ctrl + Alt + F` | Vollbild-Desktop umschalten (obere Leiste + Fensterabstände) |

## Erinnerungen

| Tastenkürzel | Funktion |
| --- | --- |
| `Super + Ctrl + R` | Eine Erinnerung einstellen |
| `Super + Ctrl + Alt + R` | Alle Erinnerungen ansehen |
| `Super + Ctrl + Shift + R` | Alle Erinnerungen löschen |

## Hinweise

| Tastenkürzel | Funktion |
| --- | --- |
| `Super + Ctrl + Alt + T` | Zeit als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + B` | Akku als Benachrichtigung anzeigen |
| `Super + Ctrl + Alt + W` | Wetter als Benachrichtigung umschalten |

## Tmux

Die Präfix-Taste ist `Ctrl + Space` (`Ctrl + B` funktioniert auch). Du kannst diese Belegungen in `~/.config/tmux/tmux.conf` ändern.

### Teilfenster

| Tastenkürzel | Funktion |
| --- | --- |
| `Prefix + v` | Teilfenster daneben teilen (vertikal) |
| `Prefix + h` | Teilfenster darunter teilen (horizontal) |
| `Prefix + x` | Teilfenster beenden |
| `Prefix + z` | Zoom des Teilfensters umschalten (Vollbild) |
| `Alt + Enter` | Teilfenster darunter teilen (ohne Präfix) |
| `Alt + Shift + Enter` | Teilfenster daneben teilen (ohne Präfix) |
| `Alt + Escape` | Teilfenster beenden (ohne Präfix) |
| `Ctrl + Alt + Arrows` | Zwischen Teilfenstern bewegen |
| `Ctrl + Alt + Shift + Arrows` | Größe von Teilfenstern ändern |

### Fenster

| Tastenkürzel | Funktion |
| --- | --- |
| `Prefix + c` | Neues Fenster |
| `Prefix + k` | Fenster beenden |
| `Prefix + r` | Fenster umbenennen |
| `Alt + 1-9` | Zu einem bestimmten Fenster gehen |
| `Alt + Arrow Left/Right` | Zwischen Fenstern bewegen |
| `Alt + Shift + Arrow Left/Right` | Fenster nach links/rechts verschieben |

### Sitzungen

| Tastenkürzel | Funktion |
| --- | --- |
| `Prefix + C` | Neue Sitzung |
| `Prefix + K` | Sitzung beenden |
| `Prefix + R` | Sitzung umbenennen |
| `Prefix + N` | Nächste Sitzung |
| `Prefix + P` | Vorherige Sitzung |
| `Alt + Arrow Up/Down` | Zwischen Sitzungen bewegen |
| `Prefix + s` | Sitzungen auflisten |
| `Prefix + d` | Von Sitzung trennen |

### Kopiermodus (vi-Stil)

| Tastenkürzel | Funktion |
| --- | --- |
| `Prefix + [` | In den Kopiermodus wechseln |
| `v` | Auswahl beginnen (im Kopiermodus) |
| `y` | Auswahl kopieren (im Kopiermodus) |

### Allgemein

| Tastenkürzel | Funktion |
| --- | --- |
| `Prefix + q` | Konfiguration neu laden |
| `Prefix + ?` | Tmux-Tastenbelegungen anzeigen |
| `Prefix + :` | Eingabeaufforderung |

### Tmux-Layoutfunktionen

Diese Funktionen müssen innerhalb einer Tmux-Sitzung ausgeführt werden.

| Befehl | Funktion |
| --- | --- |
| `tdl <ai> [<second_ai>]` | Dev-Layout mit Editor, KI und Terminal erstellen |
| `tdlm <ai> [<second_ai>]` | Dev-Layout pro Unterverzeichnis erstellen |
| `tsl <count> <command>` | Multi-Pane-Schwarm-Layout erstellen |

## Ghostty Terminal

Das Ghostty-Terminal wird über _Install > Terminal_ im Omarchy-Menü installiert.

| Tastenkürzel | Funktion |
| --- | --- |
| `Ctrl + Shift + E` | Neue Teilung darunter |
| `Ctrl + Shift + O` | Neue Teilung daneben |
| `Ctrl + Alt + Arrows` | Zwischen Teilungen bewegen |
| `Super + Ctrl + Shift + Arrows` | Teilung um 10 Zeilen in der Größe ändern |
| `Super + Ctrl + Shift + Alt + Arrows` | Teilung um 100 Zeilen in der Größe ändern |
| `Ctrl + Shift + T` | Neuer Tab |
| `Ctrl + Shift + Arrows` | Zwischen Tabs bewegen |
| `Alt + Numbers` | Zu einem bestimmten Tab gehen |
| `Shift + Pg Up/Down` | Durch den Verlauf scrollen |
| `Ctrl + Left mouse` | Link im Browser öffnen |

## Dateimanager

| Tastenkürzel | Funktion |
| --- | --- |
| `Ctrl + L` | Zu einem Pfad gehen |
| `Space` | Dateivorschau (Pfeile navigieren) |
| `Alt + Up` | Zum übergeordneten Ordner hochgehen |

## Neovim (mit LazyVim)

### Navigation

| Tastenkürzel | Funktion |
| --- | --- |
| `Space` | Befehlsoptionen anzeigen |
| `Space Space` | Datei über Fuzzy-Suche öffnen |
| `Space E` | Seitenleiste umschalten |
| `Space G G` | Git-Steuerelemente anzeigen |
| `Space S G` | Dateiinhalt durchsuchen |
| `Ctrl + W W` | Zwischen Seitenleiste und Editor springen |
| `Ctrl + Left/right arrow` | Größe der Seitenleiste ändern |
| `Shift + H` | Zum linken Datei-Tab gehen |
| `Shift + L` | Zum rechten Datei-Tab gehen |
| `Space B D` | Datei-Tab schließen |

### In der Seitenleiste

| Tastenkürzel | Funktion |
| --- | --- |
| `A` | Neue Datei im übergeordneten Verzeichnis hinzufügen |
| `Shift + A` | Neues Unterverzeichnis im übergeordneten Verzeichnis hinzufügen |
| `D` | Markierte Datei/markiertes Verzeichnis löschen |
| `M` | Markierte Datei/markiertes Verzeichnis verschieben |
| `R` | Markierte Datei/markiertes Verzeichnis umbenennen |
| `?` | Hilfe für alle Befehle anzeigen |

[Alle von LazyVim konfigurierten Neovim-Tastenkürzel ansehen](https://www.lazyvim.org/keymaps).

## Emojis im Schnellzugriff

Du kannst `Super + Ctrl + E` verwenden, um eine vollständige Emoji-Auswahl anzuzeigen, die die Auswahl in die Zwischenablage legt, oder du kannst diese Schnellzugriffsoptionen verwenden.

| Tastenkürzel | EM | Hinweis |
| --- | --- | --- |
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
| `Shift + CapsLock M T` | 🥂 | Anstoßen |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | Begrüßung |
| `Shift + CapsLock M A` |💪 | Arm |
| `Shift + CapsLock M B` |🤯 | Kopf explodiert |

## Schnelle Vervollständigungen

| Tastenkürzel | Vervollständigung |
| --- | --- |
| `Shift + CapsLock Space Space` | — (Gedankenstrich) |
| `Shift + CapsLock Space N` | Dein Name (wie bei der Einrichtung eingegeben) |
| `Shift + CapsLock Space E` | Deine E-Mail (wie bei der Einrichtung eingegeben) |

Du kannst weitere eigene hinzufügen, indem du `~/.XCompose` bearbeitest und dann `omarchy restart xcompose` im Terminal ausführst, damit die Änderungen übernommen werden.
