# Biztonság

Az Omarchy rendkívül komolyan veszi a biztonságot. Ennek olyan operációs rendszernek kell lennie, amellyel _Valódi Munkát_ végezhetsz a _Valódi Világban_. Ahol egy laptop elvesztése nem vezethet biztonsági vészhelyzethez. Íme, ezt tesszük:

1. *A teljes lemez titkosítása kötelező*: Ez a legfontosabb lépés az adataid fizikai védelmének biztosításához. Ha a számítógéped elvész vagy ellopják, az adatok teljesen titkosítva vannak a szabványos LUKS (Linux Unified Key Setup) használatával.
2. *A tűzfal alapértelmezés szerint engedélyezve van*: Minden bejövő forgalom alapértelmezés szerint blokkolva van, kivéve az 53317-es portot a [LocalSend](https://localsend.org/) számára. Még az ssh is ki van kapcsolva, amíg be nem kapcsolod a _Beállítás > Biztonság > SSHD_ menüpontban, amely a beállítás részeként megnyitja a 22-es portot (a nyers erő elleni védelem érdekében sebességkorlátozással). Még a Docker-hozzáférést is lezárjuk az [ufw-docker](https://github.com/chaifeng/ufw-docker) beállítással, hogy megakadályozzuk, hogy a konténereid véletlenül ki legyenek téve a világnak.
3. *Az Arch mindig a legfrissebb frissítésekkel rendelkezik*: Az Arch, az alapul szolgáló disztribúció, amelyre az Omarchy épül, gördülő disztribúció. Ez azt jelenti, hogy minden felfedezett és bármely csomagban javított biztonsági sebezhetőség gyorsan elérhetővé válik telepítésre az `omarchy-update` használatával. Így mindig mindenből a legfrissebb, legbiztonságosabb verziót futtatod.
4. *Az Omarchy saját csomagokat és tükröt tart fenn*: Az Omarchy alapértelmezés szerint csak az Arch saját core/extra/multilib tárolóiból és a saját Omarchy Package Repository tárolójából származó csomagokra támaszkodik. Telepíthetsz szoftvert közvetlenül az AUR-ból, de az alapszintű telepítés nem teszi — csak néhány opcionális telepítés, például a harmadik féltől származó böngészők, húz az AUR-ból.
5. *A Cloudflare véd minket a DDoS ellen*: Az Omarchy terjesztési infrastruktúrája — az ISO-k, az Omarchy-csomagok, az Arch-tükör — a Cloudflare félelmetes DDoS-pajzsa mögött védett, és az ő CDN-jén van hosztolva. Ez kiváló rendelkezésre állást biztosít.

## A jelszavaid megváltoztatása

Titkosított telepítésen két jelszavad van: az egyik, amelyik indításkor feloldja a meghajtót, és az, amelyikkel bejelentkezel és `sudo`-zol. A telepítő ugyanazt állítja be mindkettőnek. Mindkettő megváltoztatható az Omarchy menü _Frissítés > Jelszó_ pontjában — az első a _Meghajtótitkosítás_, a második a _Felhasználó_ alatt. A meghajtó jelszavának megváltoztatása először a jelenlegit kéri, tehát legyen kéznél. Ha egy változtatás megszakad, futtasd újra a _Meghajtótitkosítás_ pontot: azt a jelszót kéri, amelyik most feloldja a meghajtót, és befejezi a változtatást.

## Egy már használt gép továbbadása

Ha valaki másnak adod át a gépedet, nem kell újratelepítened. Futtasd az Omarchy menü _Beállítás > Számítógép visszaállítása_ pontját, a megerősítéshez gépeld be: `reset`, majd indítsd újra. Ez töröl minden felhasználói fiókot és mindent a `/home` alatt, eldob minden csomagot és rendszer-módosítást, amelyet a telepítés óta tettél, és törli a gép identitását — a hálózati kapcsolatokat, a hosztkulcsokat és mindent. Ami visszajön, az az első indításkor megjelenő beállítóvarázsló, készen arra, hogy az új tulajdonosa megadja a saját nevét, jelszavát és titkosítási jelszavát.

Úgy működik, hogy visszaállítja a telepítő által készített alap pillanatképet, ezért csak az Omarchy ISO-ról telepített gépeken érhető el. Titkosítás nélküli meghajtón pedig a visszaállítás törlés, nem pedig biztonságos törlés, tehát ha az adatok érzékenyek voltak, helyette végezz friss telepítést.

## Jelszó nélküli sudo

Néha azt akarod, hogy a `sudo` ne kérdezzen többet, leggyakrabban akkor, amikor egy AI-ügynök hosszú rendszer-munkát végez helyetted. A _Beállítás > Biztonság > Jelszó nélküli sudo_ megkérdezi, mennyi ideig engedélyezze a hozzáférést: **15 perc**, **1 óra**, **1 nap** vagy **Véglegesen**. Egy piros figyelmeztető ikon jelenik meg a többi menüsávjelző mellett, amíg a hozzáférés aktív. Kattints rá, vagy futtasd újra a parancsot a hozzáférés kikapcsolásához. Megadhatod a saját percek számát is (1-től 1440-ig) az `omarchy-sudo-passwordless 30` paranccsal, vagy használd az `omarchy-sudo-passwordless permanent` parancsot.

Az időzített hozzáférés automatikusan lejár, beleértve közvetlenül az olyan felfüggesztésből való visszatérés után is, amely átlépte a határidőt. A számítógép újraindítása hamarabb véget vet neki. A végleges hozzáférés túléli az újraindításokat, és addig engedélyezve marad, amíg ki nem kapcsolod.

Az Omarchy beállításcsomagjának frissítése vagy eltávolítása minden ideiglenes engedélyt megszüntet, mielőtt megváltozna annak lejárati támogatása. Ha a parancs hitelesítési vagy tisztítási hibát jelez, oldd meg azt, mielőtt újabb engedélyt próbálnál engedélyezni; a hiba nem jelenti azt, hogy a jelszó nélküli hozzáférés inaktív.

Lásd tisztán ezt: amíg be van kapcsolva, bármi, ami a felhasználódként fut, bármit megtehet rootként anélkül, hogy megkérdezné. Pontosan ez a lényege, és pontosan ez a kockázata is.

## Aláírókulcsok

Az összes ISO-aláírás és az Omarchy repó csomagjának nyilvános kulcsa: `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ellenőrzés az openpgp.org oldalon](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Az `omarchy/omarchy-keyring` csomag szintén tartalmazza ezt, és arra lesz használva, hogy zökkenőmentesen terjessze az esetleges frissítéseket.

Bármely ISO-kiadás aláírását megtalálod, ha .sig kiterjesztést adsz az URL-hez. Például https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
