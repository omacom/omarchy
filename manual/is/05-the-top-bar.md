# Efsta stikan

Röndin efst á skjánum þínum er Omarchy-sláin. Hún er ekki áfest stöðuslá heldur hluti af Omarchy-skelinni, því eina langlífa Quickshell-ferli sem einnig teiknar valmyndina, tilkynningarnar, OSD-spjöldin og læsiskjáinn. Þess vegna þemast hún fullkomlega með öllu öðru og þess vegna opnast spjald samstundis í stað þess að ræsa nýtt forrit.

Hún er líka eini hluti skjáborðsins sem er alltaf á skjánum, svo það er þess virði að vita hvað öll þessi litlu tákn gera.

## Hvað er á henni sjálfgefið

Sláin hefur þrjá hluta. Til vinstri situr Omarchy-merkið (valmyndaræsarinn) og vinnusvæðavísarnir. Í miðjunni færðu stöðuvísana, klukkuna, Elsewhen (heimsklukku), veðrið og merki um Omarchy-uppfærslu. Til hægri: kerfisbakkan, lyklaborðsuppsetninguna (þegar fleiri en ein er stillt), umboð, bluetooth, net, hljóð, skjá og afl.

Nokkrir þeirra birtast aðeins þegar þeir hafa eitthvað að segja. Lyklaborðsuppsetningin birtist aðeins ef þú hefur stillt fleiri en eina uppsetningu. Uppfærslumerkið birtist aðeins þegar Omarchy-uppfærsla bíður. Og umboðstáknið birtist í fyrsta skipti sem Omarchy finnur notkun gervigreindarkóðunar á vélinni (sjá [Gervigreind](17-ai.md)).

## Að smella um

Næstum hver bútur gerir eitthvað við vinstri, hægri og miðsmell, og nokkrir bregðast við skrunun. Þetta er sá hluti sem fólk missir af — hægri og miðhnapparnir eru þar sem mikið af því góða felst.

| Bútur | Vinstri | Hægri | Miðja / skrun |
| --- | --- | --- | --- |
| Valmynd | Omarchy-valmynd | Nýr útstöð | — |
| Vinnusvæði | Beina fókus á það vinnusvæði á þessum skjá | — | Skrun: næsta/fyrra vinnusvæði |
| Klukka | Dagatalsspjald | Skipta um snið merkisins | Miðja: tímabeltisval |
| Veður | Veðurspáspspjald | Fullt veður sem tilkynning | Miðja: endurnýja |
| Hljóð | Hljóðspjald | Þagga | Miðja: spjald · skrun: hljóðstyrkur |
| Hljóðnemi | Þagga hljóðnemann | — | Miðja: hljóðspjald · skrun: inntaksstyrkur |
| Net | Netspjald | — | — |
| Bluetooth | Bluetooth-spjald | Kveikja/slökkva á útvarpinu | — |
| Skjár | Skjáspjald | — | Skrun: birta |
| Afl | Aflspjald | Kveikja/slökkva á prósentu rafhlöðu | — |
| Margmiðlun | Spila/setja á pásu | Kápumyndarspjald | Miðja: næsta · skrun: fyrra/næsta |
| Umboð | Umboðsspjald | Ræsa umboðið þitt | Miðja: næsta áskrift |
| Bakki | Sveima til að sýna skúffuna | Hægri á örinni til að stjórna | — |
| Omarchy-uppfærsla | Keyra uppfærsluna | — | — |

Ekki er allt í þeirri töflu á slánni þinni úr kassanum. Margmiðlunarbúturinn (MPRIS sem er að spila núna, með skrunandi lagi og listamanni) og hljóðnemabúturinn eru báðir innbyggðir en slökktir sjálfgefið — bættu þeim við ef þú vilt þá, eins og lýst er hér að neðan.

## Spjöldin

Að smella á tákn á slánni opnar spjald, sem er alvöru sprettigluggi með rennum, listum og lyklaborðsleiðsögn frekar en vísbending. Hvert þeirra hefur líka flýtilykil, svo þú þarft aldrei að miða á 16 punkta tákn:

| Flýtilykill | Spjald |
| --- | --- |
| `Super + Ctrl + A` | Hljóð |
| `Super + Ctrl + N` | Net |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skjár |
| `Super + Ctrl + P` | Afl |
| `Super + Ctrl + Alt + D` | Dagatal |
| `Super + Ctrl + Alt + E` | Heimsklukka |
| `Super + Ctrl + 1-9` | Kveikja/slökkva á n-ta spjaldinu í hægri hlutanum |

