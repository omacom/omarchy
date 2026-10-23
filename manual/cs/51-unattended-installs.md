# Bezobslužné instalace

Obraz ISO systému Omarchy se může nainstalovat sám, aniž by kdokoli seděl u klávesnice. Pokud instalátor najde druhou jednotku označenou `cidata` se svými konfiguračními soubory, zkopíruje si je, průvodce prvotním nastavením úplně přeskočí a sám restartuje počítač do hotového systému. Není potřeba žádná zvláštní sestava ISO, žádná další položka spouštěcí nabídky — není-li připojena žádná taková jednotka, nic se nemění a dostanete běžného průvodce.

Díky tomu se Omarchy výborně hodí jako základní obraz pro jednorázová vývojová prostředí: vytvoříte virtuální počítač v systému Proxmox nebo pomocí nástroje Packer, spustíte ho, odejdete a přihlásíte se přes SSH. Označení `cidata` je označením `NoCloud` nástrojí cloud-init, takže všechny běžné virtualizační nástroje už takovou jednotku připojit umějí.

## Konfigurační soubory

Soubory jsou přesně tytéž, které zapíše vlastní průvodce instalátoru, takže nejsnadnější způsob, jak získat výchozí sadu, je provést jednu interaktivní instalaci (třeba ve virtuálním počítači) a zkopírovat si, co zapsala do složky `/root`:

| Soubor | Povinný | Účel |
|------|----------|---------|
| `user_configuration.json` | Ano | Disk, název hostitele, časové pásmo, klávesnice |
| `user_credentials.json` | Ano | Uživatelské jméno a hash hesla |
| `user_full_name.txt` | Ne | Úplné jméno pro Git |
| `user_email_address.txt` | Ne | E-mail pro Git |
| `user_encrypt_installation.txt` | Ne | Hodnota `true`, pokud konfigurace obsahuje blok `disk_encryption` |
| `authorized_keys` | Ne | Veřejné klíče SSH, jeden na řádku |
| `tailscale_authkey` | Ne | Autorizační klíč Tailscale pro připojení k vašemu tailnetu při prvním spuštění |

Hash hesla pro soubor `user_credentials.json` vygenerujete příkazem `openssl passwd -6 "yourpassword"`.

Místo souboru `user_credentials.json` můžete také vložit prázdný soubor s názvem `defer-provisioning`. Tím se spustí stejná [instalace s přípravou pro jiného vlastníka](02-getting-started.md), kterou můžete vyvolat interaktivně: počítač se nainstaluje bez osobních údajů a ten, kdo ho spustí jako první, si vybere klávesnici a vytvoří si uživatele. To je režim pro zařízení určená k nasazování obrazů, kde by jednotka neměla obsahovat vůbec ničí přihlašovací údaje.

## Přístup přes SSH

Pokud je soubor `authorized_keys` přítomen, instalace nastaví klíče jako soubor `~/.ssh/authorized_keys` příslušného uživatele, povolí službu `sshd` a otevře pro ni firewall. (U standardní instalace Omarchy se služba openssh dodává vypnutá a port je uzavřený, takže bezobslužný počítač by jinak byl nedostupný.) Při instalaci se přidají pouze vaše klíče — žádná jiná nastavení ověřování démona SSH se neuvolní.

Pokud je přítomen soubor `tailscale_authkey`, počítač se namísto toho při prvním spuštění připojí k vašemu tailnetu: služba Tailscale se nainstaluje z balíčků přibalených k obrazu ISO, firewall povolí rozhraní tailnetu a úloha na pozadí spustí připojení, jakmile bude počítač skutečně připojený k síti, přičemž se o to bude pokoušet opakovaně, dokud se to nepodaří. Používejte opakovaně použitelný, předem autorizovaný klíč, aby jeden obraz jednotky mohl sloužit mnoha počítačům.

## Vytvoření jednotky cidata

Funguje jakýkoli souborový systém se správným označením. Snadným řešením je drobný obraz ISO:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Poté ho připojte k virtuálnímu počítači vedle obrazu ISO systému Omarchy. Zde je úplný příklad pro Proxmox:

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

Pořadí spouštění uvádí disk na první pozici záměrně: prázdný disk při prvním spuštění propadne na obraz ISO a nainstalovaný systém se od té chvíle spouští z disku.

## Dvě výhrady

Šifrované bezobslužné instalace nejsou úplně bezobslužné — někdo přece jen musí při prvním spuštění zadat přístupovou frázi LUKS. A blok `disk_encryption` v souboru `user_configuration.json` tuto přístupovou frázi obsahuje v prostém textu, takže s jednotkou cidata vytvořenou na základě šifrované instalace nakládejte jako s tajemstvím, kterým skutečně je.
