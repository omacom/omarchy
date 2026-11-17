# Nenadzorovane namestitve

ISO Omarchy se lahko namesti sam, brez nikogar za tipkovnico. Če namestitveni program najde drugi pogon z oznako `cidata`, na katerem so njegove konfiguracijske datoteke, jih prekopira, v celoti preskoči čarovnika za nastavitev in se sam znova zažene v dokončani sistem. Brez posebne gradnje ISO, brez dodatnega vnosa v zagonskem meniju — če tak pogon ni priključen, se nič ne spremeni in dobite običajnega čarovnika.

Zaradi tega je Omarchy odličen kot osnovna slika za razvojna okolja za enkratno uporabo: ustvarite VM v Proxmox ali s Packer, ga zaženete, odidete, se povežete prek SSH. `cidata` je oznaka cloud-init `NoCloud`, zato vsa običajna orodja za virtualizacijo tak pogon že znajo priključiti.

## Konfiguracijske datoteke

Datoteke so natanko tiste, ki jih zapiše čarovnik namestitvenega programa, zato je najlažji način za začetni nabor izvesti eno interaktivno namestitev (na primer v VM) in prekopirati, kar je zapisala v `/root`:

| File | Required | Purpose |
|------|----------|---------|
| `user_configuration.json` | Yes | Disk, hostname, timezone, keyboard |
| `user_credentials.json` | Yes | Username and password hash |
| `user_encrypt_installation.txt` | No | `true` when the configuration carries a `disk_encryption` block |
| `authorized_keys` | No | SSH public keys, one per line |
| `tailscale_authkey` | No | Tailscale auth key for joining your tailnet on first boot |

Generate the password hash for `user_credentials.json` with `openssl passwd -6 "yourpassword"`.

Ime in e-pošta za potrditve git nista del namestitve. Nastavite ju, ko je naprava zagnana, na primer prek SSH, z `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Namesto `user_credentials.json` lahko odložite tudi prazno datoteko z imenom `defer-provisioning`. To zažene isto [namestitev s pripravo za drugega lastnika](02-getting-started.md), ki jo lahko sprožite interaktivno: naprava se namesti brez osebnih podatkov, kdor jo prvi zažene, pa izbere svojo tipkovnico in ustvari svojega uporabnika. To je način za delovne postaje za ustvarjanje slik, kjer na pogonu sploh ne sme biti nikogaršnjih poverilnic.

## Dostop prek SSH

Kadar je prisotna datoteka `authorized_keys`, namestitev nastavi ključe kot uporabnikovo datoteko `~/.ssh/authorized_keys`, omogoči `sshd` in zanj odpre požarni zid. (Običajna namestitev Omarchy ima openssh z onemogočeno storitvijo in zaprtimi vrati, zato nenadzorovana naprava sicer ne bi bila dosegljiva.) Namestitev doda samo vaše ključe — ne zrahlja nobene druge nastavitve preverjanja pristnosti demona SSH.

Kadar je prisotna datoteka `tailscale_authkey`, se naprava ob prvem zagonu namesto tega pridruži vašemu omrežju tailnet: Tailscale se namesti iz paketov, priloženih ISO, požarni zid dovoli vmesnik tailnet, opravilo v ozadju pa izvede pridružitev, takoj ko ima naprava dejansko omrežje, in poskuša znova, dokler ne uspe. Uporabite ključ za večkratno uporabo s predhodno odobritvijo, da lahko ena slika pogona služi številnim napravam.

## Izdelava pogona cidata

Deluje kateri koli datotečni sistem s pravo oznako. Majhen ISO je enostavna pot:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Nato ga priključite VM poleg ISO Omarchy. Tukaj je celoten primer za Proxmox:

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

Vrstni red zagona namerno na prvo mesto postavi disk: prazen disk pri prvem zagonu pade naprej na ISO, nameščeni sistem pa se odtlej vedno zažene z diska.

## Dve opozorili

Šifrirane nenadzorovane namestitve niso povsem nenadzorovane — nekdo mora ob prvem zagonu še vedno vtipkati geselno frazo LUKS. In blok `disk_encryption` v `user_configuration.json` to geselno frazo vsebuje v navadnem besedilu, zato pogon cidata, izdelan iz šifrirane namestitve, obravnavajte kot skrivnost, kar tudi je.
