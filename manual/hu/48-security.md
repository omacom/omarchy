# Biztonság

Az Omarchy rendkívül komolyan veszi a biztonságot. Ez egy olyan operációs rendszer, amelyet _Valódi Munkára_ használhatsz a _Valódi Világban_. Ahol egy laptop elvesztése nem vezethet biztonsági vészhelyzethez. Íme, amit teszünk:

1. *A teljes lemeztitkosítás alapértelmezés szerint be van kapcsolva*: Ez a legfontosabb lépés az adataid fizikai védelmének biztosításához. Ha a számítógéped elveszik vagy ellopják, az adatok teljesen titkosítva vannak a szabványos LUKS (Linux Unified Key Setup) használatával. A telepítő lehetővé teszi, hogy eldobható gépek esetén lemondj róla (lásd [Kezdő lépések](02-getting-started.md)); a titkosítás nélküli telepítésnél ez a védelem egyáltalán nem érvényesül, és bárki, akinél a meghajtó van, elolvashatja azt.
2. *A tűzfal alapértelmezés szerint engedélyezve van*: Minden bejövő forgalom alapértelmezés szerint blokkolva van, néhány kivétellel: az 53317-es port a [LocalSend](https://localsend.org/) számára; DNS-lekérdezések a számítógép saját feloldójához a Docker bridge címén (172.17.0.1), amelyeket a Docker a konténereinek adott privát címtartományokból fogad el; és a multicast DNS (5353-as port), amely lehetővé teszi, hogy a nyomtatók és más eszközök a hálózatodon megtalálják egymást, és a számítógéped nevét is bejelenti ott. Ezeken felül a tűzfal megtartja az UFW szokásos engedélyeit a pingre, a címszerzésre a routeredtől (DHCP) és az UPnP-felderítésre. Még az ssh is ki van kapcsolva, amíg be nem kapcsolod a _Beállítás > Biztonság > SSHD_ menüpontban, amely engedélyezi az SSH-kulcsodat, kikapcsolja a jelszavas bejelentkezéseket, és csak ezután nyitja meg a 22-es portot (brute force elleni sebességkorlátozással). Még a Docker-hozzáférést is lezárjuk a [ufw-docker](https://github.com/chaifeng/ufw-docker) beállítással, hogy megakadályozzuk, hogy a konténereid véletlenül kikerüljenek a világba.
3. *Az Arch mindig a legfrissebb frissítésekkel rendelkezik*: Az Arch, az alapul szolgáló disztribúció, amelyre az Omarchy épül, gördülő disztribúció. Ez azt jelenti, hogy bármely biztonsági sebezhetőség, amelyet felfedeznek és javítanak bármely csomagban, gyorsan elérhetővé válik telepítésre az `omarchy-update` használatával. Így mindig mindenből a legfrissebb, legbiztonságosabb verziót futtatod.
4. *Az Omarchy saját csomagokat és tükröt tart fenn*: Az Omarchy alapértelmezés szerint csak az Arch saját core/extra/multilib tárolóiból származó csomagokra támaszkodik (ARM gépeken az Arch Linux ARM tárolóira, plusz Apple Siliconon az Asahi ALARM-ra) és a saját Omarchy Package Repository tárolójára. Telepíthetsz szoftvert közvetlenül az AUR-ból, de az alaptelepítés nem teszi — csak néhány opcionális telepítés, például a harmadik féltől származó böngészők, húz be csomagokat az AUR-ból.
5. *A Cloudflare véd minket a DDoS ellen*: Az Omarchy terjesztési infrastruktúráját — az ISO-kat, az Omarchy csomagokat, az Arch tükröt — a Cloudflare félelmetes DDoS-pajzsa védi, és a CDN-jükön van hosztolva. Ez kiváló rendelkezésre állást biztosít.

## A jelszavaid megváltoztatása

Titkosított telepítés esetén két jelszavad van: az egyik, amely feloldja a meghajtót rendszerindításkor, és az, amellyel bejelentkezel és `sudo`-zol. A beállítás során ezek azonosak lesznek. Az Omarchy menü _Frissítés > Jelszó_ menüpontja mindkettőt egyszerre megváltoztatja, így azonosak maradnak: kéri az aktuális meghajtójelszót, majd az újat, megváltoztatja a meghajtóét, majd a bejelentkezési jelszavadat is ahhoz igazítja. Meghajtótitkosítás nélkül csak a bejelentkezési jelszavadat változtatja meg. Ha egy változtatás megszakad, futtasd újra az _Frissítés > Jelszó_ menüpontot: azt a jelszót kéri, amely most feloldja a meghajtót, befejezi a változtatást, és a bejelentkezési jelszavadat is arra állítja. Egy másik titkosított meghajtó jelszavának megváltoztatásához futtasd az `omarchy-drive-password` parancsot egy terminálban.

## Egy már használt gép továbbadása

Ha a gépedet átadod valaki másnak, nem kell újratelepítened. Futtasd az Omarchy menü _Eltávolítás > Gyári visszaállítás_ menüpontját, írd be a `reset` szót a megerősítéshez, add meg a meghajtótitkosítási jelszavadat, ha kéri, és indítsd újra a gépet. Ez töröl minden felhasználói fiókot és mindent a `/home` alatt, eldob minden csomagot és rendszermódosítást, amelyet a telepítés óta végeztél, és törli a gép identitását — hálózati kapcsolatokat, hostkulcsokat és mindent. Ami ezután feláll, az az első rendszerindításkor megjelenő beállítási varázsló, készen arra, hogy az új tulajdonos megadja a saját nevét, jelszavát és titkosítási jelszavát.

Ez úgy működik, hogy visszaállítja a telepítő által készített alap pillanatképet, ezért csak az Omarchy ISO-ról telepített gépeken érhető el. Titkosítás nélküli meghajtón pedig a visszaállítás törlés, nem pedig biztonságos törlés, ezért ha az adatok érzékenyek voltak, végezz inkább friss telepítést.

## Jelszó nélküli sudo

Néha azt szeretnéd, hogy a `sudo` ne kérdezzen tovább, leggyakrabban akkor, amikor egy AI agent hosszú rendszerfeladatot végez helyetted. A _Beállítás > Biztonság > Jelszó nélküli sudo_ megkérdezi, mennyi ideig engedélyezed a hozzáférést: **15 perc**, **1 óra**, **1 nap** vagy **Véglegesen**. Amíg a hozzáférés aktív, egy piros figyelmeztető ikon jelenik meg a többi menüsorjelző mellett. Kattints rá, vagy futtasd újra a parancsot a hozzáférés kikapcsolásához. Saját percszámot is megadhatsz (1 és 1440 között) az `omarchy-sudo-passwordless 30` paranccsal, vagy használd az `omarchy-sudo-passwordless permanent` parancsot.

Az időzített hozzáférés automatikusan lejár, beleértve közvetlenül azután is, hogy visszatérsz egy olyan felfüggesztésből, amely átlépte a határidőt. A számítógép újraindítása idő előtt lezárja. A végleges hozzáférés túléli az újraindításokat, és engedélyezve marad, amíg ki nem kapcsolod.

Az Omarchy beállításcsomagjának frissítése vagy eltávolítása lezár minden ideiglenes engedélyt, mielőtt annak lejárati támogatása megváltozna. Ha a parancs engedélyezési vagy takarítási hibát jelez, oldd meg, mielőtt újabb engedélyt próbálnál engedélyezni; a hiba nem jelenti azt, hogy a jelszó nélküli hozzáférés inaktív.

Légy tisztában ezzel: amíg be van kapcsolva, bármi, ami a felhasználódként fut, bármit megtehet rootként anélkül, hogy kérdezne. Ez az egész lényege, és ez az egész kockázata is.

## Aláírókulcsok

Minden ISO-aláírás és az Omarchy repo csomag nyilvános kulcsa a `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ellenőrzés az openpgp.org oldalon](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Az `omarchy/omarchy-keyring` csomag is tartalmazza ezt, és arra szolgál, hogy az esetleges frissítéseket zökkenőmentesen terjessze.

Bármely ISO-kiadás aláírását megtalálod, ha hozzáadod a `.sig` kiterjesztést az URL-jéhez, például `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
