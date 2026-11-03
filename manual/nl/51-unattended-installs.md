# Installaties zonder toezicht

De Omarchy ISO kan zichzelf installeren zonder dat er iemand achter het toetsenbord zit. Als het installatieprogramma een tweede schijf vindt met het label `cidata` waarop de configuratiebestanden staan, kopieert het die eraf, slaat het de installatiewizard volledig over en start het zelf opnieuw op in het voltooide systeem. Geen speciale ISO-build, geen extra opstartmenu-item — zonder zo'n schijf verandert er niets en krijg je de normale wizard.

Hierdoor is Omarchy uitstekend als basisimage voor wegwerp-ontwikkelomgevingen: maak een VM in Proxmox of met Packer, start hem op, loop weg, log in via SSH. `cidata` is het cloud-init `NoCloud`-label, dus alle gangbare virtualisatietools weten al hoe ze zo'n schijf moeten koppelen.

## De configuratiebestanden

De bestanden zijn precies wat de wizard van het installatieprogramma zelf wegschrijft, dus de makkelijkste manier om een startset te krijgen is één interactieve installatie uitvoeren (in een VM, bijvoorbeeld) en kopiëren wat die naar `/root` heeft geschreven:

| Bestand | Vereist | Doel |
|------|----------|---------|
| `user_configuration.json` | Ja | Schijf, hostnaam, tijdzone, toetsenbord |
| `user_credentials.json` | Ja | Gebruikersnaam en wachtwoordhash |
| `user_encrypt_installation.txt` | Nee | `true` wanneer de configuratie een `disk_encryption`-blok bevat |
| `authorized_keys` | Nee | Publieke SSH-sleutels, één per regel |
| `tailscale_authkey` | Nee | Tailscale-authkey om bij de eerste start lid te worden van je tailnet |

Genereer de wachtwoordhash voor `user_credentials.json` met `openssl passwd -6 "yourpassword"`.

De naam en het e-mailadres voor git-commits maken geen deel uit van de installatie. Stel ze in zodra de machine draait, via SSH bijvoorbeeld, met `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Je kunt ook een leeg bestand met de naam `defer-provisioning` neerzetten in plaats van `user_credentials.json`. Dat voert dezelfde [installatie voorbereiden voor een andere eigenaar](02-getting-started.md) uit die je interactief kunt starten: de machine installeert zonder persoonlijke gegevens, en wie hem als eerste opstart, kiest zijn toetsenbord en maakt zijn gebruiker aan. Dat is de modus voor imaging-rigs, waarbij de schijf helemaal geen inloggegevens van iemand mag bevatten.

## SSH-toegang

Als `authorized_keys` aanwezig is, stelt de installatie de sleutels in als de `~/.ssh/authorized_keys` van de gebruiker, schakelt ze `sshd` in en opent ze de firewall ervoor. (Een standaard Omarchy-installatie levert openssh met de service uitgeschakeld en de poort gesloten, dus een machine zonder toezicht zou anders onbereikbaar zijn.) De installatie voegt alleen je sleutels toe — ze versoepelt geen van de andere authenticatie-instellingen van de SSH-daemon.

Als `tailscale_authkey` aanwezig is, wordt de machine in plaats daarvan bij de eerste start lid van je tailnet: Tailscale wordt geïnstalleerd vanaf de meegeleverde pakketten op de ISO, de firewall staat de tailnet-interface toe, en een achtergrondtaak voert de aanmelding uit zodra de machine echt netwerk heeft, en blijft het proberen tot het lukt. Gebruik een herbruikbare, vooraf geautoriseerde sleutel, zodat één schijfimage veel machines kan bedienen.

## De cidata-schijf bouwen

Elk bestandssysteem met het juiste label werkt. Een kleine ISO is de makkelijke manier:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Koppel hem vervolgens naast de Omarchy ISO aan de VM. Hier is een volledig Proxmox-voorbeeld:

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

De opstartvolgorde zet de schijf bewust op de eerste plaats: de lege schijf valt bij de eerste start door naar de ISO, en daarna start het geïnstalleerde systeem voor altijd vanaf schijf.

## Twee kanttekeningen

Versleutelde installaties zonder toezicht zijn niet volledig zonder toezicht — iemand moet bij de eerste start nog steeds de LUKS-wachtwoordzin typen. En het `disk_encryption`-blok in `user_configuration.json` bevat die wachtwoordzin in platte tekst, dus behandel een cidata-schijf die is gebouwd vanaf een versleutelde installatie als het geheim dat het is.
