# Von Mac oder Windows kommen

Wenn du Jahre mit macOS oder Windows verbracht hast, kennen deine Finger hundert Dinge, von denen dein Gehirn vergessen hat, dass es sie je gelernt hat. Dieses Kapitel ist die Übersetzungsschicht: wohin diese Instinkte in Omarchy gehören. Die Funktionen selbst werden an anderer Stelle ausführlich behandelt — dies ist nur die Karte.

### Super ist der Mittelpunkt von allem

All das Muskelgedächtnis, das du rund um Cmd oder die Windows-Taste aufgebaut hast, überträgt sich auf eine Taste: Super. Das ist die Windows-Taste auf einer PC-Tastatur, und sie ist der Anker für fast jedes Tastenkürzel in Omarchy.

Dein Reflex für Spotlight oder Raycast oder das Startmenü wird zu `Super + Space`. Das öffnet das Omarchy-Menü, das Apps startet, Einstellungen ändert, Software installiert, den Bildschirm aufnimmt — so ziemlich alles. Beginne zu tippen, um zu filtern. `Super + Alt + Space` zeigt jede App in einem Raster, so wie es Launchpad tut. Siehe [Navigation](04-navigation.md).

### Es gibt kein Dock und keine Desktop-Symbole

Nichts zum Anklicken, um Dinge zu starten, keine Symbole zum Anordnen auf dem Desktop. Apps starten über ein Tastenkürzel (`Super + Return` für das Terminal, `Super + Shift + Return` für den Browser und `Super + K` für eine Liste von allem, was zugeordnet ist) oder über das Menü. Das einzige dauerhafte Stück UI ist [die Menüleiste](05-the-top-bar.md), die abdeckt, was vorher die Menüleiste, die Taskleiste und die Mitteilungszentrale für dich getan haben — und fast jedes Widget darauf tut etwas bei Links-, Rechts- und Mittelklick.

### Fenster platzieren sich selbst

Der größte Umdenken: Du ziehst Fenster nicht herum und rastest sie nicht an Bildschirmhälften ein. Öffne ein Fenster, und es nimmt den ganzen Bildschirm ein. Öffne ein zweites, und sie teilen ihn sich. Du fischst nie ein Fenster unter einem anderen hervor, weil sich Fenster nicht überlappen.

Wenn du wirklich ein schwebendes Fenster brauchst, schaltet `Super + T` das aktive Fenster aus dem Tiling heraus (und wieder zurück). Aber gib dem Tiling zuerst eine echte Chance — es ist das Herz der ganzen Sache. [Navigation](04-navigation.md) führt dich hindurch.

Arbeitsflächen werden sich vertraut anfühlen: Sie sind macOS Spaces oder virtuelle Desktops von Windows, nur dass du sie tatsächlich benutzen wirst, weil `Super + 1/2/3/4` direkt zu einer springt und `Super + Shift + 1/2/3/4` das aktive Fenster dorthin schickt. Keine Animationsverzögerung, nur sofortige Sprünge. Das bedeutet, dass du vielleicht nicht einmal mehrere Monitore brauchst, wenn du das vorher gewohnt warst.

### Kopieren und Einfügen funktionieren einfach

Auf dem Mac hattest du überall Cmd + C. Unter Windows hattest du überall Ctrl + C — außer im Terminal, wo es dein Programm beendet. Omarchy gibt dir `Super + C`, `Super + X` und `Super + V`, und sie funktionieren überall, auch im Terminal. Kein separater Reflex für die Shell zu lernen.

Windows-Nutzer: Euer Win + V-Zwischenablageverlauf liegt auf `Super + Ctrl + V` und enthält sowohl Bilder als auch Text. Siehe [einheitliche Zwischenablage & Verlauf](08-unified-clipboard-history.md).

### Die Übersetzungstabelle

| Wonach du greifst | In Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Startmenü | `Super + Space` — das Omarchy-Menü |
| AirDrop | LocalSend, über `Super + Ctrl + S` — siehe [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — siehe [Screenshots & Aufnahme](12-screenshots-recording.md) |
| Mitteilungszentrale | Benachrichtigungsverlauf auf `Super + Shift + Alt + ,` |
| Time Machine (für das System) | Automatische [System-Snapshots](47-system-snapshots.md) bei jeder Aktualisierung |
| App Store / einen Installer herunterladen | _Installieren_ im Menü oder `omarchy pkg add` — siehe [andere Pakete](29-other-packages.md) |
| Systemeinstellungen / Systemsteuerung | _Einrichtung_ im Menü, das einfache Konfigurationsdateien bearbeitet — siehe [Dotfiles](31-dotfiles.md) |

### Manche Dinge sind wirklich anders

Viele Einstellungen leben in Textdateien, die du bearbeitest, nicht in Panels, durch die du dich klickst. Das klingt primitiv, bis du erkennst, dass es bedeutet, dass jede Anpassung gesehen, auf deine nächste Maschine kopiert und in Versionskontrolle gelegt werden kann. Das Menü _Einrichtung_ setzt dich direkt in die richtige Datei und startet neu, was neu gestartet werden muss, wenn du fertig bist.

Aktualisierungen kommen über einen Befehl — _Aktualisieren > Omarchy_ — der Omarchy selbst und jedes Paket auf dem System aktualisiert und vorher einen Snapshot erstellt. Keine Updater pro App, die dich zufällig nerven. Siehe [Aktualisierungen](30-updates.md).

Software kommt von einem Paketmanager, nicht von heruntergeladenen Installern.

Und wenn du ein Fenster schließt, beendet sich die App tatsächlich. Es gibt kein macOS-Limbo, in dem das Programm ohne Fenster weiterläuft. `Super + W` — oder `Super + Q`, wenn das das Fingergedächtnis ist, mit dem du angekommen bist — bedeutet weg.

### Auf Mac-Hardware

Omarchy läuft gut auf Intel-Macs — siehe [Mac-Support](44-mac-support.md). Und die Tastatur ist freundlich zu dir: Omarchy ordnet nichts neu zu, und Linux behandelt die Command-Taste als Super, sodass Super genau dort sitzt, wo Cmd immer war. Dein Daumen wird den Umzug nicht bemerken.

### Gib ihm zwei Wochen

Die Instinkte übertragen sich schneller, als du denkst. Überfliege das Kapitel [Tastenkürzel](07-hotkeys.md) einmal, und wann immer dir eine Zuordnung nicht einfällt, drücke `Super + K` — es zeigt dir alle. Das ist das einzige Tastenkürzel, das du dir wirklich merken musst.
