# Biztonság

Az Omarchy rendkívül komolyan veszi a biztonságot. Ez egy olyan operációs rendszernek készült, amelyet _Valódi Munkára_ használhatsz a _Valódi Világban_. Ahol egy laptop elvesztése nem vezethet biztonsági vészhelyzethez. Íme, mit teszünk:

1. *Alapértelmezés szerint be van kapcsolva a teljes lemeztitkosítás*: Ez a legfontosabb lépés adataid fizikai védelmének biztosításához. Ha a számítógéped elveszik vagy ellopják, az adatok teljes mértékben titkosítva vannak a szabványos LUKS (Linux Unified Key Setup) használatával. A telepítő lehetővé teszi, hogy eldobható gépek esetén lemondj róla (lásd [Első lépések](02-getting-started.md)); a titkosítás nélküli telepítés nem rendelkezik ezzel a védelemmel, és bárki, akinél a meghajtó van, elolvashatja azt.
2. *Alapértelmezés szerint engedélyezve van a tűzfal*: Minden bejövő forgalom alapértelmezés szerint blokkolva van, néhány kivétellel: az 53317-es port a [LocalSend](https://localsend.org/) számára; a DNS-lekérdezések a számítógép saját feloldójához a Docker bridge címén (172.17.0.1), amelyeket a Docker által a konténereinek adott privát címtartományokból fogad el; és a multicast DNS (5353-as port), amely lehetővé teszi, hogy a nyomtatók és más eszközök a hálózatodon megtalálják egymást, és ott a számítógéped nevét is közzéteszi. Ezeken felül a tűzfal megtartja az UFW szokásos engedélyeit a ping, a cím lekérése az útválasztódtól (DHCP) és az UPnP-felderítés számára. Még az ssh is ki van kapcsolva, amíg be nem kapcsolod a _Beállítás > Biztonság > SSHD_ pont alatt, amely engedélyezi az SSH-kulcsodat, kikapcsolja a jelszavas bejelentkezéseket, és csak ezután nyitja meg a 22-es portot (sebességkorlátozással a brute force ellen). Még a Docker-hozzáférést is lezárjuk a [ufw-docker](https://github.com/chaifeng/ufw-docker) beállítás használatával, hogy megakadályozzuk, hogy a konténereid véletlenül ki legyenek téve a világnak.
3. *Az Arch mindig a legfrissebb frissítésekkel rendelkezik*: Az Arch, a mögöttes disztribúció, amelyre az Omarchy épül, gördülő disztribúció. Ez azt jelenti, hogy bármely felfedezett és bármely csomagban javított biztonsági sebezhetőség gyorsan elérhetővé válik telepítésre az `omarchy-update` használatával. Így mindig mindenből a legújabb, legbiztonságosabb verziókat futtatod.
4. *Az Omarchy saját csomagokat és tükröt tart fenn*: Az Omarchy alapértelmezés szerint csak az Arch saját core/extra/multilib tárolóiból származó csomagokra támaszkodik (ARM gépeken az Arch Linux ARM tárolóira, valamint Apple Silicon esetén az Asahi ALARM-ra) és a saját Omarchy Package Repositoryjára. Telepíthetsz szoftvert közvetlenül az AUR-ból, de az alaptelepítés nem teszi — csak néhány opcionális telepítés, például a harmadik féltől származó böngészők származnak az AUR-ból.
5. *A Cloudflare véd minket a DDoS ellen*: Az Omarchy terjesztési infrastruktúráját — az ISO-kat, az Omarchy-csomagokat, az Arch-tükröt — a Cloudflare félelmetes DDoS-pajzsa védi, és a CDN-jükön van hosztolva. Ez kiváló rendelkezésre állást biztosít.

## Jelszavaid megváltoztatása

Titkosított telepítés esetén két jelszavad van: az egyik, amely rendszerindításkor feloldja a meghajtót, és a másik, amellyel bejelentkezel és `sudo`-zol. A beállítás során ugyanazt kapják. Mindkettő megváltoztatható az Omarchy menü _Frissítés > Jelszó_ pontja alatt — az első a _Meghajtótitkosítás_, a második a _Felhasználó_ alatt. A meghajtó jelszavának megváltoztatása először a jelenlegit kéri, tehát legyen kéznél. Ha egy módosítás megszakad, futtasd újra a _Meghajtótitkosítás_ műveletet: megkérdezi a meghajtót jelenleg feloldó jelszót, és befejezi a módosítást.

## Egy már használt gép továbbadása

Ha másnak adod át a gépedet, nem kell újratelepítened. Futtasd az Omarchy menüben az _Eltávolítás > Gyári visszaállítás_ parancsot, írd be a `reset` szót a megerősítéshez, add meg a meghajtótitkosítási jelszavadat, ha kéri, és indítsd újra a gépet. Ez töröl minden felhasználói fiókot és mindent a `/home` könyvtárban, eldob minden csomagot és rendszer-módosítást, amelyet a telepítés óta végeztél, és törli a gép identitását — a hálózati kapcsolatokat, a hostkulcsokat és mindent. Ami újraindul, az az első rendszerindításkor megjelenő beállítási varázsló, készen arra, hogy új tulajdonosa megadja a saját nevét, jelszavát és titkosítási jelszavát.

Úgy működik, hogy visszaállítja a telepítő által készített alap pillanatképet, ezért csak az Omarchy ISO-ról telepített gépeken érhető el. Titkosítás nélküli meghajtón pedig a visszaállítás törlés, nem biztonságos törlés, ezért ha az adatok érzékenyek voltak, végezz inkább friss telepítést.

## Jelszó nélküli sudo

Néha azt akarod, hogy a `sudo` ne kérdezzen többé, leggyakrabban akkor, amikor egy AI agent hosszú ideig rendszermunkát végez helyetted. A _Beállítás > Biztonság > Jelszó nélküli sudo_ megkérdezi, mennyi ideig engedélyezed a hozzáférést: **15 perc**, **1 óra**, **1 nap** vagy **Állandóan**. Egy piros figyelmeztető ikon jelenik meg a többi menüsor-jelző mellett, amíg a hozzáférés aktív. Kattints rá, vagy futtasd újra a parancsot a hozzáférés kikapcsolásához. Saját percszámot is megadhatsz (1 és 1440 között) az `omarchy-sudo-passwordless 30` paranccsal, vagy használhatod az `omarchy-sudo-passwordless permanent` parancsot.

Az időzített hozzáférés automatikusan lejár, beleértve közvetlenül azután is, hogy visszatérsz egy olyan felfüggesztésből, amely átlépte a határidőt. A számítógép újraindítása korábban véget vet neki. Az állandó hozzáférés túléli az újraindításokat, és engedélyezve marad, amíg ki nem kapcsolod.

Az Omarchy beállításcsomagjának frissítése vagy eltávolítása minden ideiglenes engedélyt megszüntet, mielőtt megváltozna annak lejárati támogatása. Ha a parancs engedélyezési vagy takarítási hibát jelez, oldd meg azt, mielőtt megpróbálnál egy másik engedélyt engedélyezni; a hiba nem jelenti azt, hogy a jelszó nélküli hozzáférés inaktív.

Légy tisztában ezzel: amíg be van kapcsolva, bármi, ami a felhasználódként fut, bármit megtehet rootként anélkül, hogy megkérdezné. Ez az egész lényege, és ez az egész kockázata is.

## Aláírókulcsok

Az összes ISO-aláírás és az Omarchy tárolócsomag nyilvános kulcsa a `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ellenőrzés az openpgp.org oldalon](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Az `omarchy/omarchy-keyring` csomag szintén tartalmazza ezt, és az esetleges frissítések zökkenőmentes bevezetésére lesz használva.

Bármely ISO-kiadás aláírását megtalálod, ha hozzáadod a `.sig` kiterjesztést az URL-jéhez, például `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
