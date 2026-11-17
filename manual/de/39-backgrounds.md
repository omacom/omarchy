# Hintergrundbilder

Jedes Theme wird mit eigenen Hintergrundbildern ausgeliefert, und du kannst in `~/.config/omarchy/backgrounds/[theme]` eigene zusätzliche hinzufügen. Wenn du zum Beispiel zum nord-Theme ein zusätzliches Hintergrundbild hinzufügen möchtest, legst du die Datei einfach in `~/.config/omarchy/backgrounds/nord`.

Am einfachsten geht das, indem du im Omarchy Menu zu _Install > Style > Background_ gehst. Dadurch wird der Ordner geöffnet, in dem die Hintergrundbilder für dieses Theme gespeichert sind. Drücke `Super + Shift + F`, um einen weiteren Dateimanager zu öffnen, suche dein Hintergrundbild und kopiere es hinüber. Jetzt ist es in der Auswahl der Hintergrundbilder enthalten, zwischen denen du mit `Super + Ctrl + W` wechseln kannst.

Hintergrundbilder können sowohl Videos als auch Standbilder sein. Lege eine `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- oder `avi`-Datei in denselben Ordner, und sie erscheint neben den Bildern. Videos werden von der OWE-Wallpaper-Engine abgespielt. Sie dekodiert das Video einmal für alle Monitore, spielt seinen Ton über den Standard-Audioausgang ab und stoppt die Wiedergabe, sobald nichts mehr davon zu sehen ist. Ein Video-Hintergrundbild verbraucht trotzdem deutlich mehr Strom als ein Standbild.

Themes können ein kurzes Intro für ein Standbild-Hintergrundbild enthalten. Für `backgrounds/road.webp` liegt das passende Video unter `backgrounds/intros/road.mp4`. Es wird automatisch beim Booten abgespielt, wenn du zu einem Theme mit diesem ausgewählten Hintergrundbild wechselst und wenn du dieses Hintergrundbild auswählst, und kehrt dann zum Standbild zurück. Intro-Videos tauchen nicht in der Hintergrundbild-Auswahl auf und werden niemals in einer Endlosschleife abgespielt.

Das Deaktivieren von _Appearance > Animations_ deaktiviert auch Hintergrund-Intros. Omarchy macht das standardmäßig in einer virtuellen Maschine. Mit dem Befehl `omarchy theme bg intro toggle` kannst du Intros separat ein- und ausschalten. Beim Aktualisieren eines Themes wird kein Intro abgespielt.

Eine riesige Sammlung cooler, kuratierter Hintergrundbilder findest du in [dharmx/walls](https://github.com/dharmx/walls).

Der Sperrbildschirm zeigt ein Standbild eines Video-Hintergrundbilds, genauso wie er ein Standbild eines animierten GIF zeigt.
