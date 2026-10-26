# Rofar, aðgerðaleysi og skjáhvílan

Margt af því sem þú breytir dag frá degi er í raun ekki stilling. Það er hamur sem þú kveikir á í klukkustund og slekkur svo aftur: næturljós á meðan þú vinnur seint, ekki trufla á meðan þú ert með kynningu, halda vakandi á meðan þú horfir á eitthvað. Omarchy kallar þá rofa og þeir virka allir eins — flýtilykill, valmyndaratriði og skipun, allt að ýta á sama rofann.

### Rofavalmyndin

`Super + Ctrl + O` opnar _Trigger > Toggle_ beint, eða þú getur farið þangað úr Omarchy-valmyndinni (`Super + Space`). Allt á þeim lista er rofi sem þú getur slegið á án þess að hugsa um hvar ástandið býr. Rofar fyrir útlit skjáborðsins sitja við hliðina á honum, undir _Appearance_.

Í flugstöðinni eru sömu rofar `omarchy toggle <thing>`. Keyrðu `omarchy toggle` eitt og sér til að sjá allan hópinn.

| Rofi | Flýtilykill | Skipun |
| ------ | ------ | ------- |
| Næturljós | — | `omarchy toggle nightlight` |
| Þagga tilkynningar | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Halda vakandi (engin læsing við aðgerðaleysi) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Hrunskráning | — | `omarchy toggle crash-capture` |
| Skjáhvíla | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) samstilling þema | — | `omarchy toggle theme sync` |
| Valmyndarstika | `Super + Shift + Space` | `omarchy toggle bar` |
| Snertiplatti | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Snertiskjár | — | `omarchy toggle touchscreen` |
| Svæfa | — | `omarchy toggle suspend` |
| Blönduð GPU | — | `omarchy toggle hybrid gpu` |

Snertiplatta-, snertiskjá- og blönduðu GPU-rofarnir búa undir _Trigger > Hardware_ (`Super + Ctrl + H`) frekar en undir Toggle, þar sem þeir birtast aðeins þegar þú ert raunverulega með þann vélbúnað. Snertiplatta- og snertiskjárofarnir lifa Hyprland-endurræsingu af — nafn óvirka tækisins er vistað í litla ástandsskrá sem Hyprland les við ræsingu til að gera það óvirkt aftur.

_Appearance_ geymir valmyndarstikuna og hreyfingar, auk nokkurra hluta sem eru ekki `omarchy toggle` skipanir en hegða sér eins: prósenta rafhlöðu í stikunni, sjálfgefið skipulag vinnusvæða og, undir _Windows_, bil milli glugga (`Super + Shift + Backspace`) og ferkantað hlutfall fyrir 1 glugga (`Super + Ctrl + Backspace`).

Flestir þeirra eru bara fánaskrá undir `~/.local/state/omarchy/toggles/`. Ef þú vilt greina á einn í forskrift, þá gefur `omarchy-toggle-enabled` þér útgöngukóða í stað þess að láta þig fara að leita:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Fánarnir eru nefndir eftir slökktu ástandinu — `screensaver-off`, `suspend-off`, `bar-off` — svo tilvist þeirra þýðir að eiginleikinn er óvirkur.

### Vísar í stikunni

Þegar hamur er virkur færðu lítið tákn í miðri efri stikunni við hlið klukkunnar. Það er vísagræjan og hún ber upptöku með rödd, skjáupptöku, áminningar í bið, næturljós, ekki trufla og halda vakandi.

Óvirkir vísar eru faldir. Sveimaðu einhvers staðar yfir stikunni og þeir birtast deyfðir, svo þú getur smellt á einn til að kveikja á honum án þess að þekkja flýtilykilinn hans. Að smella á virkan vísi slekkur á honum aftur. Ef þú vilt frekar sjá þá alla alltaf skaltu stilla `alwaysShow` á `true` á `omarchy.indicators` færslunni í `~/.config/omarchy/shell.json` — sjá [efri stikuna](05-the-top-bar.md) um hvernig græjur í stiku eru stilltar.

### Næturljós

Næturljós vermir skjáinn í 4000K og að slá á það aftur setur hann aftur í 6500K. Sláðu á það úr rofavalmyndinni (`Super + Ctrl + O`) eða með `omarchy toggle nightlight`. Það er knúið af hyprsunset, sem rofinn ræsir fyrir þig ef það er ekki þegar í gangi.

