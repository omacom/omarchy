# Valmyndastikan

Ströndin eftir efri hluta skjásins er Omarchy-stikan. Hún er ekki stöðustika sem var skrúfuð á eftirá heldur hluti af Omarchy-skelinni, eina langlífa Quickshell-ferlinu sem teiknar líka valmyndina, tilkynningarnar, OSD-sprettiguggana og læsingarskjáinn. Þess vegna þemast hún fullkomlega með öllu öðru og þess vegna opnast spjald samstundis í stað þess að ræsa nýtt forrit.

Hún er líka eini hluti skjáborðsins sem er alltaf á skjánum, svo það er þess virði að vita hvað öll þessi litlu tákn gera.

## Hvað er á henni sjálfgefið

Stikan hefur þrjá hluta. Vinstra megin situr Omarchy-merkið (valmyndaræsirinn) og vinnusvæðavísarnir. Í miðjunni færðu stöðuvísana, klukkuna, Elsewhen (heimsklukku), veðrið og Omarchy-uppfærslumerki. Hægra megin: lyklaborðsskipanina (þegar fleiri en ein er stillt), kerfisbakkan, agents, bluetooth, net, hljóð, skjá og orku.

Nokkur af þessu birtist aðeins þegar það hefur eitthvað að segja. Lyklaborðsskipanin birtist aðeins ef þú hefur stillt fleiri en eina skipan. Uppfærslumerkið birtist aðeins þegar Omarchy-uppfærsla bíður. Og agents-táknið birtist í fyrsta skipti sem Omarchy finnur notkun á gervigreindarkóðun á vélinni (sjá [AI](17-ai.md)).

## Að smella um

Næstum hver græja gerir eitthvað við vinstri, hægri og miðjusmell, og nokkrar bregðast við skrunun. Þetta er hlutinn sem fólk missir af — hægri og miðjuhnappurinn eru þar sem mikið af góða efninu felur sig.

| Græja | Vinstri | Hægri | Miðja / skrunun |
| --- | --- | --- | --- |
| Valmynd | Omarchy-valmynd | Nýr terminal | — |
| Vinnusvæði | Fókusa á það vinnusvæði | — | Skrunun: næsta/fyrra vinnusvæði |
| Klukka | Dagatalssprettigluggi | Skipta um merkissnið | Miðja: tímabeltaval |
| Veður | Spásprettigluggi | Fullt veður sem tilkynning | Miðja: endurnýja |
| Hljóð | Hljóðspjald | Þagga | Miðja: spjald · skrunun: hljóðstyrkur |
| Hljóðnemi | Þagga hljóðnemann | — | Miðja: hljóðspjald · skrunun: inntakshljóðstyrkur |
| Net | Netspjald | — | — |
| Bluetooth | Bluetooth-spjald | Víxla útvarpinu | — |
| Skjár | Skjáspjald | — | Skrunun: birta |
| Orka | Orkuspjald | Víxla rafhlöðuhlutfalinu | — |
| Miðlar | Spila/gera hlé | Spjald með forsíðumynd | Miðja: næsta · skrunun: fyrra/næsta |
| Agents | Agents-spjald | Ræsa agentinn þinn | Miðja: næsta áskrift |
| Bakki | Sveimðu til að birta skúffuna | Hægri á örina til að stjórna | — |
| Omarchy-uppfærsla | Keyra uppfærsluna | — | — |

Ekki er allt í þeirri töflu á stikunni þinni úr kassanum. Miðlagræjan (MPRIS, það sem er verið að spila, með skrunnandi lagi og flytjanda) og hljóðnemagræjan eru báðar innbyggðar en slökktar sjálfgefið — bættu þeim við ef þú vilt þær, eins og lýst er hér að neðan.

## Spjöldin

Að smella á tákni í stikunni opnar spjald, sem er alvöru sprettigluggi með sleðum, listum og lyklaborðsleiðsögn frekar en verkfæratipp. Hvert þeirra hefur líka flýtilykil, svo þú þarft aldrei að miða á 16 punkta tákn:

