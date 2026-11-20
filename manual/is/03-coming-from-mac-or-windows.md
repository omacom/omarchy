# Ef þú kemur af Mac eða Windows

Ef þú hefur eytt árum á macOS eða Windows þekkja fingurnir þínir hundrað hluti sem heilinn hefur gleymt að hann hafi nokkurn tíma lært. Þessi kafli er þýðingarlagið: hvert þessi viðbrögð fara í Omarchy. Eiginleikarnir sjálfir eru ræddir ítarlega annars staðar — þetta er bara kortið.

### Super er miðpunktur alls

Allt vöðvaminnið sem þú hefur byggt upp í kringum Cmd eða Windows-lykilinn flyst yfir á einn lykil: Super. Það er Windows-lykillinn á PC-lyklaborði, og hann er akkerið fyrir næstum alla flýtilykla í Omarchy.

Viðbragðið þitt fyrir Spotlight eða Raycast eða Start-valmyndina verður `Super + Space`. Það opnar Omarchy-valmyndina, sem ræsir forrit, breytir stillingum, setur upp hugbúnað og fangar skjáinn — eiginlega allt. Byrjaðu að skrifa til að sía. `Super + Alt + Space` sýnir öll forrit á einu neti, eins og Launchpad gerir. Sjá [leiðsögn](04-navigation.md).

### Engin skjáborðstákn, og bryggjan birtist aðeins þegar þú flýtur

Engin tákn til að raða á skjáborðið, og engin bryggja á flísalagðu vinnusvæði — bryggjan birtist aðeins á fljótandi vinnusvæði (sjá [leiðsögn](04-navigation.md)). Forrit ræsast með flýtilykli (`Super + Return` fyrir skjáherminn, `Super + Shift + Return` fyrir vafrann og `Super + K` fyrir lista yfir allt sem er tengt við lykla) eða úr valmyndinni. Eini viðmótshlutinn sem er alltaf til staðar er [efsta stikan](05-the-top-bar.md), sem sér um það sem valmyndastikan, kerfisbakki og Notification Center gerðu fyrir þig áður — og næstum hver einasta græja á henni gerir eitthvað við vinstri, hægri og miðjusmell.

### Gluggar raða sér sjálfir

Stærsta hugarfarsbreytingin: þú dregur ekki glugga um og smellir þeim ekki á helminga skjásins. Opnaðu glugga og hann tekur allan skjáinn. Opnaðu annan og þeir skipta honum á milli sín. Þú veiðir aldrei glugga undan öðrum, því gluggar skarast ekki.

Þegar þú þarft í alvörunni fljótandi glugga kveikir og slekkur `Super + T` á flísalagningu virka gluggans (og til baka). En gefðu flísalagningunni alvöru tækifæri fyrst — hún er hjartað í öllu saman. [Leiðsögn](04-navigation.md) leiðir þig í gegnum þetta.

Vinnusvæði munu finnast kunnugleg: þau eru macOS Spaces eða sýndarskjáborð í Windows, nema þú munt í alvörunni nota þau, því `Super + 1/2/3/4` hoppar beint á eitt þeirra og `Super + Shift + 1/2/3/4` sendir virka gluggann þangað. Engin töf vegna hreyfimynda, bara tafarlaus höpp. Þetta þýðir að þú gætir jafnvel ekki þurft marga skjái, ef þú varst vanur því áður.

### Afrita og líma virkar bara

Á Mac hafðir þú Cmd + C alls staðar. Á Windows hafðir þú Ctrl + C alls staðar — nema í skjáherminum, þar sem það drepur forritið þitt. Omarchy gefur þér `Super + C`, `Super + X` og `Super + V`, og þau virka alls staðar, líka í skjáherminum. Ekkert sérstakt viðbragð þarf að læra fyrir skelina.

Windows-fólk: Win + V klippispjaldssagan þín býr á `Super + Ctrl + V`, og hún geymir myndir jafnt sem texta. Sjá [sameinað klippispjald og saga](08-unified-clipboard-history.md).

### Þýðingartaflan

| Þú leitar að | Í Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-valmynd | `Super + Space` — Omarchy-valmyndin |
| AirDrop | LocalSend, með `Super + Ctrl + S` — sjá [grafísk viðmót](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eða `Print Screen` — sjá [skjámyndir og upptaka](12-screenshots-recording.md) |
| Notification Center | Tilkynningasaga á `Super + Shift + Alt + ,` |
| Time Machine (fyrir kerfið) | Sjálfvirk [kerfisafrit](47-system-snapshots.md) við hverja uppfærslu |
| App Store / að hlaða niður uppsetningarforriti | _Setja upp_ í valmyndinni, eða `omarchy pkg add` — sjá [aðrir pakkar](29-other-packages.md) |
| Kerfisstillingar / Stjórnborð | _Uppsetning_ í valmyndinni, sem breytir einföldum stillingaskrám — sjá [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, á `Super + Shift + F` — sjá [grafísk viðmót](22-guis.md) |
| Safari / Edge | Google Chrome á `Super + Shift + Return`; veldu annan undir _Uppsetning > Sjálfgefið > Vafri_ — sjá [vafrar](23-browsers.md) |
| Preview / Photos | Omaview fyrir myndir, myndbönd og tónlist, Document Viewer fyrir PDF-skjöl — sjá [grafísk viðmót](22-guis.md) |
| TextEdit / Notepad | Plain, á `Super + Shift + N`; veldu annan undir _Uppsetning > Sjálfgefið > Ritill_ |

### Sumt er í alvörunni öðruvísi

Margar stillingar búa í textaskrám sem þú breytir, ekki í spjöldum sem þú smellir þig í gegnum. Það hljómar frumstætt þangað til þú áttar þig á að það þýðir að hægt er að sjá hverja einustu breytingu, afrita hana á næstu vélina þína og setja hana í útgáfustjórnun. _Uppsetning_-valmyndin fer með þig beint í rétta skrá og endurræsir það sem þarf að endurræsa þegar þú ert búinn.

Uppfærslur koma í gegnum eina skipun — _Uppfæra > Omarchy_ — sem uppfærir Omarchy sjálft og hvern einasta pakka á kerfinu, og tekur kerfisafrit fyrst. Engin uppfærsluforrit fyrir hvert forrit að nöldra í þér af handahófi. Sjá [uppfærslur](30-updates.md).

Hugbúnaður kemur frá pakkastjóra, ekki frá niðurhölum uppsetningarforritum.

Og þegar þú lokar glugga hættir forritið í alvörunni. Það er ekkert macOS-limbó þar sem forritið heldur áfram að keyra án glugga. `Super + W` — eða `Super + Q`, ef það er fingraminnið sem þú komst með — þýðir horfið.

### Á Mac-vélbúnaði

Omarchy keyrir vel á Intel Mac-tölvum — sjá [Mac-stuðningur](44-mac-support.md). Og lyklaborðið er þér hliðhollt: Omarchy endurtengir ekkert, og Linux meðhöndlar Command-lykilinn sem Super, svo Super situr nákvæmlega þar sem Cmd var alltaf. Þumalinn þinn tekur ekki eftir flutningnum.

### Gefðu þessu tvær vikur

Viðbrögðin flytjast yfir hraðar en þú heldur. Flettu í gegnum [flýtilykla](07-hotkeys.md)-kaflann einu sinni, og þegar þú manst ekki tengingu skaltu ýta á `Super + K` — það sýnir þér þær allar. Það er eini flýtilykillinn sem þú þarft í alvörunni að leggja á minnið.
