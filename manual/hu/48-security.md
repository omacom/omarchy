# Biztonság

Az Omarchy rendkívül komolyan veszi a biztonságot. Ez olyan operációs rendszernek készült, amelyet _valódi munkára_ használhatsz a _valódi világban_. Ahol egy laptop elvesztése nem vezethet biztonsági vészhelyzethez. Nézzük tehát, mit teszünk:

1. *A teljes lemez titkosítása kötelező*: Ez a legfontosabb lépés adataid fizikai védelmének biztosításához. Ha a számítógéped elvész vagy ellopják, az adatok teljesen titkosítva vannak a szabványos LUKS (Linux Unified Key Setup) használatával.
2. *A tűzfal alapértelmezetten be van kapcsolva*: Minden bejövő forgalom alapértelmezetten blokkolva van, kivéve az 53317-es portot a [LocalSendhez](https://localsend.org/). Még az ssh is ki van kapcsolva, amíg be nem kapcsolod a _Beállítás > Biztonság > SSHD_ ponton keresztül, amely a beállítás részeként megnyitja a 22-es portot (nyers erő ellen sebességkorlátozva). A Docker-hozzáférést is lezárjuk a [ufw-docker](https://github.com/chaifeng/ufw-docker) beállítással, hogy megakadályozzuk, hogy a konténereid véletlenül a világnak legyenek kitéve.
3. *Az Archnak mindig a legújabb frissítései vannak*: Az Arch, a mögöttes disztró, amelyre az Omarchy épül, gördülő disztribúció. Ez azt jelenti, hogy bármely biztonsági sebezhetőség, amelyet felfedeznek és javítanak bármely csomagban, gyorsan elérhető telepítésre az `omarchy-update` használatával. Így mindenből mindig a legújabb, legbiztonságosabb verziót futtatod.
4. *Az Omarchy saját csomagokat és tükröt tart fenn*: Az Omarchy alapértelmezetten csak az Arch saját core/extra/multilib tárolóiból és a saját Omarchy csomagtárolójából származó csomagokra támaszkodik. Telepíthetsz szoftvert közvetlenül az AUR-ból, de az alaptelepítés nem — csak néhány opcionális telepítés, például a harmadik felek böngészői, húz az AUR-ból.
5. *A Cloudflare megvéd minket a DDoS-tól*: A teljes Omarchy terjesztési infrastruktúra — az ISO-k, az Omarchy-csomagok, az Arch-tükör — a Cloudflare félelmetes DDoS-pajzsa mögött van védve, és CDN-jén üzemel. Ez kiváló rendelkezésre állást biztosít.

## Jelszavaid megváltoztatása

Egy titkosított telepítésen két jelszavad van: az, amelyik rendszerindításkor feloldja a meghajtót, és az, amellyel bejelentkezel és `sudo` jogot szerzel. A beállítás egyformává teszi őket. Mindkettő megváltoztatható az Omarchy menü _Frissítés > Jelszó_ pontjában — az elsőhöz a _Meghajtótitkosítás_, a másodikhoz a _Felhasználó_. A meghajtójelszó megváltoztatása először a jelenlegit kéri, úgyhogy legyen kéznél. Ha egy változtatás megszakad, futtasd újra a _Meghajtótitkosítás_ pontot: azt a jelszót kéri, amelyik most feloldja a meghajtót, és befejezi a változtatást.

## Egy általad már használt gép továbbadása

Ha valaki másnak adod át a géped, nem kell újratelepítened. Futtasd az Omarchy menü _Beállítás > Gép visszaállítása_ pontját, írd be a `reset` szót a megerősítéshez, és indíts újra. Ez minden felhasználói fiókot és a `/home` minden tartalmát törli, kidob minden csomagot és rendszermódosítást, amelyet a telepítés óta végeztél, és törli a gép identitását — hálózati kapcsolatokat, hosts-kulcsokat és mindent. Ami visszajön, az az első indítás beállításvarázslója, készen arra, hogy új tulajdonosa megadja saját nevét, jelszavát és titkosítási jelszavát.

A telepítő által készített kiindulási pillanatkép visszaállításával működik, így csak Omarchy ISO-ról telepített gépeken érhető el. És egy titkosítás nélküli meghajtón a visszaállítás törlés, nem biztonságos törlés, így ha az adat érzékeny volt, ehelyett végezz friss telepítést.

## Jelszó nélküli sudo

Néha azt akarod, hogy a `sudo` ne kérdezzen többé, leggyakrabban amikor egy AI-ügynök hosszú szakaszban rendszerszintű munkát végez számodra. A _Beállítás > Biztonság > Jelszó nélküli sudo_ megkérdezi, mennyi ideig engedélyezze a hozzáférést: **15 perc**, **1 óra**, **1 nap** vagy **Véglegesen**. Egy piros figyelmeztető ikon jelenik meg a menüsáv többi jelzője mellett, amíg a hozzáférés aktív. Kattints rá, vagy futtasd újra a parancsot a hozzáférés kikapcsolásához. Saját percek számát (1-től 1440-ig) is megadhatod az `omarchy-sudo-passwordless 30` paranccsal, vagy használhatod az `omarchy-sudo-passwordless permanent` parancsot.

Az időzített hozzáférés automatikusan lejár, beleértve közvetlenül egy olyan felfüggesztésből való folytatás után is, amely keresztezte a határidőt. A számítógép újraindítása korán véget vet neki. A végleges hozzáférés túléli az újraindításokat, és addig engedélyezett marad, amíg ki nem kapcsolod.

Az Omarchy beállításcsomagjának frissítése vagy eltávolítása minden ideiglenes engedélyt megszüntet, mielőtt a lejárati támogatása megváltozna. Ha a parancs engedélyezési vagy tisztítási hibát jelez, oldd meg, mielőtt másik engedélyt próbálnál engedélyezni; egy hiba nem jelenti azt, hogy a jelszó nélküli hozzáférés inaktív.

Légy tisztán látó ebben az ügyben: amíg be van kapcsolva, bármi, ami a felhasználódként fut, bármit megtehet rootként rákérdezés nélkül. Ez az egész értelme, és ez az egész kockázat is.

## Aláírókulcsok

Az összes ISO-aláírás és Omarchy repócsomag nyilvános kulcsa `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ellenőrzés az openpgp.org oldalon](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Az `omarchy/omarchy-keyring` csomag ezt is tartalmazza, és zökkenőmentesen minden esetleges frissítés terjesztésére használják.

Bármely ISO-kiadás aláírását megtalálod, ha .sig utótagot adsz az URL-hez. Például https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
