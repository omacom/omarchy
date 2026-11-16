# Bezobslužné inštalácie

ISO Omarchy sa dokáže nainštalovať samo, bez nikoho pri klávesnici. Ak inštalátor nájde druhú jednotku s menovkou `cidata`, ktorá nesie jeho konfiguračné súbory, skopíruje ich z nej, úplne preskočí sprievodcu nastavením a sám sa reštartuje do hotového systému. Žiadny špeciálny build ISO, žiadna extra položka v boot menu — bez pripojenej takejto jednotky sa nič nemení a dostanete bežného sprievodcu.

Vďaka tomu je Omarchy skvelé ako základný obraz pre jednorazové vývojové prostredia: vytvorte VM v Proxmoxe alebo pomocou Packera, nabootujte ju, odíďte preč, prihláste sa cez SSH. `cidata` je menovka `NoCloud` z cloud-init, takže všetky bežné virtualizačné nástroje už vedia, ako takúto jednotku pripojiť.

## Konfiguračné súbory

Súbory sú presne tie, ktoré zapisuje vlastný sprievodca inštalátora, takže najjednoduchší spôsob, ako získať počiatočnú sadu, je spustiť jednu interaktívnu inštaláciu (povedzme vo VM) a skopírovať, čo zapísala do `/root`:

| Súbor | Povinný | Účel |
|------|----------|---------|
| `user_configuration.json` | Áno | Disk, názov hostiteľa, časové pásmo, klávesnica |
| `user_credentials.json` | Áno | Používateľské meno a hash hesla |
| `user_encrypt_installation.txt` | Nie | `true`, keď konfigurácia nesie blok `disk_encryption` |
| `authorized_keys` | Nie | Verejné kľúče SSH, jeden na riadok |
| `tailscale_authkey` | Nie | Auth kľúč Tailscale na pripojenie k vášmu tailnetu pri prvom boote |

Hash hesla pre `user_credentials.json` vygenerujte pomocou `openssl passwd -6 "yourpassword"`.

Meno a e-mail pre commity v gite nie sú súčasťou inštalácie. Nastavte ich, keď stroj beží, napríklad cez SSH, pomocou `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Namiesto `user_credentials.json` môžete tiež vložiť prázdny súbor s názvom `defer-provisioning`. Spustí sa tým rovnaká [inštalácia s prípravou pre iného vlastníka](02-getting-started.md), akú môžete spustiť interaktívne: stroj sa nainštaluje bez osobných údajov a kto ho prvý nabootuje, vyberie si klávesnicu a vytvorí si používateľa. To je režim pre imaging rigy, kde jednotka nemá niesť vôbec ničné prihlasovacie údaje.

## Prístup cez SSH

Keď je prítomný súbor `authorized_keys`, inštalácia nastaví kľúče ako používateľove `~/.ssh/authorized_keys`, povolí `sshd` a otvorí preň firewall. (Štandardná inštalácia Omarchy dodáva openssh s vypnutou službou a zatvoreným portom, takže bezobslužný stroj by inak bol nedostupný.) Inštalácia iba pridá vaše kľúče — neuvoľní žiadne iné nastavenia autentifikácie démona SSH.

Keď je prítomný súbor `tailscale_authkey`, stroj sa namiesto toho pri prvom boote pripojí k vášmu tailnetu: Tailscale sa nainštaluje z balíkov priložených k ISO, firewall povolí rozhranie tailnetu a úloha na pozadí spustí pripojenie hneď, ako má stroj skutočne sieť, a opakuje pokusy, kým sa to nepodarí. Použite opakovane použiteľný, vopred autorizovaný kľúč, aby jeden obraz jednotky mohol slúžiť mnohým strojom.

## Vytvorenie jednotky cidata

Funguje akýkoľvek súborový systém so správnou menovkou. Malé ISO je jednoduchá cesta:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Potom ju pripojte k VM popri ISO Omarchy. Tu je kompletný príklad pre Proxmox:

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

Poradie bootovania uvádza disk ako prvý zámerne: prázdny disk pri prvom boote prepadne k ISO a nainštalovaný systém odvtedy bootuje z disku.

## Dve upozornenia

Šifrované bezobslužné inštalácie nie sú úplne bezobslužné — niekto stále musí pri prvom boote zadať prístupovú frázu LUKS. A blok `disk_encryption` v `user_configuration.json` nesie túto prístupovú frázu v čistom texte, takže s jednotkou cidata vytvorenou zo šifrovanej inštalácie zaobchádzajte ako s tajomstvom, ktorým je.
