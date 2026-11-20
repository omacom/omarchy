# Biztonság

Az Omarchy rendkívül komolyan veszi a biztonságot. Ennek olyan operációs rendszernek kell lennie, amellyel _Valódi Munkát_ végezhetsz a _Valódi Világban_. Ahol egy laptop elvesztése nem okozhat biztonsági vészhelyzetet. Íme, mit teszünk ennek érdekében:

1. *A teljes lemeztitkosítás alapértelmezés szerint be van kapcsolva*: Ez a legfontosabb lépés az adataid fizikai védelmének biztosításához. Ha a számítógéped elveszik vagy ellopják, az adatok teljes egészében titkosítva vannak a szabványos LUKS (Linux Unified Key Setup) használatával. A telepítő lehetővé teszi a kihagyását eldobható gépek esetén (lásd: [Első lépések](02-getting-started.md)); a titkosítás nélküli telepítés nem rendelkezik ezzel a védelemmel, és bárki, akinél a meghajtó van, elolvashatja azt.
2. *A tűzfal alapértelmezés szerint engedélyezve van*: Alapértelmezés szerint minden bejövő forgalom blokkolva van, néhány kivétellel: az 53317-es port a [LocalSend](https://localsend.org/) számára; a DNS-lekérdezések a számítógép saját feloldójához a Docker bridge címén (172.17.0.1), amelyeket a Docker a tárolóinak adott privát címtartományokból fogad el; valamint a multicast DNS (5353-as port), amely lehetővé teszi, hogy a nyomtatók és más eszközök a hálózatodon megtalálják egymást, és ott a számítógéped nevét is bejelenti. Ezeken felül a tűzfal megtartja az UFW szabványos engedélyeit a pingre, a cím lekérésére az útválasztódtól (DHCP), valamint az UPnP-felderítésre. Még az ssh is ki van kapcsolva, amíg be nem kapcsolod a _Beállítás > Biztonság > SSHD_ menüpontban, amely a beállítás részeként megnyitja a 22-es portot (a nyers erővel végrehajtott támadások ellen sebességkorlátozással). A Docker-hozzáférést is szigorúan korlátozzuk az [ufw-docker](https://github.com/chaifeng/ufw-docker) beállítással, hogy megakadályozzuk, hogy a tárolóid véletlenül ki legyenek téve a világnak.
3. *Az Arch mindig a legfrissebb frissítésekkel rendelkezik*: Az Arch, az alapul szolgáló disztribúció, amelyre az Omarchy épül, gördülő disztribúció. Ez azt jelenti, hogy bármely biztonsági sebezhetőség, amelyet felfedeznek és bármely csomagban javítanak, gyorsan elérhetővé válik telepítésre az `omarchy-update` használatával. Így mindig mindenből a legfrissebb, legbiztonságosabb verziót futtatod.
4. *Az Omarchy saját csomagokat és tükröt tart fenn*: Az Omarchy alapértelmezés szerint csak az Arch saját core/extra/multilib tárolóiból és a saját Omarchy Package Repository tárolójából származó csomagokra támaszkodik. Telepíthetsz szoftvert közvetlenül az AUR-ból, de az alaptelepítés nem teszi — csak néhány opcionális telepítés, például a külső böngészők, húz be csomagot az AUR-ból.
5. *A Cloudflare véd minket a DDoS ellen*: Az Omarchy terjesztési infrastruktúráját — az ISO-kat, az Omarchy-csomagokat, az Arch-tükröt — a Cloudflare félelmetes DDoS-pajzsa védi, és a CDN-jükön hosztoljuk. Ez kiváló rendelkezésre állást biztosít.

## A jelszavak megváltoztatása

Titkosított telepítés esetén két jelszavad van: az egyik, amely rendszerindításkor feloldja a meghajtót, és a másik, amellyel bejelentkezel és `sudo`-zol. A beállítás azonosra állítja őket. Mindkettő megváltoztatható az Omarchy menü _Frissítés > Jelszó_ pontja alatt — az első a _Meghajtótitkosítás_, a második a _Felhasználó_ alatt. A meghajtó jelszavának megváltoztatásakor először a jelenlegit kéri, tehát legyen kéznél. Ha egy módosítás megszakad, futtasd újra a _Meghajtótitkosítás_ műveletet: megkérdezi a meghajtót jelenleg feloldó jelszót, és befejezi a módosítást.

## Egy már használt gép továbbadása

Ha a gépedet átadod valaki másnak, nem kell újratelepítened. Futtasd az Omarchy menü _Eltávolítás > Gyári visszaállítás_ pontját, a megerősítéshez írd be a `reset` szót, majd indítsd újra a gépet. Ez töröl minden felhasználói fiókot és mindent a `/home` könyvtárban, eldobja az összes csomagot és rendszer-módosítást, amelyet a telepítés óta végrehajtottál, és törli a gép identitását — a hálózati kapcsolatokat, a gazdagépkulcsokat és mindent. Ami visszatér, az az első indításkor megjelenő beállítóvarázsló, készen arra, hogy új tulajdonosa megadja a saját nevét, jelszavát és titkosítási jelszavát.

Úgy működik, hogy visszaállítja a telepítő által készített alapállapot-pillanatképet, ezért csak az Omarchy ISO-ról telepített gépeken érhető el. Titkosítás nélküli meghajtón pedig a visszaállítás törlés, nem biztonságos törlés, tehát ha az adatok érzékenyek voltak, végezz inkább friss telepítést.

## Jelszó nélküli sudo

Néha azt szeretnéd, hogy a `sudo` ne kérdezzen tovább, leggyakrabban akkor, amikor egy AI-ügynök hosszú szakaszon át végez rendszer-munkát helyetted. A _Beállítás > Biztonság > Jelszó nélküli sudo_ megkérdezi, mennyi ideig engedélyezed a hozzáférést: **15 perc**, **1 óra**, **1 nap** vagy **Tartósan**. Piros figyelmeztető ikon jelenik meg a többi menüsávjelző mellett, amíg a hozzáférés aktív. Kattints rá, vagy futtasd újra a parancsot a hozzáférés kikapcsolásához. Saját percszámot is megadhatsz (1 és 1440 között) az `omarchy-sudo-passwordless 30` paranccsal, vagy használd az `omarchy-sudo-passwordless permanent` parancsot.

Az időzített hozzáférés automatikusan lejár, beleértve közvetlenül a határidőt átlépő felfüggesztésből való visszatérés után is. A számítógép újraindítása idő előtt véget vet neki. A tartós hozzáférés túléli az újraindításokat, és engedélyezve marad, amíg ki nem kapcsolod.

Az Omarchy beállításcsomagjának frissítése vagy eltávolítása minden ideiglenes engedélyt megszüntet, mielőtt megváltozna a lejáratának támogatása. Ha a parancs engedélyezési vagy tisztítási hibát jelez, oldd meg azt, mielőtt újabb engedélyt próbálnál engedélyezni; a hiba nem jelenti azt, hogy a jelszó nélküli hozzáférés inaktív.

Légy tisztában ezzel: amíg be van kapcsolva, bármi, ami a felhasználód alatt fut, bármit megtehet rootként anélkül, hogy megkérdezné. Pontosan ez a lényege, és pontosan ez a kockázata is.

## Aláírókulcsok

Az összes ISO-aláírás és az Omarchy-tároló csomagjainak nyilvános kulcsa a `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ellenőrzés az openpgp.org oldalon](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Az `omarchy/omarchy-keyring` csomag szintén tartalmazza ezt, és az esetleges frissítések zökkenőmentes bevezetésére lesz használva.

Bármely ISO-kiadás aláírását megtalálod, ha a `.sig` kiterjesztést hozzáadod az URL-jéhez, például `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
