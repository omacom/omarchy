# Sicherheit

Omarchy nimmt Sicherheit äußerst ernst. Dies soll ein Betriebssystem sein, mit dem du _echte Arbeit_ in der _echten Welt_ erledigen kannst. Bei dem der Verlust eines Laptops nicht zu einem Sicherheitsnotfall führen kann. Das tun wir also:

1. *Vollständige Festplattenverschlüsselung ist standardmäßig aktiviert*: Dies ist der wichtigste Schritt, um deine Daten physisch zu schützen. Wenn dein Computer verloren geht oder gestohlen wird, sind die Daten mit dem Standard LUKS (Linux Unified Key Setup) vollständig verschlüsselt. Im Installer kannst du dich für Wegwerf-Rechner dagegen entscheiden (siehe [Erste Schritte](02-getting-started.md)); eine Installation ohne Verschlüsselung hat diesen Schutz nicht, und jeder, der das Laufwerk in die Hände bekommt, kann es auslesen.
2. *Firewall ist standardmäßig aktiviert*: Jeglicher eingehender Datenverkehr wird standardmäßig blockiert, mit wenigen Ausnahmen: Port 53317 für [LocalSend](https://localsend.org/); DNS-Anfragen an den eigenen Resolver des Computers unter der Docker-Bridge-Adresse (172.17.0.1), akzeptiert aus den privaten Adressbereichen, die Docker seinen Containern zuweist; und Multicast-DNS (Port 5353), wodurch Drucker und andere Geräte in deinem Netzwerk einander finden können und das dort auch den Namen deines Computers bekannt gibt. Darüber hinaus behält die Firewall die Standardfreigaben von UFW für Ping, das Beziehen einer Adresse von deinem Router (DHCP) und UPnP-Discovery bei. Selbst ssh ist deaktiviert, bis du es über _Einrichtung > Sicherheit > SSHD_ aktivierst, wodurch im Rahmen der Einrichtung Port 22 geöffnet wird (gegen Brute-Force ratenbegrenzt). Wir sperren sogar den Docker-Zugriff mithilfe des [ufw-docker](https://github.com/chaifeng/ufw-docker)-Setups ab, um zu verhindern, dass deine Container versehentlich für die Welt freigegeben werden.
3. *Arch hat immer die neuesten Updates*: Arch, die zugrunde liegende Distribution, auf der Omarchy aufbaut, ist eine Rolling Distribution. Das bedeutet, dass jede Sicherheitslücke, die in irgendeinem Paket entdeckt und behoben wird, schnell per `omarchy-update` zur Installation verfügbar ist. So führst du immer die neuesten, sichersten Versionen von allem aus.
4. *Omarchy pflegt seine eigenen Pakete und seinen eigenen Mirror*: Omarchy verlässt sich standardmäßig nur auf Pakete aus Archs eigenen core/extra/multilib-Repositories und seinem eigenen Omarchy Package Repository. Du kannst Software direkt aus dem AUR installieren, aber die Basisinstallation tut das nicht — nur wenige optionale Installationen, wie die Browser von Drittanbietern, ziehen aus dem AUR.
5. *Cloudflare schützt uns vor DDoS*: Die Vertriebsinfrastruktur von Omarchy — die ISOs, die Omarchy-Pakete, der Arch-Mirror — ist hinter Cloudflares gewaltigem DDoS-Schutzschild geschützt und wird auf deren CDN gehostet. Das sorgt für hervorragende Verfügbarkeit.

## Deine Passwörter ändern

Bei einer verschlüsselten Installation hast du zwei Passwörter: eines, das das Laufwerk beim Booten entsperrt, und eines, mit dem du dich anmeldest und `sudo` ausführst. Bei der Einrichtung werden sie gleich gesetzt. Beide lassen sich im Omarchy-Menü unter _Aktualisierung > Passwort_ ändern — _Laufwerksverschlüsselung_ für das erste, _Benutzer_ für das zweite. Beim Ändern des Laufwerkspassworts wirst du zuerst nach dem aktuellen gefragt, halte es also bereit. Wird eine Änderung unterbrochen, führe _Laufwerksverschlüsselung_ erneut aus: Es fragt nach dem Passwort, das das Laufwerk jetzt entsperrt, und schließt die Änderung ab.

## Einen Rechner weitergeben, den du bereits benutzt hast

Wenn du deinen Rechner an jemand anderen weitergibst, musst du ihn nicht neu installieren. Führe im Omarchy-Menü _Entfernen > Factory Reset_ aus, tippe zur Bestätigung `reset` ein und starte neu. Das löscht jedes Benutzerkonto und alles in `/home`, verwirft alle Pakete und Systemänderungen, die du seit der Installation vorgenommen hast, und bereinigt die Identität des Rechners — Netzwerkverbindungen, Host-Schlüssel und alles. Was danach hochfährt, ist der Einrichtungsassistent vom ersten Start, bereit für seinen neuen Besitzer, seinen eigenen Namen, sein Passwort und sein Verschlüsselungspasswort einzugeben.

Es funktioniert, indem es den Baseline-Snapshot wiederherstellt, den der Installer erstellt, daher ist es nur auf Rechnern verfügbar, die von der Omarchy-ISO installiert wurden. Und auf einem Laufwerk ohne Verschlüsselung ist ein Reset ein Löschen und kein sicheres Überschreiben; wenn die Daten also sensibel waren, mache stattdessen eine frische Installation.

## Passwortloses sudo

Manchmal willst du, dass `sudo` aufhört zu fragen, am häufigsten, wenn ein KI-Agent für dich einen langen Abschnitt Systemarbeit erledigt. _Einrichtung > Sicherheit > Passwortloses Sudo_ fragt, wie lange der Zugriff erlaubt werden soll: **15 Minuten**, **1 Stunde**, **1 Tag** oder **Dauerhaft**. Während der Zugriff aktiv ist, erscheint ein rotes Warnsymbol neben den anderen Indikatoren in der Menüleiste. Klicke es an oder führe den Befehl erneut aus, um den Zugriff zu deaktivieren. Du kannst auch deine eigene Anzahl von Minuten (von 1 bis 1440) mit `omarchy-sudo-passwordless 30` übergeben oder `omarchy-sudo-passwordless permanent` verwenden.

Zeitlich begrenzter Zugriff läuft automatisch ab, auch unmittelbar nach dem Aufwachen aus einem Ruhezustand, der über die Frist hinausging. Ein Neustart des Computers beendet ihn vorzeitig. Dauerhafter Zugriff übersteht Neustarts und bleibt aktiviert, bis du ihn deaktivierst.

Das Aktualisieren oder Entfernen von Omarchys Settings-Paket beendet jede temporäre Freigabe, bevor sich deren Unterstützung für den Ablauf ändert. Wenn der Befehl einen Autorisierungs- oder Bereinigungsfehler meldet, behebe ihn, bevor du versuchst, eine weitere Freigabe zu aktivieren; ein Fehler bedeutet nicht, dass der passwortlose Zugriff inaktiv ist.

Sei dir bei dieser Sache im Klaren: Solange sie aktiviert ist, kann alles, was als dein Benutzer läuft, ohne Nachfrage alles als root tun. Das ist der ganze Sinn, und es ist auch das ganze Risiko.

## Signaturschlüssel

Der öffentliche Schlüssel für alle ISO-Signaturen und Omarchy-Repo-Pakete ist `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([bei openpgp.org prüfen](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Das Paket `omarchy/omarchy-keyring` enthält diesen ebenfalls und wird verwendet, um mögliche Updates nahtlos auszurollen.

Du findest die Signatur für jedes ISO-Release, indem du `.sig` an seine URL anhängst, wie bei `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
