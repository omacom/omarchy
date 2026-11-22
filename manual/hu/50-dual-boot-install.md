# Kettős rendszerindításos telepítés

Telepítheted az Omarchy-t egyetlen partícióra a Windows vagy más telepítések mellé.

Ez a telepítési módszer alapértelmezetten továbbra is LUKS-titkosítással érkezik a partícióhoz, így gyakorlatilag semmiben sem különbözik a teljes meghajtós telepítéstől, és egyszerűen csak szabad helyet igényel a lemezen.

## Hely felszabadítása a Windowsban

A Windows mellé történő telepítéshez írd be a `disk management` kifejezést a Start menübe, és válaszd a **Merevlemez-partíciók létrehozása és formázása** lehetőséget.

 ![dual-boot-1](images/dual-boot-1.webp)

Keresd meg a megfelelő partíciót, kattints rá jobb gombbal, és válaszd a **Kötet zsugorítása** lehetőséget.

![dual-boot-2](images/dual-boot-2.webp)

 Add meg, mennyivel szeretnéd zsugorítani a kötetet. Ne feledd, hogy ez lesz a jövőbeli Omarchy-telepítésed mérete, a rendszerindító partícióval együtt.

 ![dual-boot-3](images/dual-boot-3.webp)

Ha kész vagy, valami hasonlót kell látnod, ahol ebben a példában az 50GB-os rész az, ahová az Omarchy-t telepítjük.

 ![dual-boot-4](images/dual-boot-4.webp)

## Az Omarchy telepítése

Az Omarchy telepítési folyamata gyakorlatilag ugyanaz, mint normál esetben. Miután kiválasztottad a lemezt, megjelenik a **Telepítés szabad helyre** lehetőség. Válaszd ezt a lehetőséget, hogy ne törlődjön a teljes lemez.

 ![dual-boot-5](images/dual-boot-5.webp)

Ellenőrizd, hogy minden rendben van-e, és várd meg, amíg a telepítés a szokásos módon befejeződik. Itt választhatod azt is, hogy titkosítás nélkül telepítesz (nem ajánlott), ugyanúgy, mint egy teljes meghajtós telepítésnél.
 ![dual-boot-6](images/dual-boot-6.webp)

## Más telepítések hozzáadása a rendszerbetöltőhöz

Amikor befejezted az Omarchy telepítését, észre fogod venni, hogy mostantól a Limine rendszerbetöltő az alapértelmezett. Ezzel a Limine-hoz más telepítéseidhez, például a Windowshoz is hozzáadhatsz bejegyzéseket.

Más operációs rendszerek hozzáadásához futtasd a `limine-scan` parancsot, és kövesd az utasításokat a kívánt bejegyzések hozzáadásához a Limine-konfigurációdhoz. A rendszerindító menü alapértelmezetten rejtve marad, és egy másodperc után elindítja az Omarchy-t. A Windows vagy egy másik bejegyzés kiválasztásához nyomj meg egy tetszőleges billentyűt, amint a Limine elindul; amikor megjelenik a menü, a nyílbillentyűkkel válassz ki egy bejegyzést, és nyomd meg az Enter billentyűt. Ha az Omarchy elindul, mielőtt megnyomnál egy billentyűt, indítsd újra, és próbáld újra.

## Bitlocker

Fontos megjegyezni, hogy ez a telepítési módszer nem kompatibilis a Bitlockerrel, mivel az az egész meghajtót titkosítja, nem csak a partíciót. Ha olyan hibát kapsz, amely szerint a Bitlocker engedélyezve van, indítsd el a Windowst, lépj a **Beállítások -> Adatvédelem és biztonság -> Eszköztitkosítás** menüpontba, és kapcsold ki a Bitlockert. A meghajtó visszafejtése eltarthat egy ideig.

 ![dual-boot-7](images/dual-boot-7.webp)

## A Windows újratelepítése

Ha ez a számítógép Windowsszal érkezett, a termékkulcsa a firmware-ben van tárolva. Futtasd az `omarchy windows key` parancsot a kiírásához, így újra aktiválhatod a Windowst, ha valaha újratelepíted ezen a gépen.
