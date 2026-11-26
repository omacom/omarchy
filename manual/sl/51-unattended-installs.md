# Namestitve brez nadzora

ISO Omarchy se lahko namesti sam, brez nikogar za tipkovnico. Če namestitveni program najde drugi pogon z oznako `cidata`, ki vsebuje njegove konfiguracijske datoteke, jih prekopira, v celoti preskoči čarovnika za nastavitev in se sam znova zažene v dokončan sistem. Brez posebne izdelave ISO, brez dodatnega vnosa v zagonskem meniju — če tak pogon ni priklopljen, se nič ne spremeni in dobite običajnega čarovnika.

Zato je Omarchy odličen kot osnovna slika za razvojna okolja za enkratno uporabo: ustvarite VM v Proxmox ali s Packer, ga zaženite, odidite, povežite se prek SSH. `cidata` je oznaka cloud-init `NoCloud`, zato vsa običajna orodja za virtualizacijo že vedo, kako tak pogon priklopiti.

## Konfiguracijske datoteke

Datoteke so natanko tiste, ki jih zapiše čarovnik samega namestitvenega programa, zato je najlažji način, da dobite začetni nabor, ena interaktivna namestitev (na primer v VM) in prekopiranje tega, kar je zapisal v `/root`:

| Datoteka | Obvezna | Namen |
|------|----------|---------|
| `user_configuration.json` | Da | Disk, hostname, timezone, keyboard |
| `user_credentials.json` | Da | Username and password hash, and the LUKS passphrase for an encrypted install |
| `user_encrypt_installation.txt` | Ne | `true` when the configuration carries a `disk_encryption` block |
| `authorized_keys` | Ne | SSH public keys, one per line |
| `tailscale_authkey` | Ne | Tailscale auth key for joining your tailnet on first boot |

Hash gesla za `user_credentials.json` ustvarite z `openssl passwd -6 "yourpassword"`.

Ime in e-pošta za git commits nista del namestitve. Nastavite ju, ko je stroj zagnan, na primer prek SSH, z `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Namesto `user_credentials.json` lahko odložite tudi prazno datoteko z imenom `defer-provisioning`. To zažene isto [namestitev s pripravo za drugega lastnika](02-getting-started.md), ki jo lahko sprožite interaktivno: stroj se namesti brez osebnih podatkov, kdorkoli pa ga prvič zažene, izbere svojo tipkovnico in ustvari svojega uporabnika. To je način za postaje za izdelavo slik, kjer pogon sploh ne sme vsebovati nikogaršnjih poverilnic.

## Dostop prek SSH

Ko je prisotna datoteka `authorized_keys`, namestitev nastavi ključe kot uporabnikovo `~/.ssh/authorized_keys`, omogoči `sshd` in zanj odpre požarni zid. (Običajna namestitev Omarchy vključuje openssh z onemogočeno storitvijo in zaprtimi vrati, zato bi bil stroj brez nadzora sicer nedosegljiv.) Namestitev doda samo vaše ključe — ne zrahlja nobene druge nastavitve preverjanja pristnosti demona SSH.

Ko je prisotna datoteka `tailscale_authkey`, se stroj ob prvem zagonu namesto tega pridruži vašemu tailnet: Tailscale je nameščen iz paketov, priloženih ISO, požarni zid dovoli vmesnik tailnet, opravilo v ozadju pa izvede pridružitev, takoj ko ima stroj dejansko omrežno povezavo, in poskuša znova, dokler ne uspe. Uporabite ključ za večkratno uporabo s predhodno avtorizacijo, da lahko ena slika pogona služi številnim strojem.

## Izdelava pogona cidata

Deluje kateri koli datotečni sistem s pravo oznako. Majhen ISO je najlažja pot:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Nato ga priklopite na VM poleg ISO Omarchy. Tukaj je celoten primer za Proxmox:

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

Vrstni red zagona namenoma najprej navaja disk: prazen disk ob prvem zagonu pade na ISO, nameščen sistem pa se odtlej vedno zažene z diska.

## Dve opozorili

Šifrirane namestitve brez nadzora niso povsem brez nadzora — nekdo mora ob prvem zagonu še vedno vtipkati geslo LUKS. To geslo pa gre na najvišjo raven `user_credentials.json` kot `encryption_password` — archinstall ga bere tam, ne iz bloka `disk_encryption` v `user_configuration.json` — zato pogon cidata, izdelan iz šifrirane namestitve, obravnavajte kot skrivnost, ki to tudi je.
