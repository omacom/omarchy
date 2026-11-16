# Sicherheit

Omarchy nimmt Sicherheit extrem ernst. Dies soll ein Betriebssystem sein, mit dem du _echte Arbeit_ in der _echten Welt_ erledigen kannst. Wo ein verlorener Laptop nicht zu einem Sicherheitsnotfall führen kann. Hier ist also, was wir tun:

1. *Vollständige Festplattenverschlüsselung ist standardmäßig aktiviert*: Dies ist der wichtigste Schritt zum physischen Schutz deiner Daten. Wenn dein Computer verloren geht oder gestohlen wird, sind die Daten mit dem Standard LUKS (Linux Unified Key Setup) vollständig verschlüsselt. Der Installer lässt dich für Wegwerfmaschinen davon absehen (siehe [Erste Schritte](02-getting-started.md)); eine Installation ohne Verschlüsselung hat keinerlei Schutz dieser Art, und jeder, der die Festplatte in den Händen hält, kann sie lesen.
2. *Firewall ist standardmäßig aktiviert*: Der gesamte eingehende Datenverkehr wird standardmäßig blockiert, mit wenigen Ausnahmen: Port 53317 für [LocalSend](https://localsend.org/); DNS-Anfragen an den eigenen Resolver des Computers unter der Docker-Bridge-Adresse (172.17.0.1), akzeptiert aus den privaten Adressbereichen, die Docker seinen Containern zuweist; und Multicast-DNS (Port 5353), das es Druckern und anderen Geräten in deinem Netzwerk ermöglicht, sich gegenseitig zu finden, und dort auch den Namen deines Computers bekannt gibt. Darüber hinaus behält die Firewall die standardmäßigen UFW-Freigaben für Ping, das Beziehen einer Adresse von deinem Router (DHCP) und UPnP-Discovery bei. Selbst ssh ist deaktiviert, bis du es über _Setup > Sicherheit > SSHD_ aktivierst, wodurch Port 22 (ratelimitiert gegen Brute-Force-Angriffe) als Teil der Einrichtung geöffnet wird. Wir sperren sogar den Docker-Zugriff mithilfe des [ufw-docker](https://github.com/chaifeng/ufw-docker)-Setups ab, um zu verhindern, dass deine Container versehentlich der Welt ausgesetzt sind.
3. *Arch hat immer die neuesten Updates*: Arch, die zugrunde liegende Distribution, auf der Omarchy aufbaut, ist eine Rolling-Release-Distribution. Das bedeutet, dass jede Sicherheitslücke, die in einem Paket entdeckt und behoben wird, schnell über `omarchy-update` zur Installation verfügbar ist. Auf diese Weise nutzt du immer die neuesten, sichersten Versionen von allem.
4. *Omarchy pflegt eigene Pakete und einen eigenen Mirror*: Omarchy verlässt sich standardmäßig nur auf Pakete aus Archs eigenen core/extra/multilib-Repositories und seinem eigenen Omarchy Package Repository. Du kannst Software direkt aus dem AUR installieren, aber die Basisinstallation tut das nicht — nur wenige optionale Installationen, wie die Browser von Drittanbietern, beziehen aus dem AUR.
5. *Cloudflare schützt uns vor DDoS*: Die Omarchy-Distributionsinfrastruktur — die ISOs, die Omarchy-Pakete, der Arch-Mirror — ist hinter Cloudflares gewaltigem DDoS-Schutzschild geschützt und wird auf deren CDN gehostet. Das sorgt für hervorragende Verfügbarkeit.

## Ändern deiner Passwörter

Du hast bei einer verschlüsselten Installation zwei Passwörter: eines, das die Festplatte beim Booten entsperrt, und eines, mit dem du dich anmeldest und `sudo` verwendest. Die Einrichtung macht sie gleich. Beide können unter _Update > Passwort_ im Omarchy-Menü geändert werden — _Laufwerksverschlüsselung_ für das erste, _Benutzer_ für das zweite. Das Ändern des Festplattenpassworts fragt zuerst nach dem aktuellen, halte es also bereit. Wenn eine Änderung unterbrochen wird, führe _Laufwerksverschlüsselung_ erneut aus: Es fragt nach dem Passwort, das die Festplatte jetzt entsperrt, und schließt die Änderung ab.

## Ein bereits benutztes Gerät weitergeben

Wenn du dein Gerät an jemand anderen übergibst, musst du es nicht neu installieren. Führe _Setup > Computer zurücksetzen_ im Omarchy-Menü aus, tippe `reset` zur Bestätigung ein und starte neu. Das löscht jedes Benutzerkonto und alles in `/home`, verwirft alle Pakete und Systemänderungen, die du seit der Installation vorgenommen hast, und löscht die Identität des Geräts — Netzwerkverbindungen, Hostschlüssel und alles. Was wieder hochfährt, ist der Einrichtungsassistent vom ersten Booten, bereit für seinen neuen Besitzer, seinen eigenen Namen, sein Passwort und sein Verschlüsselungspasswort einzugeben.

Es funktioniert, indem es den Basis-Snapshot wiederherstellt, den der Installer erstellt, daher ist es nur auf Geräten verfügbar, die vom Omarchy ISO installiert wurden. Und auf einer Festplatte ohne Verschlüsselung ist ein Zurücksetzen ein Löschen statt eines sicheren Überschreibens, wenn die Daten also sensibel waren, mache stattdessen eine frische Installation.

## Passwortloses sudo

Manchmal willst du, dass `sudo` aufhört zu fragen, am häufigsten, wenn ein AI-Agent eine lange Strecke Systemarbeit für dich erledigt. _Setup > Sicherheit > Passwortloses Sudo_ fragt, wie lange der Zugriff erlaubt werden soll: **15 Minuten**, **1 Stunde**, **1 Tag** oder **Permanent**. Ein rotes Warnsymbol erscheint neben den anderen Menüleistenanzeigen, solange der Zugriff aktiv ist. Klicke darauf oder führe den Befehl erneut aus, um den Zugriff zu deaktivieren. Du kannst auch deine eigene Anzahl an Minuten (von 1 bis 1440) mit `omarchy-sudo-passwordless 30` übergeben oder `omarchy-sudo-passwordless permanent` verwenden.

Zeitlich begrenzter Zugriff läuft automatisch ab, auch unmittelbar nach dem Aufwecken aus einem Ruhezustand, der die Frist überschritten hat. Ein Neustart des Computers beendet ihn vorzeitig. Permanenter Zugriff übersteht Neustarts und bleibt aktiviert, bis du ihn deaktivierst.

Das Aktualisieren oder Entfernen von Omarchys Einstellungen-Paket beendet jede vorübergehende Freigabe, bevor sich deren Ablaufunterstützung ändert. Wenn der Befehl einen Autorisierungs- oder Bereinigungsfehler meldet, behebe ihn, bevor du versuchst, eine weitere Freigabe zu aktivieren; ein Fehler bedeutet nicht, dass der passwortlose Zugriff inaktiv ist.

Sei dir darüber im Klaren: Solange es aktiviert ist, kann alles, was als dein Benutzer läuft, alles als root tun, ohne gefragt zu werden. Das ist der ganze Sinn, und es ist auch das ganze Risiko.

## Signaturschlüssel

Der öffentliche Schlüssel für alle ISO-Signaturen und Omarchy-Repo-Pakete ist `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([bei openpgp.org verifizieren](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Das Paket `omarchy/omarchy-keyring` enthält diesen ebenfalls und wird verwendet, um mögliche Updates nahtlos auszurollen.

Du findest die Signatur für jedes ISO-Release, indem du `.sig` an dessen URL anhängst, wie `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
