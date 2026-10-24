# Felügyelet nélküli telepítések

Az Omarchy ISO a billentyűzetnél lévő személy nélkül is telepítheti önmagát. Ha a telepítő talál egy `cidata` címkéjű második meghajtót, amely a konfigurációs fájljait hordozza, lemásolja őket, teljesen kihagyja a beállításvarázslót, és magától újraindul a kész rendszerbe. Nincs különleges ISO-build, nincs extra rendszerindítási menübejegyzés — ha nincs ilyen meghajtó csatlakoztatva, semmi sem változik, és a normál varázslót kapod.

Ez nagyszerűvé teszi az Omarchyt eldobható fejlesztői környezetek alapimage-ének: hozz létre egy VM-et Proxmoxban vagy Packerrel, indítsd el, sétálj el, SSH-zz be. A `cidata` a cloud-init `NoCloud` címkéje, így a szokásos virtualizációs eszközök mind tudják már, hogyan csatoljanak ilyen meghajtót.

## A konfigurációs fájlok

A fájlok pont azt jelentik, amit a telepítő saját varázslója ír, így a kiindulási készlet beszerzésének legegyszerűbb módja egy interaktív telepítés futtatása (mondjuk egy VM-ben) és a `/root` mappába írt tartalom másolása:

| Fájl | Kötelező | Cél |
|------|----------|---------|
| `user_configuration.json` | Igen | Lemez, hosztnév, időzóna, billentyűzet |
| `user_credentials.json` | Igen | Felhasználónév és jelszó-hash |
| `user_full_name.txt` | Nem | Git teljes név |
| `user_email_address.txt` | Nem | Git e-mail |
| `user_encrypt_installation.txt` | Nem | `true`, amikor a konfiguráció egy `disk_encryption` blokkot hordoz |
| `authorized_keys` | Nem | SSH nyilvános kulcsok, soronként egy |
| `tailscale_authkey` | Nem | Tailscale hitelesítési kulcs a tailnethez való csatlakozáshoz első indításkor |

A `user_credentials.json` jelszó-hashét az `openssl passwd -6 "yourpassword"` paranccsal generáld.

A `user_credentials.json` helyébe egy üres, `defer-provisioning` nevű fájlt is dobhatsz. Ez ugyanazt a [másik tulajdonosnak való előkészítő telepítést](02-getting-started.md) futtatja, amelyet interaktívan is kiválthatsz: a gép személyes adatok nélkül települ, és aki először indítja el, az választja ki a billentyűzetét és hozza létre a felhasználóját. Ez az imaging-állomások módja, ahol a meghajtónak egyáltalán nem szabad senki hitelesítőadatait hordoznia.

## SSH-hozzáférés

Amikor az `authorized_keys` jelen van, a telepítés beállítja a kulcsokat a felhasználó `~/.ssh/authorized_keys` fájljaként, engedélyezi az `sshd` szolgáltatást, és megnyitja hozzá a tűzfalat. (Egy stock Omarchy-telepítés az openssh-val érkezik, a szolgáltatás letiltva és a port lezárva, így egy felügyelet nélküli gép egyébként elérhetetlen lenne.) A telepítés csak hozzáadja a kulcsaidat — nem lazít az SSH-démon semmilyen más hitelesítési beállításán.

Amikor a `tailscale_authkey` jelen van, a gép ehelyett első indításkor csatlakozik a tailnetedhez: a Tailscale az ISO mellékelt csomagjaiból települ, a tűzfal engedélyezi a tailnet-interfészt, és egy háttérfeladat futtatja a csatlakozást, amint a gépnek tényleg van hálózata, újrapróbálkozva, amíg sikerül. Használj újrafelhasználható, előengedélyezett kulcsot, hogy egy meghajtóimage sok gépet szolgálhasson ki.

## A cidata meghajtó építése

Minden fájlrendszer működik a helyes címkével. Egy apró ISO a könnyű mód:

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

Az indítási sorrend szándékosan a lemezt sorolja először: az üres lemez az első indításkor átadja a helyét az ISO-nak, és a telepített rendszer attól kezdve mindig lemezről indul.

## Két megjegyzés

A titkosított felügyelet nélküli telepítések nem teljesen felügyelet nélküliek — valakinek továbbra is be kell írnia a LUKS-jelmondatot az első indításkor. És a `user_configuration.json` fájlban lévő `disk_encryption` blokk ezt a jelmondatot egyszerű szövegben hordozza, úgyhogy egy titkosított telepítésből épített cidata meghajtót kezeld annak a titoknak, ami.