Sjálfgefið gerir hyprsunset alls ekkert við skjáinn þinn. `~/.config/hypr/hyprsunset.conf` fylgir með auðkennisprófíl einmitt til að skjárinn haldist ósnortinn þar til þú biður um hlýju. Ef þú vilt frekar að það skipti eftir klukkunni skaltu skipta því út fyrir tímaprófíl:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ræstu svo hyprsunset við innskráningu með því að bæta `o.launch_on_start("hyprsunset")` við `~/.config/hypr/autostart.lua`. 4000K/6500K parið sem rofinn notar er fast, svo stillingaskráin er staðurinn til að fara á ef þú vilt annað hitastig.

### Ekki trufla

`Super + Ctrl + Alt + ,` þaggar tilkynningar. Engar tilkynningar skjótast upp á meðan það er virkt og yfirstrikaða bjölluvísirinn situr í stikunni til að minna þig á af hverju skjáborðið er orðið hljótt.

Ekkert glatast þó. Þögguðum tilkynningum er haldið eftir: settu síðustu nokkrar aftur á skjáinn með `Super + Shift + Alt + ,`. Sjá [tilkynningar](10-notices.md) fyrir afganginn.

Tvenns konar skilaboð komast samt í gegn: eigin staðfestingartilkynningar Omarchy fyrir eitthvað sem þú varst að gera ("Þema breytt", "Skjámynd vistuð") og mikilvæg viðvörun send af skipanalínunni. Spjallforrit sem merkja allt mikilvægt til að þvinga sig fram fyrir þig eiga það ekki skilið.

### Aðgerðaleysi

Omarchy-skelin á hegðun við aðgerðaleysi og tímarnir eru `idle` blokk á efsta stigi í `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Báðar tölurnar eru sekúndur taldar frá augnablikinu þegar þú varðst aðgerðalaus — ekki hver frá annarri. Svo með sjálfgefnu gildunum kemur skjáhvílan upp eftir tvær og hálfa mínútu og læsingarskjárinn tekur við eftir fimm mínútur, hvort sem skjáhvílan keyrði eða ekki. Vistaðu skrána og skelin tekur upp nýju tímana strax.

Ef þú vísar skjáhvílunni frá fyrir læsingarfrestinn telst það sem virkni og læsingin í bið er aflýst. Þú læsist ekki úti fyrir að líta á vélina þína.

Til að hætta alveg að læsa við aðgerðaleysi snýr `Super + Ctrl + I` — eða `omarchy toggle idle` — halda vakandi á, og kaffibollavísirinn birtist í stikunni. Það er sá sem á að ýta á fyrir langa kynningu eða byggingu sem þú vilt fylgjast með. Ýttu á hann aftur til að fara til baka í venjulegt ástand. `omarchy toggle idle status` prentar núverandi ástand sem JSON ef þú þarft það úr forskrift.

Þetta snýst um læsingu og skjáhvíluna, ekki afl. Svæfing og dvali hafa sína eigin uppsetningu í [kerfissvefni](36-system-sleep.md).

### Skjáhvílan

Skjáhvíla Omarchy er ASCII-list sem keyrir í gegnum slembin textaáhrif, eitt tilvik á hvern skjá. Sérhver lykill eða hreyfing músar hættir henni.

Þú getur ræst hana eftir þörfum úr _System > Screensaver_ (`Super + Esc`), sem þvingar hana upp jafnvel þó þú hafir slökkt á skjáhvílu við aðgerðaleysi. Enginn flýtilykill er sjálfgefið bundinn við hana.

`omarchy toggle screensaver` er það sem slekkur á þeirri við aðgerðaleysi, ef þú vilt frekar fara beint úr vinnu í læst ástand. Hún þarf flugstöð sem hún veit hvernig á að stilla — Alacritty, Foot, Ghostty eða Kitty — og lætur þig vita ef sjálfgefna flugstöðin þín er eitthvað annað.

Merkið sem hún teiknar er þitt að breyta, undir _Appearance > Branding > Screensaver_. Hladdu upp png eða svg og Omarchy breytir því í ASCII. Sjá [vörumerki](41-branding.md).

### Læsingarskjárinn

`Super + Ctrl + L` læsir vélinni. Það keyrir læsingarskjáinn úr Omarchy-skelinni, slekkur á skjánum, endurstillir lyklaborðsskipulagið þitt á það fyrsta svo þú sért ekki að slá inn lykilorðið þitt á röngu stafrófi og — ef þú ert með hann í gangi — læsir 1Password á leiðinni út.

Læsingarskjárinn tekur lykilorð og hann tekur líka fingrafar þegar þú hefur sett eitt upp. Það, og aðrar leiðir til að auðkenna þig, er fjallað um í [auðkenningu með vélbúnaði](37-hardware-authentication.md).
