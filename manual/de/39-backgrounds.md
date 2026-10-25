# Hintergründe

Jedes Theme bringt seine eigenen Hintergründe mit, und du kannst eigene Extras in `~/.config/omarchy/backgrounds/[theme]` hinzufügen. Wenn du zum Beispiel dem nord-Theme ein zusätzliches Hintergrundbild hinzufügen willst, legst du die Datei einfach in `~/.config/omarchy/backgrounds/nord`.

Am einfachsten geht das über _Install > Style > Background_ im Omarchy Menu. Dadurch wird der Ordner geöffnet, in dem die Hintergründe für dieses Theme gespeichert sind. Drücke `Super + Shift + F`, um einen weiteren Dateimanager zu öffnen, suche deinen Hintergrund und kopiere ihn hinüber. Jetzt ist er in den Hintergrundoptionen enthalten, zwischen denen du mit `Super + Ctrl + W` auswählen kannst.

Hintergründe können Videos ebenso wie Standbilder sein. Lege eine `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- oder `avi`-Datei in denselben Ordner, und sie erscheint neben den Bildern. Videos werden von der OWE-Wallpaper-Engine abgespielt. Sie decodiert das Video einmal für alle Monitore, spielt seinen Ton über die Standard-Audioausgabe ab und stoppt die Wiedergabe immer dann, wenn nichts es sehen kann. Ein Video-Hintergrund verbraucht trotzdem weitaus mehr Strom als ein Standbild.

Themes können ein kurzes Intro für einen Standbild-Hintergrund enthalten. Für `backgrounds/road.webp` liegt das passende Video unter `backgrounds/intros/road.mp4`. Es wird automatisch beim Booten und beim Wechsel zu einem Theme mit diesem ausgewählten Hintergrund abgespielt und kehrt dann zum Standbild zurück. Intro-Videos bleiben aus der Hintergrundauswahl heraus und laufen nie in einer Schleife.

Das Deaktivieren von _Appearance > Animations_ deaktiviert auch die Hintergrund-Intros. Omarchy macht das standardmäßig in einer virtuellen Maschine. Mit dem Befehl `omarchy theme bg intro toggle` lassen sich Intros separat umschalten. Das Aktualisieren eines Themes oder die Auswahl eines anderen Hintergrunds innerhalb desselben Themes spielt kein Intro ab.

Eine riesige Sammlung cooler, kuratierter Hintergründe findest du auf https://github.com/dharmx/walls.

Der Sperrbildschirm zeigt ein Standbild eines Video-Hintergrunds, genauso wie er ein Standbild eines animierten GIF zeigt.
