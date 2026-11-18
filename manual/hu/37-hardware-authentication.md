# Hardveres hitelesítés

### Ujjlenyomatos hitelesítés

Sok laptop ujjlenyomat-érzékelővel érkezik a hitelesítéshez. Ezt az Omarchyban úgy használhatod, ha futtatod a _Setup > Security > Fingerprint_ elemet az Omarchy menüben (`Super + Space`).

Ez telepíti az ujjlenyomatos csomagot, rögzíti a lenyomatodat, ellenőrzi azt, és máris készen állsz arra, hogy az ujjlenyomatoddal oldd fel a zárolási képernyőt (amelyet a `Super + Ctrl + L` kombinációval hozhatsz elő), lépj be sudo módba, és engedélyezd a rendszer kéréseit.

Miután a zárolási képernyő kikapcsolta a kijelzőt, az érzékelő pihen, hogy energiát takarítson meg, ezért mielőtt megérintenéd, ébreszd fel a képernyőt bármelyik billentyűvel vagy az érintőpaddal.

Amikor a laptopod fedele le van csukva, az ujjlenyomatos kérés automatikusan kimarad, így egyenesen a jelszókéréshez jutsz, ahelyett hogy egy elérhetetlen érzékelőre várnál. Ha egyébként olyan külső billentyűzeten kell dolgoznod, amelyen nincs érzékelő, csak nyomd meg a `CTRL + C` kombinációt, amikor a `sudo` során az ujjlenyomatodat kéri.

Az ujjlenyomatos hitelesítést az Omarchy menü _Remove > Security > Fingerprint_ pontja alatt távolíthatod el.

### Fido2-hitelesítés

Ha Fido2-eszközt használsz, beállíthatod `sudo` hitelesítésre az Omarchy menü _Setup > Security > Fido2_ pontjával (`Super + Space`). Ez viszont a `sudo` és a rendszer engedélyezési kéréseire terjed ki, a számítógéped feloldására nem.

A fido2-hitelesítést az Omarchy menü _Remove > Security > Fido2_ pontja alatt távolíthatod el.
