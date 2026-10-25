# Instalēšana bez uzraudzības

Omarchy ISO var instalēties pats, nevienam nesēžot pie tastatūras. Ja instalētājs atrod otru disku ar nosaukumu `cidata`, kurā ir tā konfigurācijas faili, tas tos nokopē, pilnībā izlaiž iestatīšanas vedni un pats pārstartējas gatavajā sistēmā. Nav vajadzīga īpaša ISO versija, nav vajadzīgs papildu ieraksts palaišanas izvēlnē — ja šāda diska nav, nekas nemainās un jūs saņemat parasto vedni.

Tas padara Omarchy par lielisku bāzes attēlu vienreizlietojamām izstrādes vidēm: izveidojiet VM Proxmox vai ar Packer, palaidiet to, ejiet prom un pieslēdzieties caur SSH. `cidata` ir cloud-init `NoCloud` nosaukums, tāpēc visi izplatītie virtualizācijas rīki jau zina, kā šādu disku pievienot.

## Konfigurācijas faili

Šie faili ir tieši tie paši, ko raksta instalētāja vednis, tāpēc vienkāršākais veids, kā iegūt sākuma kopu, ir veikt vienu interaktīvu instalēšanu (piemēram, VM) un nokopēt to, ko tā ierakstīja `/root`:

| Fails | Obligāts | Nolūks |
|------|----------|---------|
| `user_configuration.json` | Jā | Disks, resursdatora nosaukums, laika josla, tastatūra |
| `user_credentials.json` | Jā | Lietotājvārds un paroles jaucējvērtība |
| `user_encrypt_installation.txt` | Nē | `true`, ja konfigurācijā ir `disk_encryption` bloks |
| `authorized_keys` | Nē | SSH publiskās atslēgas, pa vienai katrā rindā |
| `tailscale_authkey` | Nē | Tailscale autentifikācijas atslēga, lai pirmajā palaišanā pievienotos jūsu tailnet |

Ģenerējiet paroles jaucējvērtību failam `user_credentials.json` ar `openssl passwd -6 "yourpassword"`.

Vārds un e-pasts git komitiem nav instalēšanas daļa. Iestatiet tos, kad ierīce ir darbspējīga, piemēram, caur SSH, ar `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Varat arī `user_credentials.json` vietā ievietot tukšu failu ar nosaukumu `defer-provisioning`. Tas palaiž to pašu [instalēšanu, kas sagatavo ierīci citam īpašniekam](02-getting-started.md), ko varat palaist interaktīvi: ierīce instalējas bez personas datiem, un tas, kurš to palaiž pirmais, izvēlas savu tastatūru un izveido savu lietotāju. Tas ir režīms attēlu veidošanas iekārtām, kur diskā nevajadzētu būt neviena akreditācijas datiem.

## SSH piekļuve

Ja ir `authorized_keys`, instalēšana iestata atslēgas kā lietotāja `~/.ssh/authorized_keys`, iespējo `sshd` un atver tam ugunsmūri. (Standarta Omarchy instalācijā ir openssh ar atspējotu pakalpojumu un aizvērtu portu, tāpēc ierīce bez uzraudzības citādi būtu nesasniedzama.) Instalēšana tikai pievieno jūsu atslēgas — tā nemazina nevienu citu SSH dēmona autentifikācijas iestatījumu.

Ja ir `tailscale_authkey`, ierīce pirmajā palaišanā tā vietā pievienojas jūsu tailnet: Tailscale tiek instalēts no ISO komplektā iekļautajām pakotnēm, ugunsmūris atļauj tailnet saskarni, un fona darbs veic pievienošanos, tiklīdz ierīcei faktiski ir tīkls, mēģinot atkārtoti, līdz tas izdodas. Izmantojiet atkārtoti lietojamu, iepriekš autorizētu atslēgu, lai viens diska attēls varētu apkalpot daudzas ierīces.

## cidata diska izveide

Der jebkura failu sistēma ar pareizo nosaukumu. Neliels ISO ir vienkāršākais veids:

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

Palaišanas secībā disks apzināti ir pirmais: tukšais disks pirmajā palaišanā pāriet uz ISO, un pēc tam instalētā sistēma vienmēr palaižas no diska.

## Divi brīdinājumi

Šifrēta instalēšana bez uzraudzības nav pilnībā bez uzraudzības — kādam pirmajā palaišanā joprojām jāievada LUKS parole. Un `disk_encryption` bloks failā `user_configuration.json` satur šo paroli atklātā tekstā, tāpēc izturieties pret cidata disku, kas izveidots no šifrētas instalēšanas, kā pret noslēpumu, kas tas arī ir.
