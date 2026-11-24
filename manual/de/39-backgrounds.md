# Hintergründe

Jedes Theme bringt seine eigenen Hintergründe mit, und du kannst eigene Ergänzungen in `~/.config/omarchy/backgrounds/[theme]` hinzufügen. Wenn du zum Beispiel ein zusätzliches Hintergrundbild zum nord-Theme hinzufügen willst, legst du die Datei einfach in `~/.config/omarchy/backgrounds/nord`.

Am einfachsten geht das, indem du im Omarchy-Menü zu _Installieren > Stil > Hintergrund_ gehst. Dadurch öffnet sich der Ordner, in dem die Hintergründe für dieses Theme gespeichert sind. Drücke `Super + Shift + F`, um einen weiteren Dateimanager zu starten, suche deinen Hintergrund und kopiere ihn hinüber. Jetzt gehört er zu den Hintergründen, zwischen denen du mit `Super + Ctrl + W` wählen kannst.

Hintergründe können sowohl Videos als auch Standbilder sein. Lege eine `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- oder `avi`-Datei in denselben Ordner, und sie erscheint neben den Bildern. Videos werden von der OWE wallpaper engine abgespielt. Sie decodiert das Video einmal für alle Monitore, gibt seinen Ton über die Standard-Audioausgabe aus und stoppt die Wiedergabe immer dann, wenn nichts es sehen kann. Ein Video-Hintergrund verbraucht trotzdem deutlich mehr Strom als ein Standbild.

Themes können ein kurzes Intro für einen Standbild-Hintergrund enthalten. Für `backgrounds/road.webp` liegt das passende Video unter `backgrounds/intros/road.mp4`. Es wird automatisch beim Booten abgespielt, wenn du zu einem Theme mit diesem ausgewählten Hintergrund wechselst und wenn du diesen Hintergrund auswählst, und kehrt dann zum Standbild zurück. Intro-Videos bleiben aus der Hintergrundauswahl heraus und werden niemals in einer Schleife abgespielt.

Wenn du _Darstellung > Animationen aus_ wählst, werden auch die Hintergrund-Intros ausgeschaltet. Omarchy tut dies standardmäßig in einer virtuellen Maschine. Mit dem Befehl `omarchy theme bg intro toggle` kannst du Intros separat umschalten. Beim Aktualisieren eines Themes wird kein Intro abgespielt.

Ein Standbild kann auch einen Loop haben, eine ruhige Version desselben Bildes, die sich weiterbewegt, unter `backgrounds/loops/road.mp4`. Er wird anstelle des Standbildes abgespielt, nach seinem Intro, falls es eines hat, und stoppt, wenn die Animationen ausgeschaltet sind. Im Akkubetrieb wird stattdessen das Standbild angezeigt, und der Loop kehrt zurück, sobald du das Gerät wieder anschließt. Loops bleiben aus der Hintergrundauswahl heraus.

Eine riesige Sammlung cooler, kuratierter Hintergründe findest du in [dharmx/walls](https://github.com/dharmx/walls).

Der Sperrbildschirm zeigt ein Standbild eines Video-Hintergrunds, genauso wie er ein Standbild eines animierten GIF zeigt.
