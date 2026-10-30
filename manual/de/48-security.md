# Sicherheit

Omarchy nimmt Sicherheit extrem ernst. Dies soll ein Betriebssystem sein, das du für _echte Arbeit_ in der _echten Welt_ verwenden kannst. Eines, bei dem der Verlust eines Laptops nicht zu einem Sicherheitsnotfall führen kann. Das tun wir also dafür:

1. *Vollständige Festplattenverschlüsselung ist Pflicht*: Dies ist der wichtigste Schritt, um deine Daten physisch zu schützen. Wenn dein Computer verloren geht oder gestohlen wird, sind die Daten mit dem Standard LUKS (Linux Unified Key Setup) vollständig verschlüsselt.
2. *Firewall ist standardmäßig aktiviert*: Der gesamte eingehende Datenverkehr wird standardmäßig blockiert, mit Ausnahme von Port 53317 für [LocalSend](https://localsend.org/). Selbst ssh ist deaktiviert, bis du es über _Setup > Security > SSHD_ aktivierst, wodurch im Rahmen der Einrichtung Port 22 geöffnet wird (mit Ratenbegrenzung gegen Brute-Force-Angriffe). Wir schränken sogar den Docker-Zugriff mit dem [ufw-docker](https://github.com/chaifeng/ufw-docker)-Setup ein, um zu verhindern, dass deine Container versehentlich der Welt ausgesetzt werden.
3. *Arch hat immer die neuesten Updates*: Arch, die zugrunde liegende Distribution, auf der Omarchy basiert, ist eine Rolling Distribution. Das bedeutet, dass jede Sicherheitslücke, die in einem Paket entdeckt und behoben wird, schnell per `omarchy-update` zur Installation verfügbar ist. Auf diese Weise verwendest du immer die neuesten, sichersten Versionen von allem.
4. *Omarchy pflegt seine eigenen Pakete und Mirror*: Omarchy setzt standardmäßig nur auf Pakete aus den Arch-eigenen Repositories core/extra/multilib und aus seinem eigenen Omarchy Package Repository. Du kannst Software direkt aus dem AUR installieren, aber die Basisinstallation tut das nicht — nur wenige optionale Installationen, wie die Browser von Drittanbietern, stammen aus dem AUR.
5. *Cloudflare schützt uns vor DDoS*: Die Verteilungsinfrastruktur von Omarchy — die ISOs, die Omarchy-Pakete und der Arch-Mirror — ist hinter Cloudflares gewaltigem DDoS-Schutzschild geschützt und wird auf dessen CDN gehostet. Das sorgt für hervorragende Verfügbarkeit.

## Deine Passwörter ändern

Bei einer verschlüsselten Installation hast du zwei Passwörter: eines, das beim Booten das Laufwerk entsperrt, und eines, mit dem du dich anmeldest und `sudo` verwendest. Die Einrichtung macht beide gleich. Beide können im Omarchy-Menü unter _Update > Password_ geändert werden — _Drive Encryption_ für das erste und _User_ für das zweite. Beim Ändern des Laufwerkspassworts wird zuerst das aktuelle Passwort abgefragt, halte es also bereit. Falls eine Änderung unterbrochen wird, führe _Drive Encryption_ erneut aus: Es fragt nach dem Passwort, das das Laufwerk jetzt entsperrt, und schließt die Änderung ab.

## Einen Rechner weitergeben, den du bereits benutzt hast

Wenn du deinen Rechner an jemand anderen weitergibst, musst du ihn nicht neu installieren. Führe im Omarchy-Menü _Setup > Reset Computer_ aus, tippe zur Bestätigung `reset` ein und starte neu. Dadurch werden jedes Benutzerkonto und alles unter `/home` gelöscht, alle Pakete und Systemänderungen verworfen, die du seit der Installation vorgenommen hast, und die Identität des Rechners bereinigt — Netzwerkverbindungen, Host Keys und alles. Beim nächsten Start erscheint der Einrichtungsassistent vom ersten Boot, bereit für den neuen Besitzer, seinen eigenen Namen, sein Passwort und sein Verschlüsselungspasswort einzugeben.

Das funktioniert, indem der Baseline-Snapshot wiederhergestellt wird, den das Installationsprogramm erstellt, und ist daher nur auf Rechnern verfügbar, die über die Omarchy ISO installiert wurden. Und auf einem Laufwerk ohne Verschlüsselung ist ein Zurücksetzen ein Löschen und keine sichere Löschung. Wenn die Daten sensibel waren, mache stattdessen eine frische Installation.

## Passwortloses sudo

Manchmal möchtest du, dass `sudo` aufhört zu fragen, am häufigsten dann, wenn ein AI-Agent für dich einen langen Abschnitt Systemarbeit erledigt. _Setup > Security > Passwordless Sudo_ fragt, wie lange der Zugriff erlaubt sein soll: **15 Minuten**, **1 Stunde**, **1 Tag** oder **Dauerhaft**. Ein rotes Warnsymbol erscheint neben den anderen Indikatoren der Menüleiste, solange der Zugriff aktiv ist. Klicke darauf oder führe den Befehl erneut aus, um den Zugriff zu deaktivieren. Du kannst mit `omarchy-sudo-passwordless 30` auch deine eigene Anzahl an Minuten (von 1 bis 1440) übergeben oder `omarchy-sudo-passwordless permanent` verwenden.

Ein zeitlich begrenzter Zugriff läuft automatisch ab, auch unmittelbar nach dem Aufwachen aus einem Suspend, der die Frist überschritten hat. Ein Neustart des Computers beendet ihn vorzeitig. Dauerhafter Zugriff übersteht Neustarts und bleibt aktiviert, bis du ihn deaktivierst.

Das Aktualisieren oder Entfernen des Einstellungspakets von Omarchy beendet jede temporäre Freigabe, bevor sich ihre Ablaufunterstützung ändert. Wenn der Befehl einen Autorisierungs- oder Bereinigungsfehler meldet, behebe ihn, bevor du versuchst, eine weitere Freigabe zu aktivieren; ein Fehler bedeutet nicht, dass der passwortlose Zugriff inaktiv ist.

Mache dir bei dieser Sache nichts vor: Solange sie aktiviert ist, kann alles, was unter deinem Benutzer läuft, ohne zu fragen alles als root ausführen. Das ist der ganze Sinn dahinter, und es ist auch das ganze Risiko.

## Signaturschlüssel

Der öffentliche Schlüssel für alle ISO-Signaturen und das Omarchy-Repo-Paket lautet `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([auf openpgp.org überprüfen](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Das Paket `omarchy/omarchy-keyring` enthält diesen ebenfalls und wird verwendet, um mögliche Updates nahtlos auszurollen.

Du findest die Signatur für jede ISO-Version, indem du `.sig` an ihre URL anhängst, wie bei `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
