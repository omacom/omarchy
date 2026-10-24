# Að koma frá Mac eða Windows

Ef þú hefur eytt árum á macOS eða Windows vita fingurnir þínir hundrað hluti sem heilinn hefur gleymt að hann hafi nokkurn tíma lært. Þessi kafli er þýðingarlagið: hvert þessi eðlishvöt fer í Omarchy. Eiginleikarnir sjálfir eru teknir fyrir ítarlega annars staðar — þetta er bara kortið.

### Super er miðja alls

Allt vöðvaminnið sem þú hefur byggt upp í kringum Cmd eða Windows-lykilinn færist yfir á einn lykil: Super. Það er Windows-lykillinn á PC-lyklaborði, og hann er akkerið fyrir næstum alla flýtilykla í Omarchy.

Viðbragðið þitt gagnvart Spotlight eða Raycast eða Start-valmyndinni verður `Super + Space`. Það opnar Omarchy-valmyndina, sem ræsir forrit, breytir stillingum, setur upp hugbúnað, fangar skjáinn — nánast allt. Byrjaðu að skrifa til að sía. `Super + Alt + Space` sýnir öll forrit á einu neti, eins og Launchpad gerir. Sjá [leiðsögn](04-navigation.md).

### Það er ekkert dock og engin tákn á skjáborðinu

Ekkert að smella á til að ræsa hluti, engin tákn til að raða á skjáborðinu. Forrit ræsast með flýtilykli (`Super + Return` fyrir terminal, `Super + Shift + Return` fyrir vafrann og `Super + K` fyrir lista yfir allt sem er tengt) eða úr valmyndinni. Eini viðvarandi hluti viðmótsins er [valmyndastikan](05-the-top-bar.md), sem sér um það sem valmyndastikan, kerfisbakkinn og tilkynningamiðstöðin gerðu fyrir þig áður — og næstum hver græja á henni gerir eitthvað við vinstri, hægri og miðjusmell.

### Gluggar staðsetja sig sjálfir

Stærsta hugarfarsbreytingin: þú dregur ekki glugga um og smellir þeim ekki á skjáhelminga. Opnaðu glugga og hann tekur allan skjáinn. Opnaðu annan og þeir skipta honum. Þú þarft aldrei að fiska glugga upp undan öðrum, þar sem gluggar skarast ekki.

Þegar þú raunverulega þarft fljótandi glugga víxlar `Super + T` virka glugganum út úr flísalögninni (og til baka). En gefðu flísalögninni almennilegt tækifæri fyrst — hún er hjartað í þessu öllu. [Leiðsögn](04-navigation.md) leiðir þig í gegnum þetta.

Vinnusvæði munu virðast kunnugleg: þau eru macOS Spaces eða Windows sýndarskjáborð, nema þú munt í alvöru nota þau, þar sem `Super + 1/2/3/4` hoppar beint á eitt og `Super + Shift + 1/2/3/4` sendir virka gluggann þangað. Engin bið eftir hreyfingu, bara augnablikshopp. Þetta þýðir að þú gætir ekki einu sinni þurft marga skjái, ef þú varst vanur því áður.

### Afritun og líming virka bara

Á Mac hafðir þú Cmd + C alls staðar. Á Windows hafðir þú Ctrl + C alls staðar — nema í terminal, þar sem það drepur forritið þitt. Omarchy gefur þér `Super + C`, `Super + X` og `Super + V`, og þau virka alls staðar, líka í terminal. Ekkert sérstakt viðbragð að læra fyrir skelina.

Windows-fólk: Win + V klippiborðssagan ykkar býr á `Super + Ctrl + V`, og hún geymir myndir jafnt sem texta. Sjá [sameinað klippiborð og saga](08-unified-clipboard-history.md).

### Þýðingartaflan

| Þú nærð í | Í Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-valmynd | `Super + Space` — Omarchy-valmyndin |
| AirDrop | LocalSend, með `Super + Ctrl + S` — sjá [GUI-forrit](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — sjá [skjámyndir og upptaka](12-screenshots-recording.md) |
| Tilkynningamiðstöð | Tilkynningasaga á `Super + Shift + Alt + ,` |
| Time Machine (fyrir kerfið) | Sjálfvirkar [kerfismyndir](47-system-snapshots.md) við hverja uppfærslu |
| App Store / að sækja uppsetningarforrit | _Setja upp_ í valmyndinni, eða `omarchy pkg add` — sjá [aðrir pakkar](29-other-packages.md) |
| Kerfisstillingar / Stjórnborð | _Uppsetning_ í valmyndinni, sem breytir einföldum stillingarskrám — sjá [dotfiles](31-dotfiles.md) |

### Sumir hlutir eru raunverulega öðruvísi

Margar stillingar búa í textaskrám sem þú breytir, ekki spjöldum sem þú smellir í gegnum. Það hljómar frumstætt þar til þú áttar þig á því að það þýðir að hægt er að sjá hverja stillingu, afrita hana yfir á næstu vél og setja hana í útgáfustjórnun. _Uppsetning_-valmyndin setur þig beint í réttu skrána og endurræsir það sem þarf að endurræsa þegar þú ert búinn.

Uppfærslur koma með einni skipun — _Uppfæra > Omarchy_ — sem uppfærir Omarchy sjálft og hvern pakka á kerfinu og tekur skyndimynd fyrst. Engin uppfærsluforrit á hvert forrit að nöldra í þér á handahófskenndum tímum. Sjá [uppfærslur](30-updates.md).

Hugbúnaður kemur frá pakkastjóra, ekki úr niðurhöluðum uppsetningarforritum.

Og þegar þú lokar glugga hættir forritið í alvöru. Það er ekkert macOS-limbó þar sem forritið keyrir áfram án glugga. `Super + W` — eða `Super + Q`, ef það er fingraminnið sem þú komst með — þýðir farið.

### Á Mac-vélbúnaði

Omarchy keyrir vel á Intel Mac-tölvum — sjá [Mac-stuðning](44-mac-support.md). Og lyklaborðið er vinsamlegt við þig: Omarchy endurkortleggur ekkert, og Linux meðhöndlar Command-lykilinn sem Super, svo Super situr nákvæmlega þar sem Cmd var alltaf. Þumallinn þinn tekur ekki eftir flutningnum.

### Gefðu þessu tvær vikur

Eðlishvötin flytjast hraðar en þú heldur. Rennið einu sinni í gegnum [flýtilykla](07-hotkeys.md)kaflann, og þegar þú manst ekki tengingu skaltu ýta á `Super + K` — það sýnir þér þær allar. Það er eini flýtilykillinn sem þú þarft í alvöru að leggja á minnið.
