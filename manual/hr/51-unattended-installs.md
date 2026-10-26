# Instalacije bez nadzora

Omarchy ISO može se instalirati sam, bez ikoga za tipkovnicom. Ako instalacijski program pronađe drugi disk s oznakom `cidata` na kojem se nalaze njegove konfiguracijske datoteke, kopirat će ih, u potpunosti preskočiti čarobnjaka za postavljanje i samostalno se ponovno pokrenuti u dovršeni sustav. Nije potrebna posebna izrada ISO-a niti dodatna stavka u izborniku za pokretanje — ako takav disk nije priključen, ništa se ne mijenja i dobivate uobičajenog čarobnjaka.

Zbog toga je Omarchy izvrstan kao osnovna slika za jednokratna razvojna okruženja: stvorite VM u Proxmoxu ili pomoću Packera, pokrenite ga, odšetajte i povežite se putem SSH-a. `cidata` je cloud-init oznaka `NoCloud`, pa svi uobičajeni alati za virtualizaciju već znaju kako priključiti takav disk.

## Konfiguracijske datoteke

Te su datoteke upravo ono što zapisuje čarobnjak samog instalacijskog programa, pa je najlakši način da dobijete početni skup da jednom pokrenete interaktivnu instalaciju (recimo u VM-u) i kopirate ono što je zapisao u `/root`:

| Datoteka | Obvezno | Svrha |
|------|----------|---------|
| `user_configuration.json` | Da | Disk, hostname, vremenska zona, tipkovnica |
| `user_credentials.json` | Da | Korisničko ime i hash lozinke |
| `user_encrypt_installation.txt` | Ne | `true` kada konfiguracija sadrži blok `disk_encryption` |
| `authorized_keys` | Ne | SSH javni ključevi, jedan po retku |
| `tailscale_authkey` | Ne | Tailscale ključ za autentifikaciju za pridruživanje vašem tailnetu pri prvom pokretanju |

Hash lozinke za `user_credentials.json` generirajte pomoću `openssl passwd -6 "yourpassword"`.

Ime i e-pošta za git commitove nisu dio instalacije. Postavite ih nakon što se računalo pokrene, primjerice putem SSH-a, pomoću `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Možete i umjesto `user_credentials.json` ubaciti praznu datoteku pod nazivom `defer-provisioning`. Time se pokreće ista [instalacija s pripremom za drugog vlasnika](02-getting-started.md) koju možete pokrenuti interaktivno: računalo se instalira bez ikakvih osobnih podataka, a tko god ga prvi pokrene, odabire svoju tipkovnicu i stvara svog korisnika. To je način rada za postrojenja za izradu slika, na kojima disk uopće ne bi trebao nositi ničije vjerodajnice.

## Pristup putem SSH-a

Kada je prisutan `authorized_keys`, instalacija postavlja ključeve kao korisnikov `~/.ssh/authorized_keys`, omogućuje `sshd` i otvara vatrozid za njega. (Uobičajena instalacija Omarchyja isporučuje openssh s onemogućenom uslugom i zatvorenim portom, pa bi računalo bez nadzora inače bilo nedostupno.) Instalacija samo dodaje vaše ključeve — ne olabavljuje nijednu drugu postavku autentifikacije SSH daemona.

Kada je prisutan `tailscale_authkey`, računalo se pri prvom pokretanju umjesto toga pridružuje vašem tailnetu: Tailscale se instalira iz paketa priloženih uz ISO, vatrozid dopušta sučelje tailneta, a pozadinski posao pokreće pridruživanje čim računalo doista dobije mrežu, ponavljajući pokušaje dok ne uspije. Upotrijebite višekratni, unaprijed autorizirani ključ kako bi jedna slika diska mogla poslužiti za mnoga računala.

## Izrada cidata pogona

Bilo koji datotečni sustav s pravom oznakom funkcionirat će. Maleni ISO jednostavan je način:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Zatim ga priključite u VM uz Omarchy ISO. Evo potpunog primjera za Proxmox:

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

Redoslijed pokretanja namjerno prvo navodi disk: prazan disk pri prvom pokretanju propada do ISO-a, a instalirani sustav od tada se uvijek pokreće s diska.

## Dva upozorenja

Šifrirane instalacije bez nadzora nisu u potpunosti bez nadzora — netko ipak mora upisati LUKS lozinku pri prvom pokretanju. A blok `disk_encryption` u `user_configuration.json` tu lozinku nosi u običnom tekstu, pa cidata pogon izrađen na temelju šifrirane instalacije tretirajte kao tajnu, što i jest.
