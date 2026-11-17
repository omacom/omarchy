# Windows VM

Az Omarchy egyszerű lehetőséget kínál a Windows Docker-VM-en keresztüli futtatására. Az Omarchy menü (`Super + Space`) _Install > Windows_ pontjában telepítheted.

A gépednek ehhez KVM-virtualizációra van szüksége, amely a legtöbb gép rendelkezik — de néha a BIOS-ban ki van kapcsolva, és a telepítő jelzi, ha ez a helyzet. A lemezterületre is szükséged lesz: bármennyit adsz a Windowsnak, plusz kb. 10 GB magának a képnek.

A telepítő megkérdezi, hogy mennyi RAM-ot, hány CPU-magot és mennyi lemezt kell átadni (64 GB vagy több az értelmes alap), majd egy Windows-felhasználónevet és jelszót kér. Hagyd üresen ezeket, és megkapod a `docker` / `admin` párost. A letöltés eltart egy darabig — 10–15 perc normális —, és az előrehaladást a böngészőben itt követheted: `http://127.0.0.1:8006`. A böngésző a konzol megnyitása előtt ugyanarra a felhasználónévre és jelszóra rákérdez.

 ![windows-vm](images/windows-vm.webp)

## Használata

A telepítés után indítsd el a _Windowst_ az alkalmazásindítóból. Ez elindítja a VM-et, ha még nem fut, és RDP-n kapcsol, teljes képernyősen. Hidegindításkor adj neki 15-30 másodpercet.

Az RDP munkamenet hordozza a hangot, a mikrofonodat és a közös vágólapot is, így a szöveg másolása Linux és a Windows között egyszerűen működik. A felbontás követi az ablakodat, és az Omarchy átveszi a kijelző skálázását, így nem lesz homályos káosz a HiDPI képernyőn.

Amikor bezárod az RDP ablakot, a VM automatikusan leáll. Ha inkább futni hagynád — mondjuk valami ott dolgozik — indítsd inkább az `omarchy windows vm launch --keep-alive` paranccsal.

A többi vezérlő ugyanazon a paranccson van:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Fájlmegosztás

A saját mappájában lévő `~/Windows` könyvtár automatikusan megoszlik a VM-mel. Helyezze ide a fájlokat, ha azt szeretné, hogy a Windows elérje azokat. A VM-nek a fájlrendszered más részéhez nincs hozzáférése, így biztonságban vagy a Windows oldali káros dolgoktól. Saját virtuális lemeze itt érhető el: `~/.windows`.

A megszokott otthoni elérési utak saját fájlrendszereiken maradnak. Lehetnek szimbolikus hivatkozások is a saját könyvtáraidra, ami hasznos, amikor a virtuális lemez egy nagyobb meghajtón él. A telepítő a szabad helyet azon a fájlrendszeren méri, amely valójában a `~/.windows` mappát tartalmazza, nem feltétlenül azon, amelyik az otthoni könyvtárát tartalmazza.

Tartsd a lemez- és megosztott elérési utakat külön, nem átfedő könyvtárakként. Az eltávolítás szándékosan üríti a lemezkönyvtárat, de megőrzi a megosztott könyvtárat. Közvetlenül törlés előtt az Omarchy egy korlátozott elszigetelési ellenőrzést végez, és megtagadja a törlést, ha az ellenőrzés túllépi az időt, vagy nem tudja bizonyítani, hogy a két fa különálló.

A VM indítása előtt az Omarchy megnyitja és rögzíti e két könyvtárat, majd kötött csatolással (bind-mount) a pontos könyvtár-inode-okat privát, felhasználónkénti horgonyokhoz köti a `/var/lib/omarchy/windows/mounts` alatt. A Docker csak ezeket a root-védett horgonyokat látja. Ez megőrzi az egyéni lemezhelyeket, miközben megakadályozza, hogy egy másik folyamat, amelyik az ön jogosultságában fut, kicserélje az ellenőrzött elérési utat, mielőtt a privilegizált konténer felhasználja azt. A meglévő lemez- és megosztott könyvtárak engedélyei a migráció során `0700`-ra szűkülnek, így más helyi fiókok nem böngészhetik a tartalmukat.

A VM portjai csak a localhosthoz vannak kötve, így a hálózatodon semmi sem éri el a Windows gépet. A webes konzol is a konfigurált Windows-felhasználónevet és jelszót igényli, ezáltal megakadályozva, hogy egy másik helyi fiók az 8006-os porton vezérelje a VM-et.

## Korlátok és licenc

Ez a beállítás nem támogat GPU-átvezetést, így nem alkalmas játékra vagy videószerkesztésre. Nagyszerű kapu a Microsoft Office vagy bármi más futtatásához, amit feltétlenül akarsz.

A telepített verzió Windows 11 Pro, aktiválás nélkül. Saját licenckulcsodra lesz szükséged a korlátozott funkciók használatához.

Ha ez a számítógép Windowssal érkezett, az OEM-kulcs a firmware-ben még mindig megvan az Omarchy telepítése után is. Kiírhatod az `omarchy windows key` paranccsal. Ez a kulcs ehhez a géphez kötődik — aktiválja a Windows ezen a hardveren újratelepített változatát, de általában a VM-et nem aktiválja.

A erőforrás-kiosztást később az `omarchy-windows-vm install` újrafuttatásával módosíthatod, amely átírja a VM konfigurációját a válaszaidból. A compose-fájl maga most itt él: `/var/lib/omarchy/windows/docker-compose.yml`, tulajdona a root — ez szándékos, így egy olyan folyamat, amelyik az Ön jogosultságában fut, nem képes azt átírni és a privilegizált indítással az egész lemezt a konténerbe felcsatolni. Ha kézzel kell szerkeszteni (például USB-eszközt csatolni), szerkeszd `sudo`-val, és nézd meg az összes lehetőséget [a Dockur Windows projektben](https://github.com/dockur/windows).

Hogy az egészet eltávolítsd, használd az Omarchy menüben az _Remove > Windows_ pontot. Törli a VM lemezét és minden adatát, ezért előbb győződj meg arról, hogy minden, amit érdekel, el van helyezve a `~/Windows` mappán kívül.
