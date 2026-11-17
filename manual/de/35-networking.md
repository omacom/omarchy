# Netzwerk

Netzwerk in Omarchy wird von NetworkManager verwaltet, und du bedienst es über das Netzwerksymbol in der [oberen Leiste](05-the-top-bar.md) oder mit `Super + Ctrl + N`.

Dieses Panel sucht nach Wi-Fi-Netzwerken, zeigt die Signalstärke an und stellt die Verbindung her. Ethernet braucht überhaupt nichts — einstecken, und es funktioniert. Wenn du lieber im Terminal bleibst, bietet dir `nmtui` dieselben Steuerelemente, und es gibt auch eine Befehlsgruppe `omarchy network`.

## Dein Wi-Fi teilen

Anstatt ein langes Passwort laut vorzulesen, führe _Setup > Network > QR Code_ aus, während du mit Wi-Fi verbunden bist. Damit erscheint ein QR-Code auf dem Bildschirm, den jede Handykamera scannen kann, um sich zu verbinden. Es ist eines dieser Dinge, die du öfter nutzen wirst, als du erwartest, sobald du weißt, dass es da ist.

Wenn du tatsächlich das Passwort selbst brauchst, gibt `omarchy network password <interface>` es aus.

## DNS

Omarchy verwendet den DNS, den dein Netzwerk über DHCP ausgibt. Du kannst das für die ganze Maschine unter _Setup > Network > DNS_ überschreiben, wo Cloudflare und Google nur einen Klick entfernt sind. Wähle _Custom_, um deine eigenen Server einzugeben.

Vom Terminal aus gibt `omarchy dns` den aktuellen Anbieter aus, und `omarchy dns Cloudflare` legt einen fest.

## Das Wi-Fi-Band fixieren

Wenn dein Router 2.4GHz, 5GHz und 6GHz unter demselben Netzwerknamen zusammenfasst, klammert sich dein Laptop manchmal an das langsame Band. `omarchy network band` zeigt, auf welchem Band du bist, und `omarchy network band 5` fixiert es. Verwende `auto`, um es wieder selbst wählen zu lassen.

Damit wird das Band fixiert statt eines bestimmten Zugangspunkts, sodass du weiterhin normal zwischen APs roamst.

## Wie schnell ist es?

_Trigger > Speed Test > Network Speed Test_ misst deine tatsächliche Geschwindigkeit beim Hoch- und Herunterladen mit einem Paar Rundinstrumenten. Vom Terminal aus ist es `omarchy network speedtest down` oder `up`. Es misst gegen den eigenen Dienst von Omarchy und zählt nur dessen Testübertragungen. Andere Downloads können um Bandbreite konkurrieren, werden aber nicht zum Ergebnis des Geschwindigkeitstests hinzugerechnet. (Direkt daneben sitzt in diesem Menü ein Festplatten-Geschwindigkeitstest, falls du den anderen Engpass benchmarken willst.)

## Die Firewall

Die Firewall ist standardmäßig eingeschaltet und blockiert den gesamten eingehenden Datenverkehr, mit einer Ausnahme: Port 53317, damit [LocalSend](22-guis.md) sofort einsatzbereit funktioniert.

SSH ist ausgeschaltet, bis du es mit _Setup > Security > SSHD_ einschaltest, was den Daemon startet, Port 22 ratenbegrenzt gegen Brute Force öffnet und einen Schlüssel autorisiert. Docker ist ebenfalls abgeriegelt, sodass Container sich nicht versehentlich der Welt aussetzen können. Siehe [Sicherheit](48-security.md) für die ganze Geschichte.

## Tailscale

[Tailscale](https://tailscale.com/) ist ein Mesh-VPN, das es einfach und sicher macht, all deine Computer und Server über das Internet zu erreichen. Installiere es mit _Install > Service > Tailscale_.

Damit bekommst du ein Tailscale-Panel in der Leiste, das das Tailnet verbindet und trennt, Konten wechselt und einen Exit-Knoten auswählt — deine eigenen Maschinen und Mullvad-Regionen tauchen beide in der Liste auf. Es durchsucht auch deine Maschinen, und dort lebt Taildrop: Wähle eine Maschine aus und drücke `s`, um ihr Dateien zu senden, oder `c`, `n` und `d`, um ihre IP, ihren Namen oder ihren vollständigen DNS-Namen zu kopieren. Das Terminal-Äquivalent ist `omarchy tailscale send <machine> [file...]`, und an dich gesendete Dateien landen automatisch in `~/Downloads`. Die Benachrichtigung, die eine Ankunft ankündigt, wartet, bis du sie per Klick öffnest oder sie verwirfst, sodass eine Datei, die eintrifft, während du nicht an der Maschine bist, immer noch da ist, um beantwortet zu werden, wenn du zurückkommst.

Durch die Installation wird auch eine Web-App für die Tailscale-Admin-Konsole hinzugefügt.

## Wenn es nicht mehr funktioniert

Bevor du neu startest, versuche, das betroffene Teil für sich neu zu starten. _Update > Hardware_ hat Wi-Fi, Bluetooth, Audio und Trackpad, und eines davon neu zu laden räumt die meisten „es hat vor fünf Minuten noch funktioniert“-Situationen aus. Siehe [Fehlerbehebung](45-troubleshooting.md).
