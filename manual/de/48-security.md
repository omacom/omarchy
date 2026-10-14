# Sicherheit

Omarchy nimmt Sicherheit extrem ernst. Das soll ein Betriebssystem sein, mit dem du _echte Arbeit_ in der _echten Welt_ erledigen kannst. Wo ein verlorener Laptop nicht zu einem Sicherheitsnotfall führen kann. Das tun wir also:

1. *Festplattenverschlüsselung ist Pflicht*: Das ist der wichtigste Schritt, um den physischen Schutz deiner Daten zu sichern. Wenn dein Computer verloren geht oder gestohlen wird, sind die Daten vollständig mit Standard-LUKS (Linux Unified Key Setup) verschlüsselt.
2. *Firewall ist standardmäßig aktiviert*: Jeglicher eingehende Verkehr ist standardmäßig blockiert, außer Port 53317 für [LocalSend](https://localsend.org/). Selbst SSH ist ausgeschaltet, bis du es über _Einrichtung > Security > SSHD_ einschaltest, was als Teil der Einrichtung Port 22 öffnet (mit Rate-Limit gegen Brute Force). Wir verriegeln sogar den Docker-Zugriff mit dem [ufw-docker](https://github.com/chaifeng/ufw-docker)-Setup, um zu verhindern, dass deine Container versehentlich der Welt ausgesetzt sind.
3. *Arch hat immer die neuesten Updates*: Arch, die zugrunde liegende Distribution, auf der Omarchy aufbaut, ist eine Rolling Distribution. Das bedeutet, dass jede Sicherheitslücke, die in irgendeinem Paket entdeckt und geschlossen wird, schnell über `omarchy-update` zur Installation verfügbar ist. So fährst du immer die neuesten, sichersten Versionen von allem.
4. *Omarchy pflegt seine eigenen Pakete und seinen eigenen Mirror*: Omarchy verlässt sich standardmäßig nur auf Pakete aus Archs eigenen Repositories core/extra/multilib und seinem eigenen Omarchy Package Repository. Du kannst Software direkt aus dem AUR installieren, aber die Basisinstallation tut es nicht — nur wenige optionale Installationen, wie die Browser von Drittanbietern, ziehen aus dem AUR.
5. *Cloudflare schützt uns vor DDoS*: Die gesamte Omarchy-Vertriebsinfrastruktur — die ISOs, die Omarchy-Pakete, der Arch-Mirror — ist hinter Cloudflares beeindruckendem DDoS-Schutz geschützt und auf ihrer CDN gehostet. Das bietet hervorragende Verfügbarkeit.

## Deine Passwörter ändern

Auf einer verschlüsselten Installation hast du zwei Passwörter: das eine, das beim Booten das Laufwerk entsperrt, und das, mit dem du dich anmeldest und `sudo` nutzt. Die Einrichtung macht sie gleich. Beide kannst du im Omarchy-Menü unter _Aktualisieren > Password_ ändern — _Drive Encryption_ für das erste, _User_ für das zweite. Beim Ändern des Laufwerkspassworts wird zuerst das aktuelle verlangt, halte es also bereit. Wenn eine Änderung unterbrochen wird, starte _Drive Encryption_ erneut: Es fragt nach dem Passwort, das das Laufwerk jetzt entsperrt, und beendet die Änderung.

## Einen bereits genutzten Rechner weitergeben

Wenn du deinen Rechner an jemanden anderen weitergibst, musst du ihn nicht neu installieren. Starte _Einrichtung > Reset Computer_ im Omarchy-Menü, tippe zur Bestätigung `reset` und starte neu. Das löscht jedes Benutzerkonto und alles in `/home`, wirft alle Pakete und Systemänderungen weg, die du seit der Installation gemacht hast, und löscht die Identität des Rechners — Netzwerkverbindungen, Host-Schlüssel und alles. Was wieder hochfährt, ist der Einrichtungsassistent vom ersten Boot, bereit für seinen neuen Besitzer, seinen eigenen Namen, sein Passwort und sein Verschlüsselungspasswort einzugeben.

Das funktioniert, indem der Basis-Snapshot wiederhergestellt wird, den der Installer anlegt, sodass es nur auf Rechnern verfügbar ist, die von der Omarchy-ISO installiert wurden. Und auf einem Laufwerk ohne Verschlüsselung ist ein Zurücksetzen ein Löschen statt einer sicheren Löschung. Wenn die Daten also empfindlich waren, mache stattdessen eine frische Installation.

## Passwortloses sudo

Manchmal willst du, dass `sudo` aufhört zu fragen, meist wenn ein KI-Agent eine lange Strecke Systemarbeit für dich erledigt. _Einrichtung > Security > Passwordless Sudo_ fragt, wie lange der Zugriff erlaubt sein soll: **15 minutes**, **1 Hour**, **1 Day** oder **Permanently**. Neben den anderen Anzeigen der Menüleiste erscheint ein rotes Warnsymbol, solange der Zugriff aktiv ist. Klicke es an oder führe den Befehl erneut aus, um den Zugriff auszuschalten. Du kannst auch deine eigene Minutenzahl (von 1 bis 1440) mit `omarchy-sudo-passwordless 30` übergeben oder `omarchy-sudo-passwordless permanent` nutzen.

Zeitlich begrenzter Zugriff läuft automatisch aus, auch sofort nach dem Aufwachen aus einem Standby, der die Frist überschritten hat. Ein Neustart des Computers beendet ihn frühzeitig. Dauerhafter Zugriff übersteht Neustarts und bleibt aktiviert, bis du ihn deaktivierst.

Das Aktualisieren oder Entfernen von Omarchys Settings-Paket beendet jede vorübergehende Freigabe, bevor sich ihre Ablauf-Unterstützung ändert. Wenn der Befehl einen Autorisierungs- oder Aufräumfehler meldet, behebe ihn, bevor du versuchst, eine weitere Freigabe zu aktivieren; ein Fehler bedeutet nicht, dass passwortloser Zugriff inaktiv ist.

Sei dir bei diesem Punkt im Klaren: Solange er aktiv ist, kann alles, was als dein Benutzer läuft, alles als root tun, ohne gefragt zu werden. Das ist der ganze Zweck, und das ist auch das ganze Risiko.

## Signaturschlüssel

Der öffentliche Schlüssel für alle ISO-Signaturen und Omarchy-Repo-Pakete ist `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([überprüfe ihn auf openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Das Paket `omarchy/omarchy-keyring` enthält ihn ebenfalls und wird verwendet, um mögliche Updates nahtlos auszurollen.

Die Signatur für jede ISO-Version findest du, indem du .sig an die URL anhängst. Wie https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
