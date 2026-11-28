# Að koma frá Mac eða Windows

Ef þú hefur eytt árum á macOS eða Windows þekkja fingurnir þínir hundrað hluti sem heilinn þinn hefur gleymt að hann hafi nokkurn tíma lært. Þessi kafli er þýðingarlagið: hvert þessi eðlishvöt eiga að fara í Omarchy. Eiginleikarnir sjálfir eru teknir fyrir ítarlega annars staðar — þetta er bara kortið.

### Super er miðpunktur alls

Öll vöðvaminni sem þú hefur byggt upp í kringum Cmd eða Windows-lykilinn flytjast yfir á einn lykil: Super. Það er Windows-lykillinn á PC-lyklaborði, og hann er akkerið fyrir næstum alla flýtilykla í Omarchy.

Spotlight- eða Raycast- eða Start-valmyndarviðbragðið þitt verður `Super + Space`. Það opnar Omarchy-valmyndina, sem ræsir forrit, breytir stillingum, setur upp hugbúnað, tekur skjáinn — nánast allt. Byrjaðu að skrifa til að sía. `Super + Alt + Space` sýnir öll forrit á einu neti, eins og Launchpad gerir. Sjá [leiðsögn](04-navigation.md).

### Engin tákn á skjáborðinu, og bryggjan heldur sig til hlés

Engin tákn til að raða á skjáborðið, og bryggjan felur sig um leið og vinnusvæði hefur glugga, þar til þú ýtir bendlinum að brún skjásins þar sem hún er, þeirri hægri nema þú færir hana (sjá [leiðsögn](04-navigation.md)). Forrit hefjast með flýtilykli (`Super + Return` fyrir útstöðina, `Super + Shift + Return` fyrir vafrann, og `Super + K` fyrir lista yfir allt sem er varpað) eða úr valmyndinni. Eini viðvarandi hluti viðmótsins er [efsta stikan](05-the-top-bar.md), sem sér um það sem valmyndastikan, kerfisbakinn og Notification Center gerðu fyrir þig áður — og næstum hver græja á henni gerir eitthvað við vinstri, hægri og miðjusmell.

### Gluggar staðsetja sig sjálfir

Stærsta hugarfarsbreytingin: þú dregur ekki glugga til og frá eða smellir þeim á skjáhelminga. Opnaðu glugga og hann tekur allan skjáinn. Opnaðu annan og þeir skipta honum. Þú veiðir aldrei glugga undan öðrum, því gluggar skarast ekki.

Þegar þú þarft virkilega fljótandi glugga skiptir `Super + T` virka glugganum út úr flísalaginu (og til baka). En gefðu flísalaginu alvöru tækifæri fyrst — það er hjartað í öllu saman. [Leiðsögn](04-navigation.md) leiðir þig í gegnum það.

Vinnusvæði munu finnast kunnugleg: þau eru macOS Spaces eða sýndarskjáborð Windows, nema þú munt í alvörunni nota þau, því `Super + 1/2/3/4` hoppar beint á eitt og `Super + Shift + 1/2/3/4` sendir virka gluggann þangað. Engin töf vegna hreyfimynda, bara stökk á augabragði. Þetta þýðir að þú gætir jafnvel ekki þurft marga skjái, ef þú varst vanur því áður.

### Afritun og líming virkar bara

Á Mac hafðir þú Cmd + C alls staðar. Á Windows hafðir þú Ctrl + C alls staðar — nema í útstöðinni, þar sem það drepur forritið þitt. Omarchy gefur þér `Super + C`, `Super + X` og `Super + V`, og þau virka alls staðar, líka í útstöðinni. Ekkert sérstakt viðbragð þarf að læra fyrir skelina.

Windows-fólk: Win + V klippiborðssagan ykkar býr á `Super + Ctrl + V`, og hún geymir myndir jafnt sem texta. Sjá [sameinað klippiborð og saga](08-unified-clipboard-history.md).

### Þýðingartaflan

| Þú nærð í | Í Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-valmynd | `Super + Space` — Omarchy-valmyndin |
| AirDrop | LocalSend, með `Super + Ctrl + S` — sjá [grafísk viðmót](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eða `Print Screen` — sjá [skjáskot og upptaka](12-screenshots-recording.md) |
| Notification Center | Tilkynningasaga á `Super + Shift + Alt + ,` |
| Time Machine (fyrir kerfið) | Sjálfvirkar [kerfisaugnabliksmyndir](47-system-snapshots.md) við hverja uppfærslu |
| App Store / að hlaða niður uppsetningarforriti | _Install_ í valmyndinni, eða `omarchy pkg add` — sjá [aðrir pakkar](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ í valmyndinni, sem breytir einföldum stillingaskrám — sjá [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, á `Super + Shift + F` — sjá [grafísk viðmót](22-guis.md) |
| Safari / Edge | Google Chrome á `Super + Shift + Return`; veldu annan undir _Setup > Defaults > Browser_ — sjá [vafrar](23-browsers.md) |
| Preview / Photos | Omaview fyrir myndir, myndbönd og tónlist, Document Viewer fyrir PDF — sjá [grafísk viðmót](22-guis.md) |
| TextEdit / Notepad | Plain, á `Super + Shift + N`; veldu annan undir _Setup > Defaults > Editor_ |

### Sumt er í alvörunni öðruvísi

Margir stillingar búa í textaskrám sem þú breytir, ekki spjöldum sem þú smellir þig í gegnum. Það hljómar frumstætt þar til þú áttar þig á að það þýðir að hægt er að sjá hverja smábreytingu, afrita hana yfir á næstu vélina þína og setja hana í útgáfustýringu. _Setup_-valmyndin setur þig beint í rétta skrá og endurræsir það sem þarf að endurræsa þegar þú ert búinn.

Uppfærslur koma með einni skipun — _Update > Omarchy_ — sem uppfærir Omarchy sjálft og hvern pakka á kerfinu, og tekur augnabliksmynd fyrst. Engin uppfærsluforrit fyrir hvert forrit að nöldra í þér af handahófi. Sjá [uppfærslur](30-updates.md).

Hugbúnaður kemur frá pakkastjóra, ekki frá niðurhöluðum uppsetningarforritum.

Og þegar þú lokar glugga hættir forritið í alvörunni. Það er ekkert macOS-limbó þar sem forritið heldur áfram að keyra án glugga. `Super + W` — eða `Super + Q`, ef það er fingraminnið sem þú komst með — þýðir horfið.

### Á Mac-vélbúnaði

Omarchy keyrir vel á Intel-Mac-tölvum, og á M1-, M2- og M3-Mac-tölvum með Omarchy for Apple Silicon. Sjá [Mac-stuðningur](44-mac-support.md). Og lyklaborðið er þér góðhjartað: Omarchy endurvarpar engu, og Linux meðhöndlar Command-lykilinn sem Super, svo Super situr nákvæmlega þar sem Cmd var alltaf. Þumallinn þinn mun ekki taka eftir flutningnum.

### Gefðu því tvær vikur

Eðlishvötin flytjast hraðar en þú heldur. Flettu í gegnum [flýtilykla](07-hotkeys.md)-kaflann einu sinni, og þegar þú manst ekki bindingu skaltu ýta á `Super + K` — það sýnir þér þær allar. Það er eini flýtilykillinn sem þú þarft í alvörunni að leggja á minnið.
