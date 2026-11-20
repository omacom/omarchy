# Hintergründe

Jedes Theme bringt einen eigenen Satz Hintergründe mit, und du kannst unter `~/.config/omarchy/backgrounds/[theme]` eigene hinzufügen. Wenn du zum Beispiel ein zusätzliches Hintergrundbild zum Theme nord hinzufügen möchtest, legst du die Datei einfach in `~/.config/omarchy/backgrounds/nord`.

Am einfachsten geht das, indem du im Omarchy Menu zu _Install > Style > Background_ gehst. Dadurch öffnet sich der Ordner, in dem die Hintergründe für dieses Theme gespeichert sind. Drücke `Super + Shift + F`, um einen weiteren Dateimanager zu öffnen, suche deinen Hintergrund und kopiere ihn hinüber. Jetzt ist er in der Auswahl der Hintergründe enthalten, zwischen denen du mit `Super + Ctrl + W` wählen kannst.

Hintergründe können sowohl Videos als auch Standbilder sein. Lege eine Datei in den Formaten `mp4`, `m4v`, `mov`, `webm`, `mkv` oder `avi` in denselben Ordner, und sie erscheint neben den Bildern. Videos werden von der OWE Wallpaper-Engine abgespielt. Sie dekodiert das Video einmal für alle Monitore, spielt seinen Ton über die Standard-Audioausgabe ab und stoppt die Wiedergabe, sobald es von nichts mehr gesehen werden kann. Ein Video-Hintergrund verbraucht trotzdem deutlich mehr Strom als ein Standbild.

Themes können für einen Standbild-Hintergrund ein kurzes Intro enthalten. Für `backgrounds/road.webp` liegt das passende Video unter `backgrounds/intros/road.mp4`. Es wird automatisch beim Booten abgespielt, wenn zu einem Theme mit diesem ausgewählten Hintergrund gewechselt wird und wenn dieser Hintergrund ausgewählt wird, und kehrt dann zum Standbild zurück. Intro-Videos bleiben aus der Hintergrundauswahl ausgeschlossen und laufen niemals in einer Schleife.

Das Deaktivieren von _Appearance > Animations_ deaktiviert auch Hintergrund-Intros. Omarchy macht dies standardmäßig in einer virtuellen Maschine. Mit dem Befehl `omarchy theme bg intro toggle` lassen sich Intros separat umschalten. Das Aktualisieren eines Themes spielt kein Intro ab.

Ein Standbild kann auch eine Schleife haben, eine ruhige Version desselben Bildes, die sich ständig bewegt, unter `backgrounds/loops/road.mp4`. Sie wird anstelle des Standbildes abgespielt, nach seinem Intro, falls vorhanden, und stoppt, wenn Animationen deaktiviert sind. Im Akkubetrieb wird stattdessen das Standbild angezeigt, und die Schleife kehrt zurück, sobald du das Gerät wieder anschließt. Schleifen bleiben aus der Hintergrundauswahl ausgeschlossen.

Eine riesige Sammlung cooler, kuratierter Hintergründe findest du in [dharmx/walls](https://github.com/dharmx/walls).

Der Sperrbildschirm zeigt ein Standbild eines Video-Hintergrunds, genauso wie er ein Standbild eines animierten GIF zeigt.
