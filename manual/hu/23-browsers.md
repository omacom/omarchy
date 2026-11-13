# Böngészők

Az Omarchy alapértelmezett böngészőként a [Google Chrome](https://www.google.com/chrome/) böngészőt szállítja. A témája illeszkedik a rendszered többi részéhez, ez nyílik meg a `Super + Shift + Return` billentyűkombinációval, és ebben fut minden [webalkalmazás](25-web-apps.md) is. Egyenesen böngészőablakkal indul: nincs üdvözlőképernyő vagy bejelentkezésre felszólító üzenet, a használati statisztikákat és az összeomlási jelentéseket nem küldi el a Google-nak, a hirdetések adatvédelmével kapcsolatos felszólítások pedig ki vannak kapcsolva. Ha szeretnéd a szinkronizálást, a profilgombra kattintva bármikor bejelentkezhetsz a Google-fiókodba.

Ha a Chrome nem a te ízlésed, nem vagy hozzákötve. Az Omarchy menü _Telepítés > Böngésző_ pontja alatt megtalálod a [Chromium](https://www.chromium.org/) böngészőt (a sima, nyílt forráskódú buildet, amelyből a Chrome is készül), az Edge-et, a Brave-et, a Brave Origint, a Firefoxot és a [Zen](https://zen-browser.app/) böngészőt. Válassz egyet, és az Omarchy telepíti, beállítja a házirendkönyvtárát, és alkalmazza rá az aktuális témádat.

## Az egyik beállítása alapértelmezettként

Attól, hogy telepítesz egy böngészőt, még nem lesz alapértelmezett. Ha már fent van a gépen, menj a _Beállítás > Alapértelmezések > Böngésző_ menüpontba, és válaszd ki — a menü csak azokat a böngészőket sorolja fel, amelyeket ténylegesen telepítettél, az aktuális alapértelmezettet pedig pipával jelöli.

Terminálból így megy:

```bash
omarchy default browser firefox
```

Argumentum nélkül futtatva megmondja, mi az aktuális alapértelmezett. Ez az XDG-kezelőt állítja be, így nem csak az Omarchy gyorsbillentyűi igazodnak hozzá — minden, ami linket nyit meg, a csevegőalkalmazástól a terminálparancsig, az általad választott böngészőbe kerül.

## URL másolása és videó letöltése

A Chromium-család böngészői (maga a Chromium, a Chrome, az Edge és a Brave) két Omarchy-bővítménnyel érkeznek, amelyek kinyúlnak a böngészőből a rendszered többi részébe.

Az **URL másolása** az `Alt + Shift + L` billentyűkombinációval a vágólapra teszi az aktuális lap címét. Ez gyorsabb, mint belekattintani a címsorba és másolni, és mivel a rendszer vágólapján keresztül megy, nem a böngészőén, Omarchy-értesítés erősíti meg, és az URL azonnal elérhető a [vágólapelőzményekben](08-unified-clipboard-history.md) és minden más alkalmazásban is. Van eszköztárgomb is, ha inkább kattintanál.

A **Videó letöltése** az `Alt + Shift + D` billentyűkombinációval letölti az éppen nézett oldalon lejátszott videót. Átadja az URL-t a [yt-dlp](https://github.com/yt-dlp/yt-dlp) programnak, így messze nem csak a YouTube-on működik, a letöltés pedig a `~/Videos` mappába érkezik. A folyamat ugyanabban a képernyőn megjelenő kijelzésben látszik, amelyet a hangerő és a fényerő is használ, és helyben frissül ahelyett, hogy egymásra halmozná az értesítéseket. Állítsd be az `OMARCHY_YTDLP_DIR` változót, ha inkább máshová szeretnéd menteni a fájlokat — a környezeti változók helyéről lásd a [GYIK](46-faq.md) részt.

Mindkét bővítmény egy kis natív üzenetküldő gazdaprogramon keresztül kommunikál az Omarchyval, amely a böngészővel együtt települ. Ez az a darab, amely lehetővé teszi, hogy egy weboldal videója a saját könyvtáradba, egy URL pedig a vágólapkezelődbe kerüljön, amire egy átlagos bővítmény önmagában nem képes.

Ezek csak a Chromium-családhoz járnak. A Firefox és a Zen nem kapja meg őket.

## Firefox és Zen

A Firefox és a Zen más családba tartozik, ezért más elbánásban részesül: az Omarchy egy házirendfájlt telepít az ésszerű alapértelmezésekhez, és natív Wayland módba kapcsolja őket, amelyet tört skálázáshoz és sima, érintőpados görgetéshez akarsz.

Nem kapják meg a fenti Chromium-bővítményeket, és az Omarchy sem témázza őket, így az élménynek ezeket a részeit neked kell beállítanod.

## Eltávolítás

Ezek bármelyike, a Chrome-ot is beleértve, újra eltávolítható az _Eltávolítás > Böngésző_ menüpont alatt. Ezután a linkek a Chrome-ban vagy a Chromiumban nyílnak meg, ha a másik még telepítve van.
