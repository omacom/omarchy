# Windows VM

Omarchy bietet eine einfache Möglichkeit, Windows über eine Docker VM auf x86_64-Maschinen auszuführen. Du kannst sie mit _Install > Windows_ aus dem Omarchy-Menü (`Super + Space`) installieren.

Deine Maschine braucht dafür KVM-Virtualisierung, die die meisten haben — aber manchmal ist sie im BIOS ausgeschaltet, und der Installer sagt dir, wenn das der Fall ist. Du wirst auch den Festplattenplatz wollen: was auch immer du Windows gibst, plus etwa 10GB für das Image selbst.

Der Installer fragt, wie viel RAM, wie viele CPU-Kerne und wie viel Festplattenplatz du abgeben willst (64GB oder mehr ist die vernünftige Untergrenze), dann nach einem Windows-Benutzernamen und einem Passwort. Lässt du diese leer, bekommst du `docker` / `admin`. Der Download dauert eine Weile — 10-15 Minuten sind normal — und du kannst den Fortschritt im Browser unter `http://127.0.0.1:8006` verfolgen. Der Browser fragt nach demselben Benutzernamen und Passwort, bevor er die Konsole öffnet.

 ![windows-vm](images/windows-vm.webp)

## Verwendung

Sobald sie installiert ist, starte _Windows_ aus dem App-Launcher. Das startet die VM, falls sie nicht bereits läuft, und verbindet dich über RDP, im Vollbild. Gib ihr bei einem Kaltstart 15-30 Sekunden.

Die RDP-Sitzung überträgt Sound, dein Mikrofon und eine gemeinsame Zwischenablage, sodass das Kopieren von Text zwischen Linux und Windows einfach funktioniert. Die Auflösung folgt deinem Fenster, und Omarchy reicht deine Anzeige-Skalierung hindurch, sodass es auf einem HiDPI-Bildschirm kein verschwommenes Durcheinander ist.

Wenn du das RDP-Fenster schließt, fährt die VM automatisch herunter. Wenn du sie lieber weiterlaufen lassen willst — sagen wir, dort drinnen arbeitet gerade etwas vor sich hin — starte sie stattdessen mit `omarchy windows vm launch --keep-alive`.

Der Rest der Steuerung läuft über denselben Befehl:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Dateien teilen

Das Verzeichnis `~/Windows` in deinem Home-Verzeichnis wird automatisch mit der VM geteilt. Lege dort Dateien ab, wenn du willst, dass sie für Windows zugänglich sind. Die VM hat keinen Zugriff auf irgendeinen anderen Teil deines Dateisystems, sodass du vor allem Fiesen auf der Windows-Seite sicher bist. Ihre eigene virtuelle Festplatte ist unter `~/.windows` verfügbar.

Diese vertrauten Home-Pfade bleiben auf ihren eigenen Dateisystemen. Sie können auch Symlinks zu Verzeichnissen sein, die dir gehören, was nützlich ist, wenn die virtuelle Festplatte auf einem größeren Laufwerk liegt. Der Installer misst den freien Speicherplatz auf dem Dateisystem, das `~/.windows` tatsächlich enthält, nicht unbedingt auf dem Dateisystem, das dein Home-Verzeichnis enthält.

Halte die Festplatten- und die geteilten Pfade als separate, sich nicht überschneidende Verzeichnisse. Beim Entfernen wird das Festplattenverzeichnis absichtlich geleert, das geteilte Verzeichnis aber bleibt erhalten. Unmittelbar vor dem Löschen führt Omarchy eine zeitlich begrenzte Containment-Prüfung durch und weigert sich, irgendetwas zu entfernen, wenn diese Prüfung eine Zeitüberschreitung erreicht oder nicht beweisen kann, dass die beiden Verzeichnisbäume getrennt sind.

Bevor die VM startet, öffnet und pinnt Omarchy diese beiden Verzeichnisse und bind-mountet dann die exakten Verzeichnis-Inodes auf private, benutzerspezifische Anker unterhalb von `/var/lib/omarchy/windows/mounts`. Docker sieht nur diese von root geschützten Anker. Das bewahrt benutzerdefinierte Festplattenorte und verhindert gleichzeitig, dass ein anderer Prozess, der als du läuft, einen geprüften Pfad austauscht, bevor der privilegierte Container ihn übernimmt. Bestehende Festplatten- und geteilte Verzeichnisse werden während der Migration auf den Modus `0700` verschärft, damit andere lokale Konten ihre Inhalte nicht durchsuchen können.

Die Ports der VM sind nur an localhost gebunden, sodass nichts in deinem Netzwerk die Windows-Maschine erreichen kann. Die Webkonsole erfordert außerdem den konfigurierten Windows-Benutzernamen und das Passwort, was verhindert, dass ein anderes lokales Konto die VM über Port 8006 steuern kann.

## Einschränkungen und Lizenzierung

Bei diesem Setup gibt es kein GPU-Passthrough, sodass es nicht für Gaming oder Videobearbeitung geeignet ist. Es ist eine großartige Möglichkeit, Microsoft Office oder was auch immer du unbedingt haben musst auszuführen.

Die installierte Version ist Windows 11 Pro, nicht aktiviert. Du brauchst deinen eigenen Lizenzschlüssel, um die zugangsbeschränkten Funktionen zu nutzen.

Wenn dieser Computer mit Windows ausgeliefert wurde, befindet sich der OEM-Schlüssel auch nach der Installation von Omarchy noch in der Firmware. Gib ihn mit `omarchy windows key` aus. Dieser Schlüssel ist an diese Maschine gebunden — er wird ein auf dieser Hardware neu installiertes Windows aktivieren, aber in der Regel nicht die VM.

Du kannst die Ressourcenzuweisung später ändern, indem du `omarchy windows vm install` in einem Terminal ausführst, was die Konfiguration der VM aus deinen Antworten neu schreibt. Die Compose-Datei selbst befindet sich jetzt unter `/var/lib/omarchy/windows/docker-compose.yml` und gehört root — das ist Absicht, damit ein Prozess, der als du läuft, sie nicht umschreiben und beim privilegierten Hochfahren deine ganze Festplatte in den Container einhängen lassen kann. Wenn du sie von Hand bearbeiten musst (zum Beispiel, um ein USB-Gerät einzuhängen), bearbeite sie mit `sudo` und sieh dir alle Optionen beim [Dockur Windows-Projekt](https://github.com/dockur/windows) an.

Um das Ganze loszuwerden, verwende _Remove > Windows_ aus dem Omarchy-Menü. Das löscht die Festplatte der VM in `~/.windows` und alles, was innerhalb von Windows installiert ist, also kopiere vorher alles, was du brauchst, aus der VM heraus. Dein geteilter Ordner `~/Windows` bleibt unberührt.
