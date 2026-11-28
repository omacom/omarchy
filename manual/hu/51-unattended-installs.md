# Felügyelet nélküli telepítések

Az Omarchy ISO képes magát telepíteni úgy, hogy senki sem ül a billentyűzetnél. Ha a telepítő talál egy második, `cidata` címkéjű meghajtót, amely a konfigurációs fájljait hordozza, lemásolja azokat, teljesen kihagyja a beállítóvarázslót, és magától újraindul a kész rendszerbe. Nincs szükség speciális ISO-buildre, nincs extra bejegyzés a bootmenüben — ha nincs ilyen meghajtó csatlakoztatva, semmi sem változik, és a szokásos varázslót kapod.

Ettől az Omarchy remek alapimage eldobható fejlesztői környezetekhez: hozz létre egy VM-et Proxmoxban vagy Packerrel, indítsd el, menj el, majd lépj be SSH-val. A `cidata` a cloud-init `NoCloud` címkéje, így minden elterjedt virtualizációs eszköz már tudja, hogyan kell ilyen meghajtót csatolni.

## A konfigurációs fájlok

A fájlok pontosan azok, amelyeket a telepítő saját varázslója ír, így a legegyszerűbb módja egy kiinduló készlet beszerzésének az, ha lefuttatsz egy interaktív telepítést (mondjuk egy VM-ben), és átmásolod, amit a `/root` könyvtárba írt:

| Fájl | Kötelező | Cél |
|------|----------|---------|
| `user_configuration.json` | Igen | Lemez, hosztnév, időzóna, billentyűzet |
| `user_credentials.json` | Igen | Felhasználónév és jelszóhash, valamint a LUKS jelmondat titkosított telepítéshez |
| `user_encrypt_installation.txt` | Nem | `true`, ha a konfiguráció `disk_encryption` blokkot tartalmaz |
| `authorized_keys` | Nem | SSH nyilvános kulcsok, soronként egy |
| `tailscale_authkey` | Nem | Tailscale hitelesítési kulcs a tailnethez való csatlakozáshoz az első indításkor |

A `user_credentials.json` jelszóhashét az `openssl passwd -6 "yourpassword"` paranccsal generáld.

A git commitokhoz használt név és e-mail cím nem része a telepítésnek. Állítsd be őket, miután a gép elindult, például SSH-n keresztül az `omarchy setup git --name "Jane Doe" --email jane@example.com` paranccsal.

A `user_credentials.json` helyett betehetsz egy üres, `defer-provisioning` nevű fájlt is. Ez ugyanazt a [másik tulajdonosra felkészítő telepítést](02-getting-started.md) futtatja, amelyet interaktívan is elindíthatsz: a gép személyes adatok nélkül települ, és aki először elindítja, az választja ki a billentyűzetét és hozza létre a felhasználóját. Ez az üzemmód image-előállító gépekhez való, ahol a meghajtónak egyáltalán nem szabad senki hitelesítő adatait hordoznia.

## SSH-hozzáférés

Ha az `authorized_keys` jelen van, a telepítés beállítja a kulcsokat a felhasználó `~/.ssh/authorized_keys` fájljaként, engedélyezi az `sshd` szolgáltatást, és megnyitja hozzá a tűzfalat. (Egy gyári Omarchy telepítés az openssh-t letiltott szolgáltatással és zárt porttal szállítja, így egy felügyelet nélküli gép egyébként elérhetetlen lenne.) A telepítés csak hozzáadja a kulcsaidat — az SSH démon egyéb hitelesítési beállításain nem lazít.

Ha a `tailscale_authkey` jelen van, a gép helyette az első indításkor csatlakozik a tailnetedhez: a Tailscale az ISO mellékelt csomagjaiból települ, a tűzfal engedélyezi a tailnet interfészt, és egy háttérfeladat lefuttatja a csatlakozást, amint a gép ténylegesen hálózathoz jut, és sikerig újrapróbálkozik. Használj újrafelhasználható, előre engedélyezett kulcsot, hogy egyetlen meghajtóimage sok gépet szolgálhasson ki.

## A cidata meghajtó elkészítése

Bármilyen, megfelelő címkéjű fájlrendszer megfelel. Egy apró ISO a legegyszerűbb megoldás:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Ezután csatold a VM-hez az Omarchy ISO mellé. Íme egy teljes Proxmox példa:

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

A rendszerindítási sorrend szándékosan sorolja a lemezt első helyre: az üres lemez az első indításkor továbbesik az ISO-ra, a telepített rendszer pedig attól kezdve mindig lemezről indul.

## Két figyelmeztetés

A titkosított, felügyelet nélküli telepítések nem teljesen felügyelet nélküliek — valakinek még mindig be kell gépelnie a LUKS jelmondatot az első indításkor. És ez a jelmondat a `user_credentials.json` legfelső szintjére kerül `encryption_password` néven — az archinstall onnan olvassa, nem a `user_configuration.json` fájlban lévő `disk_encryption` blokkból — ezért egy titkosított telepítésből épített cidata meghajtót kezeld akkora titokként, amekkora valójában.