| Flýtilykill | Spjald |
| --- | --- |
| `Super + Ctrl + A` | Hljóð |
| `Super + Ctrl + W` | Net |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skjár |
| `Super + Ctrl + P` | Orka |
| `Super + Ctrl + Alt + D` | Dagatal |
| `Super + Ctrl + Alt + E` | Heimsklukka |
| `Super + Ctrl + 1-9` | Víxla n-ta spjaldinu í hægri hlutanum |

Spjöldin eru ekki aflestrar. Þau eru þar sem þú gerir hlutina í alvöru:

- **Hljóð** hefur aðalhljóðstyrkssleða, val fyrir úttakstæki og blandara fyrir hvert forrit, svo þú getir lækkað í þessum eina vafraflipu án þess að snerta allt annað.
- **Net** skannar eftir Wi-Fi, sýnir merkisstyrk, tengist og lætur þig velja DNS-veitu.
- **Bluetooth** listar tækin þín með tengingu/aftengingu og rafhlöðustöðu.
- **Orka** sýnir rafhlöðutölfræði, skiptir um orkusnið (það man sérstakt val fyrir rafhlöðu og rafstraum) og prentar nokkrar kerfisupplýsingar.
- **Skjár** ber birtusleða, textastærð, forstillingar fyrir skjákvörðun og — þegar þú hefur fleiri en einn skjá — stjórntæki fyrir hvern skjá. Sjá [skjái](33-monitors.md) fyrir dýpri söguna.
- **Klukka** opnar mánaðarnet með ISO-vikunúmerum og mánaðarþrepum.

Hvert spjald tekur við lyklaborðinu jafnt sem músinni: örvar færa, Return virkjar, Tab stígur á næsta spjald og Escape lokar.

`Super + Ctrl + 1-9` telur spjöld frá vinstri til hægri í hægri hlutanum og sleppir bakkanum þar sem hann hefur ekkert eigið spjald. Svo talan samsvarar tákninu sem þú myndir benda á.

### Tailscale og Dropbox

Tvær græjur til viðbótar birtast á stikunni aðeins þegar þú setur upp samsvarandi þjónustu úr **Setja upp → Þjónusta**, og það er þess virði að þekkja þær báðar þar sem þær gera meira en að tilkynna stöðu.

**Tailscale**-spjaldið tengir og aftengir tailnetið, skiptir á milli reikninga og velur útgönguhnút (bæði þínar eigin vélar og Mullvad-svæði birtast á þeim lista). Það vafrar líka um vélarnar þínar — og með eina valda sendir `s` skrár til hennar með Taildrop, sem er fljótlegasta leiðin til að flytja skrá í símann þinn eða aðra fartölvu. `c` afritar IP-tölu vélarinnar, `n` nafn hennar og `d` fullt DNS-nafn hennar. Það er líka sendihnappur á hverri vélaröð ef þú vilt frekar smella. Sama úr terminal er `omarchy tailscale send <machine> [file...]`.

**Dropbox**-spjaldið sér um innskráningu, sýnir hversu mikið geymslupláss þú hefur notað og listar nýlega samstilltar skrár.

Að fjarlægja aðra hvora þjónustuna tekur græjuna hennar aftur af stikunni.

## Vísar

Litli hópurinn í miðjunni er vísagræjan. Þetta eru stöðutákn fyrir stillingar sem þú hefur kveikt á: ekki trufla, næturljós, [áminningu](09-reminders.md) í biðröð, virka skjáupptöku, halda vakandi og [upplesningu](11-text-extraction-dictation.md). Þau lýsast þegar stillingin er virk og halda sig annars til hlés — sveimðu vinstra megin við klukkuna (fyrir ofan hana á lóðréttri stiku) til að kíkja á þau óvirku. Að smella á vísi víxlar þeirri stillingu. Einn í viðbót er aðeins staða: fjartenging lýsist rauð á meðan einhver er tengdur við þessa vél í gegnum gliff.

Ef þú vilt frekar að þau séu alltaf sýnileg skaltu stilla `alwaysShow` á `true` á græjunni. Og ef þér er aðeins sama um sum þeirra skaltu lista þau sem þú vilt í `items`: `["Dnd", "Reminder", "NightLight"]`. Þú getur haft fleiri en eina vísagræju, svo mismunandi hlutar geta sýnt mismunandi undirmengi.

