# Felügyelet nélküli telepítések

Az Omarchy ISO képes önmagát telepíteni úgy, hogy senki sem ül a billentyűzetnél. Ha a telepítő talál egy második, `cidata` címkéjű meghajtót, amely a konfigurációs fájljait hordozza, lemásolja azokat, teljesen kihagyja a beállítási varázslót, és magától újraindul az elkészült rendszerbe. Nem kell hozzá külön ISO-build, sem extra rendszerindító menüpont — ha nincs ilyen meghajtó csatlakoztatva, semmi sem változik, és a szokásos varázslót kapod.

Ezzel az Omarchy remek alapképfájl eldobható fejlesztői környezetekhez: hozz létre egy VM-et Proxmoxban vagy Packerrel, indítsd el, sétálj el, majd lépj be SSH-val. A `cidata` a cloud-init `NoCloud` címkéje, így az összes elterjedt virtualizációs eszköz már tudja, hogyan kell ilyen meghajtót csatlakoztatni.

## A konfigurációs fájlok

A fájlok pontosan azok, amelyeket a telepítő saját varázslója ír ki, ezért a legegyszerűbben úgy juthatsz kiinduló készlethez, ha lefuttatsz egy interaktív telepítést (például egy VM-ben), és átmásolod, amit a `/root` könyvtárba írt:

| Fájl | Kötelező | Cél |
|------|----------|---------|
| `user_configuration.json` | Igen | Lemez, gépnév, időzóna, billentyűzet |
| `user_credentials.json` | Igen | Felhasználónév és jelszóhash |
| `user_encrypt_installation.txt` | Nem | `true`, amikor a konfiguráció tartalmaz egy `disk_encryption` blokkot |
| `authorized_keys` | Nem | SSH nyilvános kulcsok, soronként egy |
| `tailscale_authkey` | Nem | Tailscale hitelesítőkulcs a tailnethez való csatlakozáshoz az első rendszerindításkor |

A `user_credentials.json` jelszóhashét az `openssl passwd -6 "yourpassword"` paranccsal állíthatod elő.

A git-commitetekhez használt név és e-mail-cím nem része a telepítésnek. Állítsd be őket, amint a gép felállt, például SSH-n keresztül, ezzel: `omarchy setup git --name "Jane Doe" --email jane@example.com`.

A `user_credentials.json` helyett betehetsz egy üres, `defer-provisioning` nevű fájlt is. Ez ugyanazt a [másik tulajdonosra felkészítő telepítést](02-getting-started.md) futtatja, amelyet interaktívan is elindíthatsz: a gép személyes adatok nélkül települ, és aki először elindítja, az választja ki a billentyűzetét és hozza létre a felhasználóját. Ez a mód képfájlkészítő gépekhez való, ahol a meghajtónak egyáltalán nem szabad senki hitelesítő adatait hordoznia.

## SSH-hozzáférés

Ha az `authorized_keys` jelen van, a telepítés beállítja a kulcsokat a felhasználó `~/.ssh/authorized_keys` fájljaként, engedélyezi az `sshd` szolgáltatást, és megnyitja hozzá a tűzfalat. (Egy gyári Omarchy-telepítés úgy szállítja az openssh csomagot, hogy a szolgáltatás le van tiltva és a port zárva van, így egy felügyelet nélküli gép egyébként elérhetetlen lenne.) A telepítés csak hozzáadja a kulcsaidat — az SSH-démon többi hitelesítési beállításán semmit sem lazít.

Ha a `tailscale_authkey` jelen van, a gép helyette az első rendszerindításkor csatlakozik a tailnetedhez: a Tailscale az ISO mellékelt csomagjaiból települ, a tűzfal engedélyezi a tailnet interfészt, és egy háttérfeladat végrehajtja a csatlakozást, amint a gépnek ténylegesen van hálózata, és sikerig újrapróbálkozik. Újrafelhasználható, előzetesen engedélyezett kulcsot használj, így egyetlen meghajtóképfájl sok gépet is ki tud szolgálni.

## A cidata meghajtó elkészítése

Bármilyen fájlrendszer működik a megfelelő címkével. Egy apró ISO a legegyszerűbb út:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Ezután csatold a VM-hez az Omarchy ISO mellé. Íme egy teljes Proxmox-példa:

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

A rendszerindítási sorrend szándékosan sorolja előre a lemezt: az üres lemez az első indításkor továbbesik az ISO-ra, utána pedig a telepített rendszer örökre a lemezről indul.

## Két figyelmeztetés

A titkosított felügyelet nélküli telepítések nem teljesen felügyelet nélküliek — valakinek továbbra is be kell gépelnie a LUKS-jelmondatot az első rendszerindításkor. És a `user_configuration.json` fájlban lévő `disk_encryption` blokk nyílt szövegként hordozza ezt a jelmondatot, ezért a titkosított telepítésből épített cidata meghajtót kezeld akkora titokként, amekkora valójában.
