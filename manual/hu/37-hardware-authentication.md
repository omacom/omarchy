# Hardveres hitelesítés

### Ujjlenyomatos hitelesítés

Sok laptop ujjlenyomat-érzékelővel érkezik a hitelesítéshez. Ezt az Omarchyban az Omarchy menü (`Super + Space`) _Setup > Security > Fingerprint_ pontjával használhatod.

Ez egy teljes képernyős ujjlenyomatot nyit meg, amely fokozatosan kitöltődik, ahogy megérinted az érzékelőt. A háttérben az Omarchy telepíti az ujjlenyomat-csomagot, rögzíti a lenyomatodat, ellenőrzi azt, és készen is állsz arra, hogy az ujjlenyomatoddal oldd fel a zárolási képernyőt (amelyet a `Super + Ctrl + L` billentyűkombinációval hívhatsz elő), lépj sudo módba, és hagyj jóvá rendszerkéréseket.

Miután a zárolási képernyő kikapcsolta a kijelzőt, az érzékelő energiatakarékosságból pihenő állapotba lép, ezért mielőtt megérintenéd, ébreszd fel a képernyőt bármelyik billentyűvel vagy az érintőpaddal.

Ha a laptopod fedele le van csukva, az ujjlenyomat-kérés automatikusan kimarad, így egyenesen a jelszókéréshez jutsz, ahelyett hogy egy elérhetetlen érzékelőre várnál. Ha egyébként olyan külső billentyűzeten kell dolgoznod, amelyen nincs érzékelő, egyszerűen nyomd meg a `CTRL + C` billentyűkombinációt, amikor `sudo` közben az ujjlenyomatodat kéri a rendszer.

Az ujjlenyomatos hitelesítést az Omarchy menü _Remove > Security > Fingerprint_ pontja alatt távolíthatod el.

### Fido2-hitelesítés

Ha Fido2-eszközt használsz, beállíthatod `sudo`-hitelesítéshez az Omarchy menü (`Super + Space`) _Setup > Security > Fido2_ pontjával. Ez azonban a `sudo`- és a rendszerengedélyezési kérésekre vonatkozik, a számítógéped feloldására nem.

A fido2-hitelesítést az Omarchy menü _Remove > Security > Fido2_ pontja alatt távolíthatod el.
