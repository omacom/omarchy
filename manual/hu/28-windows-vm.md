# Windows VM

Az Omarchy egyszerű módot kínál a Windows futtatására Docker VM segítségével x86_64-es gépeken. Az Omarchy menü (`Super + Space`) _Install > Windows_ pontjával telepítheted.

A gépednek ehhez KVM virtualizációra van szüksége, amit a legtöbb gép tud — de néha ki van kapcsolva a BIOS-ban, és a telepítő szólni fog, ha nálad is ez a helyzet. Lemezterületre is szükséged lesz: amennyit a Windowsnak adsz, plusz körülbelül 10GB magának a lemezképnek.

A telepítő megkérdezi, mennyi RAM-ot, hány CPU-magot és mennyi lemezterületet adsz át (64GB vagy több az ésszerű minimum), majd egy Windows felhasználónevet és jelszót kér. Hagyd ezeket üresen, és `docker` / `admin` lesz belőle. A letöltés eltart egy ideig — 10-15 perc teljesen normális —, a folyamatot pedig a böngészőben követheted a `http://127.0.0.1:8006` címen. A böngésző ugyanazt a felhasználónevet és jelszót kéri, mielőtt megnyitná a konzolt.

 ![windows-vm](images/windows-vm.webp)

## Használat

Ha települt, indítsd el a _Windows_ alkalmazást az alkalmazásindítóból. Ez elindítja a VM-et, ha még nem fut, és RDP-n keresztül, teljes képernyőn csatlakoztat hozzá. Hidegindításnál adj neki 15-30 másodpercet.

Az RDP-munkamenet átviszi a hangot, a mikrofonodat és egy közös vágólapot, így a szöveg másolása Linux és Windows között egyszerűen működik. A felbontás követi az ablakodat, az Omarchy pedig átadja a kijelződ méretezését is, így HiDPI képernyőn sem lesz belőle elmosódott katyvasz.

Ha bezárod az RDP-ablakot, a VM automatikusan leáll. Ha inkább futva hagynád — mondjuk épp dolgozik ott bent valami —, indítsd inkább az `omarchy windows vm launch --keep-alive` paranccsal.

A többi vezérlő ugyanennél a parancsnál érhető el:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Fájlok megosztása

A home könyvtáradban található `~/Windows` könyvtár automatikusan meg van osztva a VM-mel. Tégy oda fájlokat, ha azt akarod, hogy a Windows hozzáférjen. A VM a fájlrendszered semmilyen más részéhez nem fér hozzá, így biztonságban vagy mindentől, ami a Windows oldalon garázdálkodna. A saját virtuális lemeze a `~/.windows` helyen érhető el.

Ezek az ismerős home elérési utak a saját fájlrendszereiken maradnak. Szimbolikus linkek is lehetnek általad birtokolt könyvtárakra, ami hasznos, ha a virtuális lemez egy nagyobb meghajtón van. A telepítő azon a fájlrendszeren méri a szabad helyet, amely ténylegesen tartalmazza a `~/.windows` könyvtárat, nem feltétlenül azon, amely a home könyvtáradat tartalmazza.

Tartsd a lemez és a megosztott elérési utakat különálló, egymást nem átfedő könyvtárakként. Az eltávolítás szándékosan kiüríti a lemez könyvtárát, de megőrzi a megosztott könyvtárat. Közvetlenül a törlés előtt az Omarchy egy korlátozott tartalmazási ellenőrzést végez, és megtagadja bármi eltávolítását, ha az ellenőrzés időtúllépésbe ütközik, vagy nem tudja bizonyítani, hogy a két fa különálló.

A VM indulása előtt az Omarchy megnyitja és rögzíti ezt a két könyvtárat, majd az adott könyvtár inode-jait bind-mountolja privát, felhasználónkénti horgonyokra a `/var/lib/omarchy/windows/mounts` alatt. A Docker csak ezeket a root által védett horgonyokat látja. Ez megőrzi az egyéni lemezhelyeket, miközben megakadályozza, hogy egy másik, a te nevedben futó folyamat kicserélje az ellenőrzött elérési utat, mielőtt a privilegizált konténer felhasználná. A meglévő lemez- és megosztott könyvtárakat a migráció során `0700` módra szigorítjuk, hogy más helyi fiókok ne böngészhessék a tartalmukat.

A VM portjai csak localhosthoz vannak kötve, így a hálózatodon semmi nem érheti el a Windows gépet. A webes konzol szintén megköveteli a beállított Windows felhasználónevet és jelszót, így másik helyi fiók nem vezérelheti a VM-et a 8006-os porton keresztül.

## Korlátok és licencelés

Ebben a felállásban nincs GPU passthrough, így játékra vagy videószerkesztésre nem alkalmas. Arra viszont kiváló megoldás, hogy futtasd a Microsoft Office-t, vagy bármi mást, amire feltétlenül szükséged van.

A telepített verzió a Windows 11 Pro, aktiválás nélkül. Az aktiváláshoz kötött funkciók használatához saját licenckulcsra lesz szükséged.

Ha ez a számítógép Windowsszal érkezett, az OEM kulcs az Omarchy telepítése után is ott van a firmware-ben. Írasd ki az `omarchy windows key` paranccsal. Ez a kulcs ehhez a géphez kötött — aktiválni fogja az erre a hardverre újratelepített Windowst, de a VM-et általában nem fogja.

Az erőforrás-kiosztást később is megváltoztathatod, ha terminálban futtatod az `omarchy windows vm install` parancsot, amely a válaszaid alapján újraírja a VM konfigurációját. Maga a compose fájl most a `/var/lib/omarchy/windows/docker-compose.yml` helyen él, és a root tulajdona — ez szándékos, hogy egy a te nevedben futó folyamat ne írhassa át, és a privilegizált indítással ne mountoltathassa be az egész lemezedet a konténerbe. Ha kézzel kell szerkesztened (például egy USB-eszköz mountolásához), szerkeszd `sudo` használatával, az összes lehetőséget pedig nézd meg [a Dockur Windows projektben](https://github.com/dockur/windows).

Ha az egésztől meg akarsz szabadulni, használd az Omarchy menü _Remove > Windows_ pontját. Ez törli a VM lemezét a `~/.windows` helyen és mindent, ami a Windowsban telepítve van, ezért előbb másolj ki a VM-ből mindent, amire szükséged van. A megosztott `~/Windows` mappád érintetlen marad.