Spjöldin eru ekki aflestrar. Þau eru þar sem þú gerir hlutinn í raun:

- **Audio** er með aðalhljóðstyrksrennu, vali fyrir úttakstæki og blöndunartæki fyrir hvert forrit, svo þú getur lækkað í þeim eina vafraflipa án þess að snerta allt annað.
- **Network** leitar að Wi-Fi, sýnir merkjastyrk, tengist og lætur þig velja DNS-veitu.
- **Bluetooth** listar tækin þín með tengingu/aftengingu og stöðu rafhlöðu.
- **Power** sýnir tölfræði rafhlöðu, skiptir um aflsnið (það man sérstakt val fyrir rafhlöðu og AC) og prentar einhverjar kerfisupplýsingar.
- **Display** er með birturennu, textastærð, forstillingar fyrir skjákvarða og — þegar þú ert með fleiri en einn skjá — stýringar fyrir hvern skjá. Sjá [skjái](33-monitors.md) fyrir dýpri söguna.
- **Clock** opnar mánaðarnet með ISO-vikunúmerum og skrefum milli mánaða.
- **World clock** heldur röð fyrir hverja borg, með veðri hennar og hvernig dagurinn hennar gengur. Leit finnur bæi jafnt sem tímabelti, svo Fort Lauderdale er Fort Lauderdale en ekki New York. Ef línan efst nefnir ranga borg skaltu smella á hana og segja hvar þú ert; veldu einhvers staðar á öðru tímabelti og kerfisklukkan færist þangað líka, sem er handhægt þegar þú ferðast. Sveimaðu yfir borg og smelltu á persónuhnappinn til að segja hver býr þar — einföld nöfn, eða `@` GitHub-auðkenni til að koma með andlit þeirra með.

Hvert spjald tekur við lyklaborðinu jafnt sem músinni: örvar færast, Return virkjar, Tab stígur yfir í næsta spjald og Escape lokar.

`Super + Ctrl + 1-9` telur spjöld frá vinstri til hægri í hægri hlutanum og sleppir bakkanum þar sem hann hefur ekkert spjald sitt eigið. Svo talan samsvarar tákninu sem þú myndir benda á.

### Tailscale og Dropbox

Tveir bútar í viðbót birtast á slánni aðeins þegar þú setur upp samsvarandi þjónustu úr **Install → Service**, og báðir eru þess virði að vita af því þeir gera meira en að tilkynna stöðu.

**Tailscale**-spjaldið tengir og aftengir tailnet-ið, skiptir á milli reikninga og velur útgönguhnút (þínar eigin vélar og Mullvad-svæði birtast bæði í þeim lista). Það vafrar líka um vélarnar þínar — og með eina valda sendir `s` skrár til hennar yfir Taildrop, sem er fljótlegasta leiðin til að færa skrá í símann þinn eða aðra fartölvu. `c` afritar IP-tölu vélarinnar, `n` nafn hennar og `d` fullt DNS-nafn hennar. Það er líka sendingarhnappur á hverri vélaröð, ef þú vilt frekar smella. Sama hluturinn úr útstöðinni er `omarchy tailscale send <machine> [file...]`.

**Dropbox**-spjaldið sér um innskráningu, sýnir hversu mikið geymslurými þú hefur notað og listar nýlega samstilltar skrár.

Að fjarlægja hvora þjónustuna sem er tekur búta hennar aftur af slánni.

## Vísar

Litla klasið í miðjunni er vísabúturinn. Þetta eru stöðutákn fyrir ham sem þú hefur kveikt á: ekki trufla, næturljós, [áminning](09-reminders.md) í biðröð, virk skjáupptaka, halda vöku og [ræðsritun](11-text-extraction-dictation.md). Þau lýsast upp þegar hamurinn er virkur og halda sig annars frá — sveimaðu hvar sem er á slánni til að kíkja á þau óvirku. Að smella á vísi skiptir um þann ham. Einn til viðbótar er aðeins staða: fjartenging lýsist rauð á meðan einhver er tengdur við þessa vél í gegnum gliff.

Ef þú vilt frekar að þau séu alltaf sýnileg skaltu setja `alwaysShow` á `true` á bútinn. Og ef þér er aðeins sama um sum þeirra skaltu lista þau sem þú vilt í `items`: `["Dnd", "Reminder", "NightLight"]`. Þú getur haft fleiri en einn vísabút, svo mismunandi hlutar geta sýnt mismunandi undirmengi.

## Að endurraða slánni

