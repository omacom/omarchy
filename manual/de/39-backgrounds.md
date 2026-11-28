# Hintergründe

Jedes Theme wird mit einem eigenen Satz an Hintergründen ausgeliefert, und du kannst unter `~/.config/omarchy/backgrounds/[theme]` eigene hinzufügen. Wenn du zum Beispiel zum Theme nord ein zusätzliches Hintergrundbild hinzufügen willst, legst du die Datei einfach in `~/.config/omarchy/backgrounds/nord`.

Am einfachsten geht das über _Installieren > Stil > Hintergrund_ im Omarchy Menu. Dadurch wird der Ordner geöffnet, in dem die Hintergründe für dieses Theme gespeichert sind. Drücke `Super + Shift + F`, um einen weiteren Dateimanager zu starten, suche deinen Hintergrund und kopiere ihn dorthin. Jetzt ist er in der Auswahl der Hintergründe enthalten, zwischen denen du mit `Super + Ctrl + W` wechseln kannst.

Ein Theme ohne eigene Hintergründe bekommt einen, der aus seinen Farben gezeichnet wird: das Omarchy-Logo in der Akzentfarbe des Themes auf seiner Hintergrundfarbe. Füge deine eigenen hinzu, um ihn zu ersetzen.

Hintergründe können Videos ebenso wie Standbilder sein. Lege eine Datei in den Formaten `mp4`, `m4v`, `mov`, `webm`, `mkv` oder `avi` in denselben Ordner, und sie erscheint neben den Bildern. Videos werden von der OWE Wallpaper Engine abgespielt. Sie decodiert das Video einmal für alle Monitore und gibt seinen Ton über die Standard-Audioausgabe aus, und sie stoppt die Wiedergabe, sobald nichts sie sehen kann. Ein Video-Hintergrund verbraucht trotzdem deutlich mehr Strom als ein Standbild.

Themes können ein kurzes Intro für einen Standbild-Hintergrund enthalten. Für `backgrounds/road.webp` liegt das passende Video unter `backgrounds/intros/road.mp4`. Es wird automatisch beim Booten abgespielt, beim Wechsel zu einem Theme mit diesem ausgewählten Hintergrund und beim Auswählen dieses Hintergrunds, und kehrt dann zum Standbild zurück. Intro-Videos bleiben aus der Hintergrundauswahl heraus und laufen nie in einer Schleife.

Die Auswahl von _Darstellung > Animationen aus_ schaltet auch Hintergrund-Intros aus. Omarchy tut dies standardmäßig in einer virtuellen Maschine. Mit dem Befehl `omarchy theme bg intro toggle` lassen sich Intros separat umschalten. Das Aktualisieren eines Themes spielt kein Intro ab.

Ein Standbild kann auch eine Schleife haben, eine ruhige Version desselben Bildes, die sich weiter bewegt, unter `backgrounds/loops/road.mp4`. Sie wird anstelle des Standbildes abgespielt, nach seinem Intro, falls es eines hat, und stoppt, wenn Animationen ausgeschaltet werden. Im Akkubetrieb wird stattdessen das Standbild angezeigt, und die Schleife kommt zurück, sobald du das Netzteil einsteckst. Schleifen bleiben aus der Hintergrundauswahl heraus.

Eine riesige Sammlung cooler, kuratierter Hintergründe findest du in [dharmx/walls](https://github.com/dharmx/walls).

Der Sperrbildschirm zeigt ein Standbild eines Video-Hintergrunds, genauso wie er ein Standbild eines animierten GIF zeigt.
