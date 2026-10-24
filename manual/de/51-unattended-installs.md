# Unbeaufsichtigte Installationen

Die Omarchy-ISO kann sich installieren, ohne dass jemand an der Tastatur sitzt. Wenn der Installer ein zweites Laufwerk mit der Bezeichnung `cidata` findet, das seine Konfigurationsdateien trägt, kopiert er sie herunter, überspringt den Einrichtungsassistenten vollständig und startet von selbst in das fertige System neu. Kein spezieller ISO-Build, kein extra Boot-Menü-Eintrag — ohne so ein Laufwerk ändert sich nichts, und du bekommst den normalen Assistenten.

Das macht Omarchy ideal als Basis-Image für wegwerfbare Entwicklungsumgebungen: eine VM in Proxmox oder mit Packer erstellen, booten, weggehen, per SSH einloggen. `cidata` ist die cloud-init-Bezeichnung `NoCloud`, sodass alle üblichen Virtualisierungstools bereits wissen, wie man so ein Laufwerk anhängt.

## Die Konfigurationsdateien

Die Dateien sind genau das, was der Assistent des Installers selbst schreibt. Der einfachste Weg zu einem Ausgangssatz ist also, eine interaktive Installation durchzuführen (zum Beispiel in einer VM) und zu kopieren, was er nach `/root` geschrieben hat:

| Datei | Erforderlich | Zweck |
|------|----------|---------|
| `user_configuration.json` | Ja | Platte, Hostname, Zeitzone, Tastatur |
| `user_credentials.json` | Ja | Benutzername und Passwort-Hash |
| `user_full_name.txt` | Nein | Vollständiger Name für Git |
| `user_email_address.txt` | Nein | E-Mail für Git |
| `user_encrypt_installation.txt` | Nein | `true`, wenn die Konfiguration einen `disk_encryption`-Block trägt |
| `authorized_keys` | Nein | Öffentliche SSH-Schlüssel, einer pro Zeile |
| `tailscale_authkey` | Nein | Tailscale-Auth-Schlüssel, um beim ersten Boot deinem Tailnet beizutreten |

Den Passwort-Hash für `user_credentials.json` erzeugst du mit `openssl passwd -6 "yourpassword"`.

Du kannst auch eine leere Datei namens `defer-provisioning` statt `user_credentials.json` einlegen. Das führt dieselbe [prepare-for-another-owner Installation](02-getting-started.md) aus, die du auch interaktiv auslösen kannst: Der Rechner installiert ohne persönliche Angaben, und wer ihn zuerst bootet, wählt seine Tastatur und erstellt seinen Benutzer. Das ist der Modus für Imaging-Systeme, bei denen das Laufwerk niemandes Zugangsdaten tragen sollte.

## SSH-Zugriff

Wenn `authorized_keys` vorhanden ist, richtet die Installation die Schlüssel als `~/.ssh/authorized_keys` des Benutzers ein, aktiviert `sshd` und öffnet die Firewall dafür. (Eine Standard-Omarchy-Installation liefert openssh mit deaktiviertem Dienst und geschlossenem Port, sodass ein unbeaufsichtigter Rechner sonst unerreichbar wäre.) Die Installation fügt nur deine Schlüssel hinzu — sie lockert keine der anderen Authentifizierungseinstellungen des SSH-Dienstes.

Wenn `tailscale_authkey` vorhanden ist, tritt der Rechner stattdessen beim ersten Boot deinem Tailnet bei: Tailscale wird aus den mitgelieferten Paketen der ISO installiert, die Firewall erlaubt die Tailnet-Schnittstelle, und ein Hintergrundjob führt den Beitritt aus, sobald der Rechner tatsächlich Netzwerk hat, und wiederholt es, bis es gelingt. Verwende einen wiederverwendbaren, vorautorisierten Schlüssel, sodass ein Laufwerks-Image vielen Rechnern dienen kann.

## Das cidata-Laufwerk bauen

Jedes Dateisystem mit der richtigen Bezeichnung funktioniert. Eine winzige ISO ist der einfache Weg:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Dann hängst du es zusammen mit der Omarchy-ISO an die VM an. Hier ist ein vollständiges Proxmox-Beispiel:

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

Die Boot-Reihenfolge listet die Platte absichtlich zuerst: Die leere Platte fällt beim ersten Boot auf die ISO durch, und das installierte System bootet danach immer von der Platte.

## Zwei Vorbehalte

Verschlüsselte unbeaufsichtigte Installationen sind nicht vollständig unbeaufsichtigt — jemand muss beim ersten Boot noch die LUKS-Passphrase eingeben. Und der Block `disk_encryption` in `user_configuration.json` trägt diese Passphrase im Klartext, also behandle ein cidata-Laufwerk, das aus einer verschlüsselten Installation gebaut wurde, als das Geheimnis, das es ist.