Sláin stillir sig sjálf. Þú þarft ekki að opna stillingaskrá til að færa hluti.

Gríptu í tómt svæði á slánni um miðjuna og dragðu það í átt að annarri skjábrún, og sláin færist þangað — vinstri, hægri, efst eða neðst virkar allt, og hver bútur aðlagast (lóðréttar slár falla til baka í þéttar táknmyndir eingöngu). Smellur-og-hald byrjar sama drag. Tvísmelltu með vinstri á sama tóma svæðið til að skipta bakgrunni slárinnar úr gegnsæjum í glerkenndan í ógegnsæjan. Og dragðu hvaða bút sem er til að endurraða honum eða henda honum í annan hluta; hinir bútarnir renna í sundur til að gera pláss þar sem hann mun lenda.

Miðja slárinnar er kassi: það sem er í honum helst miðjað sem einn hópur, og bútarnir sitt hvorum megin við hann hanga af brúnum hans. Á meðan þú dregur bút sýnist kassinn sem útlína, eða lína yfir slána þegar hann er tómur, og þú getur sleppt inn í hann eða við hliðina á honum. Þegar slepping myndi lenda í kassanum stækkar kassinn til að taka bútinn inn.

Bútur sem þú vilt hafa nálægt en ekki alltaf í sjónmáli getur farið í skúffu bakkans: dragðu hann á bakkann, og skúffan opnast til að taka við honum. Hann situr þar á eftir forritatáknunum, birtist hvenær sem skúffan gerir það og heldur skúffunni sinni opinni á meðan spjaldið hans er uppi. Dragðu hann aftur út á slána til að setja hann aftur.

Ef þú vilt frekar velja úr valmynd hefur **Appearance → Menu Bar** staðsetninguna, og **Bar Background** velur hvernig sláin er teiknuð: **Opaque Bar**, **Glassy Bar** (gegnsæ, með það sem er fyrir aftan hana þokað), eða **Clear Bar**.

Sömu hlutir hafa skipanir, sem er það sem þú vilt fyrir [dotfiles](31-dotfiles.md) uppsetningu:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Til að bæta við eða fjarlægja bút alfarið skaltu nota viðbótaskipanirnar. `omarchy plugin list` prentar hvern bút sem skelin þekkir með auðkenni hans, og síðan:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Að fela slána

`Super + Shift + Space` skiptir slánni af og aftur á án þess að drepa skelina — spjöld og flýtilyklar halda áfram að virka, þú færð bara punktana til baka. Það er líka í valmyndinni undir **Appearance → Menu Bar → Hide Bar**.

## Stillingaskráin

Allt þetta er geymt í `~/.config/omarchy/shell.json`, undir `bar`-lyklinum. Hér er stytt útgáfa:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Hver bútur er ein færsla í einum af fimm uppsetningarfylkjunum, og stillingar hans sitja innfelldar á þeirri færslu — það er engin sérstök stillingaskrá og ekkert `config`-undirhlut. `format`, `formatAlt` (það sem hægrismellur skiptir yfir í) og `verticalFormat` klukkunnar búa öll þar á `{ "id": "omarchy.clock" }`.

`center` er kassinn í miðri slánni: allt í honum er miðjað á skjánum sem einn hópur. `centerBegin` og `centerEnd` hanga af hvorri hlið kassans, sem er hvernig klukkan helst dauðmiðjuð jafnvel þegar veðrið og uppfærslumerkið koma og fara. Settu fleiri en einn bút í `center` og þeir eru miðjaðir saman; skildu hann eftir tóman og `centerBegin` og `centerEnd` mætast í miðri slánni.

Ein regla sem vert er að tileinka sér: **þegar þú átt þína eigin `shell.json` er hún frumheimildin**. Þangað til þú sérsníður eitthvað les skelin sjálfgefna skrá Omarchy. Um leið og þú dregur bút, keyrir `omarchy bar` eða breytir skránni sjálfur átt þú hana — það er engin djúp sameining, svo nýir sjálfgefnir bútar í framtíðarútgáfum Omarchy munu ekki birtast á slánni þinni sjálfkrafa. `omarchy bar defaults` setur afhentu uppsetninguna aftur hvenær sem þú vilt hreint borð.

Sama skrá geymir líka aðgerðaleysistíma þína á efsta stigi, utan `bar`-lykilsins: `idle.screensaver` og `idle.lock`, bæði í sekúndum frá því þú varðst aðgerðalaus. Svo sjálfgefni skjávörðurinn fer í gang eftir 150 sekúndur og læsingin eftir 300.
