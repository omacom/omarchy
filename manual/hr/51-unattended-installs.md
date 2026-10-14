# Instalacije bez nadzora

Omarchy ISO može se sam instalirati bez ikoga za tipkovnicom. Ako instalacijski program pronađe drugi pogon označen `cidata` koji nosi svoje konfiguracijske datoteke, kopira ih, potpuno preskoči čarobnjak za postavljanje i sam se ponovno pokrene u dovršeni sustav. Nema posebne ISO izgradnje, nema dodatne stavke izbornika za pokretanje — bez priključenog takvog pogona ništa se ne mijenja i dobivate uobičajeni čarobnjak.

To Omarchy čini sjajnim kao osnovnu sliku za jednokratna razvojna okruženja: stvorite VM u Proxmoxu ili s Packerom, pokrenite ga, udaljite se, SSH-ajte. `cidata` je cloud-init oznaka `NoCloud`, pa svi uobičajeni alati za virtualizaciju već znaju kako priključiti takav pogon.

## Konfiguracijske datoteke

Datoteke su točno ono što vlastiti čarobnjak instalacijskog programa upisuje, pa je najlakši način za dobivanje početnog skupa pokrenuti jednu interaktivnu instalaciju (u VM-u, recimo) i kopirati što je upisao u `/root`:

| Datoteka | Obavezno | Svrha |
|------|----------|---------|
| `user_configuration.json` | Da | Disk, ime hosta, vremenska zona, tipkovnica |
| `user_credentials.json` | Da | Korisničko ime i hash lozinke |
| `user_full_name.txt` | Ne | Puno ime za Git |
| `user_email_address.txt` | Ne | E-pošta za Git |
| `user_encrypt_installation.txt` | Ne | `true` kad konfiguracija nosi blok `disk_encryption` |
| `authorized_keys` | Ne | SSH javni ključevi, jedan po retku |
| `tailscale_authkey` | Ne | Tailscale autentifikacijski ključ za pridruživanje vašem tailnetu pri prvom pokretanju |

Hash lozinke za `user_credentials.json` generirajte s `openssl passwd -6 "yourpassword"`.

Umjesto `user_credentials.json` također možete ubaciti praznu datoteku nazvanu `defer-provisioning`. Time se pokreće ista [instalacija pripremljena za drugog vlasnika](02-getting-started.md) koju možete pokrenuti interaktivno: računalo se instalira bez osobnih podataka, a tko ga prvi pokrene odabire svoju tipkovnicu i stvara svog korisnika. To je način za postrojenja za snimanje slika, gdje pogon uopće ne bi trebao nositi ničije vjerodajnice.

## SSH pristup

Kad je prisutan `authorized_keys`, instalacija postavlja ključeve kao korisnički `~/.ssh/authorized_keys`, omogućuje `sshd` i otvara vatrozid za njega. (Standardna Omarchy instalacija isporučuje openssh s onemogućenim servisom i zatvorenim priključkom, pa bi računalo bez nadzora inače bilo nedostupno.) Instalacija samo dodaje vaše ključeve — ne olabavljuje nijednu drugu postavku autentifikacije SSH servisa.

Kad je prisutan `tailscale_authkey`, računalo se umjesto toga pridružuje vašem tailnetu pri prvom pokretanju: Tailscale se instalira iz paketa uključenih u ISO, vatrozid dopušta sučelje tailneta, a pozadinski posao pokreće pridruživanje čim računalo zapravo ima mrežu, ponavljajući dok ne uspije. Koristite višekratni, unaprijed odobreni ključ kako bi jedna slika pogona mogla poslužiti mnogim računalima.

## Izrada cidata pogona

Svaki datotečni sustav s pravom oznakom radi. Maleni ISO je jednostavan način:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Zatim ga priključite na VM pored Omarchy ISO-a. Evo potpunog primjera s Proxmoxom:

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

Redoslijed pokretanja namjerno prvo navodi disk: prazan disk propada na ISO pri prvom pokretanju, a instalirani sustav zauvijek nakon toga pokreće se s diska.

## Dva upozorenja

Šifrirane instalacije bez nadzora nisu potpuno bez nadzora — netko i dalje mora upisati LUKS lozinku pri prvom pokretanju. A blok `disk_encryption` u `user_configuration.json` nosi tu lozinku u otvorenom tekstu, pa cidata pogon izgrađen iz šifrirane instalacije tretirajte kao tajnu kakva jest.
