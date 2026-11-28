# Webes alkalmazások

Saját webes alkalmazásokat adhatsz hozzá az Omarchy menü (`Super + Space`) _Install > Web App_ pontjával. Meg fogja kérdezni az alkalmazás nevét, az alkalmazás URL-jét és az ikon URL-jét, ha nem tudja lekérni faviconon keresztül. Számos népszerű webes alkalmazáshoz találsz remek PNG ikonokat a [Dashboard Icons](https://dashboardicons.com) oldalon.

Ezután elérhetők lesznek az alkalmazásindítón (`Super + Space`) keresztül, és a gyönyörű, keret nélküli webes alkalmazásablakot használják.

Ha el szeretnél távolítani egy webes alkalmazást, egyszerűen lépj az Omarchy menü _Remove > Web App_ pontjára.

A legjobb, ha egy hagyományos böngészőben jelentkezel be az összes fiókodba, mielőtt használnád a webes alkalmazások parancsikonjait. A vékony burkolókeret nem működik jól a 1password szolgáltatással, ezért egyszerűen könnyebb előbb közvetlenül bejelentkezni.

Ezeknek a webes alkalmazásoknak az összes billentyűparancsa módosítható a `~/.config/hypr/bindings.lua` fájlban.

Amikor egy webes alkalmazásban vagy, az aktuális URL-t a `Shift + Alt + L` billentyűkombinációval másolhatod a vágólapra.

Az Omarchy alapértelmezetten már egy sor alapértelmezett alkalmazással érkezik:

## HEY

A [HEY](https://www.hey.com/) egy e-mail- és naptárszolgáltatás, amely remek alternatívát kínál azoknak, akiknek elegük van a Gmail, az Outlook vagy az Apple Mail szolgáltatásból. A [37signals](https://37signals.com/) készíti, ahonnan az Omarchy is származik.

A HEY Email alkalmazást a `Super + Shift + E` billentyűkombinációval indíthatod, a `Super + Shift + Alt + E` billentyűkombinációval rögtön új e-mail írásához ugorhatsz, a HEY Calendar alkalmazást pedig a `Super + Shift + C` billentyűkombinációval indíthatod.

## Basecamp

A [Basecamp](https://basecamp.com/) egy projektmenedzsment-szolgáltatás, amely segít a kis csapatoknak gyorsabban haladni és többet elérni. Ahelyett, hogy a Trello, a Slack, az Asana, a Notion vagy bármi más összevisszaságát foltozgatnád össze, a Basecamp segítségével mindez egy helyen megtalálható. A [37signals](https://37signals.com/) készíti, ahonnan az Omarchy is származik.

A Basecamp alkalmazást az alkalmazásindítóval (`Super + Space`) indíthatod

## ChatGPT

A [ChatGPT](https://chatgpt.com) a világ legnépszerűbb AI-chatbotja.

A ChatGPT alkalmazást a `Super + Shift + A` billentyűkombinációval indíthatod.

## Grok

A [Grok](https://grok.com) az xAI chatbotja.

A Grok alkalmazást a `Super + Shift + Alt + A` billentyűkombinációval indíthatod.

## WhatsApp

A [WhatsApp](https://www.whatsapp.com/) a világ egyik legnépszerűbb üzenetküldő szolgáltatása, és a webes verzió remek lehetőség Linuxon.

A WhatsApp alkalmazást a `Super + Shift + Alt + G` billentyűkombinációval indíthatod. Az Omarchy WhatsApp Slim bővítményével nyílik meg, amely a témádhoz igazítja, és összecsukja a chatlistát, ha az ablak keskeny.

## Google-alkalmazások

A Google Messages, a Google Photos, a Google Maps és a Google Contacts szintén webes alkalmazásként szerepel a kínálatban.

A Google Messages alkalmazást a `Super + Shift + Ctrl + G`, a Google Photos alkalmazást a `Super + Shift + P`, a Google Maps alkalmazást pedig a `Super + Shift + S` billentyűkombinációval indíthatod. A Google Contacts az alkalmazásindítón (`Super + Space`) keresztül érhető el.

## X

Az X-en robbannak be a hírek.

Az X alkalmazást a `Super + Shift + X` billentyűkombinációval indíthatod, és a `Super + Shift + Alt + X` billentyűkombinációval rögtön új bejegyzés írásához ugorhatsz.

## YouTube

A [YouTube](https://youtube.com/) a világ legnépszerűbb videóplatformja.

A YouTube alkalmazást a `Super + Shift + Y` billentyűkombinációval indíthatod.

## Netflix

A [Netflix](https://www.netflix.com/) új telepítéseknél webes alkalmazásként szerepel.

A Netflix alkalmazást az alkalmazásindítóval (`Super + Space`) indíthatod.

## Zoom

A [Zoom](https://zoom.us/) az Egyesült Államokban használt legnépszerűbb videochat-rendszer. Remek kapcsolatok a világ minden táján. És 40 perces megbeszélések fizetős fiók nélkül is tarthatók. Az Omarchy a Zoom webes kliensét csomagolja be, és a zoom megbeszéléslinkek közvetlenül abban nyílnak meg.

A Zoom alkalmazást az alkalmazásindítóval (`Super + Space`) indíthatod.

## Discord

A [Discord](https://discord.com/) az a hely, ahol a legtöbb játékos és nyílt forráskódú közösség tanyázik, beleértve az [Omarchy sajátját](https://discord.gg/tXFUdasqhY) is.

A Discord alkalmazást az alkalmazásindítóval (`Super + Space`) indíthatod.

## Microsoft-alkalmazások

Válaszd az _Install > Service > Microsoft_ pontot, ha webes alkalmazásként szeretnéd hozzáadni az Outlook, a Word, az Excel, a PowerPoint, a Teams és a OneDrive alkalmazást. Mindegyik alkalmazásnak saját indítója van, és közvetlenül megnyílik, a kereskedelmi Microsoft 365 URL-eket és a meglévő böngészőprofilodat használva. Ugyanolyan böngészőalkalmazás-ablakokban nyílnak meg, mint az Omarchy többi webes alkalmazása; nem telepítik a külön Teams for Linux klienst.

A csomagot a _Remove > Services > Microsoft_ ponttal távolíthatod el, az egyes alkalmazásokat pedig a _Remove > Web App_ ponttal. Az _Install > Web App_ ponton keresztül csak azokat az alkalmazásokat is telepítheted, amelyeket szeretnél.

Kormányzati vagy szuverén felhő esetén szerkeszd az URL-t a megfelelő indító `Exec=` sorában a `~/.local/share/applications/` könyvtár alatt, például a `Microsoft Teams.desktop` fájlban, a szervezeted által megadott URL használatával. Minden szó szerinti `%` karaktert `%%` formában írj be abba a sorba. A módosítások a következő indításkor lépnek érvénybe. A csomagtelepítő újbóli futtatása az alapértelmezett URL-ekre cseréli az indítóit.

Ha külön szeretnéd tartani a munkahelyi bejelentkezéseket, fűzz hozzá egy böngésző-adatkönyvtárat mindegyik indító `Exec=` sorához:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Cseréld le a példakönyvtárat egy általad választott abszolút elérési útra, és mind a hat indítónál ugyanazt az elérési utat használd, hogy megoszd közöttük a munkahelyi bejelentkezéseket. A webes alkalmazások az Omarchy által kiválasztott támogatott böngészőt használják, és a Chrome böngészőre állnak vissza, ha az alapértelmezett böngésző nem támogatott.
