# Sicherheit

Omarchy nimmt Sicherheit extrem ernst. Das soll ein Betriebssystem sein, mit dem du _echte Arbeit_ in der _realen Welt_ erledigen kannst. Wo ein verlorener Laptop nicht zu einem Sicherheitsnotfall führen kann. Das tun wir dafür:

1. *Vollständige Festplattenverschlüsselung ist standardmäßig aktiviert*: Das ist der wichtigste Schritt, um deine Daten physisch zu schützen. Wenn dein Computer verloren geht oder gestohlen wird, sind die Daten mit dem Standard LUKS (Linux Unified Key Setup) vollständig verschlüsselt. Mit dem Installer kannst du dich bei Wegwerf-Rechnern dagegen entscheiden (siehe [Erste Schritte](02-getting-started.md)); eine Installation ohne Verschlüsselung hat keinerlei Schutz dieser Art, und jeder, der das Laufwerk in die Hände bekommt, kann es auslesen.
2. *Firewall ist standardmäßig aktiviert*: Jeglicher eingehender Datenverkehr wird standardmäßig blockiert, mit ein paar Ausnahmen: Port 53317 für [LocalSend](https://localsend.org/); DNS-Anfragen an den eigenen Resolver des Computers an der Docker-Bridge-Adresse (172.17.0.1), akzeptiert aus den privaten Adressbereichen, die Docker seinen Containern zuweist; und Multicast-DNS (Port 5353), das Druckern und anderen Geräten in deinem Netzwerk ermöglicht, sich gegenseitig zu finden, und dort auch den Namen deines Computers bekannt gibt. Darüber hinaus behält die Firewall die Standardfreigaben von UFW für Ping, das Beziehen einer Adresse von deinem Router (DHCP) und UPnP-Erkennung bei. Selbst ssh ist ausgeschaltet, bis du es über _Einrichtung > Sicherheit > SSHD_ einschaltest, wodurch dein SSH-Schlüssel autorisiert, Passwort-Anmeldungen abgeschaltet und erst dann Port 22 geöffnet wird (gegen Brute-Force-Angriffe ratenbegrenzt). Wir schotten sogar den Docker-Zugriff mit dem [ufw-docker](https://github.com/chaifeng/ufw-docker)-Setup ab, damit deine Container nicht versehentlich für die ganze Welt freigegeben werden.
3. *Arch hat immer die neuesten Updates*: Arch, die zugrunde liegende Distro, auf der Omarchy aufbaut, ist eine Rolling Distribution. Das bedeutet, dass jede Sicherheitslücke, die in irgendeinem Paket entdeckt und gepatcht wird, schnell per `omarchy-update` zur Installation verfügbar ist. So führst du immer die neuesten, sichersten Versionen von allem aus.
4. *Omarchy pflegt eigene Pakete und einen eigenen Mirror*: Omarchy setzt standardmäßig nur auf Pakete aus Archs eigenen core/extra/multilib-Repositories (auf ARM-Geräten auf die von Arch Linux ARM, plus Asahi ALARM auf Apple Silicon) und sein eigenes Omarchy Package Repository. Du kannst Software direkt aus dem AUR installieren, die Basisinstallation tut das aber nicht — nur ein paar optionale Installationen, etwa die Browser von Drittanbietern, ziehen aus dem AUR.
5. *Cloudflare schützt uns vor DDoS*: Die Vertriebsinfrastruktur von Omarchy — die ISOs, die Omarchy-Pakete, der Arch-Mirror — ist hinter Cloudflares gewaltigem DDoS-Schutzschild geschützt und auf deren CDN gehostet. Das sorgt für hervorragende Verfügbarkeit.

## Passwörter ändern

Bei einer verschlüsselten Installation hast du zwei Passwörter: eines, das das Laufwerk beim Booten entsperrt, und eines, mit dem du dich anmeldest und `sudo` verwendest. Die Einrichtung legt beide identisch fest. Beide lassen sich im Omarchy-Menü unter _Aktualisierung > Passwort_ ändern — _Laufwerkverschlüsselung_ für das erste, _Benutzer_ für das zweite. Beim Ändern des Laufwerkpassworts wirst du zuerst nach dem aktuellen gefragt, halte es also bereit. Wenn eine Änderung unterbrochen wird, führe _Laufwerkverschlüsselung_ erneut aus: Es fragt nach dem Passwort, das das Laufwerk jetzt entsperrt, und schließt die Änderung ab.

## Ein bereits genutztes Gerät weitergeben

Wenn du dein Gerät an jemand anderen übergibst, musst du es nicht neu installieren. Führe im Omarchy-Menü _Entfernen > Auf Werkseinstellungen zurücksetzen_ aus, tippe zur Bestätigung `reset`, gib bei Aufforderung dein Passwort für die Laufwerkverschlüsselung ein und starte neu. Das löscht jedes Benutzerkonto und alles in `/home`, verwirft alle Pakete und Systemänderungen, die du seit der Installation vorgenommen hast, und bereinigt die Identität des Geräts — Netzwerkverbindungen, Host-Schlüssel, einfach alles. Was danach hochfährt, ist der Einrichtungsassistent vom ersten Boot, bereit für seinen neuen Besitzer, seinen eigenen Namen, sein Passwort und sein Verschlüsselungspasswort einzugeben.

Das funktioniert, indem der Baseline-Snapshot wiederhergestellt wird, den der Installer anlegt, daher ist es nur auf Geräten verfügbar, die von der Omarchy ISO installiert wurden. Und auf einem Laufwerk ohne Verschlüsselung ist ein Zurücksetzen ein Löschen und kein sicheres Überschreiben; wenn die Daten sensibel waren, mache stattdessen eine frische Installation.

## sudo ohne Passwort

Manchmal willst du, dass `sudo` aufhört zu fragen, am häufigsten, wenn ein KI-Agent eine lange Strecke Systemarbeit für dich erledigt. _Einrichtung > Sicherheit > sudo ohne Passwort_ fragt, wie lange der Zugriff erlaubt werden soll: **15 Minuten**, **1 Stunde**, **1 Tag** oder **Dauerhaft**. Während der Zugriff aktiv ist, erscheint ein rotes Warnsymbol neben den anderen Anzeigen in der Menüleiste. Klicke darauf oder führe den Befehl erneut aus, um den Zugriff abzuschalten. Du kannst mit `omarchy-sudo-passwordless 30` auch deine eigene Anzahl Minuten (von 1 bis 1440) übergeben oder `omarchy-sudo-passwordless permanent` verwenden.

Zeitlich begrenzter Zugriff läuft automatisch ab, auch unmittelbar nach dem Aufwachen aus einem Ruhezustand, der über die Frist hinausging. Ein Neustart des Computers beendet ihn vorzeitig. Dauerhafter Zugriff übersteht Neustarts und bleibt aktiviert, bis du ihn deaktivierst.

Das Aktualisieren oder Entfernen von Omarchys Einstellungspaket beendet jede temporäre Freigabe, bevor sich deren Ablaufunterstützung ändert. Wenn der Befehl einen Autorisierungs- oder Bereinigungsfehler meldet, behebe ihn, bevor du versuchst, eine weitere Freigabe zu aktivieren; ein Fehler bedeutet nicht, dass der passwortlose Zugriff inaktiv ist.

Sei dir bei dieser Sache im Klaren: Solange sie eingeschaltet ist, kann alles, was unter deinem Benutzer läuft, ohne Nachfrage alles als root tun. Das ist der ganze Sinn, und es ist auch das ganze Risiko.

## Signaturschlüssel

Der öffentliche Schlüssel für alle ISO-Signaturen und Omarchy-Repo-Pakete ist `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([prüfe ihn auf openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Das Paket `omarchy/omarchy-keyring` enthält ihn ebenfalls und wird verwendet, um alle möglichen Updates nahtlos auszurollen.

Du findest die Signatur für jede ISO-Veröffentlichung, indem du `.sig` an ihre URL anhängst, etwa `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
