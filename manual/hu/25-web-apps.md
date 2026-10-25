# Webalkalmazások

Az Omarchy menü (`Super + Space`) _Install > Web App_ pontjában adhatod hozzá saját webalkalmazásaidat. Megkérdezi az alkalmazás nevét, az alkalmazás URL-jét és az ikon URL-jét, ha nem tudja lekérni faviconból. Nagyszerű PNG-ikonokat találsz sok népszerű webalkalmazáshoz a [Dashboard Icons](https://dashboardicons.com) oldalon.

Ezután az alkalmazásindítón (`Super + Space`) keresztül érhetők el, és a gyönyörű, keret nélküli webalkalmazás-ablakot használják.

Ha el szeretnél távolítani egy webalkalmazást, csak menj az Omarchy menü _Remove > Web App_ pontjába.

A legjobb, ha egy szokásos böngészőben minden fiókodba bejelentkezel, mielőtt a webalkalmazások gyorsbillentyűit használod. A vékony csomagolókeret nem működik jól az 1passworddel, így könnyebb, ha előbb közvetlenül be vagy jelentkezve.

Ezen webalkalmazások összes billentyűparancsa módosítható a `~/.config/hypr/bindings.lua` fájlban.

Amikor egy webalkalmazásban vagy, az aktuális URL-t a `Shift + Alt + L` kombinációval másolhatod a vágólapra.

Alapértelmezetten az Omarchy már egy sor alapértelmezett alkalmazással érkezik:

## HEY

A [HEY](https://www.hey.com/) egy e-mail- és naptárszolgáltatás, amely kiváló alternatívaként szolgál azoknak, akik belefáradtak a Gmailbe, az Outlookba vagy az Apple Mailbe. A [37signals](https://37signals.com/) készíti, ahonnan az Omarchy származik.

A HEY Emailt a `Super + Shift + E` kombinációval indíthatod, közvetlenül egy új e-mail írásához ugorhatsz a `Super + Shift + Alt + E` kombinációval, a HEY Calendart pedig a `Super + Shift + C` kombinációval indíthatod.

## Basecamp

A [Basecamp](https://basecamp.com/) egy projektmenedzsment-szolgáltatás, amely segít a kis csapatoknak gyorsabban haladni és nagyobb előrehaladást elérni. Ahelyett, hogy Trello-, Slack-, Asana-, Notion- vagy akármilyen összevisszaságot foltoznál össze, a Basecamppel mindent egy helyen megkaphatsz. A [37signals](https://37signals.com/) készíti, ahonnan az Omarchy származik.

A Basecampot az alkalmazásindítón keresztül indíthatod (`Super + Space`)

## ChatGPT

A [ChatGPT](https://chatgpt.com) a világ legnépszerűbb AI-csevegőbotja.

A ChatGPT-t a `Super + Shift + A` kombinációval indíthatod.

## Grok

A [Grok](https://grok.com) az xAI csevegőbotja.

A Grokot a `Super + Shift + Alt + A` kombinációval indíthatod.

## WhatsApp

A [WhatsApp](https://www.whatsapp.com/) a világ egyik legnépszerűbb üzenetküldő szolgáltatása, és a webes verzió kiváló lehetőség Linuxon.

A WhatsAppot a `Super + Shift + Alt + G` kombinációval indíthatod.

## Google-alkalmazások

A Google Messages, a Google Photos, a Google Maps és a Google Contacts szintén webalkalmazásként találhatók meg.

A Google Messages-t a `Super + Shift + Ctrl + G`, a Google Photost a `Super + Shift + P`, a Google Mapset pedig a `Super + Shift + S` kombinációval indíthatod. A Google Contacts az alkalmazásindítón (`Super + Space`) keresztül érhető el.

## X

Az X az a hely, ahol a hírek születnek.

Az X-et a `Super + Shift + X` kombinációval indíthatod, és közvetlenül egy új bejegyzés írásához ugorhatsz a `Super + Shift + Alt + X` kombinációval.

## YouTube

A [YouTube](https://youtube.com/) a világ legnépszerűbb videóplatformja.

A YouTube-ot a `Super + Shift + Y` kombinációval indíthatod.

## Zoom

A [Zoom](https://zoom.us/) a legnépszerűbb videócsevegő-rendszer az Egyesült Államokban. Az egész világon kiváló kapcsolatokat biztosít. És 40 perces megbeszélések fizetős fiók nélkül is tarthatók. Az Omarchy becsomagolja a Zoom webes kliensét, és a zoom-megbeszéléslinkek közvetlenül abban nyílnak meg.

A Zoomot az alkalmazásindítón (`Super + Space`) keresztül indíthatod.

## Discord

A [Discord](https://discord.com/) az a hely, ahol a legtöbb játékos- és nyílt forráskódú közösség időzik, beleértve az [Omarchy sajátját](https://discord.gg/tXFUdasqhY) is.

A Discordot az alkalmazásindítón (`Super + Space`) keresztül indíthatod.

## Microsoft-alkalmazások

Válaszd az _Install > Service > Microsoft_ pontot az Outlook, a Word, az Excel, a PowerPoint, a Teams és a OneDrive webalkalmazásként történő hozzáadásához. Minden alkalmazásnak van saját indítója, és közvetlenül megnyílik, a kereskedelmi Microsoft 365 URL-eket és a meglévő böngészőprofilodat használva. Ugyanazokban a böngésző-alkalmazásablakokban nyílnak, mint az Omarchy többi webalkalmazása; nem telepítik a különálló Teams for Linux klienst.

A csomagot az _Remove > Service > Microsoft_ ponttal távolítsd el, vagy az egyes alkalmazásokat az _Remove > Web App_ ponttal. Az _Install > Web App_ pontban csak a kívánt alkalmazásokat is telepítheted.

Kormányzati vagy szuverén felhő esetén szerkeszd az `Exec=` soron lévő URL-t a vonatkozó indítóban a `~/.local/share/applications/` alatt, például a `Microsoft Teams.desktop` fájlban, a szervezeted által megadott URL-t használva. Ebben a sorban minden literális `%` jelet `%%` formában írj. A módosítások a következő indításkor lépnek életbe. A csomagtelepítő újrafuttatása visszaállítja az indítók alapértelmezett URL-jeit.

A munkahelyi bejelentkezések különválasztásához fűzz hozzá egy böngészőadatkönyvtárat minden indító `Exec=` sorához:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Cseréld ki a példakönyvtárat egy általad választott abszolút útvonalra, és használd ugyanazt az útvonalat mind a hat indítóhoz, hogy megosszák a munkahelyi bejelentkezéseket. A webalkalmazások az Omarchy által kiválasztott, támogatott böngészőt használják, és a Chromiumra esnek vissza, amikor az alapértelmezett böngésző nem támogatott.
