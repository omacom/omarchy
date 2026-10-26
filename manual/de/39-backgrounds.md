# Hintergründe

Jedes Theme liefert seinen eigenen Satz an Hintergründen mit, und du kannst eigene zusätzliche in `~/.config/omarchy/backgrounds/[theme]` hinzufügen. Wenn du zum Beispiel zum Theme nord ein zusätzliches Hintergrundbild hinzufügen willst, legst du die Datei einfach in `~/.config/omarchy/backgrounds/nord`.

Am einfachsten geht das über _Install > Style > Background_ im Omarchy Menu. Dadurch öffnet sich der Ordner, in dem die Hintergründe für dieses Theme gespeichert sind. Drücke `Super + Shift + F`, um einen weiteren Dateimanager zu starten, suche deinen Hintergrund und kopiere ihn hinüber. Jetzt wird er in die Auswahl an Hintergründen aufgenommen, zwischen denen du mit `Super + Ctrl + W` wählen kannst.

Hintergründe können Videos genauso wie Standbilder sein. Lege eine Datei in den Formaten `mp4`, `m4v`, `mov`, `webm`, `mkv` oder `avi` im selben Ordner ab, und sie erscheint neben den Bildern. Videos werden von der OWE Wallpaper Engine abgespielt. Sie dekodiert das Video einmal für alle Monitore, spielt seinen Ton über die Standard-Audioausgabe ab und stoppt die Wiedergabe, sobald nichts sie mehr sehen kann. Ein Video-Hintergrund kostet trotzdem deutlich mehr Strom als ein Standbild.

Themes können ein kurzes Intro für einen Standbild-Hintergrund enthalten. Für `backgrounds/road.webp` liegt das zugehörige Video unter `backgrounds/intros/road.mp4`. Es wird beim Booten und beim Wechsel zu einem Theme mit diesem ausgewählten Hintergrund automatisch abgespielt und kehrt dann zum Standbild zurück. Intro-Videos tauchen nicht in der Hintergrundauswahl auf und laufen nie in Schleife.

Das Ausschalten von _Appearance > Animations_ schaltet auch die Hintergrund-Intros aus. Omarchy macht das in einer VM standardmäßig so. Mit dem Befehl `omarchy theme bg intro toggle` kannst du Intros separat umschalten. Das Aktualisieren eines Themes oder die Auswahl eines anderen Hintergrunds innerhalb desselben Themes spielt kein Intro ab.

Eine riesige Sammlung cooler, kuratierter Hintergründe findest du in [dharmx/walls](https://github.com/dharmx/walls).

Der Sperrbildschirm zeigt ein Standbild eines Video-Hintergrunds, genauso wie er ein Standbild eines animierten GIF zeigt.
