# Telepítés kettős rendszerindítással

Az Omarchy egyetlen partícióra is telepíthető a Windows vagy más telepítések mellé.

Ez a telepítési mód alapértelmezetten szintén LUKS titkosítást használ a partícióhoz, így gyakorlatilag semmiben sem különbözik a teljes meghajtót használó telepítéstől, mindössze szabad helyre van szükség a lemezen.

## Hely felszabadítása a Windowsban

A Windows mellé történő telepítéshez írd be a Start menübe a következőt: `disk management`, majd válaszd a **Lemezpartíciók létrehozása és formázása** lehetőséget.

 ![dual-boot-1](images/dual-boot-1.webp)

Keresd meg a megfelelő partíciót, kattints rá jobb gombbal, és válaszd a **Kötet zsugorítása** lehetőséget.

![dual-boot-2](images/dual-boot-2.webp)

 Add meg, mekkora mérettel szeretnéd zsugorítani a kötetet. Ne feledd, ez lesz a jövőbeli Omarchy telepítésed mérete, a boot partíciót is beleértve.

 ![dual-boot-3](images/dual-boot-3.webp)

Ha végeztél, valami ehhez hasonlót kell látnod, ahol ebben a példában az 50GB-os rész az, ahová az Omarchyt telepíteni fogjuk.

 ![dual-boot-4](images/dual-boot-4.webp)

## Az Omarchy telepítése

Az Omarchy telepítési folyamata gyakorlatilag ugyanaz, mint normál esetben. Miután kiválasztottad a lemezt, megjelenik a **Telepítés szabad helyre** lehetőség. Válaszd ezt a lehetőséget, hogy elkerüld a teljes lemez törlését.

 ![dual-boot-5](images/dual-boot-5.webp)

Ellenőrizd, hogy minden rendben van-e, majd várd meg, amíg a telepítés a szokásos módon befejeződik. Itt választhatod azt is, hogy titkosítás nélkül telepítesz (nem ajánlott), ugyanúgy, mint a teljes meghajtós telepítésnél.
 ![dual-boot-6](images/dual-boot-6.webp)

## Más telepítések hozzáadása a rendszerbetöltőhöz

Amikor befejezted az Omarchy telepítését, észre fogod venni, hogy mostantól a Limine rendszerbetöltő az alapértelmezett. Ezzel a Limine-hez más telepítéseidhez, például a Windowshoz is hozzáadhatsz bejegyzéseket.

Más operációs rendszerek hozzáadásához futtasd a `limine-scan` parancsot, és kövesd az utasításokat a kívánt bejegyzések hozzáadásához a Limine konfigurációdhoz. A rendszerindító menü alapértelmezetten rejtve marad, és egy másodperc múlva elindítja az Omarchyt. A Windows vagy egy másik bejegyzés kiválasztásához nyomj meg egy tetszőleges billentyűt, amint a Limine elindul; amikor megjelenik a menü, a nyílbillentyűkkel válassz ki egy bejegyzést, majd nyomd meg az Enter billentyűt. Ha az Omarchy elindul, mielőtt megnyomnál egy billentyűt, indítsd újra a gépet, és próbáld újra. Ha bekapcsoltad a _Setup > Direct Boot_ lehetőséget, a firmware teljesen kihagyja a Limine-t, ezért válaszd a Limine-t a BIOS rendszerindító menüjéből, vagy futtasd újra a _Setup > Direct Boot_ lehetőséget a bejegyzés eltávolításához.

## Bitlocker

Fontos megjegyezni, hogy ez a telepítési mód nem kompatibilis a Bitlockerrel, mivel az a teljes meghajtót titkosítja, nem csak a partíciót. Ha olyan hibába ütközöl, amely szerint a Bitlocker engedélyezve van, indítsd el a Windowst, lépj a **Beállítások -> Adatvédelem és biztonság -> Eszköztitkosítás** menüpontba, és kapcsold ki a Bitlockert. A meghajtó visszafejtése eltarthat egy ideig.

 ![dual-boot-7](images/dual-boot-7.webp)
