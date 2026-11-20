# Hinweise

Benachrichtigungen landen in der oberen rechten Ecke des fokussierten Displays. Mit den Hotkey-Hinweisen greifst du außerdem schnell auf Datum und Uhrzeit, Akkustand und das aktuelle Wetter zu.

## Benachrichtigungen

Benachrichtigungen derselben App oder Website stapeln sich zu einem Deck, damit ein gesprächiger Slack-Kanal deine Build-Fehlermeldung nicht vom Bildschirm schiebt. Fahre mit der Maus über ein Deck, um es aufzufächern; während du liest, rutscht nichts Neues unter deinen Zeiger. Klicke auf eine Karte, um zu ihrer Quelle zu springen, klicke mit der rechten oder mittleren Maustaste oder tippe auf das ✕, um sie zu schließen.

Karten bieten das an, was sie mitbringen: _Code kopieren_ für Bestätigungscodes (bleiben aus dem [Verlauf der Zwischenablage](08-unified-clipboard-history.md) heraus und werden nach einer Minute gelöscht), plus alle Buttons, die die App bereitstellt. Links im Text einer Benachrichtigung öffnen sich beim Anklicken.

`Super + ,` schließt die neueste Benachrichtigung oder öffnet das, worauf sie zeigt, wenn sie das anbietet, `Super + Alt + ,` schließt nur die letzte, `Super + Shift + ,` schließt sie alle, und `Super + Shift + Alt + ,` öffnet den Verlauf. Um sie ohne Maus zu nutzen, drücke `Super + Ctrl + ,`. Die neueste Benachrichtigung ist ausgewählt und ihre Buttons sind nummeriert: Drücke eine Zahl, um einen zu nutzen, `Enter`, um auf die Benachrichtigung zu klicken, `↑` und `↓`, um zwischen Benachrichtigungen zu wechseln, `Delete`, um eine zu schließen, und `Esc`, um die Tastatur zurückzugeben. Nach ein paar Sekunden ohne Eingabe lässt sie auch von selbst wieder los.

Stummgeschaltete Benachrichtigungen werden zurückgehalten, außer Omarchys eigenen Bestätigungen, Notfallwarnungen und Bestätigungscodes, um die du gerade eben gebeten hast. Hole die letzten paar wieder auf den Bildschirm, zurückgehalten oder nicht, mit `Super + Shift + Alt + ,`. Der Verlauf wird einen Tag lang aufbewahrt.

## Hotkey-Hinweise

### Datum & Uhrzeit

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Wetter

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Der Standort wird anhand deiner IP-Adresse ermittelt, was meist nah genug dran ist, aber nicht immer. Du kannst ihn mit `omarchy weather location --set Malibu` festlegen oder mit Koordinaten exakt angeben: `omarchy weather location --set Malibu 34.0259,-118.7798`. Führe `omarchy weather location` allein aus, um zu sehen, wo es dich vermutet, und `--clear`, um zur automatischen Erkennung zurückzukehren.

### Akku

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
