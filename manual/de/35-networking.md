# Netzwerk

Netzwerke in Omarchy werden von NetworkManager verwaltet, und du steuerst sie über das Netzwerksymbol in der [oberen Leiste](05-the-top-bar.md) oder mit `Super + Ctrl + N`.

Dieses Panel sucht nach Wi-Fi-Netzwerken, zeigt die Signalstärke an und verbindet dich. Ethernet braucht überhaupt nichts — einstecken, und es funktioniert. Wenn du lieber im Terminal bleibst, bietet dir `nmtui` dieselben Steuerelemente, und es gibt auch eine Befehlsgruppe `omarchy network`.

## Dein Wi-Fi teilen

Anstatt ein langes Passwort laut vorzulesen, führe _Setup > Network > QR Code_ aus, während du mit einem Wi-Fi verbunden bist. Dadurch erscheint ein QR Code auf dem Bildschirm, den jede Handykamera scannen kann, um sich zu verbinden. Das ist eines dieser Dinge, die du öfter nutzen wirst, als du erwartest, sobald du weißt, dass es da ist.

Wenn du das Passwort selbst brauchst, gibt `omarchy network password <interface>` es aus.

## DNS

Omarchy verwendet den DNS, den dein Netzwerk per DHCP bereitstellt. Du kannst das für den gesamten Rechner unter _Setup > Network > DNS_ überschreiben, wo Cloudflare und Google nur einen Klick entfernt sind. Wähle _Custom_, um deine eigenen Server einzugeben.

Vom Terminal aus gibt `omarchy dns` den aktuellen Anbieter aus und `omarchy dns Cloudflare` legt einen fest.

## Das Wi-Fi-Band festlegen

Wenn dein Router 2.4GHz, 5GHz und 6GHz unter demselben Netzwerknamen zusammenfasst, klammert sich dein Laptop manchmal an das langsame Band. `omarchy network band` zeigt, auf welchem Band du bist, und `omarchy network band 5` fixiert es. Verwende `auto`, damit es wieder selbst wählen kann.

Dadurch wird das Band fixiert, nicht ein bestimmter Access Point, sodass du weiterhin normal zwischen APs wechselst.

## Wie schnell ist es?

_Trigger > Speed Test > Network Speed Test_ misst deine tatsächliche Upload- und Download-Geschwindigkeit mit zwei Rundanzeigen. Vom Terminal aus geht das mit `omarchy network speedtest down` oder `up`. (Direkt daneben in diesem Menü sitzt ein Festplatten-Geschwindigkeitstest, falls du den anderen Engpass benchmarken willst.)

## Die Firewall

Die Firewall ist standardmäßig aktiviert und blockiert den gesamten eingehenden Datenverkehr, mit einer Ausnahme: Port 53317, damit [LocalSend](22-guis.md) sofort funktioniert.

SSH ist deaktiviert, bis du es mit _Setup > Security > SSHD_ aktivierst, was den Daemon startet, Port 22 ratenbegrenzt gegen Brute Force öffnet und einen Schlüssel autorisiert. Auch Docker ist abgeriegelt, damit Container sich nicht versehentlich der Welt aussetzen. Siehe [Sicherheit](48-security.md) für die ganze Geschichte.

## Tailscale

[Tailscale](https://tailscale.com/) ist ein Mesh-VPN, das es einfach und sicher macht, all deine Computer und Server über das Internet zu erreichen. Installiere es mit _Install > Service > Tailscale_.

Dadurch bekommst du ein Tailscale-Panel in der Leiste, das das Tailnet verbindet und trennt, Konten wechselt und einen Exit Node auswählt — deine eigenen Rechner und Mullvad-Regionen tauchen beide in der Liste auf. Es durchsucht auch deine Rechner, und dort lebt Taildrop: Wähle einen Rechner aus und drücke `s`, um ihm Dateien zu senden, oder `c`, `n` und `d`, um seine IP, seinen Namen oder seinen vollständigen DNS-Namen zu kopieren. Das Terminal-Äquivalent ist `omarchy tailscale send <machine> [file...]`, und an dich gesendete Dateien landen automatisch in `~/Downloads`. Die Benachrichtigung, die eine Ankunft ankündigt, wartet, bis du sie anklickst, um sie zu öffnen, oder sie verwirfst, sodass eine Datei, die eintrifft, während du nicht am Rechner bist, noch da ist, um beantwortet zu werden, wenn du zurückkommst.

Bei der Installation wird außerdem eine Web-App für die Tailscale-Admin-Konsole hinzugefügt.

## Wenn es nicht mehr funktioniert

Bevor du neu startest, versuche, das betroffene Teil für sich allein neu zu starten. _Update > Hardware_ bietet Wi-Fi, Bluetooth, Audio und Trackpad, und eines davon neu zu laden räumt die meisten „vor fünf Minuten ging es noch“-Situationen aus. Siehe [Fehlerbehebung](45-troubleshooting.md).
