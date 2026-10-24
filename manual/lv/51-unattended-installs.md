# Bez uzraudzības instalēšanas

Omarchy ISO var instalēties pats, nevienam neesot pie tastatūras. Ja instalētājs atrod otru disku ar etiķeti `cidata`, kas nes tā konfigurācijas failus, tas tos nokopē, pilnībā izlaiž iestatīšanas vedni un pats pārstartējas gatavajā sistēmā. Nekāda īpaša ISO būvējuma, nekāda papildu sāknēšanas izvēlnes ieraksta — bez šāda pievienota diska nekas nemainās, un jūs iegūstat parasto vedni.

Tas Omarchy padara lielisku kā bāzes attēlu vienreizējām izstrādes vidēm: izveidojiet VM Proxmox vai ar Packer, sāknējiet to, aizejiet, pieslēdzieties ar SSH. `cidata` ir cloud-init `NoCloud` etiķete, tāpēc visi parastie virtualizācijas rīki jau zina, kā šādu disku pievienot.

## Konfigurācijas faili

Faili ir tieši tie, ko raksta paša instalētāja vednis, tāpēc vieglākais veids, kā iegūt sākuma komplektu, ir veikt vienu interaktīvu instalēšanu (teiksim, VM) un nokopēt, ko tas ierakstīja mapē `/root`:

| Fails | Obligāts | Nolūks |
|------|----------|---------|
| `user_configuration.json` | Jā | Disks, saimniekdatora nosaukums, laika josla, tastatūra |
| `user_credentials.json` | Jā | Lietotājvārds un paroles jaucējkods |
| `user_full_name.txt` | Nē | Git pilns vārds |
| `user_email_address.txt` | Nē | Git e-pasts |
| `user_encrypt_installation.txt` | Nē | `true`, kad konfigurācija satur `disk_encryption` bloku |
| `authorized_keys` | Nē | SSH publiskās atslēgas, pa vienai rindā |
| `tailscale_authkey` | Nē | Tailscale autorizācijas atslēga, lai pirmajā sāknēšanā pievienotos jūsu tailnet |

Paroles jaucējkodu failam `user_credentials.json` ģenerējiet ar `openssl passwd -6 "yourpassword"`.

Faila `user_credentials.json` vietā varat ielikt arī tukšu failu ar nosaukumu `defer-provisioning`. Tas palaiž to pašu [instalēšanu citam īpašniekam](02-getting-started.md), ko varat izsaukt interaktīvi: iekārta instalējas bez personiskām detaļām, un tas, kurš to sāknē pirmo, izvēlas tastatūru un izveido savu lietotāju. Tas ir režīms attēlošanas iekārtām, kur diskam vispār nevajadzētu nest neviena akreditācijas datus.

## SSH piekļuve

Kad ir `authorized_keys`, instalēšana iestata atslēgas kā lietotāja `~/.ssh/authorized_keys`, iespējo `sshd` un atver tam ugunsmūri. (Standarta Omarchy instalācija piegādā openssh ar atspējotu pakalpojumu un aizvērtu portu, tāpēc bez uzraudzības iekārta citādi būtu nesasniedzama.) Instalēšana tikai pievieno jūsu atslēgas — tā neattaisina nevienu citu SSH dēmona autentifikācijas iestatījumu.

Kad ir `tailscale_authkey`, iekārta tā vietā pirmajā sāknēšanā pievienojas jūsu tailnet: Tailscale tiek instalēta no ISO komplektētajām pakotnēm, ugunsmūris atļauj tailnet saskarni, un fona darbs palaiž pievienošanos, tiklīdz iekārtai patiešām ir tīkls, mēģinot, līdz izdodas. Izmantojiet atkārtoti lietojamu, iepriekš autorizētu atslēgu, lai viens diska attēls varētu kalpot daudzām iekārtām.

## Cidata diska būvēšana

Der jebkura failu sistēma ar pareizo etiķeti. Mazs ISO ir vieglais ceļš:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Pēc tam pievienojiet to VM līdzās Omarchy ISO. Lūk, pilns Proxmox piemērs:

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

Sāknēšanas secība disku apzināti uzskaita pirmo: tukšais disks pirmajā sāknēšanā izkrīt cauri uz ISO, un instalētā sistēma pēc tam vienmēr sāknējas no diska.

## Divi brīdinājumi

Šifrētas bezuzraudzības instalēšanas nav pilnībā bez uzraudzības — kādam pirmajā sāknēšanā joprojām ir jāieraksta LUKS ieejas frāze. Un bloks `disk_encryption` failā `user_configuration.json` šo ieejas frāzi nes atklātā tekstā, tāpēc pret cidata disku, kas būvēts no šifrētas instalēšanas, izturieties kā pret noslēpumu, kāds tas ir.
