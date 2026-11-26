# Að koma frá Mac eða Windows

Ef þú hefur eytt árum á macOS eða Windows þekkja fingurnir þínir hundrað hluti sem heilinn hefur gleymt að hann hafi nokkurn tímann lært. Þessi kafli er þýðingarlagið: hvert þessi eðlishvöt fer í Omarchy. Eiginleikarnir sjálfir eru fjallaðir ítarlega um annars staðar — þetta er bara kortið.

### Super er miðpunktur alls

Allur vöðvaminni sem þú hefur byggt upp í kringum Cmd eða Windows-lykilinn flyst yfir á einn lykil: Super. Það er Windows-lykillinn á PC-lyklaborði, og hann er akkerið fyrir næstum alla flýtilykla í Omarchy.

Spotlight- eða Raycast- eða Start-valmyndarviðbragðið þitt verður `Super + Space`. Það opnar Omarchy-valmyndina, sem ræsir forrit, breytir stillingum, setur upp hugbúnað, tekur skjáinn — eiginlega allt. Byrjaðu að skrifa til að sía. `Super + Alt + Space` sýnir öll forrit á einu neti, eins og Launchpad gerir. Sjá [flakk](04-navigation.md).

### Engin tákn á skjáborði, og dockið birtist aðeins þegar þú flýtur

Engin tákn til að raða á skjáborðið, og ekkert dock á flísalagðu vinnusvæði — dockið birtist aðeins á fljótandi vinnusvæði (sjá [flakk](04-navigation.md)). Forrit ræsast með flýtilykli (`Super + Return` fyrir útstöðina, `Super + Shift + Return` fyrir vafrann, og `Super + K` fyrir lista yfir allt sem er tengt lyklum) eða úr valmyndinni. Eini viðmótshlutinn sem er alltaf til staðar er [efri stikan](05-the-top-bar.md), sem sér um það sem valmyndastikan, kerfisbakki og Notification Center gerðu fyrir þig áður — og næstum hver einasta græja á henni gerir eitthvað við vinstri, hægri og miðju smell.

### Gluggar staðsetja sig sjálfir

Stærsta hugarfarsbreytingin: þú dregur ekki glugga til og frá eða smellir þeim á helminga skjásins. Opnaðu glugga og hann tekur allan skjáinn. Opnaðu annan og þeir skipta honum á milli sín. Þú þarft aldrei að fiska glugga upp undan öðrum, því gluggar skarast ekki.

Þegar þú þarft virkilega fljótandi glugga skiptir `Super + T` virka glugganum út úr flísalagningunni (og til baka). En gefðu flísalagningunni alvöru séns fyrst — hún er hjartað í öllu saman. [Flakk](04-navigation.md) leiðir þig í gegnum það.

Vinnusvæði munu virðast kunnugleg: þau eru macOS Spaces eða sýndarskjáborð Windows, nema þú munt í alvörunni nota þau, því `Super + 1/2/3/4` hoppar beint á eitt þeirra og `Super + Shift + 1/2/3/4` sendir virka gluggann þangað. Engin töf vegna hreyfimynda, bara stökk á augabragði. Þetta þýðir að þú þarft kannski ekki einu sinni marga skjái, ef þú varst vön því áður.

### Afritun og líming virka bara

Á Mac hafðir þú Cmd + C alls staðar. Á Windows hafðir þú Ctrl + C alls staðar — nema í útstöðinni, þar sem það drepur forritið þitt. Omarchy gefur þér `Super + C`, `Super + X` og `Super + V`, og þau virka alls staðar, líka í útstöðinni. Engin sérstök viðbrögð þarf að læra fyrir skelina.

Windows-fólk: Win + V klippispjaldsagan ykkar býr á `Super + Ctrl + V`, og hún geymir myndir jafnt sem texta. Sjá [sameinað klippispjald og saga](08-unified-clipboard-history.md).

### Þýðingartaflan

| Þú nærð í | Í Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy-valmyndin |
| AirDrop | LocalSend, í gegnum `Super + Ctrl + S` — sjá [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eða `Print Screen` — sjá [skjámyndir og upptaka](12-screenshots-recording.md) |
| Notification Center | Tilkynningasaga á `Super + Shift + Alt + ,` |
| Time Machine (fyrir kerfið) | Sjálfvirkar [augnabliksmyndir kerfisins](47-system-snapshots.md) við hverja uppfærslu |
| App Store / að hlaða niður uppsetningarforriti | _Install_ í valmyndinni, eða `omarchy pkg add` — sjá [aðrir pakkar](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ í valmyndinni, sem breytir einföldum stillingarskrám — sjá [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, á `Super + Shift + F` — sjá [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome á `Super + Shift + Return`; veldu annan undir _Setup > Defaults > Browser_ — sjá [vafrar](23-browsers.md) |
| Preview / Photos | Omaview fyrir myndir, myndbönd og tónlist, Document Viewer fyrir PDF-skjöl — sjá [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, á `Super + Shift + N`; veldu annan undir _Setup > Defaults > Editor_ |

### Sumir hlutir eru virkilega öðruvísi

Margir stillingar búa í textaskrám sem þú breytir, ekki í spjöldum sem þú smellir þig í gegnum. Það hljómar frumstætt þangað til þú áttar þig á að það þýðir að hægt er að sjá hverja smábreytingu, afrita hana á næstu vélina þína og setja hana í útgáfustjórnun. _Setup_-valmyndin fer með þig beint í rétta skrá og endurræsir það sem þarf að endurræsa þegar þú ert búinn.

Uppfærslur koma í gegnum eina skipun — _Update > Omarchy_ — sem uppfærir Omarchy sjálft og hvern einasta pakka á kerfinu, og tekur augnabliksmynd fyrst. Engin uppfærsluforrit fyrir hvert forrit að nöldra í þér af handahófi. Sjá [uppfærslur](30-updates.md).

Hugbúnaður kemur frá pakkastjóra, ekki frá uppsetningarforritum sem hlaðið er niður.

Og þegar þú lokar glugga hættir forritið í alvörunni. Það er ekkert macOS-limbó þar sem forritið heldur áfram að keyra án glugga. `Super + W` — eða `Super + Q`, ef það er fingraminnið sem þú komst með — þýðir farinn.

### Á Mac-vélbúnaði

Omarchy keyrir vel á Intel Mac-tölvum, og á M1, M2 og M3 Mac-tölvum með Omarchy for Apple Silicon. Sjá [Mac-stuðningur](44-mac-support.md). Og lyklaborðið er þér hliðhollt: Omarchy endurtengir ekkert, og Linux meðhöndlar Command-lykilinn sem Super, svo Super situr nákvæmlega þar sem Cmd var alltaf. Þumallinn þinn mun ekki taka eftir flutningnum.

### Gefðu þessu tvær vikur

Eðlishvötin flytjast hraðar en þú heldur. Flettu í gegnum [flýtilyklar](07-hotkeys.md) kaflann einu sinni, og þegar þú manst ekki tengingu skaltu ýta á `Super + K` — það sýnir þér þær allar. Það er eini flýtilykillinn sem þú þarft í raun að leggja á minnið.
