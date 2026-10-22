# Oövervakade installationer

Omarchy ISO kan installera sig själv utan någon vid tangentbordet. Om installationsprogrammet hittar en andra enhet märkt `cidata` som bär dess konfigurationsfiler kopierar det av dem, hoppar över installationsguiden helt och startar om in till det färdiga systemet på egen hand. Inget specialbygge av ISO, ingen extra post i startmenyn — utan en sådan enhet ansluten ändras ingenting och du får den normala guiden.

Detta gör Omarchy fantastisk som basbild för engångsmiljöer för utveckling: skapa en VM i Proxmox eller med Packer, starta den, gå därifrån, SSH:a in. `cidata` är cloud-init `NoCloud`-etiketten, så alla vanliga virtualiseringsverktyg vet redan hur man ansluter en sådan enhet.

## Konfigurationsfilerna

Filerna är exakt vad installationsprogrammets egen guide skriver, så det enklaste sättet att få en startuppsättning är att köra en interaktiv installation (i en VM, till exempel) och kopiera det den skrev till `/root`:

| Fil | Krävs | Syfte |
|------|----------|---------|
| `user_configuration.json` | Ja | Disk, värdnamn, tidszon, tangentbord |
| `user_credentials.json` | Ja | Användarnamn och lösenordshash |
| `user_full_name.txt` | Nej | Git fullständigt namn |
| `user_email_address.txt` | Nej | Git e-post |
| `user_encrypt_installation.txt` | Nej | `true` när konfigurationen bär ett `disk_encryption`-block |
| `authorized_keys` | Nej | SSH publika nycklar, en per rad |
| `tailscale_authkey` | Nej | Tailscale auth-nyckel för att ansluta till ditt tailnet vid första uppstart |

Generera lösenordshashen för `user_credentials.json` med `openssl passwd -6 "yourpassword"`.

Du kan också lägga in en tom fil med namnet `defer-provisioning` på platsen för `user_credentials.json`. Det kör samma [installera-för-en-annan-ägare-installation](02-getting-started.md) som du kan utlösa interaktivt: datorn installeras utan personliga uppgifter, och den som startar den först väljer sitt tangentbord och skapar sin användare. Det är läget för avbildningsriggar, där enheten inte bör bära någons uppgifter alls.

## SSH-åtkomst

När `authorized_keys` finns konfigurerar installationen nycklarna som användarens `~/.ssh/authorized_keys`, aktiverar `sshd` och öppnar brandväggen för den. (En standard Omarchy-installation levererar openssh med tjänsten inaktiverad och porten stängd, så en oövervakad dator skulle annars vara oåtkomlig.) Installationen lägger endast till dina nycklar — den lossar inte någon av SSH-demonens andra autentiseringsinställningar.

När `tailscale_authkey` finns ansluter datorn i stället till ditt tailnet vid första uppstart: Tailscale installeras från ISO:s bundlade paket, brandväggen tillåter tailnet-gränssnittet, och ett bakgrundsjobb kör anslutningen så snart datorn faktiskt har nätverk, och försöker igen tills den lyckas. Använd en återanvändbar, förauktoriserad nyckel så att en enhetsbild kan tjäna många datorer.

## Bygga cidata-enheten

Vilket filsystem som helst med rätt etikett fungerar. En liten ISO är det enkla sättet:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Anslut den sedan till VM:en bredvid Omarchy ISO. Här är ett fullständigt Proxmox-exempel:

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

Startordningen listar disken först med flit: den tomma disken faller igenom till ISO vid första start, och det installerade systemet startar från disk för alltid därefter.

## Två förbehåll

Krypterade oövervakade installationer är inte helt oövervakade — någon måste fortfarande skriva LUKS-lösenfrasen vid första uppstarten. Och `disk_encryption`-blocket i `user_configuration.json` bär denna lösenfras i klartext, så behandla en cidata-enhet byggd från en krypterad installation som den hemlighet den är.
