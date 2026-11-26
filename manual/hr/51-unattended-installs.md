# Instalacije bez nadzora

Omarchy ISO može se instalirati sam, bez ikoga za tipkovnicom. Ako instalacijski program pronađe drugi pogon s oznakom `cidata` koji sadrži njegove konfiguracijske datoteke, kopirat će ih, u potpunosti preskočiti čarobnjak za postavljanje i samostalno se ponovno pokrenuti u dovršeni sustav. Nije potrebna posebna ISO izrada ni dodatna stavka u izborniku pokretanja — bez priključenog takvog pogona ništa se ne mijenja i dobivate uobičajeni čarobnjak.

Zbog toga je Omarchy odličan kao osnovna slika za jednokratna razvojna okruženja: stvorite VM u Proxmox ili pomoću Packer, pokrenite ga, odšetajte i povežite se putem SSH. `cidata` je cloud-init oznaka `NoCloud`, pa svi uobičajeni alati za virtualizaciju već znaju kako priključiti takav pogon.

## Konfiguracijske datoteke

Datoteke su upravo one koje zapisuje čarobnjak samog instalacijskog programa, pa je najlakši način da dobijete početni skup pokrenuti jednu interaktivnu instalaciju (u VM-u, recimo) i kopirati ono što je zapisao u `/root`:

| Datoteka | Obvezno | Svrha |
|------|----------|---------|
| `user_configuration.json` | Da | Disk, naziv računala, vremenska zona, tipkovnica |
| `user_credentials.json` | Da | Korisničko ime i hash lozinke te LUKS lozinka za šifriranu instalaciju |
| `user_encrypt_installation.txt` | Ne | `true` kada konfiguracija sadrži blok `disk_encryption` |
| `authorized_keys` | Ne | SSH javni ključevi, jedan po retku |
| `tailscale_authkey` | Ne | Tailscale autorizacijski ključ za pridruživanje vašem tailnetu pri prvom pokretanju |

Generirajte hash lozinke za `user_credentials.json` pomoću `openssl passwd -6 "yourpassword"`.

Ime i e-pošta za git commitove nisu dio instalacije. Postavite ih nakon što se računalo pokrene, primjerice putem SSH, pomoću `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Možete ubaciti i praznu datoteku pod nazivom `defer-provisioning` umjesto `user_credentials.json`. Time se pokreće ista [instalacija s pripremom za drugog vlasnika](02-getting-started.md) koju možete interaktivno pokrenuti: računalo se instalira bez osobnih podataka, a tko ga prvi pokrene, odabire svoju tipkovnicu i stvara svog korisnika. To je način rada za postaje za izradu slika, gdje pogon uopće ne bi trebao sadržavati ničije vjerodajnice.

## SSH pristup

Kada je `authorized_keys` prisutan, instalacija postavlja ključeve kao korisnikovu datoteku `~/.ssh/authorized_keys`, omogućuje `sshd` i otvara vatrozid za njega. (Standardna Omarchy instalacija isporučuje openssh s onemogućenim servisom i zatvorenim portom, pa bi nenadzirano računalo inače bilo nedostupno.) Instalacija samo dodaje vaše ključeve — ne ublažava nijednu drugu postavku autentifikacije SSH demona.

Kada je `tailscale_authkey` prisutan, računalo se umjesto toga pri prvom pokretanju pridružuje vašem tailnetu: Tailscale se instalira iz paketa priloženih uz ISO, vatrozid dopušta sučelje tailneta, a pozadinski zadatak pokreće pridruživanje čim računalo doista dobije mrežu, ponavljajući pokušaje dok ne uspije. Upotrijebite višekratni, unaprijed autorizirani ključ kako bi jedna slika pogona mogla poslužiti za mnoga računala.

## Izrada cidata pogona

Radi svaki datotečni sustav s pravom oznakom. Mali ISO je jednostavan način:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Zatim ga priključite VM-u uz Omarchy ISO. Evo potpunog Proxmox primjera:

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

Redoslijed pokretanja namjerno prvo navodi disk: prazni disk pri prvom pokretanju preskače na ISO, a instalirani sustav od tada se uvijek pokreće s diska.

## Dva upozorenja

Šifrirane instalacije bez nadzora nisu u potpunosti bez nadzora — netko ipak mora upisati LUKS lozinku pri prvom pokretanju. A ta lozinka ide na najvišu razinu datoteke `user_credentials.json` kao `encryption_password` — archinstall je čita ondje, a ne iz bloka `disk_encryption` u datoteci `user_configuration.json` — pa cidata pogon izrađen iz šifrirane instalacije tretirajte kao tajnu, što i jest.
