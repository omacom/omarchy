# Hintergründe

Jedes Theme wird mit seinem eigenen Satz an Hintergründen ausgeliefert, und du kannst in `~/.config/omarchy/backgrounds/[theme]` eigene hinzufügen. Wenn du zum Beispiel ein zusätzliches Hintergrundbild zum nord-Theme hinzufügen willst, legst du die Datei einfach in `~/.config/omarchy/backgrounds/nord` ab.

Am einfachsten geht das, indem du im Omarchy-Menü zu _Installieren > Stil > Hintergrund_ gehst. Damit öffnet sich der Ordner, in dem die Hintergründe für dieses Theme gespeichert sind. Drücke `Super + Shift + F`, um einen weiteren Dateimanager zu starten, suche deinen Hintergrund und kopiere ihn hinüber. Jetzt ist er in der Auswahl der Hintergründe enthalten, zwischen denen du mit `Super + Ctrl + W` wählen kannst.

Hintergründe können Videos ebenso wie Standbilder sein. Lege eine `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- oder `avi`-Datei in denselben Ordner, und sie erscheint neben den Bildern. Videos werden von der OWE wallpaper engine abgespielt. Sie dekodiert das Video einmal für alle Monitore und spielt seinen Ton über die Standard-Audioausgabe ab, und sie stoppt die Wiedergabe immer dann, wenn nichts es sehen kann. Ein Video-Hintergrund verbraucht trotzdem weitaus mehr Strom als ein Standbild.

Themes können ein kurzes Intro für einen Standbild-Hintergrund enthalten. Für `backgrounds/road.webp` liegt das passende Video unter `backgrounds/intros/road.mp4`. Es wird automatisch beim Booten abgespielt, wenn du zu einem Theme mit diesem ausgewählten Hintergrund wechselst und wenn du diesen Hintergrund auswählst, und kehrt dann zum Standbild zurück. Intro-Videos bleiben aus der Hintergrundauswahl heraus und laufen nie in einer Schleife.

Das Abschalten von _Erscheinungsbild > Animationen_ schaltet auch Hintergrund-Intros ab. Omarchy tut dies standardmäßig in einer virtuellen Maschine. Mit dem Befehl `omarchy theme bg intro toggle` lassen sich Intros separat umschalten. Das Aktualisieren eines Themes spielt kein Intro ab.

Ein Standbild kann auch einen Loop haben, eine ruhige Version desselben Bildes, die sich weiter bewegt, unter `backgrounds/loops/road.mp4`. Er wird anstelle des Standbildes abgespielt, nach seinem Intro, falls es eines hat, und stoppt, wenn Animationen abgeschaltet sind. Loops bleiben aus der Hintergrundauswahl heraus und kosten, wie jeder Video-Hintergrund, mehr Strom als ein Standbild.

Eine riesige Sammlung cooler, kuratierter Hintergründe findest du in [dharmx/walls](https://github.com/dharmx/walls).

Der Sperrbildschirm zeigt ein Standbild eines Video-Hintergrunds, genauso wie er ein Standbild eines animierten GIF zeigt.
