# Hardware-Authentifizierung

### Fingerabdruck-Authentifizierung

Viele Laptops verfügen über einen Fingerabdrucksensor zur Authentifizierung. Du kannst ihn mit Omarchy nutzen, indem du im Omarchy-Menü (`Super + Space`) _Setup > Security > Fingerprint_ ausführst.

Daraufhin öffnet sich ein Fingerabdruck in Vollbild, der sich ausfüllt, während du den Sensor berührst. Im Hintergrund installiert Omarchy das Fingerabdruck-Paket, erfasst deinen Abdruck, überprüft ihn, und dann kannst du deinen Fingerabdruck verwenden, um vom Sperrbildschirm aus zu entsperren (den du mit `Super + Ctrl + L` aufrufen kannst), den sudo-Modus zu aktivieren und Systemabfragen zu autorisieren.

Sobald der Sperrbildschirm das Display ausgeschaltet hat, ruht der Sensor, um Strom zu sparen. Wecke den Bildschirm daher mit einer beliebigen Taste oder dem Touchpad auf, bevor du ihn berührst.

Wenn der Deckel deines Laptops geschlossen ist, wird die Fingerabdruck-Abfrage automatisch übersprungen, sodass du direkt zur Passwortabfrage gelangst, statt auf einen Sensor zu warten, den du nicht erreichen kannst. Wenn du ansonsten mit einer externen Tastatur ohne Sensor arbeiten musst, drücke einfach `CTRL + C`, wenn du während `sudo` zur Eingabe deines Fingerabdrucks aufgefordert wirst.

Du kannst die Fingerabdruck-Authentifizierung im Omarchy-Menü unter _Remove > Security > Fingerprint_ entfernen.

### Fido2-Authentifizierung

Wenn du ein Fido2-Gerät verwendest, kannst du es für die `sudo`-Authentifizierung einrichten, indem du im Omarchy-Menü (`Super + Space`) _Setup > Security > Fido2_ aufrufst. Es deckt allerdings `sudo` und System-Autorisierungsabfragen ab, nicht das Entsperren deines Computers.

Du kannst die Fido2-Authentifizierung im Omarchy-Menü unter _Remove > Security > Fido2_ entfernen.
