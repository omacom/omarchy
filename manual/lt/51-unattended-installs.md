# Neprižiūrimas diegimas

Omarchy ISO gali įsidiegti pats, kai nieko nėra prie klaviatūros. Jei diegimo programa randa antrą diską su žyma `cidata`, kuriame yra jos konfigūracijos failai, ji juos nukopijuoja, visiškai praleidžia sąrankos vedlį ir pati perkrauna į parengtą sistemą. Nereikia specialaus ISO kūrimo, nereikia papildomo įkrovos meniu įrašo — kai tokio disko neprijungta, niekas nesikeičia ir gaunate įprastą vedlį.

Dėl to Omarchy puikiai tinka kaip bazinis atvaizdas vienkartinėms kūrimo aplinkoms: sukurkite VM Proxmox arba su Packer, paleiskite ją, nueikite šalin, prisijunkite per SSH. `cidata` yra cloud-init `NoCloud` žyma, todėl visos įprastos virtualizacijos priemonės jau žino, kaip tokį diską prijungti.

## Konfigūracijos failai

Failai yra būtent tai, ką rašo pačios diegimo programos vedlys, todėl lengviausia pradinius failus gauti atlikus vieną interaktyvų diegimą (pavyzdžiui, VM) ir nukopijavus tai, ką ji įrašė į `/root`:

| Failas | Būtinas | Paskirtis |
|------|----------|---------|
| `user_configuration.json` | Taip | Diskas, pagrindinio kompiuterio pavadinimas, laiko juosta, klaviatūra |
| `user_credentials.json` | Taip | Vartotojo vardas ir slaptažodžio maiša bei LUKS slaptafrazė šifruotam diegimui |
| `user_encrypt_installation.txt` | Ne | `true`, kai konfigūracijoje yra `disk_encryption` blokas |
| `authorized_keys` | Ne | SSH viešieji raktai, po vieną eilutėje |
| `tailscale_authkey` | Ne | Tailscale autentifikavimo raktas, skirtas prisijungti prie jūsų tailnet pirmo paleidimo metu |

Slaptažodžio maišą, skirtą `user_credentials.json`, sugeneruokite su `openssl passwd -6 "yourpassword"`.

Vardas ir el. paštas, skirti git įrašams, nėra diegimo dalis. Nustatykite juos, kai kompiuteris jau veiks, pavyzdžiui, per SSH, su `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Vietoj `user_credentials.json` taip pat galite įdėti tuščią failą pavadinimu `defer-provisioning`. Tai paleidžia tą patį [diegimą paruošiant kitam savininkui](02-getting-started.md), kurį galite paleisti interaktyviai: kompiuteris įdiegiamas be jokių asmeninių duomenų, o kas pirmas jį paleidžia, pasirenka klaviatūrą ir susikuria savo vartotoją. Tai režimas atvaizdų kūrimo įrenginiams, kai diske apskritai neturėtų būti jokių prisijungimo duomenų.

## SSH prieiga

Kai yra `authorized_keys`, diegimas nustato raktus kaip vartotojo `~/.ssh/authorized_keys`, įjungia `sshd` ir atveria jam ugniasienę. (Įprastas Omarchy diegimas pateikiamas su openssh, kai paslauga išjungta ir prievadas uždarytas, todėl neprižiūrima mašina kitaip būtų nepasiekiama.) Diegimas tik prideda jūsų raktus — jis nesušvelnina jokių kitų SSH demono autentifikavimo nustatymų.

Kai yra `tailscale_authkey`, mašina pirmo paleidimo metu vietoj to prisijungia prie jūsų tailnet: Tailscale įdiegiama iš ISO pridėtų paketų, ugniasienė leidžia tailnet sąsają, o fone veikianti užduotis atlieka prisijungimą, kai tik mašina iš tikrųjų turi tinklą, ir bando iš naujo, kol pavyksta. Naudokite daugkartinį, iš anksto patvirtintą raktą, kad vienas disko atvaizdas galėtų aptarnauti daug mašinų.

## cidata disko kūrimas

Tiks bet kuri failų sistema su tinkama žyma. Paprasčiausias būdas — mažas ISO:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Tada prijunkite jį prie VM kartu su Omarchy ISO. Štai išsamus Proxmox pavyzdys:

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

Įkrovos tvarkoje diskas tyčia nurodytas pirmas: per pirmą paleidimą tuščias diskas praleidžiamas ir paleidžiamas ISO, o nuo tada įdiegta sistema visada paleidžiama iš disko.

## Du įspėjimai

Šifruoti neprižiūrimi diegimai nėra visiškai neprižiūrimi — per pirmą paleidimą vis tiek kažkas turi įvesti LUKS slaptafrazę. Ir ta slaptafrazė `user_credentials.json` faile nurodoma aukščiausiame lygyje kaip `encryption_password` — archinstall ją skaito iš ten, o ne iš `disk_encryption` bloko faile `user_configuration.json` — todėl cidata diską, sukurtą iš šifruoto diegimo, laikykite tokiu slaptu, koks jis ir yra.
