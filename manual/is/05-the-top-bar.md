# Efsta stikan

Ræman efst á skjánum þínum er Omarchy-stikan. Hún er ekki ábætt stöðustika heldur hluti af Omarchy-skelinni, eina langlífa Quickshell-ferlinu sem teiknar líka valmyndina, tilkynningarnar, OSD-sprettgluggana og læsiskjáinn. Þess vegna fellur hún fullkomlega að öllu öðru og þess vegna opnast spjald samstundis í stað þess að ræsa nýtt forrit.

Hún er líka eini hluti skjáborðsins sem er alltaf á skjánum, svo það borgar sig að vita hvað öll þessi litlu tákn gera.

## Hvað er á henni sjálfgefið

Stikan hefur þrjá hluta. Vinstra megin situr Omarchy-merkið (ræsir valmyndina) og vinnusvæðavísarnir. Í miðjunni færðu stöðuvísana, klukkuna, Elsewhen (heimsklukku), veðrið og Omarchy-uppfærslumerki. Hægra megin: kerfisbakkin, lyklaborðsuppsetningin (þegar fleiri en ein er stillt), umboð, bluetooth, net, hljóð, skjár og orka.

Nokkrir þeirra birtast aðeins þegar þeir hafa eitthvað að segja. Lyklaborðsuppsetningin birtist aðeins ef þú hefur stillt fleiri en eina uppsetningu. Uppfærslumerkið birtist aðeins þegar Omarchy-uppfærsla bíður. Og umboðstáknið birtist í fyrsta skipti sem Omarchy finnur notkun gervigreindar við forritun á vélinni (sjá [AI](17-ai.md)).

## Að smella um

Næstum sérhver græja gerir eitthvað við vinstri, hægri og miðsmell, og nokkrar bregðast við skrunun. Þetta er hlutinn sem fólk missir af — hægri og miðhnappurinn eru þar sem mikið af því góða felst.

| Græja | Vinstri | Hægri | Miðja / skrun |
| --- | --- | --- | --- |
| Valmynd | Omarchy-valmynd | Ný útstöð | — |
| Vinnusvæði | Beina fókus að því vinnusvæði á þessum skjá | — | Skrun: næsta/fyrra vinnusvæði |
| Klukka | Dagatalssprettigluggi | Skipta um snið merkingarinnar | Miðja: tímabeltisval |
| Veður | Sprettigluggi með veðurspá | Veður í heild sem tilkynning | Miðja: endurnýja |
| Hljóð | Hljóðspjald | Þagga | Miðja: spjald · skrun: hljóðstyrkur |
| Hljóðnemi | Þagga hljóðnemann | — | Miðja: hljóðspjald · skrun: inntaksstyrkur |
| Net | Netspjald | — | — |
| Bluetooth | Bluetooth-spjald | Kveikja/slökkva á sendinum | — |
| Skjár | Skjáspjald | — | Skrun: birtustig |
| Orka | Orkuspjald | Kveikja/slökkva á rafhlöðuprósentunni | — |
| Margmiðlun | Spila/setja í hlé | Sprettigluggi með umslagsmynd | Miðja: næsta · skrun: fyrra/næsta |
| Umboð | Umboðaspjald | Ræsa umboðið þitt | Miðja: næsta áskrift |
| Bakki | Sveima yfir til að opinbera skúffuna | Hægri á örinni til að stjórna | — |
| Omarchy-uppfærsla | Keyra uppfærsluna | — | — |

Ekki er allt í þessari töflu á stikunni þinni beint úr kassanum. Margmiðlunargræjan (MPRIS sem sýnir það sem er í spilun núna, með skrunandi lagi og listamanni) og hljóðnemagræjan eru báðar innbyggðar en slökktar sjálfgefið — bættu þeim við ef þú vilt þær, eins og lýst er hér að neðan.

## Spjöldin

Að smella á tákn á stiku opnar spjald, sem er alvöru sprettigluggi með rennistikum, listum og lyklaborðsflakki frekar en verkfæravísbending. Hvert þeirra hefur líka flýtilykil, svo þú þarft aldrei að miða á 16 pixla tákn:

| Flýtilykill | Spjald |
| --- | --- |
| `Super + Ctrl + A` | Hljóð |
| `Super + Ctrl + N` | Net |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skjár |
| `Super + Ctrl + P` | Orka |
| `Super + Ctrl + Alt + D` | Dagatal |
| `Super + Ctrl + Alt + E` | Heimsklukka |
| `Super + Ctrl + 1-9` | Kveikja/slökkva á n-ta spjaldinu í hægri hlutanum |

