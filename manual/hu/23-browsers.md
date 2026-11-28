# Böngészők

Az Omarchy alapértelmezett böngészőként a [Google Chrome](https://www.google.com/chrome/) böngészővel érkezik. A témája illeszkedik a rendszer többi részéhez, és ezt nyitja meg a `Super + Shift + Return` (vagy a `Super + Shift + B`), a `Super + Shift + Alt + B` billentyűkombinációval pedig egy privát ablakot, és minden [webalkalmazás](25-web-apps.md) is ebben fut. Közvetlenül egy böngészőablakba nyílik: nincs üdvözlőképernyő vagy bejelentkezési felszólítás, a használati statisztikák és az összeomlási jelentések nem kerülnek elküldésre a Google-nak, és a hirdetések adatvédelmére vonatkozó felszólítások ki vannak kapcsolva. A profilgombbal továbbra is bármikor bejelentkezhetsz a Google-fiókodba, amikor csak szinkronizálást szeretnél.

Ha a Chrome nem jön be neked, nem ragadsz bele. Az Omarchy menü _Telepítés > Böngésző_ pontja alatt megtalálod a [Chromium](https://www.chromium.org/) böngészőt (azt a sima nyílt forráskódú buildet, amelyből a Chrome készül), az Edge-et, a Brave-et, a Brave Origint, a Firefoxot és a [Zen](https://zen-browser.app/) böngészőt (az Edge csak x86-os gépeken). Válassz egyet, és az Omarchy telepíti, beállítja a házirendkönyvtárát, és alkalmazza rá az aktuális témádat.

## Az egyik beállítása alapértelmezettként

Egy böngésző telepítése nem teszi azt alapértelmezetté. A váltáshoz menj a _Beállítás > Alapértelmezések > Böngésző_ menüponthoz, és válassz egyet. Az aktuális alapértelmezett egy pipával van megjelölve, és egy olyan böngésző kiválasztása, amely még nincs meg neked, először telepíti azt.

Terminálból így néz ki:

```bash
omarchy default browser firefox
```

Argumentum nélkül futtatva megmondja az aktuális alapértelmezettet. Ez állítja be az XDG-kezelőt, így nem csak az Omarchy gyorsbillentyűi követik — bármi, ami egy linket nyit meg, egy csevegőalkalmazástól egy terminálparancsig, a kiválasztott böngészőbe kerül.

## URL másolása és Videó letöltése

A Chromium-családba tartozó böngészők (maga a Chromium, a Chrome, az Edge, a Brave és a Brave Origin) három Omarchy-bővítménnyel érkeznek: kettő kinyúl a böngészőből a rendszered többi részébe, egy pedig rendet tesz a WhatsAppban.

A **Copy URL** az `Alt + Shift + L` billentyűkombinációval az aktuális lap címét a vágólapodra teszi. Ez gyorsabb, mint belekattintani a címsávba és másolni, és mivel a rendszer vágólapján keresztül megy, nem a böngészőén, Omarchy-értesítést kapsz, amely megerősíti, és az URL azonnal elérhető a [vágólapelőzményekben](08-unified-clipboard-history.md) és minden más alkalmazásban. Van eszköztárgomb is, ha inkább kattintanál.

A **Download Video** az `Alt + Shift + D` billentyűkombinációval megragadja az éppen nézett oldalon lejátszott videót. Az URL-t átadja a [yt-dlp](https://github.com/yt-dlp/yt-dlp) programnak, így a YouTube-on túl sokkal több oldalon is működik, és a letöltés a `~/Videos` mappába érkezik. A folyamat ugyanabban a képernyőn megjelenő kijelzőben jelenik meg, amelyet a hangerő és a fényerő használ, és helyben frissül, ahelyett hogy értesítéseket halmozna fel. Állítsd be az `OMARCHY_YTDLP_DIR` változót, ha inkább máshová szeretnéd tenni a fájlokat — lásd a [GYIK](46-faq.md) részt arról, hová kell tenni a környezeti változókat.

Mindkét bővítmény egy kis natív üzenetkezelő gazdagépen keresztül kommunikál az Omarchyval, amely a böngészővel együtt települ neked. Ez az a darab, amely lehetővé teszi, hogy egy weboldal videója a saját könyvtáradba kerüljön, egy URL pedig a vágólapkezelődbe, amit egy normál bővítmény önmagában nem tud megtenni.

A **WhatsApp Slim** gondoskodik arról, hogy a WhatsApp Web kövesse a rendszertémádat, és összecsukja a csevegési listáját, ha az ablak keskeny.

Ezek csak a Chromium-családhoz tartoznak. A Firefox és a Zen nem kapja meg őket.

## Firefox és Zen

A Firefox és a Zen egy másik család, ezért más kezelést kapnak: az Omarchy telepít egy házirendfájlt a józan alapbeállításokhoz, és natív Wayland módba kapcsolja őket, amit a tört skálázáshoz és a sima görgetéshez a trackpaddel szeretnél.

Nem kapják meg a fenti Chromium-bővítményeket, és az Omarchy nem témázza őket, így az élménynek ezeket a részeit neked kell beállítanod.

## Egyikük eltávolítása ismét

Ezek közül bármelyik böngésző, a Chrome-ot is beleértve, eltávolítható az _Eltávolítás > Böngésző_ alatt. A linkek ezután a Chrome-ba vagy a Chromiumba kerülnek, ha a másik még telepítve van.
