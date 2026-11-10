# Hardware-Authentifizierung

### Authentifizierung per Fingerabdruck

Viele Laptops verfügen über einen Fingerabdrucksensor zur Authentifizierung. Du kannst ihn mit Omarchy nutzen, indem du im Omarchy-Menü (`Super + Space`) _Setup > Sicherheit > Fingerabdruck_ ausführst.

Daraufhin wird das Fingerabdruck-Paket installiert, dein Abdruck erfasst und verifiziert, und schon kannst du deinen Fingerabdruck verwenden, um vom Sperrbildschirm aus zu entsperren (den du mit `Super + Ctrl + L` auslösen kannst), in den sudo-Modus zu wechseln und Systemanfragen zu autorisieren.

Sobald der Sperrbildschirm das Display ausgeschaltet hat, ruht der Sensor, um Strom zu sparen, also wecke den Bildschirm mit einer beliebigen Taste oder dem Touchpad, bevor du ihn berührst.

Wenn dein Laptopdeckel geschlossen ist, wird die Fingerabdruckabfrage automatisch übersprungen, sodass du direkt zur Passwortabfrage gelangst, statt auf einen Sensor zu warten, den du nicht erreichen kannst. Wenn du ansonsten an einer externen Tastatur arbeiten musst, die keinen Sensor hat, drücke einfach `CTRL + C`, wenn du während `sudo` nach deinem Fingerabdruck gefragt wirst.

Du kannst die Authentifizierung per Fingerabdruck im Omarchy-Menü unter _Entfernen > Sicherheit > Fingerabdruck_ entfernen.

### Fido2-Authentifizierung

Wenn du ein Fido2-Gerät verwendest, kannst du es für die `sudo`-Authentifizierung einrichten, indem du im Omarchy-Menü (`Super + Space`) _Setup > Sicherheit > Fido2_ verwendest. Es deckt allerdings `sudo` und Systemautorisierungsabfragen ab, nicht das Entsperren deines Computers.

Du kannst die Fido2-Authentifizierung im Omarchy-Menü unter _Entfernen > Sicherheit > Fido2_ entfernen.
