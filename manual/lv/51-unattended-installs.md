# Instalēšana bez uzraudzības

Omarchy ISO var instalēt pats sevi bez neviena pie tastatūras. Ja instalētājs atrod otru disku ar marķējumu `cidata`, kurā ir tā konfigurācijas faili, tas tos nokopē, pilnībā izlaiž iestatīšanas vedni un pats pārstartējas gatavajā sistēmā. Nav vajadzīgs īpašs ISO būvējums, nav papildu ieraksta sāknēšanas izvēlnē — ja šāds disks nav pievienots, nekas nemainās un jūs saņemat parasto vedni.

Tas padara Omarchy par lielisku bāzes attēlu vienreizlietojamām izstrādes vidēm: izveidojiet VM Proxmox vidē vai ar Packer, palaidiet to, ejiet prom, pieslēdzieties caur SSH. `cidata` ir cloud-init `NoCloud` marķējums, tāpēc visi izplatītie virtualizācijas rīki jau zina, kā šādu disku pievienot.

## Konfigurācijas faili

Faili ir tieši tie paši, ko raksta paša instalētāja vednis, tāpēc vienkāršākais veids, kā iegūt sākuma komplektu, ir veikt vienu interaktīvu instalēšanu (piemēram, VM) un nokopēt to, ko tas ierakstīja `/root`:

| Fails | Obligāts | Mērķis |
|------|----------|---------|
| `user_configuration.json` | Jā | Disks, resursdatora nosaukums, laika josla, tastatūra |
| `user_credentials.json` | Jā | Lietotājvārds un paroles jaucējvērtība, kā arī LUKS parole šifrētai instalācijai |
| `user_encrypt_installation.txt` | Nē | `true`, ja konfigurācijā ir `disk_encryption` bloks |
| `authorized_keys` | Nē | SSH publiskās atslēgas, pa vienai katrā rindā |
| `tailscale_authkey` | Nē | Tailscale autentifikācijas atslēga, lai pievienotos jūsu tailnet pirmajā sāknēšanas reizē |

Ģenerējiet paroles jaucējvērtību failam `user_credentials.json` ar `openssl passwd -6 "yourpassword"`.

Git apstiprinājumu vārds un e-pasts nav instalācijas daļa. Iestatiet tos, kad iekārta ir darbspējīga, piemēram, caur SSH, ar `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Varat arī `user_credentials.json` vietā ievietot tukšu failu ar nosaukumu `defer-provisioning`. Tas palaiž to pašu [instalāciju, kas sagatavo sistēmu citam īpašniekam](02-getting-started.md), ko varat palaist arī interaktīvi: iekārta tiek instalēta bez personīgiem datiem, un tas, kurš to palaiž pirmais, izvēlas savu tastatūru un izveido savu lietotāju. Tas ir režīms attēlu veidošanas iekārtām, kur diskā vispār nevajadzētu būt neviena akreditācijas datiem.

## SSH piekļuve

Kad ir pieejams `authorized_keys`, instalācija iestata atslēgas kā lietotāja `~/.ssh/authorized_keys`, iespējo `sshd` un atver tam ugunsmūri. (Standarta Omarchy instalācijā openssh ir iekļauts, bet pakalpojums ir atspējots un ports ir aizvērts, tāpēc bez uzraudzības instalēta iekārta citādi būtu nesasniedzama.) Instalācija tikai pievieno jūsu atslēgas — tā nemaina nevienu citu SSH dēmona autentifikācijas iestatījumu.

Kad ir pieejams `tailscale_authkey`, iekārta pirmajā sāknēšanas reizē tā vietā pievienojas jūsu tailnet: Tailscale tiek instalēts no ISO komplektā iekļautajām pakotnēm, ugunsmūris atļauj tailnet saskarni, un fona uzdevums veic pievienošanos, tiklīdz iekārtai faktiski ir tīkls, mēģinot atkārtoti, līdz tas izdodas. Izmantojiet atkārtoti lietojamu, iepriekš autorizētu atslēgu, lai viens diska attēls varētu apkalpot daudzas iekārtas.

## cidata diska izveide

Derēs jebkura failu sistēma ar pareizo marķējumu. Vienkāršākais veids ir mazs ISO:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Pēc tam pievienojiet to VM līdzās Omarchy ISO. Šeit ir pilns Proxmox piemērs:

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

Sāknēšanas secībā disks apzināti ir norādīts pirmais: tukšais disks pirmajā sāknēšanas reizē pāriet uz ISO, un instalētā sistēma pēc tam vienmēr sāknējas no diska.

## Divi brīdinājumi

Šifrētas instalācijas bez uzraudzības nav pilnībā bez uzraudzības — kādam joprojām pirmajā sāknēšanas reizē ir jāievada LUKS parole. Un šī parole atrodas `user_credentials.json` augšējā līmenī kā `encryption_password` — archinstall to nolasa tur, nevis no `disk_encryption` bloka failā `user_configuration.json` — tāpēc uztveriet cidata disku, kas izveidots no šifrētas instalācijas, kā noslēpumu, kas tas arī ir.
