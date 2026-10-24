# Kettős indítású telepítés

Telepítheted az Omarchyt egyetlen partícióra Windows vagy más telepítések mellé.

Ez a telepítési módszer alapértelmezetten továbbra is LUKS-titkosítással érkezik a partícióhoz, így gyakorlatban nem különbözik a teljes meghajtós telepítéstől, és egyszerűen szabad helynek kell lennie a lemezen.

## Hely csinálása Windowson

Ha Windows mellé akarsz telepíteni, írd be a start menübe a `disk management` kifejezést, és válaszd a **Create and format hard disk partitions** lehetőséget.

 ![dual-boot-1](images/dual-boot-1.webp)

Keresd meg a megfelelő partíciót, kattints rá jobb gombbal, és válaszd a **Shrink Volume** lehetőséget.

![dual-boot-2](images/dual-boot-2.webp)

 Add meg, mennyivel szeretnéd zsugorítani a kötetet. Vedd figyelembe, hogy ez lesz a jövőbeli Omarchy-telepítésed mérete a rendszerindító partícióval együtt.

 ![dual-boot-3](images/dual-boot-3.webp)

Ha kész vagy, valami ilyesmit kell látnod, ahol az 50 GB-os szakasz az, ahová ebben a példában az Omarchyt telepítjük.

 ![dual-boot-4](images/dual-boot-4.webp)

## Az Omarchy telepítése

Az Omarchy telepítési folyamata gyakorlatban ugyanaz, mint normálisan. Miután kiválasztottad a lemezed, megkapod a **Free space install** lehetőségét. Válaszd azt a lehetőséget, hogy megakadályozd a teljes lemez törlését.

 ![dual-boot-5](images/dual-boot-5.webp)

Erősítsd meg, hogy minden rendben néz ki, és várd meg, amíg a telepítés a szokásos módon befejeződik. Itt is választhatod a titkosítás nélküli telepítést (nem ajánlott), csak úgy, mint egy teljes meghajtós telepítésnél.
 ![dual-boot-6](images/dual-boot-6.webp)

## Más telepítések hozzáadása a rendszerbetöltőhöz

Amikor befejezed az Omarchy-telepítésed, észreveszed, hogy most a Limine rendszerbetöltő az alapértelmezett. Ezzel lehetőségeket is adhatsz a Limine-hez más telepítéseidre, például a Windowsra.

Ennek érdekében futtasd a `limine-scan` parancsot, és kövesd az utasításokat minden olyan elem hozzáadásához, amelyet a limine-konfigurációdba akarsz. Ezután, amikor elindítod, az Omarchy szokásos lehetőségei mellett a Windows Boot Managert vagy másokat is fogsz látni.

## Bitlocker

Fontos megjegyezni, hogy ez a telepítési módszer nem kompatibilis a Bitlockerrel, mivel az a teljes meghajtót titkosítja, nem csak a partíciót. Ha olyan hibával találkozol, amely szerint a Bitlocker be van kapcsolva, indulj el Windowsra, menj a **Settings -> Privacy & Security -> Device encryption** pontra, és kapcsold ki a Bitlockert. A meghajtó visszafejtése eltarthat egy ideig.

 ![dual-boot-7](images/dual-boot-7.webp)
