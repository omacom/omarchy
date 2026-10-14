# Nenadzorovane namestitve

ISO Omarchy se lahko namesti sam, brez nikogar ob tipkovnici. Če namestitveni program najde drugi pogon z oznako `cidata`, ki nosi njegove konfiguracijske datoteke, jih skopira, v celoti preskoči čarovnika za namestitev in se sam znova zažene v končani sistem. Brez posebne zgradbe ISO, brez dodatnega vnosa zagonskega menija — brez priklopljenega takega pogona se nič ne spremeni in dobite običajnega čarovnika.

Zaradi tega je Omarchy odličen kot osnovna slika za okolja za razvoj za enkratno uporabo: ustvarite VM v Proxmox ali s Packerjem, ga zaženite, odidite, se povežite prek SSH. `cidata` je oznaka `NoCloud` za cloud-init, tako da vsa običajna orodja za virtualizacijo že vedo, kako pritrditi tak pogon.

## Konfiguracijske datoteke

Datoteke so natanko tisto, kar zapiše lastni čarovnik namestitvenega programa, zato je najlažji način za pridobitev začetnega nabora zagnati eno interaktivno namestitev (na primer v VM) in kopirati, kar je zapisal v `/root`:

| Datoteka | Obvezno | Namen |
|------|----------|---------|
| `user_configuration.json` | Da | Disk, ime gostitelja, časovni pas, tipkovnica |
| `user_credentials.json` | Da | Uporabniško ime in zgoščevalna vrednost gesla |
| `user_full_name.txt` | Ne | Polno ime za Git |
| `user_email_address.txt` | Ne | E-poštni naslov za Git |
| `user_encrypt_installation.txt` | Ne | `true`, kadar konfiguracija nosi blok `disk_encryption` |
| `authorized_keys` | Ne | Javni ključi SSH, eden na vrstico |
| `tailscale_authkey` | Ne | Avtorizacijski ključ Tailscale za pridružitev vašemu tailnetu ob prvem zagonu |

Z `openssl passwd -6 "yourpassword"` ustvarite zgoščevalno vrednost gesla za `user_credentials.json`.

Namesto `user_credentials.json` lahko vstavite tudi prazno datoteko z imenom `defer-provisioning`. To zažene isto [namestitev pripravi-za-drugega-lastnika](02-getting-started.md), ki jo lahko sprožite interaktivno: računalnik se namesti brez osebnih podatkov, kdor ga prvi zažene, pa izbere svojo tipkovnico in ustvari svojega uporabnika. To je način za odlagališča slik, kjer pogon sploh ne sme nositi nobenih poverilnic.

## Dostop SSH

Ko je prisoten `authorized_keys`, namestitev nastavi ključe kot uporabnikove `~/.ssh/authorized_keys`, omogoči `sshd` in odpre požarni zid zanj. (Običajna namestitev Omarchy prinaša openssh z onemogočeno storitvijo in zaprtimi vrati, tako da nenadzorovan računalnik sicer ne bi bil dosegljiv.) Namestitev doda samo vaše ključe — ne zrahlja nobenih drugih nastavitev preverjanja pristnosti demona SSH.

Ko je prisoten `tailscale_authkey`, se računalnik ob prvem zagonu namesto tega pridruži vašemu tailnetu: Tailscale se namesti iz priloženih paketov ISO, požarni zid dovoljuje vmesnik tailnet, opravilo v ozadju pa zažene pridružitev takoj, ko ima računalnik dejansko omrežje, pri čemer poskuša znova, dokler ne uspe. Uporabite večkrat uporaben, vnaprej pooblaščen ključ, tako da lahko ena slika pogona služi veliko računalnikom.

## Izdelava pogona cidata

Deluje vsak datotečni sistem s pravilno oznako. Majhen ISO je enostaven način:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Nato ga priklopite na VM poleg ISO-ja Omarchy. Tukaj je celoten primer Proxmox:

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

Zagonski vrstni red namenoma navaja disk najprej: prazen disk ob prvem zagonu nadaljuje z ISO, nameščeni sistem pa se od takrat naprej vedno zažene z diska.

## Dve omejitvi

Šifrirane nenadzorovane namestitve niso popolnoma nenadzorovane — nekdo mora še vedno vnesti geslo LUKS ob prvem zagonu. Blok `disk_encryption` v `user_configuration.json` pa nosi to geslo v navadnem besedilu, zato pogon cidata, zgrajen iz šifrirane namestitve, obravnavajte kot skrivnost, ki to je.
