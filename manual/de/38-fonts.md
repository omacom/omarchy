# Schriftarten

Omarchy verwendet standardmäßig JetBrainsMono Nerd Font sowohl als Terminal- als auch als Systemschriftart.

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

Du kannst das über das Menü _Darstellung > Schriftart_ im Omarchy-Menü (`Super + Space`) ändern. Dadurch wird die Monospace-Schriftart überall festgelegt: im Terminal, in der Leiste und bei allem anderen, das danach fragt.

Du kannst andere beliebte Programmierschriftarten über _Installieren > Stil > Schriftart_ im Omarchy-Menü installieren: Cascadia Mono, Meslo LG Mono, Fira Code, Victor Code, Bitstream Vera Mono und Iosevka sind alle nur einen Klick entfernt, in ihren Nerd Font-Versionen, damit die Glyphen in der Leiste und im Terminal weiterhin funktionieren. Nachdem du eine installiert hast, wähle sie unter _Darstellung > Schriftart_ aus.

## Chinesisch, Japanisch und Koreanisch

Chinesisch, Japanisch und Koreanisch teilen sich viele Zeichen, zeichnen einige davon aber unterschiedlich, sodass dasselbe Zeichen für den einen Leser richtig und für einen anderen fremd aussieht. Wenn du eine dieser Sprachen unter _Einrichtung > Sprache_ oder ihre Eingabemethode auswählst, werden die passenden Formen festgelegt. Um sie selbst zu wählen, führe `omarchy font cjk jp`, `kr`, `sc`, `tc` (Taiwan) oder `hk` (Hongkong) in einem Terminal aus; `omarchy font cjk default` kehrt zur Auswahl des Systems zurück, bei der es sich um japanische Formen handelt. Text, den eine Webseite oder ein Dokument mit einer eigenen Sprache kennzeichnet, und der gesamte Desktop, solange er in einer dieser Sprachen ist, behält die Formen dieser Sprache.
