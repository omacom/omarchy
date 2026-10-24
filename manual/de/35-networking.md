# Netzwerk

Das Netzwerk in Omarchy übernimmt NetworkManager, und du steuerst es über das Netzwerksymbol in der [Menüleiste](05-the-top-bar.md) oder mit `Super + Ctrl + W`.

Dieses Panel sucht nach WLAN-Netzwerken, zeigt die Signalstärke an und verbindet dich. Ethernet braucht gar nichts — einstecken und es läuft. Wenn du lieber im Terminal bleibst, hast du mit `nmtui` dieselben Bedienelemente, und es gibt auch eine Befehlsgruppe `omarchy network`.

## Dein WLAN teilen

Statt ein langes Passwort laut vorzulesen, startest du _Einrichtung > Netzwerk > QR-Code_, während du im WLAN bist. Damit erscheint ein QR-Code auf dem Bildschirm, den jede Handykamera zum Beitreten scannen kann. Das ist eine dieser Funktionen, die du häufiger nutzen wirst als erwartet, sobald du weißt, dass es sie gibt.

Wenn du das Passwort selbst brauchst, zeigt dir `omarchy network password <interface>` es an.

## DNS

Omarchy verwendet das DNS, das dein Netzwerk per DHCP verteilt. Das kannst du für das ganze System unter _Einrichtung > Netzwerk > DNS_ überschreiben, wo Cloudflare und Google nur einen Klick entfernt sind. Wähle _Benutzerdefiniert_, um deine eigenen Server einzugeben.

Im Terminal zeigt `omarchy dns` den aktuellen Anbieter an und `omarchy dns Cloudflare` setzt einen.

## Das WLAN-Band festlegen

Wenn dein Router 2.4GHz, 5GHz und 6GHz unter demselben Netzwerknamen anbietet, klammert sich dein Laptop manchmal an das langsame Band. `omarchy network band` zeigt, auf welchem Band du bist, und `omarchy network band 5` legt es fest. Mit `auto` lässt du es wieder automatisch wählen.

Das legt das Band fest, nicht einen bestimmten Zugangspunkt, sodass du wie gewohnt zwischen den Zugangspunkten wechseln kannst.

## Wie schnell ist es?

_Auslösen > Geschwindigkeitstest > Netzwerktest_ misst deine tatsächliche Upload- und Downloadgeschwindigkeit mit zwei Anzeigen. Im Terminal geht es mit `omarchy network speedtest down` oder `up`. (Direkt daneben in diesem Menü gibt es einen Plattentest, falls du den anderen Engpass testen willst.)

## Die Firewall

Die Firewall ist standardmäßig eingeschaltet und blockiert den gesamten eingehenden Datenverkehr, mit einer Ausnahme: Port 53317, damit [LocalSend](22-guis.md) von Anfang an funktioniert.

SSH ist ausgeschaltet, bis du es unter _Einrichtung > Security > SSHD_ einschaltest. Das startet den Dienst, öffnet Port 22 mit Rate-Limit gegen Brute Force und autorisiert einen Schlüssel. Docker ist ebenfalls verriegelt, sodass Container sich nicht versehentlich der Welt ausliefern können. Die ganze Geschichte findest du unter [Sicherheit](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) ist ein Mesh-VPN, mit dem du all deine Computer und Server über das Internet einfach und sicher erreichst. Installiere es über _Installieren > Service > Tailscale_.

Damit bekommst du ein Tailscale-Panel in der Leiste, das das Tailnet verbindet und trennt, Konten wechselt und einen Exit-Node auswählt — deine eigenen Rechner und Mullvad-Regionen erscheinen beide in der Liste. Es durchsucht auch deine Rechner, und genau dort wohnt Taildrop: Wähle einen Rechner und drücke `s`, um ihm Dateien zu senden, oder `c`, `n` und `d`, um seine IP, seinen Namen oder seinen vollständigen DNS-Namen zu kopieren. Das Terminal-Äquivalent ist `omarchy tailscale send <machine> [file...]`, und an dich gesendete Dateien landen automatisch in `~/Downloads`. Die Benachrichtigung über eine Ankunft wartet, bis du sie anklickst oder verwirfst, sodass eine Datei, die ankommt, während du nicht am Rechner bist, bei deiner Rückkehr immer noch da ist.

Die Installation fügt auch eine Web-App für die Tailscale-Admin-Konsole hinzu.

## Wenn es nicht mehr geht

Versuche vor einem Neustart, den betroffenen Teil für sich neu zu starten. Unter _Aktualisieren > Hardware_ findest du Wi-Fi, Bluetooth, Audio und Trackpad, und eines davon neu zu laden löst die meisten Situationen der Art „vor fünf Minuten ging es noch“. Siehe [Fehlerbehebung](45-troubleshooting.md).
