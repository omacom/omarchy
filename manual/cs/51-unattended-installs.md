# Instalace bez obsluhy

ISO Omarchy se dokáže nainstalovat samo, aniž by někdo seděl u klávesnice. Pokud instalační program najde druhý disk s označením `cidata`, který obsahuje jeho konfigurační soubory, zkopíruje je z něj, úplně přeskočí průvodce nastavením a sám se restartuje do hotového systému. Žádný speciální build ISO, žádná další položka ve spouštěcí nabídce — pokud takový disk není připojený, nic se nezmění a dostanete běžného průvodce.

Omarchy je tak skvělé jako základní image pro jednorázová vývojová prostředí: vytvořte VM v Proxmox nebo pomocí Packer, spusťte ji, odejděte a připojte se přes SSH. `cidata` je označení cloud-init `NoCloud`, takže všechny běžné nástroje pro virtualizaci už vědí, jak takový disk připojit.

## Konfigurační soubory

Soubory jsou přesně ty, které zapisuje vlastní průvodce instalačního programu, takže nejjednodušší způsob, jak získat výchozí sadu, je provést jednu interaktivní instalaci (třeba ve VM) a zkopírovat to, co zapsala do `/root`:

| Soubor | Povinný | Účel |
|------|----------|---------|
| `user_configuration.json` | Ano | Disk, název hostitele, časové pásmo, klávesnice |
| `user_credentials.json` | Ano | Uživatelské jméno a hash hesla |
| `user_encrypt_installation.txt` | Ne | `true`, když konfigurace obsahuje blok `disk_encryption` |
| `authorized_keys` | Ne | Veřejné klíče SSH, jeden na řádek |
| `tailscale_authkey` | Ne | Autentizační klíč Tailscale pro připojení k vaší síti tailnet při prvním spuštění |

Hash hesla pro `user_credentials.json` vygenerujete pomocí `openssl passwd -6 "yourpassword"`.

Jméno a e-mail pro commity v gitu součástí instalace nejsou. Nastavte je, jakmile stroj běží, například přes SSH pomocí `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Místo `user_credentials.json` můžete také vložit prázdný soubor s názvem `defer-provisioning`. Tím se spustí stejná [instalace s přípravou pro jiného vlastníka](02-getting-started.md), kterou můžete spustit interaktivně: stroj se nainstaluje bez jakýchkoli osobních údajů a ten, kdo ho spustí jako první, si vybere klávesnici a vytvoří svého uživatele. To je režim pro imagingové stroje, kde disk nemá obsahovat vůbec ničí přihlašovací údaje.

## Přístup přes SSH

Když je přítomen soubor `authorized_keys`, instalace nastaví klíče jako `~/.ssh/authorized_keys` uživatele, povolí `sshd` a otevře pro něj firewall. (Běžná instalace Omarchy obsahuje openssh s vypnutou službou a zavřeným portem, takže stroj bez obsluhy by jinak byl nedostupný.) Instalace pouze přidá vaše klíče — nezměkčuje žádná další nastavení ověřování démona SSH.

Když je naopak přítomen soubor `tailscale_authkey`, stroj se při prvním spuštění připojí k vaší síti tailnet: Tailscale se nainstaluje z balíčků přibalených na ISO, firewall povolí rozhraní tailnetu a úloha na pozadí provede připojení, jakmile bude mít stroj skutečně síť, a opakuje pokusy, dokud se jí to nepodaří. Použijte opakovaně použitelný, předem autorizovaný klíč, aby jedna image disku mohla sloužit mnoha strojům.

## Vytvoření disku cidata

Funguje jakýkoli souborový systém se správným označením. Malé ISO je snadná cesta:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Poté ho připojte k VM spolu s ISO Omarchy. Tady je kompletní příklad pro Proxmox:

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

Pořadí spouštění uvádí disk jako první úmyslně: prázdný disk při prvním spuštění propadne k ISO a nainstalovaný systém se už navždy spouští z disku.

## Dvě výhrady

Šifrované instalace bez obsluhy nejsou úplně bez obsluhy — někdo přesto musí při prvním spuštění zadat přístupovou frázi LUKS. A blok `disk_encryption` v `user_configuration.json` obsahuje tuto přístupovou frázi v prostém textu, takže s diskem cidata vytvořeným ze šifrované instalace zacházejte jako s tajemstvím, kterým je.
