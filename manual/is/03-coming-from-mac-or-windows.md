# Að koma frá Mac eða Windows

Ef þú hefur eytt árum á macOS eða Windows þekkja fingurnir hundrað hluti sem heilinn hefur gleymt að hann hafi nokkurn tíma lært. Þessi kafli er þýðingarlagið: hvert þessi viðbrögð fara í Omarchy. Fjallað er ítarlega um eiginleikana sjálfa annars staðar — þetta er bara kortið.

### Super er miðpunktur alls

Öll vöðvaminni sem þú hefur byggt upp í kringum Cmd eða Windows-lykilinn flytjast yfir á einn lykil: Super. Það er Windows-lykillinn á PC-lyklaborði og hann er akkerið fyrir næstum alla flýtilykla í Omarchy.

Viðbragðið þitt við Spotlight eða Raycast eða Start-valmynd verður `Super + Space`. Það opnar Omarchy-valmyndina, sem ræsir forrit, breytir stillingum, setur upp hugbúnað, fangar skjáinn — eiginlega allt. Byrjaðu að skrifa til að sía. `Super + Alt + Space` sýnir öll forrit á einu rúðuneti, eins og Launchpad gerir. Sjá [leiðsögn](04-navigation.md).

### Engin tákn á skjáborði og dockið heldur sig til hlés

Engin tákn til að raða á skjáborðinu, og dockið felur sig um leið og vinnusvæði er með glugga, þar til þú ýtir bendilinum að jaðri skjásins þar sem það er, þeim neðsta nema þú færir það (sjá [leiðsögn](04-navigation.md)). Forrit ræsast með flýtilykli (`Super + Return` fyrir skjáherminn, `Super + Shift + Return` fyrir vafrann og `Super + K` fyrir lista yfir allt sem er tengt) eða úr valmyndinni. Eini viðmótshlutinn sem er alltaf til staðar er [efsta stikan](05-the-top-bar.md), sem sér um það sem valmyndastikan, kerfisbakinn og Notification Center gerðu fyrir þig áður — og næstum hver græja á henni gerir eitthvað við vinstri, hægri og miðjusmell.

### Gluggar raða sér sjálfir

Stærsta hugarfarsbreytingin: þú dregur ekki glugga um eða smellir þeim á skjáhelminga. Opnaðu glugga og hann tekur allan skjáinn. Opnaðu annan og þeir skipta honum. Þú fiskar aldrei glugga upp undan öðrum, því gluggar skarast ekki.

Þegar þú þarft virkilega á svífandi glugga að halda, tekur `Super + T` virka gluggann úr flísaskipaninni (og setur hann aftur inn). En gefðu flísaskipaninni alvöru séns fyrst — hún er hjartað í öllu saman. [Leiðsögn](04-navigation.md) leiðir þig í gegnum það.

Vinnusvæði munu virðast kunnugleg: þau eru macOS Spaces eða sýndarskjáborð Windows, nema þú munt í alvörunni nota þau, því `Super + 1/2/3/4` hoppar beint á eitt þeirra og `Super + Shift + 1/2/3/4` sendir virka gluggann þangað. Engin töf á hreyfingum, bara stökk á augabragði. Þetta þýðir að þú þarft kannski ekki einu sinni marga skjái, ef þú hafðir vanist því áður.

### Afrita og líma virkar bara

Á Mac hafðir þú Cmd + C alls staðar. Á Windows hafðir þú Ctrl + C alls staðar — nema í skjáherminum, þar sem það drepur forritið þitt. Omarchy gefur þér `Super + C`, `Super + X` og `Super + V` og þau virka alls staðar, líka í skjáherminum. Engin sérstök viðbrögð þarf að læra fyrir skelina.

Windows-fólk: Win + V klippiborðssagan þín býr á `Super + Ctrl + V` og hún geymir myndir jafnt sem texta. Sjá [sameinað klippiborð og saga](08-unified-clipboard-history.md).

### Þýðingartaflan

| Þú grípur í | Í Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-valmynd | `Super + Space` — Omarchy-valmyndin |
| AirDrop | LocalSend, með `Super + Ctrl + S` — sjá [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eða `Print Screen` — sjá [skjámyndir og upptaka](12-screenshots-recording.md) |
| Notification Center | Tilkynningasaga á `Super + Shift + Alt + ,` |
| Time Machine (fyrir kerfið) | Sjálfvirkar [kerfisaugnabliksmyndir](47-system-snapshots.md) við hverja uppfærslu |
| App Store / að hlaða niður uppsetningarforriti | _Setja upp_ í valmyndinni, eða `omarchy pkg add` — sjá [aðrir pakkar](29-other-packages.md) |
| System Settings / Control Panel | _Uppsetning_ í valmyndinni, sem breytir einföldum stillingarskrám — sjá [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, á `Super + Shift + F` — sjá [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome á `Super + Shift + Return`; veldu annan undir _Uppsetning > Sjálfgefið > Vafri_ — sjá [vafrar](23-browsers.md) |
| Preview / Photos | Omaview fyrir myndir, myndbönd og tónlist, Document Viewer fyrir PDF-skjöl — sjá [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, á `Super + Shift + N`; veldu annan undir _Uppsetning > Sjálfgefið > Ritill_ |

### Sumt er virkilega öðruvísi

Margar stillingar búa í textaskrám sem þú breytir, ekki spjöldum sem þú smellir þig í gegnum. Það hljómar frumstætt þar til þú áttar þig á að það þýðir að hægt er að sjá hverja breytingu, afrita hana á næstu vélina þína og setja hana í útgáfustýringu. _Uppsetning_-valmyndin setur þig beint í rétta skrá og endurræsir það sem þarf að endurræsa þegar þú hefur lokið við.

Uppfærslur koma með einni skipun — _Uppfæra > Omarchy_ — sem uppfærir Omarchy sjálft og hvern pakka á kerfinu og tekur augnabliksmynd fyrst. Engin uppfærsluforrit fyrir hvert forrit að nöldra í þér af handahófi. Sjá [uppfærslur](30-updates.md).

Hugbúnaður kemur frá pakkastjóra, ekki frá niðurhöluðum uppsetningarforritum.

Og þegar þú lokar glugga hættir forritið í alvörunni. Það er ekkert macOS-limbó þar sem forritið heldur áfram að keyra án glugga. `Super + W` — eða `Super + Q`, ef það er fingraminnið sem þú komst með — þýðir horfið.

### Á Mac-vélbúnaði

Omarchy keyrir vel á Intel Mac-tölvum og á M1, M2 og M3 Mac-tölvum með Omarchy for Apple Silicon. Sjá [Mac-stuðningur](44-mac-support.md). Og lyklaborðið er þér vingjarnlegt: Omarchy endurtengir ekkert og Linux meðhöndlar Command-lykilinn sem Super, svo Super situr nákvæmlega þar sem Cmd var alltaf. Þumallinn þinn mun ekki taka eftir flutningnum.

### Gefðu því tvær vikur

Viðbrögðin flytjast hraðar en þú heldur. Skoðaðu [flýtilykla](07-hotkeys.md) kaflann einu sinni, og alltaf þegar þú manst ekki eftir tengingu, ýttu á `Super + K` — hann sýnir þér þær allar. Það er eini flýtilykillinn sem þú þarft í raun að leggja á minnið.
