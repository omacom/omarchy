# Unbeaufsichtigte Installationen

Die Omarchy-ISO kann sich selbst installieren, ohne dass jemand an der Tastatur sitzt. Findet das Installationsprogramm ein zweites Laufwerk mit der Bezeichnung `cidata`, das seine Konfigurationsdateien enthält, kopiert es sie herunter, überspringt den Einrichtungsassistenten vollständig und startet von selbst neu in das fertige System. Kein spezieller ISO-Build, kein zusätzlicher Eintrag im Boot-Menü — ist kein solches Laufwerk angeschlossen, ändert sich nichts und du bekommst den normalen Assistenten.

Damit eignet sich Omarchy hervorragend als Basis-Image für wegwerfbare Entwicklungsumgebungen: Erstelle eine VM in Proxmox oder mit Packer, starte sie, geh weg, verbinde dich per SSH. `cidata` ist die `NoCloud`-Bezeichnung von cloud-init, sodass alle gängigen Virtualisierungswerkzeuge bereits wissen, wie sie ein solches Laufwerk anhängen.

## Die Konfigurationsdateien

Die Dateien sind genau das, was der eigene Assistent des Installationsprogramms schreibt. Am einfachsten bekommst du also einen Startsatz, indem du eine interaktive Installation durchführst (etwa in einer VM) und kopierst, was sie nach `/root` geschrieben hat:

| Datei | Erforderlich | Zweck |
|------|----------|---------|
| `user_configuration.json` | Ja | Festplatte, Hostname, Zeitzone, Tastatur |
| `user_credentials.json` | Ja | Benutzername und Passwort-Hash |
| `user_encrypt_installation.txt` | Nein | `true`, wenn die Konfiguration einen `disk_encryption`-Block enthält |
| `authorized_keys` | Nein | Öffentliche SSH-Schlüssel, einer pro Zeile |
| `tailscale_authkey` | Nein | Tailscale-Authentifizierungsschlüssel, um beim ersten Start deinem Tailnet beizutreten |

Erzeuge den Passwort-Hash für `user_credentials.json` mit `openssl passwd -6 "yourpassword"`.

Name und E-Mail für Git-Commits sind nicht Teil der Installation. Lege sie fest, sobald die Maschine läuft, zum Beispiel über SSH, mit `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Du kannst auch eine leere Datei namens `defer-provisioning` anstelle von `user_credentials.json` ablegen. Das führt dieselbe [Installation zur Vorbereitung für einen anderen Besitzer](02-getting-started.md) aus, die du auch interaktiv auslösen kannst: Die Maschine wird ohne persönliche Angaben installiert, und wer sie zuerst startet, wählt seine Tastatur und erstellt seinen Benutzer. Das ist der Modus für Imaging-Rigs, bei denen das Laufwerk überhaupt keine Zugangsdaten von irgendwem enthalten sollte.

## SSH-Zugriff

Ist `authorized_keys` vorhanden, richtet die Installation die Schlüssel als `~/.ssh/authorized_keys` des Benutzers ein, aktiviert `sshd` und öffnet die Firewall dafür. (Eine Standardinstallation von Omarchy liefert openssh mit deaktiviertem Dienst und geschlossenem Port aus, sodass eine unbeaufsichtigte Maschine sonst unerreichbar wäre.) Die Installation fügt nur deine Schlüssel hinzu — sie lockert keine der anderen Authentifizierungseinstellungen des SSH-Daemons.

Ist `tailscale_authkey` vorhanden, tritt die Maschine stattdessen beim ersten Start deinem Tailnet bei: Tailscale wird aus den mitgelieferten Paketen der ISO installiert, die Firewall lässt die Tailnet-Schnittstelle zu, und ein Hintergrundjob führt den Beitritt aus, sobald die Maschine tatsächlich Netzwerk hat, und versucht es so lange weiter, bis es klappt. Verwende einen wiederverwendbaren, vorab autorisierten Schlüssel, damit ein einziges Laufwerks-Image für viele Maschinen dienen kann.

## Das cidata-Laufwerk erstellen

Jedes Dateisystem mit der richtigen Bezeichnung funktioniert. Eine winzige ISO ist der einfache Weg:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Hänge sie dann zusammen mit der Omarchy-ISO an die VM an. Hier ist ein vollständiges Proxmox-Beispiel:

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

Die Boot-Reihenfolge führt die Festplatte absichtlich zuerst auf: Die leere Festplatte fällt beim ersten Start auf die ISO durch, und danach startet das installierte System für immer von der Festplatte.

## Zwei Vorbehalte

Verschlüsselte unbeaufsichtigte Installationen sind nicht vollständig unbeaufsichtigt — jemand muss beim ersten Start immer noch die LUKS-Passphrase eingeben. Und der `disk_encryption`-Block in `user_configuration.json` enthält diese Passphrase im Klartext. Behandle ein cidata-Laufwerk, das aus einer verschlüsselten Installation erstellt wurde, also wie das Geheimnis, das es ist.
