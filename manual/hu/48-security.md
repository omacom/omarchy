# Biztonság

Az Omarchy rendkívül komolyan veszi a biztonságot. Ez egy olyan operációs rendszernek készült, amellyel _Valódi Munkát_ végezhetsz a _Valódi Világban_. Ahol egy laptop elvesztése nem vezethet biztonsági vészhelyzethez. Íme, mit teszünk:

1. *A teljes lemezes titkosítás kötelező*: Ez a legfontosabb lépés adataid fizikai védelmének biztosításához. Ha a számítógéped elveszik vagy ellopják, az adatok teljes mértékben titkosítva vannak a szabványos LUKS (Linux Unified Key Setup) használatával.
2. *A tűzfal alapértelmezetten engedélyezve van*: Minden bejövő forgalom alapértelmezetten blokkolva van, kivéve az 53317-es portot a [LocalSend](https://localsend.org/) számára. Még az ssh is ki van kapcsolva, amíg be nem kapcsolod a _Beállítás > Biztonság > SSHD_ menüpontban, amely a beállítás részeként megnyitja a 22-es portot (brute force ellen sebességkorlátozással). Még a Docker-hozzáférést is lezárjuk a [ufw-docker](https://github.com/chaifeng/ufw-docker) beállítással, hogy megakadályozzuk, hogy a konténereid véletlenül ki legyenek téve a világnak.
3. *Az Arch mindig a legfrissebb frissítésekkel rendelkezik*: Az Arch, az alapul szolgáló disztribúció, amelyre az Omarchy épül, gördülő kiadású disztribúció. Ez azt jelenti, hogy bármely csomagban felfedezett és javított biztonsági sebezhetőség gyorsan elérhetővé válik telepítésre az `omarchy-update` használatával. Így mindig mindenből a legfrissebb, legbiztonságosabb verziót futtatod.
4. *Az Omarchy saját csomagokat és tükröt tart fenn*: Az Omarchy alapértelmezetten csak az Arch saját core/extra/multilib tárolóiból és a saját Omarchy Package Repository tárolójából származó csomagokra támaszkodik. Telepíthetsz szoftvert közvetlenül az AUR-ból, de az alaptelepítés nem teszi — csak néhány opcionális telepítés, például a harmadik féltől származó böngészők, húz be az AUR-ból.
5. *A Cloudflare véd minket a DDoS ellen*: Az Omarchy terjesztési infrastruktúráját — az ISO-kat, az Omarchy csomagokat, az Arch tükröt — a Cloudflare félelmetes DDoS-pajzsa védi, és a CDN-jükön hosztoljuk. Ez kiváló rendelkezésre állást biztosít.

## A jelszavaid megváltoztatása

Egy titkosított telepítésen két jelszavad van: az egyik, amely indításkor feloldja a meghajtót, és az, amellyel bejelentkezel és `sudo`-zol. A beállítás során a kettő ugyanaz lesz. Mindkettő megváltoztatható az Omarchy menü _Frissítés > Jelszó_ pontjában — az első a _Meghajtótitkosítás_, a második a _Felhasználó_ alatt. A meghajtó jelszavának megváltoztatásakor először a jelenlegit kéri, ezért legyen kéznél. Ha egy módosítás megszakad, futtasd újra a _Meghajtótitkosítás_ opciót: azt a jelszót kéri, amely jelenleg feloldja a meghajtót, és befejezi a módosítást.

## Egy már használt gép továbbadása

Ha valaki másnak adod át a gépedet, nem kell újratelepítened. Futtasd az Omarchy menü _Beállítás > Számítógép visszaállítása_ pontját, írd be a `reset` szót a megerősítéshez, és indítsd újra a gépet. Ez töröl minden felhasználói fiókot és mindent a `/home` könyvtárban, eldob minden csomagot és rendszermódosítást, amelyet a telepítés óta végeztél, és törli a gép identitását — a hálózati kapcsolatokat, a host kulcsokat és mindent. Ami újraindul, az az első indításkor megjelenő beállítási varázsló, készen arra, hogy új tulajdonosa megadja a saját nevét, jelszavát és titkosítási jelszavát.

Ez úgy működik, hogy visszaállítja a telepítő által készített alap pillanatképet, ezért csak az Omarchy ISO-ról telepített gépeken érhető el. Titkosítás nélküli meghajtón pedig a visszaállítás törlés, nem pedig biztonságos törlés, ezért ha az adatok érzékenyek voltak, végezz inkább friss telepítést.

## Jelszó nélküli sudo

Néha azt szeretnéd, hogy a `sudo` ne kérdezzen tovább, leggyakrabban akkor, amikor egy AI agent hosszú ideig végez rendszermunkát helyetted. A _Beállítás > Biztonság > Jelszó nélküli Sudo_ megkérdezi, mennyi ideig engedélyezed a hozzáférést: **15 perc**, **1 Óra**, **1 Nap** vagy **Véglegesen**. Amíg a hozzáférés aktív, egy piros figyelmeztető ikon jelenik meg a menüsáv többi jelzője mellett. Kattints rá, vagy futtasd újra a parancsot a hozzáférés kikapcsolásához. Saját percszámot is megadhatsz (1 és 1440 között) az `omarchy-sudo-passwordless 30` paranccsal, vagy használd az `omarchy-sudo-passwordless permanent` parancsot.

Az időzített hozzáférés automatikusan lejár, beleértve azt is, ha egy felfüggesztésből térsz vissza, amely alatt átlépted a határidőt, akkor azonnal lejár. A számítógép újraindítása idő előtt megszünteti. A végleges hozzáférés túléli az újraindításokat, és addig marad engedélyezve, amíg ki nem kapcsolod.

Az Omarchy settings csomagjának frissítése vagy eltávolítása minden ideiglenes engedélyt megszüntet, mielőtt megváltozna annak lejárati támogatása. Ha a parancs hitelesítési vagy takarítási hibát jelez, oldd meg, mielőtt újabb engedélyt próbálnál engedélyezni; a hiba nem jelenti azt, hogy a jelszó nélküli hozzáférés inaktív.

Légy tisztában ezzel: amíg be van kapcsolva, bármi, ami a felhasználód alatt fut, kérdezés nélkül bármit megtehet rootként. Pontosan ez a lényege, és pontosan ez a kockázata is.

## Aláírókulcsok

Az összes ISO-aláíráshoz és az Omarchy repo csomaghoz tartozó nyilvános kulcs a `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ellenőrzés az openpgp.org oldalon](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Az `omarchy/omarchy-keyring` csomag is tartalmazza ezt, és ennek segítségével vezetünk be zökkenőmentesen minden esetleges frissítést.

Bármely ISO-kiadás aláírását megtalálod, ha `.sig` kiterjesztést adsz az URL-jéhez, például `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
