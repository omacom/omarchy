# Von Mac oder Windows kommen

Wenn du jahrelang macOS oder Windows genutzt hast, kennen deine Finger hundert Dinge, von denen dein Gehirn vergessen hat, dass es sie je gelernt hat. Dieses Kapitel ist die Übersetzungsschicht: wohin diese Instinkte in Omarchy führen. Die Funktionen selbst werden anderswo ausführlich behandelt — das hier ist nur die Landkarte.

### Super ist das Zentrum von allem

All das Muskelgedächtnis, das du rund um Cmd oder die Windows-Taste aufgebaut hast, überträgt sich auf eine Taste: Super. Das ist die Windows-Taste auf einer PC-Tastatur, und sie ist der Anker für fast jeden Hotkey in Omarchy.

Dein Reflex für Spotlight oder Raycast oder das Startmenü wird zu `Super + Space`. Das öffnet das Omarchy-Menü, das Apps startet, Einstellungen ändert, Software installiert, den Bildschirm aufnimmt — so ziemlich alles. Fange einfach an zu tippen, um zu filtern. `Super + Alt + Space` zeigt jede App in einem Raster, so wie Launchpad es tut. Siehe [Navigation](04-navigation.md).

### Es gibt kein Dock und keine Desktop-Symbole

Nichts zum Anklicken, um Dinge zu starten, keine Symbole zum Anordnen auf dem Desktop. Apps starten über einen Hotkey (`Super + Return` für das Terminal, `Super + Shift + Return` für den Browser und `Super + K` für eine Liste von allem, was belegt ist) oder über das Menü. Das einzige dauerhafte Stück UI ist [die obere Leiste](05-the-top-bar.md), die abdeckt, was vorher die Menüleiste, die Systemablage und das Notification Center für dich getan haben — und fast jedes Widget darauf tut etwas bei Links-, Rechts- und Mittelklick.

### Fenster platzieren sich selbst

Der größte Umdenkschritt: Du ziehst Fenster nicht herum und rastest sie nicht an Bildschirmhälften ein. Öffne ein Fenster und es nimmt den ganzen Bildschirm ein. Öffne ein zweites und sie teilen ihn sich. Du fischst nie ein Fenster unter einem anderen hervor, weil Fenster sich nicht überlappen.

Wenn du wirklich ein schwebendes Fenster brauchst, schaltet `Super + T` das aktive aus dem Tiling heraus (und wieder zurück). Aber gib dem Tiling zuerst eine echte Chance — es ist das Herz des Ganzen. [Navigation](04-navigation.md) führt dich hindurch.

Workspaces werden sich vertraut anfühlen: Sie sind macOS Spaces oder virtuelle Desktops von Windows, nur dass du sie tatsächlich nutzen wirst, weil `Super + 1/2/3/4` direkt zu einem springt und `Super + Shift + 1/2/3/4` das aktive Fenster dorthin schickt. Keine Animationsverzögerung, nur sofortige Sprünge. Das bedeutet, dass du vielleicht nicht einmal mehrere Monitore brauchst, falls du das von früher gewohnt warst.

### Kopieren und Einfügen funktionieren einfach

Auf dem Mac hattest du Cmd + C überall. Unter Windows hattest du Ctrl + C überall — außer im Terminal, wo es dein Programm beendet. Omarchy gibt dir `Super + C`, `Super + X` und `Super + V`, und sie funktionieren überall, auch im Terminal. Kein separater Reflex, den du für die Shell lernen musst.

Windows-Leute: Dein Verlauf der Zwischenablage mit Win + V lebt auf `Super + Ctrl + V`, und er speichert Bilder ebenso wie Text. Siehe [einheitliche Zwischenablage & Verlauf](08-unified-clipboard-history.md).

### Die Übersetzungstabelle

| Du greifst nach | In Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — das Omarchy-Menü |
| AirDrop | LocalSend, über `Super + Ctrl + S` — siehe [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` oder `Print Screen` — siehe [Screenshots & Aufnahme](12-screenshots-recording.md) |
| Notification Center | Benachrichtigungsverlauf auf `Super + Shift + Alt + ,` |
| Time Machine (für das System) | Automatische [System-Snapshots](47-system-snapshots.md) bei jedem Update |
| App Store / einen Installer herunterladen | _Install_ im Menü, oder `omarchy pkg add` — siehe [andere Pakete](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ im Menü, das einfache Konfigurationsdateien bearbeitet — siehe [Dotfiles](31-dotfiles.md) |

### Manche Dinge sind wirklich anders

Viele Einstellungen leben in Textdateien, die du bearbeitest, nicht in Panels, durch die du dich klickst. Das klingt primitiv, bis dir klar wird, dass es bedeutet, dass jede Anpassung gesehen, auf deine nächste Maschine kopiert und in Versionskontrolle gelegt werden kann. Das _Setup_-Menü wirft dich direkt in die richtige Datei und startet neu, was neu gestartet werden muss, wenn du fertig bist.

Updates kommen über einen Befehl — _Update > Omarchy_ — der Omarchy selbst und jedes Paket auf dem System aktualisiert und vorher einen Snapshot erstellt. Keine Updater pro App, die dich zu zufälligen Zeiten nerven. Siehe [Updates](30-updates.md).

Software kommt von einem Paketmanager, nicht von heruntergeladenen Installern.

Und wenn du ein Fenster schließt, beendet sich die App tatsächlich. Es gibt kein macOS-Limbo, in dem das Programm ohne Fenster weiterläuft. `Super + W` — oder `Super + Q`, falls das das Fingergedächtnis ist, mit dem du angekommen bist — bedeutet weg.

### Auf Mac-Hardware

Omarchy läuft gut auf Intel Macs — siehe [Mac-Support](44-mac-support.md). Und die Tastatur ist freundlich zu dir: Omarchy belegt nichts um, und Linux behandelt die Command-Taste als Super, also sitzt Super genau dort, wo Cmd immer war. Dein Daumen wird den Umzug nicht bemerken.

### Gib ihm zwei Wochen

Die Instinkte übertragen sich schneller, als du denkst. Überfliege das Kapitel zu den [Hotkeys](07-hotkeys.md) einmal, und wann immer dir eine Belegung nicht einfällt, drücke `Super + K` — es zeigt dir alle. Das ist der einzige Hotkey, den du dir wirklich merken musst.
