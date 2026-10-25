# Sicherheit

Omarchy nimmt Sicherheit extrem ernst. Dies soll ein Betriebssystem sein, das du nutzen kannst, um in der _echten Welt_ _echte Arbeit_ zu erledigen. Bei dem der Verlust eines Laptops nicht zu einem Sicherheitsnotfall führen kann. Das tun wir dafür:

1. *Vollständige Festplattenverschlüsselung ist Pflicht*: Das ist der wichtigste Schritt, um deine Daten physisch zu schützen. Wenn dein Computer verloren geht oder gestohlen wird, sind die Daten mit dem Standard LUKS (Linux Unified Key Setup) vollständig verschlüsselt.
2. *Die Firewall ist standardmäßig aktiviert*: Der gesamte eingehende Datenverkehr wird standardmäßig blockiert, mit Ausnahme von Port 53317 für [LocalSend](https://localsend.org/). Selbst ssh ist deaktiviert, bis du es über _Setup > Sicherheit > SSHD_ aktivierst, wodurch im Rahmen der Einrichtung Port 22 geöffnet wird (gegen Brute-Force-Angriffe ratenlimitiert). Wir schotten sogar den Docker-Zugriff mit dem [ufw-docker](https://github.com/chaifeng/ufw-docker)-Setup ab, damit deine Container nicht versehentlich für die ganze Welt zugänglich sind.
3. *Arch hat immer die neuesten Updates*: Arch, die zugrunde liegende Distribution, auf der Omarchy aufbaut, ist eine Rolling-Release-Distribution. Das bedeutet, dass jede entdeckte und behobene Sicherheitslücke in irgendeinem Paket schnell per `omarchy-update` zur Installation bereitsteht. So führst du immer die neuesten, sichersten Versionen von allem aus.
4. *Omarchy pflegt eigene Pakete und einen eigenen Mirror*: Standardmäßig setzt Omarchy nur auf Pakete aus Archs eigenen core/extra/multilib-Repositories und seinem eigenen Omarchy Package Repository. Du kannst Software direkt aus dem AUR installieren, die Basisinstallation tut das aber nicht — nur wenige optionale Installationen, wie die Browser von Drittanbietern, greifen auf das AUR zurück.
5. *Cloudflare schützt uns vor DDoS*: Die Vertriebsinfrastruktur von Omarchy — die ISOs, die Omarchy-Pakete, der Arch-Mirror — ist hinter Cloudflares gewaltigem DDoS-Schutzschild geschützt und wird auf deren CDN gehostet. Das sorgt für hervorragende Verfügbarkeit.

## Deine Passwörter ändern

Bei einer verschlüsselten Installation hast du zwei Passwörter: eines, das beim Booten das Laufwerk entsperrt, und eines, mit dem du dich anmeldest und `sudo` nutzt. Die Einrichtung macht beide gleich. Beide lassen sich im Omarchy-Menü unter _Update > Passwort_ ändern — _Festplattenverschlüsselung_ für das erste, _Benutzer_ für das zweite. Beim Ändern des Laufwerk-Passworts wirst du zuerst nach dem aktuellen gefragt, halte es also bereit. Wenn eine Änderung unterbrochen wird, führe _Festplattenverschlüsselung_ erneut aus: Es fragt nach dem Passwort, das das Laufwerk jetzt entsperrt, und schließt die Änderung ab.

## Einen bereits genutzten Rechner weitergeben

Wenn du deinen Rechner an jemand anderen übergibst, musst du ihn nicht neu installieren. Führe im Omarchy-Menü _Setup > Computer zurücksetzen_ aus, tippe `reset` zur Bestätigung und starte neu. Das löscht jedes Benutzerkonto und alles in `/home`, verwirft alle Pakete und Systemänderungen, die du seit der Installation vorgenommen hast, und bereinigt die Identität des Rechners — Netzwerkverbindungen, Host-Keys und alles. Was danach hochfährt, ist der Einrichtungsassistent vom ersten Boot, bereit für den neuen Besitzer, seinen eigenen Namen, sein Passwort und sein Verschlüsselungspasswort einzugeben.

Es funktioniert, indem es den Basis-Snapshot wiederherstellt, den das Installationsprogramm erstellt, daher ist es nur auf Rechnern verfügbar, die von der Omarchy ISO installiert wurden. Und auf einem Laufwerk ohne Verschlüsselung ist ein Zurücksetzen ein Löschen und kein sicheres Überschreiben; wenn die Daten sensibel waren, mache stattdessen eine frische Installation.

## Passwortloses sudo

Manchmal willst du, dass `sudo` aufhört zu fragen, am häufigsten, wenn ein KI-Agent für dich eine lange Strecke Systemarbeit erledigt. _Setup > Sicherheit > Passwortloses Sudo_ fragt, wie lange der Zugriff erlaubt sein soll: **15 Minuten**, **1 Stunde**, **1 Tag** oder **Permanent**. Während der Zugriff aktiv ist, erscheint ein rotes Warnsymbol neben den anderen Indikatoren in der Menüleiste. Klicke darauf oder führe den Befehl erneut aus, um den Zugriff zu deaktivieren. Du kannst auch deine eigene Anzahl an Minuten (von 1 bis 1440) mit `omarchy-sudo-passwordless 30` übergeben oder `omarchy-sudo-passwordless permanent` verwenden.

Zeitlich begrenzter Zugriff läuft automatisch ab, auch unmittelbar nach dem Aufwachen aus einem Ruhezustand, der die Frist überschritten hat. Ein Neustart des Computers beendet ihn vorzeitig. Permanenter Zugriff übersteht Neustarts und bleibt aktiviert, bis du ihn deaktivierst.

Das Aktualisieren oder Entfernen von Omarchys Einstellungspaket beendet jede temporäre Freigabe, bevor sich deren Ablaufunterstützung ändert. Wenn der Befehl einen Autorisierungs- oder Bereinigungsfehler meldet, behebe ihn, bevor du versuchst, eine weitere Freigabe zu aktivieren; ein Fehler bedeutet nicht, dass der passwortlose Zugriff inaktiv ist.

Sei dir bei dieser Sache im Klaren: Solange sie aktiv ist, kann alles, was als dein Benutzer läuft, ohne Nachfrage alles als root tun. Das ist der ganze Sinn, und es ist auch das ganze Risiko.

## Signaturschlüssel

Der öffentliche Schlüssel für alle ISO-Signaturen und Omarchy-Repo-Pakete ist `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([auf openpgp.org prüfen](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Das Paket `omarchy/omarchy-keyring` enthält diesen ebenfalls und wird verwendet, um mögliche Updates nahtlos auszurollen.

Du findest die Signatur für jedes ISO-Release, indem du .sig an die URL anhängst. Zum Beispiel https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
