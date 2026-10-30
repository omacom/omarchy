# Að koma frá Mac eða Windows

Ef þú hefur eytt árum í macOS eða Windows þekkja fingurnir hundrað hluti sem heilinn hefur gleymt að hann hafi nokkurn tíma lært. Þetta er þýðingarlagið: hvert þessi eðlishvöt á heima í Omarchy. Eiginleikarnir sjálfir eru teknir fyrir ítarlega annars staðar — þetta er bara kortið.

### Super er miðpunktur alls

Öll vöðvaminni sem þú hefur byggt upp í kringum Cmd eða Windows-lykilinn flytjast yfir á einn lykil: Super. Það er Windows-lykillinn á PC-lyklaborði, og hann er akkerið fyrir næstum alla flýtilykla í Omarchy.

Viðbragðið þitt við Spotlight eða Raycast eða Start-valmyndinni verður `Super + Space`. Það opnar Omarchy-valmyndina, sem ræsir forrit, breytir stillingum, setur upp hugbúnað, tekur skjámyndir — eiginlega allt. Byrjaðu bara að skrifa til að sía. `Super + Alt + Space` sýnir öll forrit á einu neti, eins og Launchpad gerir. Sjá [leiðsögn](04-navigation.md).

### Það er engin dokka og engin skjáborðstákn

Ekkert til að smella á til að ræsa hluti, engin tákn til að raða á skjáborðið. Forrit ræsast með flýtilykli (`Super + Return` fyrir skjáhermi, `Super + Shift + Return` fyrir vafrann og `Super + K` fyrir lista yfir allt sem er tengt) eða úr valmyndinni. Eini varanlegi hluti viðmótsins er [efri stikan](05-the-top-bar.md), sem sér um það sem valmyndastikan, kerfisbakki og Notification Center gerðu áður fyrir þig — og næstum hvert tól á henni gerir eitthvað við vinstri, hægri og miðjusmell.

### Gluggar raða sér sjálfir

Stærsta hugarfarsbreytingin: þú dregur ekki glugga um eða festir þá við helminga skjásins. Opnaðu glugga og hann tekur allan skjáinn. Opnaðu annan og þeir skipta honum á milli sín. Þú fiskar aldrei glugga upp undan öðrum, því gluggar skarast ekki.

Þegar þú þarft virkilega fljótandi glugga skiptir `Super + T` virka glugganum út úr flísalaginu (og til baka). En gefðu flísalaginu alvöru tækifæri fyrst — það er hjartað í öllu saman. [Leiðsögn](04-navigation.md) fer með þig í gegnum það.

Vinnusvæði munu virðast kunnugleg: þau eru macOS Spaces eða sýndarskjáborð í Windows, nema þú munt raunverulega nota þau, því `Super + 1/2/3/4` hoppar beint á eitt og `Super + Shift + 1/2/3/4` sendir virka gluggann þangað. Engin hreyfitöf, bara tafarlaus höpp. Þetta þýðir að þú gætir ekki einu sinni þurft marga skjái, ef þú varst vanur því áður.

### Afrita og líma virkar bara

Á Mac hafðir þú Cmd + C alls staðar. Í Windows hafðir þú Ctrl + C alls staðar — nema í skjáherminum, þar sem það drepur forritið þitt. Omarchy gefur þér `Super + C`, `Super + X` og `Super + V`, og þau virka alls staðar, líka í skjáherminum. Engin sérstök viðbrögð þarf að læra fyrir skelina.

Windows-fólk: Win + V klemmuspjaldssagan ykkar býr á `Super + Ctrl + V`, og hún geymir myndir jafnt sem texta. Sjá [sameinað klemmuspjald og saga](08-unified-clipboard-history.md).

### Þýðingartaflan

| Þú leitar að | Í Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy-valmyndin |
| AirDrop | LocalSend, með `Super + Ctrl + S` — sjá [grafísk viðmót](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eða `Print Screen` — sjá [skjámyndir og upptaka](12-screenshots-recording.md) |
| Notification Center | Tilkynningasaga á `Super + Shift + Alt + ,` |
| Time Machine (fyrir kerfið) | Sjálfvirkar [kerfisaugnabliksmyndir](47-system-snapshots.md) við hverja uppfærslu |
| App Store / að hlaða niður uppsetningarforriti | _Setja upp_ í valmyndinni, eða `omarchy pkg add` — sjá [aðrir pakkar](29-other-packages.md) |
| System Settings / Control Panel | _Uppsetning_ í valmyndinni, sem breytir einföldum stillingaskrám — sjá [dotfiles](31-dotfiles.md) |

### Sumt er í raun öðruvísi

Margar stillingar búa í textaskrám sem þú breytir, ekki spjöldum sem þú smellir þig í gegnum. Það hljómar frumstætt þangað til þú áttar þig á því að það þýðir að hægt er að sjá hverja breytingu, afrita hana á næstu vélina þína og setja hana í útgáfustjórnun. _Uppsetning_-valmyndin setur þig beint í réttu skrána og endurræsir það sem þarf að endurræsa þegar þú ert búinn.

Uppfærslur koma með einni skipun — _Uppfæra > Omarchy_ — sem uppfærir Omarchy sjálft og hvern pakka á kerfinu, og tekur augnabliksmynd fyrst. Engir uppfærslufarar fyrir hvert forrit að nöldra í þér af handahófi. Sjá [uppfærslur](30-updates.md).

Hugbúnaður kemur frá pakkastjóra, ekki frá niðurhöluðum uppsetningarforritum.

Og þegar þú lokar glugga hættir forritið í raun. Það er ekkert macOS-limbó þar sem forritið heldur áfram að keyra án glugga. `Super + W` — eða `Super + Q`, ef það er fingraminnið sem þú komst með — þýðir horfið.

### Á Mac-vélbúnaði

Omarchy keyrir vel á Intel Mac-tölvum — sjá [stuðning við Mac](44-mac-support.md). Og lyklaborðið er þér góðhjartað: Omarchy endurtengir ekkert, og Linux meðhöndlar Command-lykilinn sem Super, svo Super situr nákvæmlega þar sem Cmd var alltaf. Þumallinn þinn mun ekki taka eftir flutningnum.

### Gefðu þessu tvær vikur

Eðlishvötin flytjast hraðar en þú myndir halda. Skoðaðu [flýtilykla](07-hotkeys.md) kaflann einu sinni, og þegar þú manst ekki tengingu skaltu ýta á `Super + K` — það sýnir þér þær allar. Það er eini flýtilykillinn sem þú þarft í raun að leggja á minnið.
