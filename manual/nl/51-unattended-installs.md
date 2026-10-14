# Onbeheerde installaties

De Omarchy-ISO kan zichzelf installeren met niemand achter het toetsenbord. Als het installatieprogramma een tweede schijf vindt met het label `cidata` die zijn configuratiebestanden draagt, kopieert het ze eraf, slaat het de setupwizard volledig over en herstart het uit zichzelf in het voltooide systeem. Geen speciale ISO-build, geen extra opstartmenu-item — zonder zo'n schijf aangesloten verandert er niets en krijg je de normale wizard.

Dit maakt Omarchy geweldig als basisimage voor wegwerpbare dev-omgevingen: maak een VM in Proxmox of met Packer, start hem op, loop weg, SSH erin. `cidata` is het cloud-init `NoCloud`-label, dus alle gangbare virtualisatietooling weet al hoe zo'n schijf moet worden aangesloten.

## De configuratiebestanden

De bestanden zijn precies wat de wizard van het installatieprogramma zelf schrijft, dus de makkelijkste manier om een startset te krijgen is een interactieve installatie uitvoeren (in een VM, bijvoorbeeld) en kopiëren wat hij in `/root` schreef:

| Bestand | Vereist | Doel |
|------|----------|---------|
| `user_configuration.json` | Ja | Schijf, hostnaam, tijdzone, toetsenbord |
| `user_credentials.json` | Ja | Gebruikersnaam en wachtwoord-hash |
| `user_full_name.txt` | Nee | Volledige naam voor Git |
| `user_email_address.txt` | Nee | E-mailadres voor Git |
| `user_encrypt_installation.txt` | Nee | `true` wanneer de configuratie een `disk_encryption`-blok draagt |
| `authorized_keys` | Nee | Openbare SSH-sleutels, één per regel |
| `tailscale_authkey` | Nee | Tailscale-authsleutel om bij de eerste opstart lid te worden van je tailnet |

Genereer de wachtwoord-hash voor `user_credentials.json` met `openssl passwd -6 "yourpassword"`.

Je kunt ook een leeg bestand met de naam `defer-provisioning` plaatsen in plaats van `user_credentials.json`. Dat voert dezelfde [installatie voorbereiden-voor-een-andere-eigenaar](02-getting-started.md) uit die je interactief kunt activeren: de machine installeert zonder persoonlijke details, en wie hem als eerste opstart kiest zijn toetsenbord en maakt zijn gebruiker aan. Dat is de modus voor imaging-rigs, waarbij de schijf helemaal niemands inloggegevens mag dragen.

## SSH-toegang

Wanneer `authorized_keys` aanwezig is, stelt de installatie de sleutels in als de `~/.ssh/authorized_keys` van de gebruiker, schakelt hij `sshd` in en opent hij de firewall ervoor. (Een standaard Omarchy-installatie levert openssh met de service uitgeschakeld en de poort gesloten, dus een onbeheerde machine zou anders onbereikbaar zijn.) De installatie voegt alleen je sleutels toe — hij versoepelt geen van de andere authenticatie-instellingen van de SSH-daemon.

Wanneer `tailscale_authkey` aanwezig is, voegt de machine zich in plaats daarvan bij de eerste opstart bij je tailnet: Tailscale wordt geïnstalleerd uit de meegeleverde pakketten van de ISO, de firewall staat de tailnet-interface toe, en een achtergrondtaak voert de join uit zodra de machine daadwerkelijk netwerk heeft, en blijft het proberen totdat het lukt. Gebruik een herbruikbare, vooraf geautoriseerde sleutel zodat één schijfimage veel machines kan bedienen.

## De cidata-schijf bouwen

Elk bestandssysteem met het juiste label werkt. Een kleine ISO is de makkelijke manier:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Sluit hem vervolgens aan op de VM naast de Omarchy-ISO. Hier is een volledig Proxmox-voorbeeld:

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

De opstartvolgorde vermeldt de schijf met opzet als eerste: de lege schijf valt door naar de ISO bij de eerste opstart, en het geïnstalleerde systeem start daarna altijd op vanaf de schijf.

## Twee kanttekeningen

Versleutelde onbeheerde installaties zijn niet volledig onbeheerd — iemand moet bij de eerste opstart nog steeds de LUKS-wachtzin typen. En het `disk_encryption`-blok in `user_configuration.json` draagt die wachtzin in platte tekst, dus behandel een cidata-schijf die is gebouwd uit een versleutelde installatie als het geheim dat hij is.
