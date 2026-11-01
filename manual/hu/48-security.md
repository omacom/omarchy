# Biztonság

Az Omarchy rendkívül komolyan veszi a biztonságot. Ez egy olyan operációs rendszernek készült, amelyet _Valódi Munkára_ használhatsz a _Valódi Világban_. Ahol egy laptop elvesztése nem vezethet biztonsági vészhelyzethez. Íme, ezt tesszük:

1. *A teljes lemeztitkosítás alapértelmezés szerint be van kapcsolva*: Ez a legfontosabb lépés az adataid fizikai védelmének biztosításához. Ha a számítógéped elvész vagy ellopják, az adatok teljesen titkosítva vannak a szabványos LUKS (Linux Unified Key Setup) használatával. A telepítő lehetővé teszi ennek kihagyását eldobható gépek esetén (lásd: [Első lépések](02-getting-started.md)); a titkosítás nélküli telepítés nem rendelkezik ezzel a védelemmel, és bárki, akihez a meghajtó kerül, elolvashatja azt.
2. *A tűzfal alapértelmezés szerint engedélyezve van*: Minden bejövő forgalom alapértelmezés szerint blokkolva van, néhány kivétellel: az 53317-es port a [LocalSend](https://localsend.org/) számára; a DNS-lekérdezések a számítógép saját feloldójához a Docker bridge címén (172.17.0.1), elfogadva azokból a privát címtartományokból, amelyeket a Docker a konténereinek ad; és a multicast DNS (5353-as port), amely lehetővé teszi, hogy a hálózatodon lévő nyomtatók és egyéb eszközök megtalálják egymást, és a számítógéped nevét is hirdeti ott. Ezeken felül a tűzfal megtartja az UFW szokásos engedélyeit a pingre, a cím lekérésére az útválasztódtól (DHCP) és az UPnP-felderítésre. Még az ssh is ki van kapcsolva, amíg be nem kapcsolod a _Setup > Security > SSHD_ útvonalon, amely a beállítás részeként megnyitja a 22-es portot (sebességkorlátozással a brute force ellen). Még a Docker-hozzáférést is lezárjuk a [ufw-docker](https://github.com/chaifeng/ufw-docker) beállítás használatával, hogy megakadályozzuk, hogy a konténereid véletlenül ki legyenek téve a világnak.
3. *Az Arch mindig a legfrissebb frissítésekkel rendelkezik*: Az Arch, az alapul szolgáló disztribúció, amelyre az Omarchy épül, gördülő disztribúció. Ez azt jelenti, hogy minden biztonsági sebezhetőség, amelyet felfedeznek és bármely csomagban javítanak, gyorsan elérhetővé válik telepítésre az `omarchy-update` használatával. Így mindig mindenből a legfrissebb, legbiztonságosabb verziókat futtatod.
4. *Az Omarchy saját csomagokat és tükröt tart fenn*: Az Omarchy alapértelmezés szerint csak az Arch saját core/extra/multilib tárolóiból és a saját Omarchy Package Repository tárolójából származó csomagokra támaszkodik. Telepíthetsz szoftvert közvetlenül az AUR-ból, de az alaptelepítés nem teszi — csak néhány opcionális telepítés, például a harmadik féltől származó böngészők, húz be csomagot az AUR-ból.
5. *A Cloudflare véd minket a DDoS ellen*: Az Omarchy terjesztési infrastruktúrája — az ISO-k, az Omarchy csomagok, az Arch tükör — a Cloudflare félelmetes DDoS-védelme mögött védett, és az ő CDN-jükön van hosztolva. Ez kiváló rendelkezésre állást biztosít.

## A jelszavaid megváltoztatása

Titkosított telepítésen két jelszavad van: az egyik, amely indításkor feloldja a meghajtót, és az, amellyel bejelentkezel és `sudo`-zol. A beállítás ugyanazt állítja be mindkettőhöz. Mindkettő megváltoztatható az Omarchy menüben az _Update > Password_ alatt — az elsőhöz a _Drive Encryption_, a másodikhoz a _User_ szolgál. A meghajtó jelszavának megváltoztatása először a jelenlegit kéri, ezért legyen kéznél. Ha egy módosítás megszakad, futtasd újra a _Drive Encryption_ lehetőséget: a meghajtót most feloldó jelszót kéri, és befejezi a módosítást.

## Egy már használt gép továbbadása

Ha átadod a gépedet valaki másnak, nem kell újratelepítened. Futtasd az Omarchy menüben a _Setup > Reset Computer_ lehetőséget, gépeld be a `reset` szót a megerősítéshez, majd indítsd újra a gépet. Ez minden felhasználói fiókot és mindent töröl a `/home` alatt, eldobja az összes csomagot és rendszer-módosítást, amelyet a telepítés óta végrehajtottál, és törli a gép identitását — a hálózati kapcsolatokat, a host kulcsokat és mindent. Ami ezután elindul, az az első indításkor megjelenő beállítási varázsló, készen arra, hogy az új tulajdonos megadja a saját nevét, jelszavát és titkosítási jelszavát.

Ez úgy működik, hogy visszaállítja azt az alap pillanatképet, amelyet a telepítő készít, ezért csak az Omarchy ISO-ról telepített gépeken érhető el. Titkosítás nélküli meghajtón pedig a visszaállítás törlés, nem biztonságos törlés, ezért ha az adatok érzékenyek voltak, végezz inkább friss telepítést.

## Jelszó nélküli sudo

Néha azt szeretnéd, hogy a `sudo` ne kérdezzen többé, leggyakrabban akkor, amikor egy AI agent hosszú ideig végez rendszer-munkát helyetted. A _Setup > Security > Passwordless Sudo_ megkérdezi, mennyi ideig engedélyezed a hozzáférést: **15 perc**, **1 óra**, **1 nap** vagy **Véglegesen**. Egy piros figyelmeztető ikon jelenik meg a menüsáv többi jelzője mellett, amíg a hozzáférés aktív. Kattints rá, vagy futtasd újra a parancsot a hozzáférés kikapcsolásához. Saját percszámot is megadhatsz (1 és 1440 között) az `omarchy-sudo-passwordless 30` paranccsal, vagy használhatod az `omarchy-sudo-passwordless permanent` parancsot.

Az időzített hozzáférés automatikusan lejár, beleértve közvetlenül azután is, hogy a gép olyan felfüggesztésből tér vissza, amely átlépte a határidőt. A számítógép újraindítása idő előtt véget vet neki. A végleges hozzáférés túléli az újraindításokat, és engedélyezve marad, amíg ki nem kapcsolod.

Az Omarchy beállításcsomagjának frissítése vagy eltávolítása minden ideiglenes engedélyt megszüntet, mielőtt annak lejárati támogatása megváltozna. Ha a parancs hitelesítési vagy takarítási hibát jelez, oldd meg azt, mielőtt újabb engedélyt próbálnál engedélyezni; a hiba nem jelenti azt, hogy a jelszó nélküli hozzáférés inaktív.

Légy tisztában ezzel: amíg be van kapcsolva, bármi, ami a felhasználódként fut, bármit megtehet rootként, kérdés nélkül. Pontosan ez a lényege, és pontosan ez a kockázata is.

## Aláírókulcsok

Az összes ISO-aláírás és az Omarchy tároló csomagjainak nyilvános kulcsa a `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ellenőrzés az openpgp.org oldalon](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Az `omarchy/omarchy-keyring` csomag szintén tartalmazza ezt, és a lehetséges frissítések zökkenőmentes bevezetésére lesz használva.

Bármely ISO-kiadás aláírását megtalálod, ha hozzáadod a `.sig` kiterjesztést az URL-jéhez, például: `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
