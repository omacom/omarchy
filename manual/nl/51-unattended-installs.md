# Installaties zonder toezicht

De Omarchy-ISO kan zichzelf installeren zonder dat er iemand achter het toetsenbord zit. Als het installatieprogramma een tweede schijf vindt met het label `cidata` die zijn configuratiebestanden bevat, kopieert het ze eraf, slaat het de installatiewizard volledig over en start het uit zichzelf opnieuw op in het voltooide systeem. Geen speciale ISO-build, geen extra opstartmenu-item — zonder zo'n schijf aangesloten verandert er niets en krijg je de normale wizard.

Hierdoor is Omarchy geweldig als basisimage voor wegwerp-ontwikkelomgevingen: maak een VM in Proxmox of met Packer, start hem op, loop weg, SSH erin. `cidata` is het cloud-init `NoCloud`-label, dus alle gangbare virtualisatietools weten al hoe ze zo'n schijf moeten koppelen.

## De configuratiebestanden

De bestanden zijn precies wat de wizard van het installatieprogramma zelf schrijft, dus de makkelijkste manier om een startset te krijgen is één interactieve installatie uit te voeren (bijvoorbeeld in een VM) en te kopiëren wat hij naar `/root` heeft geschreven:

| Bestand | Vereist | Doel |
|------|----------|---------|
| `user_configuration.json` | Ja | Schijf, hostnaam, tijdzone, toetsenbord |
| `user_credentials.json` | Ja | Gebruikersnaam en wachtwoordhash, en de LUKS-passphrase voor een versleutelde installatie |
| `user_encrypt_installation.txt` | Nee | `true` wanneer de configuratie een `disk_encryption`-blok bevat |
| `authorized_keys` | Nee | Openbare SSH-sleutels, één per regel |
| `tailscale_authkey` | Nee | Tailscale-authkey om bij de eerste start lid te worden van je tailnet |

Genereer de wachtwoordhash voor `user_credentials.json` met `openssl passwd -6 "yourpassword"`.

De naam en het e-mailadres voor git-commits maken geen deel uit van de installatie. Stel ze in zodra de machine draait, bijvoorbeeld via SSH, met `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Je kunt ook een leeg bestand met de naam `defer-provisioning` neerzetten in plaats van `user_credentials.json`. Dat voert dezelfde [installatie die je voorbereidt voor een andere eigenaar](02-getting-started.md) uit die je ook interactief kunt starten: de machine installeert zonder persoonlijke gegevens, en wie haar als eerste opstart, kiest zijn toetsenbord en maakt zijn gebruiker aan. Dat is de modus voor imaging-rigs, waarbij de schijf helemaal niemands inloggegevens zou moeten bevatten.

## SSH-toegang

Wanneer `authorized_keys` aanwezig is, stelt de installatie de sleutels in als de `~/.ssh/authorized_keys` van de gebruiker, schakelt ze `sshd` in en opent ze de firewall ervoor. (Een standaard Omarchy-installatie levert openssh met de service uitgeschakeld en de poort gesloten, dus een machine zonder toezicht zou anders onbereikbaar zijn.) De installatie voegt alleen je sleutels toe — ze versoepelt geen van de andere authenticatie-instellingen van de SSH-daemon.

Wanneer `tailscale_authkey` aanwezig is, wordt de machine in plaats daarvan bij de eerste start lid van je tailnet: Tailscale wordt geïnstalleerd vanaf de meegeleverde pakketten op de ISO, de firewall staat de tailnet-interface toe, en een achtergrondtaak voert het lid worden uit zodra de machine daadwerkelijk netwerk heeft, en blijft het opnieuw proberen tot het lukt. Gebruik een herbruikbare, vooraf geautoriseerde sleutel zodat één schijfimage veel machines kan bedienen.

## De cidata-schijf bouwen

Elk bestandssysteem met het juiste label werkt. Een kleine ISO is de makkelijke manier:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Koppel hem vervolgens aan de VM naast de Omarchy-ISO. Hier is een volledig Proxmox-voorbeeld:

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

De opstartvolgorde zet de schijf expres als eerste: de lege schijf valt bij de eerste start door naar de ISO, en het geïnstalleerde systeem start daarna voor altijd vanaf schijf.

## Twee kanttekeningen

Versleutelde installaties zonder toezicht zijn niet volledig zonder toezicht — iemand moet bij de eerste start nog steeds de LUKS-passphrase typen. En die passphrase komt op het hoogste niveau van `user_credentials.json` als `encryption_password` — archinstall leest hem daar, niet uit het `disk_encryption`-blok in `user_configuration.json` — dus behandel een cidata-schijf die is gebouwd vanaf een versleutelde installatie als het geheim dat het is.
