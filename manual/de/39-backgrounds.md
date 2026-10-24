# Hintergründe

Jedes Design bringt seine eigenen Hintergründe mit, und du kannst eigene in `~/.config/omarchy/backgrounds/[theme]` hinzufügen. Wenn du zum Beispiel beim Nord-Design ein weiteres Hintergrundbild hinzufügen willst, legst du die Datei einfach in `~/.config/omarchy/backgrounds/nord`.

Am einfachsten geht das über _Installieren > Stil > Hintergrund_ im Omarchy-Menü. Damit öffnet sich der Ordner, in dem die Hintergründe für dieses Design liegen. Drücke `Super + Shift + F`, um einen weiteren Dateimanager zu öffnen, finde deinen Hintergrund und kopiere ihn herüber. Jetzt ist er in der Auswahl der Hintergründe enthalten, zwischen denen du mit `Super + Ctrl + Space` wechseln kannst.

Hintergründe können Videos ebenso wie Standbilder sein. Lege eine Datei im Format `mp4`, `m4v`, `mov`, `webm`, `mkv` oder `avi` in denselben Ordner, und sie erscheint neben den Bildern. Videos spielt die OWE-Wallpaper-Engine ab. Sie dekodiert das Video einmal für alle Monitore und gibt seinen Ton über die Standard-Audioausgabe aus, und sie stoppt die Wiedergabe, wann immer nichts davon zu sehen ist. Der Sperrbildschirm zeichnet dieselbe Dekodierung über OWE, stummgeschaltet. Ein Video-Hintergrund kostet trotzdem weit mehr Energie als ein Standbild.

Designs können eine kurze Einleitung für einen Standbild-Hintergrund enthalten. Für `backgrounds/road.webp` liegt das passende Video unter `backgrounds/intros/road.mp4`. Es spielt automatisch beim Booten und beim Wechsel zu einem Design mit diesem ausgewählten Hintergrund und kehrt dann zum Standbild zurück. Intro-Videos bleiben aus der Hintergrundauswahl draußen und laufen nie in Schleife.

Das Ausschalten von _Auslösen > Aussehen > Animationen_ schaltet auch die Hintergrund-Intros aus. Omarchy macht das in einer virtuellen Maschine standardmäßig. Mit dem Befehl `omarchy theme bg intro toggle` lassen sich Intros getrennt umschalten. Ein Design zu aktualisieren oder einen anderen Hintergrund innerhalb desselben Designs zu wählen, spielt kein Intro ab.

Eine riesige Sammlung cooler, kuratierter Hintergründe findest du auf https://github.com/dharmx/walls.

Video-Hintergründe behalten auf dem Sperrbildschirm ein zwischengespeichertes Standbild, solange die Wiedergabe pausiert oder nicht verfügbar ist. Animierte GIFs spielen auf dem Desktop und zeigen auf dem Sperrbildschirm ein Standbild.
