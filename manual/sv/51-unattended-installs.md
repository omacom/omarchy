# Obevakade installationer

Omarchy-ISO:n kan installera sig själv utan någon vid tangentbordet. Om installationsprogrammet hittar en andra enhet med etiketten `cidata` som innehåller dess konfigurationsfiler kopierar det över dem, hoppar över installationsguiden helt och startar om till det färdiga systemet på egen hand. Ingen särskild ISO-byggnad, ingen extra post i startmenyn — utan en sådan enhet ansluten förändras ingenting och du får den vanliga guiden.

Det gör Omarchy utmärkt som basavbildning för tillfälliga utvecklingsmiljöer: skapa en VM i Proxmox eller med Packer, starta den, gå därifrån, anslut via SSH. `cidata` är cloud-init-etiketten `NoCloud`, så alla vanliga virtualiseringsverktyg vet redan hur man ansluter en sådan enhet.

## Konfigurationsfilerna

Filerna är exakt det som installationsprogrammets egen guide skriver, så det enklaste sättet att få en startuppsättning är att köra en interaktiv installation (till exempel i en VM) och kopiera det den skrev till `/root`:

| Fil | Obligatorisk | Syfte |
|------|----------|---------|
| `user_configuration.json` | Ja | Disk, värdnamn, tidszon, tangentbord |
| `user_credentials.json` | Ja | Användarnamn och lösenordshash |
| `user_encrypt_installation.txt` | Nej | `true` när konfigurationen innehåller ett `disk_encryption`-block |
| `authorized_keys` | Nej | Publika SSH-nycklar, en per rad |
| `tailscale_authkey` | Nej | Tailscale-auth-nyckel för att ansluta till ditt tailnet vid första uppstarten |

Generera lösenordshashen för `user_credentials.json` med `openssl passwd -6 "yourpassword"`.

Namnet och e-postadressen för git-commits ingår inte i installationen. Ställ in dem när maskinen är igång, till exempel via SSH, med `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Du kan också lägga in en tom fil med namnet `defer-provisioning` i stället för `user_credentials.json`. Då körs samma [installation som förbereder för en annan ägare](02-getting-started.md) som du kan starta interaktivt: maskinen installeras utan personuppgifter, och den som startar den först väljer sitt tangentbord och skapar sin användare. Det är läget för avbildningsriggar, där enheten inte ska innehålla någons inloggningsuppgifter alls.

## SSH-åtkomst

När `authorized_keys` finns ställer installationen in nycklarna som användarens `~/.ssh/authorized_keys`, aktiverar `sshd` och öppnar brandväggen för den. (En vanlig Omarchy-installation levereras med openssh med tjänsten inaktiverad och porten stängd, så en obevakad maskin skulle annars vara oåtkomlig.) Installationen lägger bara till dina nycklar — den luckrar inte upp några av SSH-daemonens övriga autentiseringsinställningar.

När `tailscale_authkey` finns ansluter maskinen i stället till ditt tailnet vid första uppstarten: Tailscale installeras från ISO:ns medföljande paket, brandväggen tillåter tailnet-gränssnittet, och ett bakgrundsjobb kör anslutningen så snart maskinen faktiskt har nätverk, med nya försök tills det lyckas. Använd en återanvändbar, förhandsgodkänd nyckel så att en enhetsavbildning kan betjäna många maskiner.

## Bygga cidata-enheten

Vilket filsystem som helst med rätt etikett fungerar. En liten ISO är det enkla sättet:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Anslut den sedan till VM:en tillsammans med Omarchy-ISO:n. Här är ett komplett Proxmox-exempel:

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

Startordningen listar disken först med flit: den tomma disken faller vidare till ISO:n vid första uppstarten, och det installerade systemet startar från disk för all framtid därefter.

## Två förbehåll

Krypterade obevakade installationer är inte helt obevakade — någon måste fortfarande skriva in LUKS-lösenfrasen vid första uppstarten. Och `disk_encryption`-blocket i `user_configuration.json` innehåller den lösenfrasen i klartext, så behandla en cidata-enhet byggd från en krypterad installation som den hemlighet den är.
