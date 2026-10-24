# Neprižiūrimi įdiegimai

Omarchy ISO gali pats save įdiegti niekam nebūnant prie klaviatūros. Jei įdiegyklė randa antrą diską, pažymėtą `cidata`, nešantį jos konfigūracijos failus, ji nukopijuoja juos, visiškai praleidžia sąrankos vediklį ir pati perkraunasi į baigtą sistemą. Jokio specialaus ISO build, jokio papildomo įkrovos meniu įrašo — kai tokio disko neprijungta, niekas nesikeičia ir gauni įprastą vediklį.

Dėl to Omarchy puiki kaip bazinis atvaizdas vienkartinėms kūrimo aplinkoms: sukuri VM Proxmox ar su Packer, įkrauni ją, nueini, prisijungi per SSH. `cidata` yra cloud-init `NoCloud` etiketė, todėl visi įprasti virtualizacijos įrankiai jau žino, kaip tokį diską prijungti.

## Konfigūracijos failai

Failai yra tiksliai tai, ką įrašo pati įdiegyklės vediklis, todėl lengviausias būdas gauti pradinį rinkinį yra atlikti vieną interaktyvų įdiegimą (tarkime, VM) ir nukopijuoti tai, ką jis įrašė į `/root`:

| Failas | Privaloma | Paskirtis |
|------|----------|---------|
| `user_configuration.json` | Taip | Diskas, šeimininko pavadinimas, laiko juosta, klaviatūra |
| `user_credentials.json` | Taip | Vartotojo vardas ir slaptažodžio hash |
| `user_full_name.txt` | Ne | Git pilnas vardas |
| `user_email_address.txt` | Ne | Git el. paštas |
| `user_encrypt_installation.txt` | Ne | `true`, kai konfigūracija turi `disk_encryption` bloką |
| `authorized_keys` | Ne | SSH viešieji raktai, po vieną eilutėje |
| `tailscale_authkey` | Ne | Tailscale auth raktas prisijungimui prie tavo tailnet pirmosios įkrovos metu |

Slaptažodžio hash failui `user_credentials.json` sugeneruok su `openssl passwd -6 "yourpassword"`.

Taip pat vietoj `user_credentials.json` gali įmesti tuščią failą pavadinimu `defer-provisioning`. Tai paleidžia tą patį [paruošimo kitam savininkui įdiegimą](02-getting-started.md), kurį gali iškviesti interaktyviai: kompiuteris įsidiegia be asmeninių duomenų, o kas jį įkraus pirmas, išsirenka klaviatūrą ir susikuria vartotoją. Tai režimas atvaizdų kūrimo stendams, kur diskas neturėtų nešti niekieno kredencialų.

## SSH prieiga

Kai yra `authorized_keys`, įdiegimas nustato raktus kaip vartotojo `~/.ssh/authorized_keys`, įjungia `sshd` ir atidaro ugniasienę jam. (Standartinis Omarchy įdiegimas pateikia openssh su išjungta paslauga ir uždarytu prievadu, todėl neprižiūrimas kompiuteris kitaip būtų nepasiekiamas.) Įdiegimas tik prideda tavo raktus — jis neatpalaiduoja jokių kitų SSH demono tapatybės patvirtinimo nuostatų.

Kai yra `tailscale_authkey`, kompiuteris vietoj to pirmosios įkrovos metu prisijungia prie tavo tailnet: Tailscale įdiegiama iš ISO pateiktų paketų, ugniasienė leidžia tailnet sąsają, o foninis darbas paleidžia prisijungimą, kai tik kompiuteris iš tikrųjų turi tinklą, kartodamas, kol pavyksta. Naudok daugkartinį, iš anksto autorizuotą raktą, kad vienas disko atvaizdas galėtų tarnauti daugeliui kompiuterių.

## cidata disko kūrimas

Tinka bet kuri failų sistema su tinkama etikete. Mažas ISO yra lengvas būdas:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Tada prijunk jį prie VM šalia Omarchy ISO. Štai pilnas Proxmox pavyzdys:

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

Įkrovos tvarka diską tyčia išvardija pirmą: tuščias diskas pirmosios įkrovos metu krenta į ISO, o įdiegta sistema nuo tada kraunasi iš disko.

## Dvi išlygos

Užšifruoti neprižiūrimi įdiegimai nėra pilnai neprižiūrimi — kažkas pirmosios įkrovos metu vis tiek turi įvesti LUKS slaptafrazę. O `disk_encryption` blokas faile `user_configuration.json` tą slaptafrazę neša atviru tekstu, todėl cidata diską, sukurtą iš užšifruoto įdiegimo, laikyk tokia paslaptimi, kokia jis yra.
