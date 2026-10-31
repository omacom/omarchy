# Diegimas be priežiūros

Omarchy ISO gali įsidiegti pats, niekam nesėdint prie klaviatūros. Jei diegimo programa randa antrą diską su žyma `cidata`, kuriame yra jos konfigūracijos failai, ji juos nukopijuoja, visiškai praleidžia sąrankos vedlį ir pati persikrauna į baigtą sistemą. Jokio specialaus ISO atvaizdo, jokio papildomo įrašo paleidimo meniu — neprijungus tokio disko, niekas nesikeičia ir gaunate įprastą vedlį.

Dėl to Omarchy puikiai tinka kaip bazinis atvaizdas vienkartinėms kūrimo aplinkoms: sukuriate VM Proxmox arba su Packer, paleidžiate ją, nueinate šalin, prisijungiate per SSH. `cidata` yra cloud-init `NoCloud` žyma, todėl visi įprasti virtualizacijos įrankiai jau moka tokį diską prijungti.

## Konfigūracijos failai

Failai yra lygiai tie patys, kuriuos įrašo pačios diegimo programos vedlys, todėl lengviausia pradinį rinkinį gauti atlikus vieną interaktyvų diegimą (pavyzdžiui, VM) ir nukopijavus tai, ką ji įrašė į `/root`:

| Failas | Privalomas | Paskirtis |
|------|----------|---------|
| `user_configuration.json` | Taip | Diskas, kompiuterio pavadinimas, laiko juosta, klaviatūra |
| `user_credentials.json` | Taip | Naudotojo vardas ir slaptažodžio maiša |
| `user_encrypt_installation.txt` | Ne | `true`, kai konfigūracijoje yra `disk_encryption` blokas |
| `authorized_keys` | Ne | SSH viešieji raktai, po vieną eilutėje |
| `tailscale_authkey` | Ne | Tailscale autentifikavimo raktas, skirtas prisijungti prie jūsų tailnet pirmojo paleidimo metu |

Slaptažodžio maišą failui `user_credentials.json` sugeneruokite komanda `openssl passwd -6 "yourpassword"`.

Vardas ir el. paštas git įrašams nėra diegimo dalis. Nustatykite juos, kai kompiuteris jau veiks, pavyzdžiui, per SSH, komanda `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Taip pat galite vietoj `user_credentials.json` įdėti tuščią failą pavadinimu `defer-provisioning`. Tai paleidžia tą patį [diegimą paruošiant kitam savininkui](02-getting-started.md), kurį galite paleisti interaktyviai: kompiuteris įdiegiamas be jokių asmeninių duomenų, o tas, kas jį paleidžia pirmas, pasirenka savo klaviatūrą ir susikuria savo naudotoją. Tai režimas atvaizdų kūrimo stendams, kur diske neturėtų būti apskritai niekieno kredencialų.

## Prieiga per SSH

Kai yra `authorized_keys`, diegimas nustato raktus kaip naudotojo `~/.ssh/authorized_keys`, įjungia `sshd` ir atveria jai ugniasienę. (Standartinis Omarchy diegimas pateikiamas su openssh, kurio tarnyba išjungta, o prievadas uždarytas, todėl be priežiūros diegiamas kompiuteris kitaip būtų nepasiekiamas.) Diegimas tik prideda jūsų raktus — jis nesušvelnina jokių kitų SSH demono autentifikavimo nustatymų.

Kai yra `tailscale_authkey`, kompiuteris pirmojo paleidimo metu vietoj to prisijungia prie jūsų tailnet: Tailscale įdiegiamas iš ISO pateikiamų paketų, ugniasienė leidžia tailnet sąsają, o foninė užduotis atlieka prisijungimą, kai tik kompiuteris faktiškai gauna tinklą, ir kartoja, kol pavyksta. Naudokite daugkartinį, iš anksto autorizuotą raktą, kad vienas disko atvaizdas galėtų aptarnauti daug kompiuterių.

## cidata disko kūrimas

Tinka bet kuri failų sistema su tinkama žyma. Mažas ISO yra lengviausias būdas:

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

Paleidimo tvarkoje diskas sąmoningai nurodytas pirmas: tuščias diskas pirmojo paleidimo metu praleidžiamas ir paleidžiama iš ISO, o įdiegta sistema nuo tol visada paleidžiama iš disko.

## Dvi išlygos

Šifruoti diegimai be priežiūros nėra visiškai be priežiūros — pirmojo paleidimo metu kažkas vis tiek turi įvesti LUKS slaptafrazę. O `disk_encryption` blokas faile `user_configuration.json` saugo tą slaptafrazę atviru tekstu, todėl cidata diską, sukurtą iš šifruoto diegimo, saugokite kaip paslaptį, kokia jis ir yra.
