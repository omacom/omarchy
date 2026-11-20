# Telepítés kettős rendszerindítással

Telepítheted az Omarchy-t egyetlen partícióra a Windows vagy más telepítések mellé.

Ez a telepítési módszer alapértelmezetten továbbra is LUKS titkosítással érkezik a partícióhoz, így gyakorlatilag semmiben nem különbözik a teljes meghajtós telepítéstől, egyszerűen csak szabad helyre van szükség a lemezen.

## Hely felszabadítása Windowson

Ha a Windows mellé szeretnél telepíteni, írd be a Start menübe a `disk management` kifejezést, és válaszd a **Merevlemez-partíciók létrehozása és formázása** lehetőséget.

 ![dual-boot-1](images/dual-boot-1.webp)

Keresd meg a megfelelő partíciót, kattints rá jobb gombbal, és válaszd a **Kötet zsugorítása** lehetőséget.

![dual-boot-2](images/dual-boot-2.webp)

 Add meg, mennyivel szeretnéd zsugorítani a kötetet. Ne feledd, hogy ez lesz a jövőbeli Omarchy telepítésed mérete, a rendszerindító partíciót is beleértve.

 ![dual-boot-3](images/dual-boot-3.webp)

Ha végeztél, valami hasonlót kell látnod, ahol ebben a példában az 50GB-os részre telepítjük majd az Omarchy-t.

 ![dual-boot-4](images/dual-boot-4.webp)

## Az Omarchy telepítése

Az Omarchy telepítési folyamata gyakorlatilag ugyanaz, mint normál esetben. Miután kiválasztottad a lemezt, megkapod a **Telepítés szabad helyre** lehetőséget. Válaszd ezt a lehetőséget, hogy elkerüld a teljes lemez törlését.

 ![dual-boot-5](images/dual-boot-5.webp)

Ellenőrizd, hogy minden rendben néz-e ki, és várj, amíg a telepítés a szokásos módon befejeződik. Itt választhatod azt is, hogy titkosítás nélkül telepítesz (nem ajánlott), akárcsak a teljes meghajtós telepítésnél.
 ![dual-boot-6](images/dual-boot-6.webp)

## Más telepítések hozzáadása a rendszerbetöltőhöz

Amikor befejezted az Omarchy telepítését, észre fogod venni, hogy mostantól a Limine rendszerbetöltő az alapértelmezett. Ezzel lehetőségeket adhatsz hozzá a Limine-hez a többi telepítésedhez is, például a Windowshoz.

Más operációs rendszerek hozzáadásához futtasd a `limine-scan` parancsot, és kövesd az utasításokat a kívánt bejegyzések hozzáadásához a Limine konfigurációdhoz. A rendszerindító menü alapértelmezetten rejtve marad, és egy másodperc után elindítja az Omarchy-t. A Windows vagy egy másik bejegyzés kiválasztásához nyomj meg egy tetszőleges billentyűt, amint a Limine elindul; amikor megjelenik a menü, a nyílbillentyűkkel válassz ki egy bejegyzést, és nyomd meg az Enter billentyűt. Ha az Omarchy elindul, mielőtt megnyomnál egy billentyűt, indítsd újra a gépet, és próbáld újra.

## Bitlocker

Fontos megjegyezni, hogy ez a telepítési módszer nem kompatibilis a Bitlockerrel, mivel az az egész meghajtót titkosítja, nem csak a partíciót. Ha olyan hibával találkozol, amely szerint a Bitlocker engedélyezve van, indítsd el a Windowst, lépj a **Beállítások -> Adatvédelem és biztonság -> Eszköztitkosítás** menüpontba, és kapcsold ki a Bitlockert. A meghajtó visszafejtése eltarthat egy ideig.

 ![dual-boot-7](images/dual-boot-7.webp)
