# Böngészők

Az Omarchy alapértelmezett böngészőként a [Google Chrome](https://www.google.com/chrome/) böngészővel érkezik. A témája illeszkedik a rendszered többi részéhez, és ezt nyitja meg a `Super + Shift + Return` (vagy a `Super + Shift + B`), a `Super + Shift + Alt + B` billentyűkombinációval pedig egy privát ablakát, és ebben fut minden [webalkalmazás](25-web-apps.md) is. Egyenesen egy böngészőablakban nyílik meg: nincs üdvözlőképernyő vagy bejelentkezésre felszólító üzenet, a használati statisztikák és az összeomlási jelentések nem kerülnek elküldésre a Google-nak, a hirdetések adatvédelmével kapcsolatos felszólítások pedig ki vannak kapcsolva. A szinkronizáláshoz a profilgombbal továbbra is bármikor bejelentkezhetsz a Google-fiókodba, amikor csak akarsz.

Ha a Chrome nem a te ízlésed szerint való, nem vagy hozzáláncolva. Az Omarchy menüben az _Install > Browser_ alatt megtalálod a [Chromium](https://www.chromium.org/) böngészőt (azt a sima, nyílt forráskódú buildet, amelyből a Chrome készül), az Edge, a Brave, a Brave Origin, a Firefox, a [Zen](https://zen-browser.app/) és a [Ladybird](https://ladybird.org/) böngészőt (az Edge csak x86-os gépeken). Válassz egyet, és az Omarchy telepíti, beállítja a policy könyvtárát, és rávetíti az aktuális témádat.

## Az egyik alapértelmezetté tétele

Egy böngésző telepítése nem teszi alapértelmezetté. A váltáshoz lépj a _Setup > Defaults > Browser_ menüponthoz, és válassz egyet. A jelenlegi alapértelmezettet egy pipa jelöli, és ha olyan böngészőt választasz, amelyik még nincs meg neked, az először települ.

Terminálból így megy:

```bash
omarchy default browser firefox
```

Futtasd argumentum nélkül, és megmondja a jelenlegi alapértelmezettet. Ez az XDG-kezelőt állítja be, tehát nem csak az Omarchy gyorsbillentyűi igazodnak hozzá — minden, ami linket nyit meg, egy csevegőalkalmazástól egy terminálparancsig, a választott böngésződben köt ki.

## URL másolása és videó letöltése

A Chromium-családba tartozó böngészők (maga a Chromium, a Chrome, az Edge, a Brave és a Brave Origin) három Omarchy-bővítménnyel érkeznek: kettő kinyúl a böngészőből a rendszered többi részébe, egy pedig rendbe teszi a WhatsAppot.

A **Copy URL** az `Alt + Shift + L` billentyűkombinációval a vágólapodra teszi az aktuális fül címét. Ez gyorsabb, mint belekattintani a címsávba és kimásolni, és mivel a rendszer vágólapján keresztül megy a böngészőé helyett, egy Omarchy-értesítést kapsz, amely megerősíti, és az URL azonnal elérhető a [vágólap-előzményekben](08-unified-clipboard-history.md) és minden más alkalmazásban. Van hozzá eszköztárgomb is, ha inkább kattintanál.

A **Download Video** az `Alt + Shift + D` billentyűkombinációval elkapja az éppen nézett oldalon lejátszott videót. Átadja az URL-t a [yt-dlp](https://github.com/yt-dlp/yt-dlp) eszköznek, így a YouTube-nál jóval több helyen is működik, a letöltés pedig a `~/Videos` mappába érkezik. A folyamat ugyanabban a képernyőn megjelenő kijelzőben jelenik meg, amelyet a hangerő és a fényerő használ, és helyben frissül, ahelyett hogy egymásra halmozná az értesítéseket. Állítsd be az `OMARCHY_YTDLP_DIR` változót, ha inkább máshová szeretnéd tenni a fájlokat — a környezeti változók helyéről lásd a [GYIK](46-faq.md) részt.

Mindkét bővítmény egy kicsi, natív üzenetkezelő gazdagépen keresztül beszél az Omarchyval, amely a böngészővel együtt települ neked. Ez az a darab, amely lehetővé teszi, hogy egy weboldal videója a saját könyvtáradban kössön ki, egy URL pedig a vágólapkezelődben, amire egy normál bővítmény önmagában nem képes.

A **WhatsApp Slim** ráveszi a WhatsApp Webet, hogy kövesse a rendszertémádat, és összecsukja a csevegéslistáját, amikor az ablak keskeny.

Ezek csak a Chromium-családban érhetők el. A Firefox és a Zen nem kapja meg őket.

## Firefox és Zen

A Firefox és a Zen másik család, ezért más bánásmódban részesülnek: az Omarchy telepít hozzájuk egy policies fájlt észszerű alapértelmezésekkel, és natív Wayland módba kapcsolja őket, amire a tört léptékű méretezéshez és a sima érintőpados görgetéshez szükséged van.

Nem kapják meg a fenti Chromium-bővítményeket, és az Omarchy sem témázza őket, tehát az élmény ezen részeit neked kell beállítanod.

## Ladybird

A Ladybird egy a nulláról írt böngésző, saját motorral a Chromium vagy a Firefox motorja helyett. Még alfa állapotban van, tehát számíts olyan oldalakra, amelyek még nem működnek, az Omarchy pedig úgy telepíti, ahogy érkezik: bővítmények, téma és policyk nélkül. Privát ablaka sincs, ezért a `Super + Shift + Alt + B` egy ideiglenes profillal nyitja meg, amely bezáráskor törlődik. A [webalkalmazások](25-web-apps.md) továbbra is Chrome-ban vagy Chromiumban futnak.

## Eltávolítás

Ezen böngészők bármelyike, a Chrome-ot is beleértve, ismét eltávolítható az _Remove > Browser_ alatt. A linkek ezután a Chrome-ba vagy a Chromiumba mennek, ha a másik még telepítve van.
