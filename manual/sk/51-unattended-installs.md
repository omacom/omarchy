# Bezobslužné inštalácie

ISO Omarchy sa dokáže nainštalovať samo bez nikoho pri klávesnici. Ak inštalačný program nájde druhý disk s označením `cidata`, ktorý nesie jeho konfiguračné súbory, skopíruje ich odtiaľ, úplne preskočí sprievodcu nastavením a sám sa reštartuje do hotového systému. Žiadna špeciálna zostava ISO, žiadna ďalšia položka v ponuke zavádzania — bez pripojeného takého disku sa nič nemení a dostanete bežného sprievodcu.

Vďaka tomu je Omarchy skvelý ako základný obraz pre jednorazové vývojové prostredia: vytvorte virtuálny stroj v Proxmoxe alebo pomocou Packeru, zaveďte ho, odíďte a pripojte sa cez SSH. `cidata` je označenie `NoCloud` z cloud-init, takže všetky bežné virtualizačné nástroje už vedia, ako taký disk pripojiť.

## Konfiguračné súbory

Súbory sú presne tým, čo zapisuje vlastný sprievodca inštalačného programu, takže najjednoduchší spôsob, ako získať počiatočnú sadu, je spustiť jednu interaktívnu inštaláciu (povedzme vo virtuálnom stroji) a skopírovať to, čo zapísal do `/root`:

| Súbor | Povinné | Účel |
|------|----------|---------|
| `user_configuration.json` | Áno | Disk, názov hostiteľa, časové pásmo, klávesnica |
| `user_credentials.json` | Áno | Používateľské meno a haš hesla |
| `user_full_name.txt` | Nie | Celé meno pre Git |
| `user_email_address.txt` | Nie | E-mail pre Git |
| `user_encrypt_installation.txt` | Nie | `true`, keď konfigurácia nesie blok `disk_encryption` |
| `authorized_keys` | Nie | Verejné kľúče SSH, jeden na riadok |
| `tailscale_authkey` | Nie | Autorizačný kľúč Tailscale na pripojenie do vášho tailnetu pri prvom zavedení |

Haš hesla pre `user_credentials.json` vygenerujte príkazom `openssl passwd -6 "yourpassword"`.

Namiesto `user_credentials.json` môžete tiež vložiť prázdny súbor s názvom `defer-provisioning`. Tým sa spustí tá istá [inštalácia typu pripraviť pre iného vlastníka](02-getting-started.md), ktorú môžete vyvolať interaktívne: stroj sa nainštaluje bez osobných údajov a ktokoľvek ho zavedie ako prvý, si vyberie klávesnicu a vytvorí si svojho používateľa. To je režim pre zobrazovacie zariadenia, kde by disk nemal niesť vôbec žiadne prihlasovacie údaje.

## Prístup cez SSH

Keď je prítomný `authorized_keys`, inštalácia nastaví kľúče ako používateľský `~/.ssh/authorized_keys`, povolí `sshd` a otvorí preň firewall. (Bežná inštalácia Omarchy dodáva openssh s vypnutou službou a zatvoreným portom, takže bezobslužný stroj by inak bol nedostupný.) Inštalácia len pridá vaše kľúče — neuvoľňuje žiadne ďalšie autentifikačné nastavenia démona SSH.

Keď je prítomný `tailscale_authkey`, stroj sa namiesto toho pri prvom zavedení pripojí do vášho tailnetu: Tailscale sa nainštaluje z balíkov priložených k ISO, firewall povolí rozhranie tailnet a úloha na pozadí spustí pripojenie, akonáhle má stroj skutočne sieť, pričom sa opakuje, kým sa nepodarí. Použite opakovane použiteľný, vopred autorizovaný kľúč, aby jeden obraz disku mohol slúžiť mnohým strojom.

## Vytvorenie disku cidata

Funguje každý súborový systém so správnym označením. Jednoduchý spôsob je malé ISO:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Potom ho pripojte k virtuálnemu stroju vedľa ISO Omarchy. Tu je úplný príklad pre Proxmox:

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

Poradie zavádzania uvádza disk zámerne ako prvý: prázdny disk pri prvom zavedení prepadne na ISO a nainštalovaný systém sa potom vždy zavádza z disku.

## Dve výhrady

Zašifrované bezobslužné inštalácie nie sú úplne bezobslužné — niekto stále musí pri prvom zavedení napísať prístupovú frázu LUKS. A blok `disk_encryption` v `user_configuration.json` nesie túto prístupovú frázu v otvorenom texte, takže s diskom cidata vytvoreným zo zašifrovanej inštalácie zaobchádzajte ako s tajomstvom, ktorým je.
