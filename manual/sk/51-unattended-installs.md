# Inštalácie bez obsluhy

ISO Omarchy sa dokáže nainštalovať samo, bez nikoho pri klávesnici. Ak inštalátor nájde druhú jednotku s označením `cidata`, ktorá nesie jeho konfiguračné súbory, skopíruje ich z nej, úplne preskočí sprievodcu nastavením a sám sa reštartuje do hotového systému. Žiadna špeciálna zostava ISO, žiadna extra položka v bootovacom menu — ak taká jednotka nie je pripojená, nič sa nemení a dostanete bežného sprievodcu.

Vďaka tomu je Omarchy skvelé ako základný obraz pre jednorazové vývojové prostredia: vytvorte VM v Proxmox alebo pomocou Packer, spustite ju, odíďte preč, pripojte sa cez SSH. `cidata` je označenie cloud-init `NoCloud`, takže všetky bežné virtualizačné nástroje už vedia, ako takú jednotku pripojiť.

## Konfiguračné súbory

Súbory sú presne tie, ktoré zapisuje vlastný sprievodca inštalátora, takže najjednoduchší spôsob, ako získať počiatočnú sadu, je spustiť jednu interaktívnu inštaláciu (povedzme vo VM) a skopírovať to, čo zapísal do `/root`:

| Súbor | Povinné | Účel |
|------|----------|---------|
| `user_configuration.json` | Áno | Disk, názov hostiteľa, časové pásmo, klávesnica |
| `user_credentials.json` | Áno | Používateľské meno a hash hesla a prístupová fráza LUKS pre šifrovanú inštaláciu |
| `user_encrypt_installation.txt` | Nie | `true`, keď konfigurácia obsahuje blok `disk_encryption` |
| `authorized_keys` | Nie | Verejné kľúče SSH, jeden na riadok |
| `tailscale_authkey` | Nie | Autentizačný kľúč Tailscale na pripojenie k vášmu tailnetu pri prvom spustení |

Hash hesla pre `user_credentials.json` vygenerujte pomocou `openssl passwd -6 "yourpassword"`.

Meno a e-mail pre commity v gite nie sú súčasťou inštalácie. Nastavte ich, keď je počítač spustený, napríklad cez SSH, pomocou `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Namiesto `user_credentials.json` môžete vložiť aj prázdny súbor s názvom `defer-provisioning`. Tým sa spustí rovnaká [inštalácia s prípravou pre iného vlastníka](02-getting-started.md), akú môžete spustiť interaktívne: počítač sa nainštaluje bez osobných údajov a ten, kto ho spustí ako prvý, si vyberie klávesnicu a vytvorí svojho používateľa. To je režim pre pracoviská na prípravu obrazov diskov, kde jednotka nemá niesť vôbec ničíe prihlasovacie údaje.

## Prístup cez SSH

Keď je prítomný súbor `authorized_keys`, inštalácia nastaví kľúče ako používateľov súbor `~/.ssh/authorized_keys`, povolí `sshd` a otvorí preň firewall. (Bežná inštalácia Omarchy dodáva openssh s vypnutou službou a zatvoreným portom, takže počítač bez obsluhy by bol inak nedostupný.) Inštalácia iba pridá vaše kľúče — neuvoľňuje žiadne ďalšie nastavenia autentifikácie démona SSH.

Keď je prítomný súbor `tailscale_authkey`, počítač sa namiesto toho pri prvom spustení pripojí k vášmu tailnetu: Tailscale sa nainštaluje z balíčkov priložených k ISO, firewall povolí rozhranie tailnetu a úloha na pozadí spustí pripojenie hneď, ako bude mať počítač skutočne sieť, a opakuje pokusy, kým sa nepodarí. Použite opakovane použiteľný, vopred autorizovaný kľúč, aby jeden obraz jednotky mohol slúžiť mnohým počítačom.

## Vytvorenie jednotky cidata

Funguje akýkoľvek súborový systém so správnym označením. Malé ISO je jednoduchá cesta:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Potom ju pripojte k VM popri ISO Omarchy. Tu je úplný príklad pre Proxmox:

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

Poradie bootovania uvádza disk na prvom mieste zámerne: prázdny disk pri prvom spustení prepadne na ISO a nainštalovaný systém sa odvtedy bootuje z disku.

## Dve upozornenia

Šifrované inštalácie bez obsluhy nie sú úplne bez obsluhy — niekto stále musí pri prvom spustení zadať prístupovú frázu LUKS. A táto prístupová fráza patrí na najvyššiu úroveň súboru `user_credentials.json` ako `encryption_password` — archinstall ju číta odtiaľ, nie z bloku `disk_encryption` v súbore `user_configuration.json` — takže s jednotkou cidata vytvorenou zo šifrovanej inštalácie zaobchádzajte ako s tajomstvom, ktorým aj je.
