# Instalace bez obsluhy

ISO Omarchy se dokáže nainstalovat samo, aniž by někdo seděl u klávesnice. Pokud instalační program najde druhý disk s označením `cidata`, který nese jeho konfigurační soubory, zkopíruje je, zcela přeskočí průvodce nastavením a sám se restartuje do hotového systému. Žádná speciální sestava ISO, žádná další položka v zaváděcí nabídce — když žádný takový disk připojený není, nic se nemění a dostanete normálního průvodce.

Díky tomu je Omarchy skvělé jako základní obraz pro jednorázová vývojová prostředí: vytvoříte VM v Proxmox nebo pomocí Packer, spustíte ji, odejdete a připojíte se přes SSH. `cidata` je označení cloud-init `NoCloud`, takže všechny běžné virtualizační nástroje už vědí, jak takový disk připojit.

## Konfigurační soubory

Soubory jsou přesně to, co zapisuje vlastní průvodce instalačního programu, takže nejjednodušší způsob, jak získat výchozí sadu, je provést jednu interaktivní instalaci (třeba ve VM) a zkopírovat to, co zapsala do `/root`:

| Soubor | Povinný | Účel |
|------|----------|---------|
| `user_configuration.json` | Ano | Disk, název hostitele, časové pásmo, klávesnice |
| `user_credentials.json` | Ano | Uživatelské jméno a hash hesla a přístupová fráze LUKS pro šifrovanou instalaci |
| `user_encrypt_installation.txt` | Ne | `true`, když konfigurace nese blok `disk_encryption` |
| `authorized_keys` | Ne | Veřejné klíče SSH, jeden na řádek |
| `tailscale_authkey` | Ne | Autorizační klíč Tailscale pro připojení do vaší tailnet při prvním spuštění |

Hash hesla pro `user_credentials.json` vygenerujte pomocí `openssl passwd -6 "yourpassword"`.

Jméno a e-mail pro commity v gitu nejsou součástí instalace. Nastavte je, jakmile je počítač spuštěný, například přes SSH, pomocí `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Můžete také místo `user_credentials.json` vložit prázdný soubor s názvem `defer-provisioning`. Tím se spustí stejná [instalace typu připravit pro jiného vlastníka](02-getting-started.md), kterou můžete spustit interaktivně: počítač se nainstaluje bez jakýchkoli osobních údajů a ten, kdo jej spustí jako první, si vybere klávesnici a vytvoří svého uživatele. To je režim pro zařízení na přípravu obrazů, kde by disk neměl nést vůbec ničí přihlašovací údaje.

## Přístup přes SSH

Když je přítomen soubor `authorized_keys`, instalace nastaví klíče jako uživatelův soubor `~/.ssh/authorized_keys`, povolí `sshd` a otevře pro něj firewall. (Běžná instalace Omarchy dodává openssh s vypnutou službou a zavřeným portem, takže počítač bez obsluhy by jinak byl nedostupný.) Instalace pouze přidá vaše klíče — neuvolňuje žádná další nastavení ověřování démona SSH.

Když je přítomen soubor `tailscale_authkey`, počítač se místo toho při prvním spuštění připojí do vaší tailnet: Tailscale se nainstaluje z přibalených balíčků na ISO, firewall povolí rozhraní tailnet a úloha na pozadí provede připojení, jakmile bude mít počítač skutečně síť, a bude to opakovat, dokud se to nepodaří. Použijte opakovaně použitelný, předem autorizovaný klíč, aby jeden obraz disku mohl sloužit mnoha počítačům.

## Vytvoření disku cidata

Funguje jakýkoli souborový systém se správným označením. Malé ISO je snadná cesta:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Pak jej připojte k VM spolu s ISO Omarchy. Tady je kompletní příklad pro Proxmox:

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

Pořadí spouštění uvádí disk na prvním místě záměrně: prázdný disk při prvním spuštění propadne k ISO a nainstalovaný systém se poté už vždy spouští z disku.

## Dvě upozornění

Šifrované instalace bez obsluhy nejsou zcela bez obsluhy — někdo přesto musí při prvním spuštění zadat přístupovou frázi LUKS. A tato přístupová fráze patří na nejvyšší úroveň `user_credentials.json` jako `encryption_password` — archinstall ji čte odtud, ne z bloku `disk_encryption` v `user_configuration.json` — takže s diskem cidata vytvořeným ze šifrované instalace zacházejte jako s tajemstvím, kterým je.
