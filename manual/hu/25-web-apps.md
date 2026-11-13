# Webes alkalmazások

Saját webes alkalmazásokat adhatsz hozzá az Omarchy menüben (`Super + Space`) az _Install > Web App_ menüponttal. Meg kell adnod az alkalmazás nevét, az alkalmazás URL-jét és az ikon URL-jét, ha nem tudja lekérni a favicon alapján. Számos népszerű webes alkalmazáshoz találsz kiváló PNG-ikonokat a [Dashboard Icons](https://dashboardicons.com) oldalon.

Ezután az alkalmazásindítón (`Super + Space`) keresztül érheted el őket, és a gyönyörű, keret nélküli webalkalmazás-ablakot használják.

Ha el szeretnél távolítani egy webes alkalmazást, egyszerűen lépj az Omarchy menü _Remove > Web App_ menüpontjára.

A legjobb, ha a webalkalmazás-parancsikonok használata előtt egy hagyományos böngészőben jelentkezel be az összes fiókodba. A vékony keretalkalmazás nem működik jól a 1password szolgáltatással, ezért egyszerűbb, ha előbb közvetlenül bejelentkezel.

Ezeknek a webes alkalmazásoknak az összes billentyűparancsa módosítható a `~/.config/hypr/bindings.lua` fájlban.

Amikor egy webes alkalmazásban vagy, a `Shift + Alt + L` billentyűkombinációval a vágólapra másolhatod az aktuális URL-t.

Az Omarchy alapértelmezetten már számos alapértelmezett alkalmazással érkezik:

## HEY

A [HEY](https://www.hey.com/) egy e-mail- és naptárszolgáltatás, amely remek alternatívát kínál azoknak, akiknek elegük van a Gmail, az Outlook vagy az Apple Mail használatából. A [37signals](https://37signals.com/) készíti, ahonnan az Omarchy is származik.

A HEY Email alkalmazást a `Super + Shift + E` billentyűkombinációval indíthatod el, a `Super + Shift + Alt + E` billentyűkombinációval közvetlenül új e-mail írására ugorhatsz, a HEY Calendar alkalmazást pedig a `Super + Shift + C` billentyűkombinációval indíthatod el.

## Basecamp

A [Basecamp](https://basecamp.com/) egy projektmenedzsment-szolgáltatás, amely segít a kis csapatoknak gyorsabban haladni és több eredményt elérni. Ahelyett, hogy a Trello, a Slack, az Asana, a Notion vagy bármi más összevissza keverékét foltoznád össze, a Basecamp segítségével mindezt egy helyen megkaphatod. A [37signals](https://37signals.com/) készíti, ahonnan az Omarchy is származik.

A Basecampet az alkalmazásindítóval (`Super + Space`) indíthatod el.

## ChatGPT

A [ChatGPT](https://chatgpt.com) a világ legnépszerűbb AI-chatbotja.

A ChatGPT-t a `Super + Shift + A` billentyűkombinációval indíthatod el.

## Grok

A [Grok](https://grok.com) az xAI chatbotja.

A Grokot a `Super + Shift + Alt + A` billentyűkombinációval indíthatod el.

## WhatsApp

A [WhatsApp](https://www.whatsapp.com/) a világ egyik legnépszerűbb üzenetküldő szolgáltatása, és a webes változata remek lehetőség Linuxon.

A WhatsAppot a `Super + Shift + Alt + G` billentyűkombinációval indíthatod el.

## Google-alkalmazások

A Google Messages, a Google Photos, a Google Maps és a Google Contacts is webes alkalmazásként szerepel.

A Google Messages alkalmazást a `Super + Shift + Ctrl + G`, a Google Photos alkalmazást a `Super + Shift + P`, a Google Maps alkalmazást pedig a `Super + Shift + S` billentyűkombinációval indíthatod el. A Google Contacts az alkalmazásindítón (`Super + Space`) keresztül érhető el.

## X

Az X az a hely, ahol berobbannak a hírek.

Az X-et a `Super + Shift + X` billentyűkombinációval indíthatod el, és a `Super + Shift + Alt + X` billentyűkombinációval közvetlenül új bejegyzés írására ugorhatsz.

## YouTube

A [YouTube](https://youtube.com/) a világ legnépszerűbb videóplatformja.

A YouTube-ot a `Super + Shift + Y` billentyűkombinációval indíthatod el.

## Zoom

A [Zoom](https://zoom.us/) a legnépszerűbb videóchat-rendszer az Egyesült Államokban. Kiváló kapcsolatok világszerte. És 40 perces megbeszélések fizetős fiók nélkül is tarthatók. Az Omarchy a Zoom webes kliensét csomagolja, és a Zoom-megbeszélésekre mutató hivatkozások közvetlenül abban nyílnak meg.

A Zoomot az alkalmazásindítóval (`Super + Space`) indíthatod el.

## Discord

A [Discord](https://discord.com/) az a hely, ahol a legtöbb játékos és nyílt forráskódú közösség lóg, beleértve [az Omarchy sajátját](https://discord.gg/tXFUdasqhY) is.

A Discordot az alkalmazásindítóval (`Super + Space`) indíthatod el.

## Microsoft-alkalmazások

Válaszd az _Install > Service > Microsoft_ menüpontot az Outlook, a Word, az Excel, a PowerPoint, a Teams és a OneDrive webes alkalmazásként való hozzáadásához. Minden alkalmazásnak saját indítója van, és közvetlenül megnyílik, a kereskedelmi Microsoft 365 URL-eket és a meglévő böngészőprofilodat használva. Ugyanazokban a böngészőalkalmazás-ablakokban nyílnak meg, mint az Omarchy többi webes alkalmazása; nem telepítik a külön Teams for Linux klienst.

Távolítsd el a csomagot a _Remove > Service > Microsoft_ menüponttal, vagy távolíts el egyes alkalmazásokat a _Remove > Web App_ menüponttal. Csak a kívánt alkalmazásokat is telepítheted az _Install > Web App_ menüponttal.

Kormányzati vagy szuverén felhő esetén szerkeszd az `Exec=` sor URL-jét a `~/.local/share/applications/` alatti megfelelő indítóban, például a `Microsoft Teams.desktop` fájlban, a szervezeted által megadott URL használatával. Az adott sorban minden szó szerinti `%` jelet `%%` formában írj. A módosítások a következő indításkor lépnek érvénybe. A csomagtelepítő újbóli futtatása az alapértelmezett URL-ekre cseréli vissza az indítóit.

A munkahelyi bejelentkezések elkülönítéséhez fűzz hozzá egy böngészőadat-könyvtárat minden indító `Exec=` sorához:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Cseréld le a példakönyvtárat egy általad választott abszolút elérési útra, és használd ugyanazt az elérési utat mind a hat indítóhoz, hogy megoszd közöttük a munkahelyi bejelentkezéseket. A webes alkalmazások az Omarchy által kiválasztott támogatott böngészőt használják, és a Chrome-ot használják tartalékként, ha az alapértelmezett böngésző nem támogatott.
