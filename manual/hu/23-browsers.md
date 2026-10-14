# Böngészők

Az Omarchy alapértelmezett böngészőként a [Chromiumot](https://www.chromium.org/) szállítja. Ez a nyílt forráskódú, egyszerű build, a rendszered többi részéhez igazított témával, és ezt nyitja meg a `Super + Shift + Return`, valamint ebben fut minden [webalkalmazás](25-web-apps.md).

Ha a Chromium nem ízlésed szerinti, nem kell beérned vele. Az Omarchy menü _Install > Browser_ pontjában megtalálod a Chrome-ot, az Edge-et, a Brave-et, a Brave Origint, a Firefoxot és a [Zent](https://zen-browser.app/). Válassz egyet, és az Omarchy telepíti, beállítja a házirend-könyvtárát, és alkalmazza rá az aktuális témádat.

## Alapértelmezetté tétel

Egy böngésző telepítése nem lépteti elő. Ha már rajta van a gépen, menj a _Setup > Defaults > Browser_ ponthoz, és válaszd ki — a menü csak a ténylegesen telepített böngészőket sorolja fel, és pipával jelöli az aktuális alapértelmezettet.

Terminálból így:

```bash
omarchy default browser firefox
```

Argumentum nélkül futtatva kiírja az aktuális alapértelmezettet. Ez beállítja az XDG-kezelőt, így nem csak az Omarchy gyorsbillentyűi követik — minden, ami linket nyit meg, a csevegőalkalmazástól a terminálparancsig, a kiválasztott böngészőbe megy.

## URL másolása és videó letöltése

A Chromium-család böngészői (maga a Chromium, a Chrome, az Edge és a Brave) két Omarchy-kiegészítővel érkeznek, amelyek kinyúlnak a böngészőből a rendszered többi részébe.

A **Copy URL** az aktuális lap címét az `Alt + Shift + L` kombinációval a vágólapra helyezi. Ez gyorsabb, mint a címsorba kattintás és a másolás, és mivel a rendszer vágólapját használja a böngészőé helyett, Omarchy-értesítést kapsz a megerősítésről, és az URL azonnal elérhető a [vágólap-előzményekben](08-unified-clipboard-history.md) és minden más alkalmazásban. Az eszköztáron gomb is van, ha szívesebben kattintasz.

A **Download Video** az `Alt + Shift + D` kombinációval letölti az éppen nézett oldalon lejátszott videót. Átadja az URL-t a [yt-dlp](https://github.com/yt-dlp/yt-dlp) programnak, így a YouTube-nál jóval több oldalon működik, és a letöltés a `~/Videos` mappába érkezik. A folyamatjelzés ugyanabban a képernyőre fektetett kijelzőben jelenik meg, amelyet a hangerő és a fényerő is használ, helyben frissülve ahelyett, hogy értesítések halmozódnának. Állítsd be az `OMARCHY_YTDLP_DIR` változót, ha a fájlokat máshová szeretnéd — a környezeti változók helyéről lásd a [FAQ](46-faq.md) részt.

Mindkét kiegészítő egy apró natív üzenetközvetítőn keresztül beszél az Omarchyval, amely a böngészővel együtt telepítődik. Ez az a rész, amely lehetővé teszi, hogy egy weboldal videója a saját mappádba, egy URL pedig a vágólapkezelődbe kerüljön, amelyre egy szokásos kiegészítő önmagában nem képes.

Ezek csak a Chromium-családhoz érhetők el. A Firefox és a Zen nem kapja meg őket.

## Firefox és Zen

A Firefox és a Zen más család, ezért más kezelést kapnak: az Omarchy telepít hozzájuk egy házirendfájlt az értelmes alapértelmezésekhez, és natív Wayland-módba kapcsolja őket, ami a tört skálázáshoz és a sima érintőpados görgetéshez szükséges.

Nem kapják meg a fenti Chromium-kiegészítőket, és az Omarchy nem témázza őket, így az élmény ezen részeinek beállítása rád marad.

## Újbóli eltávolítás

Az itt telepített böngészők bármelyikét visszavonhatod az _Remove > Browser_ alatt. A Chromium nincs azon a listán — az alaprendszer része.
