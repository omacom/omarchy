# Vom Mac oder von Windows kommen

Wenn du Jahre mit macOS oder Windows verbracht hast, wissen deine Finger hundert Dinge, von denen dein Gehirn vergessen hat, dass es sie je gelernt hat. Dieses Kapitel ist die Übersetzungsschicht: wohin diese Instinkte in Omarchy wandern. Die Funktionen selbst werden anderswo ausführlich behandelt — das hier ist nur die Landkarte.

### Super ist das Zentrum von allem

Das ganze Muskelgedächtnis, das du rund um Cmd oder die Windows-Taste aufgebaut hast, verlagert sich auf eine Taste: Super. Das ist die Windows-Taste auf einer PC-Tastatur, und sie ist der Anker für fast jeden Hotkey in Omarchy.

Dein Spotlight- oder Raycast- oder Startmenü-Reflex wird zu `Super + Space`. Das öffnet das Omarchy-Menü, das Apps startet, Einstellungen ändert, Software installiert, den Bildschirm aufnimmt — so ziemlich alles. Tippe einfach los, um zu filtern. `Super + Alt + Space` zeigt jede App in einem Raster, so wie Launchpad es tut. Siehe [Navigation](04-navigation.md).

### Keine Desktop-Symbole, und das Dock zeigt sich nur, wenn du schwebst

Keine Symbole, die du auf dem Desktop anordnen müsstest, und kein Dock auf einer kachelnden Arbeitsfläche — das Dock erscheint nur auf einer schwebenden Arbeitsfläche (siehe [Navigation](04-navigation.md)). Apps starten über einen Hotkey (`Super + Return` für das Terminal, `Super + Shift + Return` für den Browser und `Super + K` für eine Liste von allem, was belegt ist) oder über das Menü. Das einzige dauerhaft sichtbare Stück UI ist [die obere Leiste](05-the-top-bar.md), die abdeckt, was vorher Menüleiste, Systemablage und Notification Center für dich getan haben — und fast jedes Widget darauf tut etwas bei Links-, Rechts- und Mittelklick.

### Fenster platzieren sich selbst

Die größte Umstellung im Kopf: Du ziehst Fenster nicht herum und rastest sie nicht an Bildschirmhälften ein. Öffne ein Fenster, und es nimmt den ganzen Bildschirm ein. Öffne ein zweites, und sie teilen ihn sich. Du fischst nie ein Fenster unter einem anderen hervor, weil Fenster sich nicht überlappen.

Wenn du wirklich ein schwebendes Fenster brauchst, schaltet `Super + T` das aktive aus der Kachelung heraus (und wieder hinein). Aber gib der Kachelung erst eine echte Chance — sie ist das Herz der ganzen Sache. [Navigation](04-navigation.md) führt dich da durch.

Arbeitsflächen werden sich vertraut anfühlen: Sie sind macOS Spaces oder virtuelle Desktops von Windows, nur dass du sie tatsächlich benutzen wirst, weil `Super + 1/2/3/4` direkt zu einer springt und `Super + Shift + 1/2/3/4` das aktive Fenster dorthin schickt. Keine Animationsverzögerung, nur sofortige Sprünge. Das bedeutet, dass du vielleicht nicht einmal mehrere Monitore brauchst, falls du das vorher gewohnt warst.

### Kopieren und Einfügen funktionieren einfach

Auf dem Mac hattest du überall Cmd + C. Unter Windows hattest du überall Ctrl + C — außer im Terminal, wo es dein Programm killt. Omarchy gibt dir `Super + C`, `Super + X` und `Super + V`, und sie funktionieren überall, auch im Terminal. Kein separater Reflex, den du für die Shell lernen musst.

Windows-Leute: Euer Verlauf der Zwischenablage mit Win + V lebt auf `Super + Ctrl + V`, und er speichert Bilder ebenso wie Text. Siehe [einheitliche Zwischenablage & Verlauf](08-unified-clipboard-history.md).

### Die Übersetzungstabelle

| Wonach du greifst | In Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Startmenü | `Super + Space` — das Omarchy-Menü |
| AirDrop | LocalSend, über `Super + Ctrl + S` — siehe [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` oder `Print Screen` — siehe [Screenshots & Bildschirmaufnahme](12-screenshots-recording.md) |
| Notification Center | Verlauf der Benachrichtigungen auf `Super + Shift + Alt + ,` |
| Time Machine (für das System) | Automatische [System-Snapshots](47-system-snapshots.md) bei jedem Update |
| App Store / einen Installer herunterladen | _Install_ im Menü, oder `omarchy pkg add` — siehe [andere Pakete](29-other-packages.md) |
| Systemeinstellungen / Systemsteuerung | _Setup_ im Menü, das einfache Konfigurationsdateien bearbeitet — siehe [Dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, auf `Super + Shift + F` — siehe [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome auf `Super + Shift + Return`; wähle einen anderen unter _Setup > Defaults > Browser_ — siehe [Browser](23-browsers.md) |
| Preview / Photos | Omaview für Bilder, Video und Musik, Document Viewer für PDFs — siehe [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, auf `Super + Shift + N`; wähle einen anderen unter _Setup > Defaults > Editor_ |

### Manche Dinge sind wirklich anders

Viele Einstellungen leben in Textdateien, die du bearbeitest, nicht in Panels, durch die du dich klickst. Das klingt primitiv, bis du merkst, dass es bedeutet, dass jede Anpassung gesehen, auf deinen nächsten Rechner kopiert und in Versionskontrolle gelegt werden kann. Das _Setup_-Menü setzt dich direkt in die richtige Datei und startet neu, was neu gestartet werden muss, wenn du fertig bist.

Updates kommen über einen Befehl — _Update > Omarchy_ —, der Omarchy selbst und jedes Paket auf dem System aktualisiert und vorher einen Snapshot macht. Keine Updater pro App, die dich zu zufälligen Zeiten nerven. Siehe [Updates](30-updates.md).

Software kommt aus einem Paketmanager, nicht aus heruntergeladenen Installern.

Und wenn du ein Fenster schließt, beendet sich die App tatsächlich. Es gibt kein macOS-Limbo, in dem das Programm ohne Fenster weiterläuft. `Super + W` — oder `Super + Q`, wenn das das Fingergedächtnis ist, mit dem du angekommen bist — bedeutet weg.

### Auf Mac-Hardware

Omarchy läuft gut auf Intel Macs — siehe [Mac-Unterstützung](44-mac-support.md). Und die Tastatur ist freundlich zu dir: Omarchy bildet nichts neu ab, und Linux behandelt die Command-Taste als Super, also sitzt Super genau dort, wo Cmd immer war. Dein Daumen wird den Umzug nicht bemerken.

### Gib ihm zwei Wochen

Die Instinkte übertragen sich schneller, als du denkst. Überfliege das Kapitel [Hotkeys](07-hotkeys.md) einmal, und wann immer dir eine Belegung nicht einfällt, drücke `Super + K` — es zeigt dir alle. Das ist der einzige Hotkey, den du dir wirklich merken musst.
