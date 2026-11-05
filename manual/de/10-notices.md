# Hinweise

Benachrichtigungen erscheinen in der oberen rechten Ecke des fokussierten Displays. Du kannst auch schnell auf Datum und Uhrzeit, Akkustand und aktuelles Wetter zugreifen, und zwar über die Tastenkürzel-Hinweise.

## Benachrichtigungen

Benachrichtigungen derselben App oder Website stapeln sich zu einem Deck, damit ein geschwätziger Slack-Kanal deinen fehlgeschlagenen Build nicht vom Bildschirm schiebt. Fahre mit der Maus über ein Deck, um es aufzufächern; nichts Neues rutscht unter deinen Zeiger, während du liest. Klicke auf eine Karte, um zu ihrem Ursprung zu springen, klicke mit der rechten oder mittleren Maustaste oder triff das ✕, um sie zu schließen.

Karten bieten an, was sie mitbringen: _Code kopieren_ für Verifizierungscodes (außen vor gelassen im [Verlauf der Zwischenablage](08-unified-clipboard-history.md) und nach einer Minute gelöscht), plus alle Schaltflächen, die die App bereitstellt. Links im Text einer Benachrichtigung öffnen sich beim Anklicken.

Um sie ohne Maus zu nutzen, drücke `Super + Ctrl + ,`. Die neueste Benachrichtigung ist ausgewählt und ihre Schaltflächen sind nummeriert: Drücke eine Zahl, um eine zu nutzen, `Enter`, um die Benachrichtigung anzuklicken, `↑` und `↓`, um zwischen Benachrichtigungen zu wechseln, `Delete`, um eine zu schließen, und `Esc`, um die Tastatur wieder freizugeben. Nach ein paar Sekunden ohne Eingabe gibt sie auch von selbst wieder frei.

Das Stummschalten von Benachrichtigungen hält sie zurück, mit Ausnahme von Omarchys eigenen Bestätigungen, Notfallwarnungen und Verifizierungscodes, um die du gerade eben gebeten hast. Bringe die letzten paar wieder auf den Bildschirm, zurückgehalten oder nicht, mit `Super + Shift + Alt + ,`. Der Verlauf wird einen Tag lang aufbewahrt.

## Tastenkürzel-Hinweise

### Datum & Uhrzeit

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Wetter

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Der Standort wird anhand deiner IP-Adresse erkannt, was normalerweise nah genug dran ist, aber nicht immer. Du kannst ihn mit `omarchy weather location --set Malibu` festlegen, oder es genau nehmen und Koordinaten hinzufügen: `omarchy weather location --set Malibu 34.0259,-118.7798`. Führe `omarchy weather location` allein aus, um zu sehen, wo es dich vermutet, und `--clear`, um zur automatischen Erkennung zurückzukehren.

### Akku

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
