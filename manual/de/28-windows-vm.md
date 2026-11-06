# Windows-VM

Omarchy bietet einen einfachen Weg, Windows über eine Docker-VM auszuführen. Du kannst sie im Omarchy-Menü (`Super + Space`) über _Installieren > Windows_ installieren.

Dein Rechner braucht dafür KVM-Virtualisierung, was die meisten haben — aber manchmal ist sie im BIOS ausgeschaltet, und der Installer wird dir das sagen, falls das der Fall ist. Du brauchst auch den Speicherplatz: was immer du Windows gibst, plus etwa 10GB für das Image selbst.

Der Installer fragt, wie viel RAM, wie viele CPU-Kerne und wie viel Plattenplatz übergeben werden sollen (64GB oder mehr ist die sinnvolle Untergrenze), dann nach einem Windows-Benutzernamen und -Passwort. Lass diese leer, und du erhältst `docker` / `admin`. Der Download dauert eine Weile — 10-15 Minuten sind normal — und du kannst den Fortschritt im Browser verfolgen: `http://127.0.0.1:8006`. Der Browser fragt nach demselben Benutzernamen und Passwort, bevor er die Konsole öffnet.

 ![windows-vm](images/windows-vm.webp)

## Sie benutzen

Sobald sie installiert ist, starte _Windows_ aus dem App-Launcher. Das startet die VM, falls sie nicht schon läuft, und verbindet dich per RDP im Vollbild. Gib ihr beim Kaltstart 15-30 Sekunden.

Die RDP-Sitzung überträgt Ton, dein Mikrofon und eine gemeinsame Zwischenablage, sodass das Kopieren von Text zwischen Linux und Windows einfach funktioniert. Die Auflösung folgt deinem Fenster, und Omarchy reicht deine Display-Skalierung durch, sodass es auf einem HiDPI-Bildschirm kein verschwommener Brei ist.

Wenn du das RDP-Fenster schließt, fährt die VM automatisch herunter. Wenn du sie lieber laufen lassen möchtest — sagen wir, du hast dort etwas am Arbeiten — starte sie stattdessen mit `omarchy windows vm launch --keep-alive`.

Der Rest der Steuerung steht auf demselben Befehl:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Dateien teilen

Das Verzeichnis `~/Windows` in deinem Home-Verzeichnis wird automatisch mit der VM geteilt. Lege Dateien dort ab, wenn sie für Windows zugänglich sein sollen. Die VM hat keinen Zugriff auf irgendeinen anderen Teil deines Dateisystems, sodass du vor allem Bösen auf der Windows-Seite sicher bist. Ihre eigene virtuelle Platte ist unter `~/.windows` verfügbar.

Diese vertrauten Home-Pfade bleiben auf ihren eigenen Dateisystemen. Sie können auch Symlinks auf Verzeichnisse sein, die dir gehören, was nützlich ist, wenn die virtuelle Platte auf einem größeren Laufwerk liegt. Der Installer misst den freien Platz auf dem Dateisystem, das tatsächlich `~/.windows` enthält, nicht unbedingt auf dem Dateisystem, das dein Home-Verzeichnis enthält.

Halte die Pfade für Platte und Freigabe als getrennte, sich nicht überlappende Verzeichnisse. Das Entfernen leert bewusst das Plattenverzeichnis, bewahrt aber das Freigabeverzeichnis. Unmittelbar vor dem Löschen führt Omarchy eine begrenzte Enthaltungsprüfung durch und weigert sich, irgendetwas zu entfernen, wenn diese Prüfung eine Zeitüberschreitung hat oder nicht beweisen kann, dass die beiden Bäume getrennt sind.

Bevor die VM startet, öffnet Omarchy diese beiden Verzeichnisse und pinnt sie, und bind-mountet dann die exakten Verzeichnis-Inodes auf private benutzerspezifische Anker unter `/var/lib/omarchy/windows/mounts`. Docker sieht nur diese root-geschützten Anker. Das bewahrt benutzerdefinierte Plattenorte und verhindert zugleich, dass ein anderer Prozess, der unter deinem Benutzer läuft, einen geprüften Pfad austauscht, bevor der privilegierte Container ihn verbraucht. Bestehende Platten- und Freigabeverzeichnisse werden während der Migration auf den Modus `0700` verschärft, damit andere lokale Konten ihre Inhalte nicht durchstöbern können.

Die Ports der VM sind nur an localhost gebunden, sodass nichts in deinem Netzwerk den Windows-Rechner erreichen kann. Die Web-Konsole erfordert außerdem den konfigurierten Windows-Benutzernamen und das Passwort, was verhindert, dass ein anderes lokales Konto die VM über Port 8006 steuert.

## Grenzen und Lizenzierung

Bei dieser Einrichtung gibt es kein GPU-Passthrough, sodass sie für Gaming oder Videobearbeitung nicht geeignet ist. Sie ist ein großartiger Weg, um Microsoft Office oder was auch immer sonst du unbedingt brauchst auszuführen.

Die installierte Version ist Windows 11 Pro, nicht aktiviert. Du brauchst deinen eigenen Lizenzschlüssel, um die gesperrten Funktionen zu nutzen.

Wenn dieser Computer mit Windows ausgeliefert wurde, ist der OEM-Schlüssel auch nach der Installation von Omarchy noch in der Firmware. Gib ihn mit `omarchy windows key` aus. Dieser Schlüssel ist an diesen Rechner gebunden — er aktiviert ein auf dieser Hardware neu installiertes Windows, aktiviert aber in der Regel nicht die VM.

Du kannst die Ressourcenzuteilung später ändern, indem du `omarchy-windows-vm install` erneut ausführst, was die Konfiguration der VM aus deinen Antworten neu schreibt. Die Compose-Datei selbst lebt jetzt unter `/var/lib/omarchy/windows/docker-compose.yml` und gehört root — das ist Absicht, damit ein Prozess, der unter deinem Benutzer läuft, sie nicht umschreiben und die privilegierte Inbetriebnahme deine ganze Platte in den Container einhängen lassen kann. Wenn du sie von Hand bearbeiten musst (zum Beispiel um ein USB-Gerät einzuhängen), bearbeite sie mit `sudo` und sieh dir alle Optionen im [Dockur-Windows-Projekt](https://github.com/dockur/windows) an.

Um das Ganze loszuwerden, verwende _Entfernen > Windows_ aus dem Omarchy-Menü. Das löscht die Platte der VM und alle ihre Daten, also stelle sicher, dass alles, was dir wichtig ist, zuerst aus `~/Windows` heraus ist.