## Að endurraða stikunni

Stikan stillir sig sjálf. Þú þarft ekki að opna stillingarskrá til að færa hluti.

Gríptu í tóman blett á stikunni í kringum miðjuna og dragðu hann í átt að öðrum skjájaðri, og stikan færist þangað — vinstri, hægri, efst eða neðst virkar allt, og hver græja aðlagast (lóðréttar stikur falla aftur í þéttar form með aðeins táknum). Smellur-og-halda byrjar sama drag. Tvívinstri-smelltu á sama tóma blettinn til að skipta bakgrunni stikunnar úr tærum í glerkenndan í ógegnsæjan. Og dragðu hvaða græju sem er til að endurraða henni eða kasta henni í annan hluta.

Græja sem þú vilt hafa við höndina en ekki alltaf í augsýn getur farið í skúffu bakkans: dragðu hana á bakkann og skúffan opnast til að taka við henni. Hún situr þar á eftir forritatáknunum, birtist alltaf þegar skúffan gerir það og heldur skúffunni opinni á meðan spjaldið hennar er opið. Dragðu hana aftur út á stikuna til að setja hana til baka.

Ef þú vilt frekar velja úr valmynd hefur **Kveikja → Útlit → Valmyndastika** staðsetninguna, og **Bakgrunnur stiku** velur hvernig stikan er teiknuð: **Ógegnsæ stika**, **Glerstika** (gegnumskyggn, með því sem er á bak við hana þokað) eða **Tær stika**.

Sömu hlutir hafa skipanir, sem er það sem þú vilt fyrir [dotfiles](31-dotfiles.md)-uppsetningu:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Til að bæta græju við eða fjarlægja hana alveg skaltu nota viðbótar-skipanirnar. `omarchy plugin list` prentar hverja græju sem skelin þekkir með auðkenni hennar, og síðan:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Að fela stikuna

`Super + Shift + Space` víxlar stikunni af og á aftur án þess að drepa skelina — spjöld og flýtilyklar halda áfram að virka, þú færð bara punktana til baka. Það er líka í valmyndinni undir **Kveikja → Útlit → Valmyndastika → Fela stiku**.

## Stillingarskráin

Allt þetta er geymt í `~/.config/omarchy/shell.json`, undir `bar`-lyklinum. Hér er stytt útgáfa:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Hver græja er ein færsla í einu af þremur skipulagsfylkjunum, og stillingar hennar sitja innfelldar á þeirri færslu — það er engin sérstök stillingarskrá og ekkert `config`-undirhlutur. `format` klukkunnar, `formatAlt` (það sem hægrismellur skiptir yfir í) og `verticalFormat` búa öll þarna á `{ "id": "omarchy.clock" }`.

`centerAnchor` nefnir þá einu miðjugræju sem er fest nákvæmlega í miðju skjásins, með hinar á hliðunum. Þannig helst klukkan dauð í miðjunni jafnvel þegar veðrið og uppfærslumerkið koma og fara. Stilltu það á tóman streng og miðjulistinn er bara miðjustilltur sem hópur í staðinn.

Ein regla sem er þess virði að innbyrða: **þegar þú hefur þína eigin `shell.json` er hún sú eina gilda**. Þar til þú aðlagar eitthvað les skelin sjálfgefna skrá Omarchy. Um leið og þú dregur græju, keyrir `omarchy bar` eða breytir skránni sjálfur, átt þú hana — það er engin djúp samruni, svo nýjar sjálfgefnar græjur í framtíðarútgáfum Omarchy munu ekki birtast á stikunni þinni sjálfkrafa. `omarchy bar defaults` setur afhenta skipulagið til baka hvenær sem þú vilt hreint borð.

Sama skrá geymir líka aðgerðaleysisstillingu þína á efsta stigi, utan `bar`-lykilsins: `idle.screensaver` og `idle.lock`, bæði í sekúndum frá því þú varðst óvirkur. Svo sjálfgefni skjáverjinn fer af stað eftir 150 sekúndur og læsingin eftir 300.