Spjöldin eru ekki bara aflestrar. Þau eru þar sem þú gerir hlutinn í raun:

- **Hljóð** er með aðalrennistik fyrir hljóðstyrk, val fyrir úttakstæki og blöndunartæki fyrir hvert forrit, svo þú getur lækkað í þeim eina vafraflipa án þess að snerta allt annað.
- **Net** leitar að Wi-Fi, sýnir merkjastyrk, tengist og lætur þig velja DNS-veitu.
- **Bluetooth** listar tækin þín með tengingu/aftengingu og rafhlöðustigum.
- **Orka** sýnir tölfræði rafhlöðu, skiptir um orkusnið (það man sérstakt val fyrir rafhlöðu og fyrir AC) og prentar nokkrar kerfisupplýsingar.
- **Skjár** er með rennistik fyrir birtustig, textastærð, forstillingar fyrir skjákvarða og — þegar þú ert með fleiri en einn skjá — stýringar fyrir hvern skjá. Sjá [skjái](33-monitors.md) fyrir dýpri söguna.
- **Klukka** opnar mánaðarnet með ISO-vikunúmerum og skrefum milli mánaða.
- **Heimsklukka** heldur röð fyrir hverja borg, með veðri hennar og hvernig dagurinn gengur þar. Leit finnur bæi jafnt sem tímabelti, svo Fort Lauderdale er Fort Lauderdale en ekki New York. Ef línan efst nefnir ranga borg skaltu smella á hana og segja hvar þú ert; veldu stað á öðru tímabelti og kerfisklukkan færist líka þangað, sem kemur sér vel þegar þú ferðast. Sveimaðu yfir borg og smelltu á persónuhnappinn til að segja hver býr þar — ber nöfn, eða `@` GitHub-auðkenni til að taka andlit þeirra með.

Sérhvert spjald tekur við lyklaborðinu jafnt sem músinni: örvar færa, Return virkjar, Tab stígur yfir á næsta spjald og Escape lokar.

`Super + Ctrl + 1-9` telur spjöld frá vinstri til hægri í hægri hlutanum og sleppir bakkanum þar sem hann hefur ekkert spjald sjálfur. Svo talan samsvarar tákninu sem þú myndir benda á.

### Tailscale og Dropbox

Tvær græjur til viðbótar birtast á stikunni aðeins þegar þú setur upp samsvarandi þjónustu úr **Uppsetning → Þjónusta**, og báðar er vert að þekkja því þær gera meira en að tilkynna stöðu.

**Tailscale**-spjaldið tengir og aftengir tailnet-ið, skiptir á milli reikninga og velur útgönguhnút (bæði vélarnar þínar og Mullvad-svæði birtast á þeim lista). Það vafrar líka um vélarnar þínar — og með eina valda sendir `s` skrár til hennar yfir Taildrop, sem er fljótlegasta leiðin til að færa skrá í símann þinn eða aðra fartölvu. `c` afritar IP-tölu vélarinnar, `n` nafn hennar og `d` fullt DNS-nafn hennar. Einnig er sendihnappur á hverri vélröð ef þú vilt frekar smella. Sama hlutur úr útstöðinni er `omarchy tailscale send <machine> [file...]`.

**Dropbox**-spjaldið sér um innskráningu, sýnir hversu mikið geymslupláss þú hefur notað og listar nýlega samstilltar skrár.

Að fjarlægja hvora þjónustuna sem er tekur græju hennar aftur af stikunni.

## Vísar

Lítill klasi í miðjunni er vísagræjan. Þetta eru stöðutákn fyrir stillingar sem þú hefur kveikt á: ekki trufla, næturljós, [áminning](09-reminders.md) í biðröð, virk skjáupptaka, halda vöku og [talinntak](11-text-extraction-dictation.md). Þau lýsast upp þegar stillingin er virk og halda sig annars frá — sveimaðu rétt við hliðina á þeim, þar sem þau óvirku myndu sitja, til að kíkja á þau. Að smella á vísi kveikir eða slekkur á þeirri stillingu. Einn í viðbót er aðeins staða: fjartenging lýsist rauð á meðan einhver er tengdur við þessa vél í gegnum gliff.

Ef þú vilt frekar að þau séu alltaf sýnileg skaltu stilla `alwaysShow` á `true` á græjunni. Og ef þér er aðeins annt um sum þeirra skaltu telja upp þau sem þú vilt í `items`: `["Dnd", "Reminder", "NightLight"]`. Þú getur haft fleiri en eina vísagræju, svo mismunandi hlutar geta sýnt mismunandi hlutmengi.

## Að endurraða stikunni

Stikan stillir sig sjálf. Þú þarft ekki að opna stillingaskrá til að færa hluti.

Gríptu í tóman blett á stikunni um miðjuna og dragðu hann að annarri skjábrún og stikan færist þangað — vinstri, hægri, efst eða neðst virkar allt, og sérhver græja aðlagast (lóðréttar stikur falla til baka í þétt form með táknum eingöngu). Smellur-og-hald byrjar sama drag. Tvísmelltu með vinstri hnappi á sama tóma rými til að skipta bakgrunni stikunnar úr gegnsæjum í glerkenndan í ógegnsæjan. Og dragðu hvaða græju sem er til að endurraða henni eða henda henni í annan hluta; hinar græjurnar renna í sundur til að gera pláss þar sem hún mun lenda.

Miðja stikunnar er kassi: það sem er í honum helst miðjað sem einn hópur, og græjurnar beggja vegna við hann hanga á brúnum hans. Á meðan þú dregur græju sýnist kassinn sem útlína, eða lína yfir stikuna þegar hann er tómur, og þú getur sleppt í hann eða við hlið hans. Þegar slepping myndi lenda í kassanum stækkar kassinn til að taka græjuna inn.

Græja sem þú vilt hafa við höndina en ekki alltaf í sjónmáli getur farið í skúffu bakkans: dragðu hana á bakkann og skúffan opnast til að taka við henni. Hún situr þar á eftir forritatáknunum, birtist þegar skúffan gerir það og heldur skúffunni sinni opinni á meðan spjaldið hennar er uppi. Dragðu hana aftur út á stikuna til að setja hana til baka.

Ef þú vilt frekar velja úr valmynd hefur **Útlit → Stika** staðsetninguna og **Bakgrunnur stiku** velur hvernig stikan er teiknuð: **Ógegnsæ stika**, **Glerkennd stika** (gegnsæ, með það sem er á bak við hana óskarpt) eða **Gegnsæ stika**.

Sömu hlutir hafa skipanir, sem er það sem þú vilt fyrir [dotfiles](31-dotfiles.md) uppsetningu:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Til að bæta græju við eða fjarlægja hana alveg skaltu nota viðbótaskipanirnar. `omarchy plugin list` prentar sérhverja græju sem skelin þekkir með auðkenni hennar, og síðan:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Að fela stikuna

`Super + Shift + Space` kveikir og slekkur á stikunni án þess að drepa skelina — spjöld og flýtilyklar halda áfram að virka, þú færð bara pixlana til baka. Það er líka í valmyndinni undir **Útlit → Stika → Fela stiku**.

## Stillingaskráin

Allt er geymt í `~/.config/omarchy/shell.json`, undir `bar` lyklinum. Hér er stytt útgáfa:

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

Sérhver græja er ein færsla í einum af fimm uppröðunarfylkjunum og stillingar hennar sitja innfelldar á þeirri færslu — það er engin sérstök stillingaskrá og ekkert `config`-undirhlut. `format`, `formatAlt` (það sem hægrismellur skiptir yfir í) og `verticalFormat` hjá klukkunni búa öll þar á `{ "id": "omarchy.clock" }`.

`center` er kassinn í miðju stikunnar: allt í honum er miðjað á skjánum sem einn hópur. `centerBegin` og `centerEnd` hanga á hvorri hlið kassans, sem er hvernig klukkan helst nákvæmlega í miðjunni jafnvel þegar veðrið og uppfærslumerkið koma og fara. Settu fleiri en eina græju í `center` og þær miðjast saman; skildu hann eftir tóman og `centerBegin` og `centerEnd` mætast í miðju stikunnar.

Ein regla sem vert er að leggja á minnið: **þegar þú átt þína eigin `shell.json` er hún ráðandi**. Þangað til þú aðlagar eitthvað les skelin sjálfgefna skrá Omarchy. Um leið og þú dregur græju, keyrir `omarchy bar` eða breytir skránni sjálfur átt þú hana — það er engin djúp samruni, svo nýjar sjálfgefnar græjur í framtíðarútgáfum Omarchy munu ekki birtast sjálfkrafa á stikunni þinni. `omarchy bar defaults` setur meðfylgjandi uppröðun til baka hvenær sem þú vilt hreint borð.

Sama skráin geymir líka aðgerðaleysistíma þína á efsta stigi, utan `bar` lykilsins: `idle.screensaver` og `idle.lock`, bæði í sekúndum síðan þú fórst í aðgerðaleysi. Svo sjálfgefni skjávörðurinn fer í gang eftir 150 sekúndur og læsingin eftir 300.
