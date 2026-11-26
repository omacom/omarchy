# Rofar, aðgerðaleysi og skjávörnin

Margt af því sem þú breytir frá degi til dags er í raun ekki stilling. Það er hamur sem þú kveikir á í klukkustund og slekkur svo aftur á: næturljós á meðan þú vinnur fram eftir, truflaðu ekki á meðan þú ert að kynna, haltu þér vakandi á meðan þú horfir á eitthvað. Omarchy kallar þá rofa, og þeir virka allir eins — flýtilykill, færsla í valmynd og skipun, allt að ýta á sama rofann.

### Rofavalmyndin

`Super + Ctrl + O` opnar _Trigger > Toggle_ beint, eða þú getur farið þangað úr Omarchy-valmyndinni (`Super + Space`). Allt á þeim lista er rofi sem þú getur víxlað án þess að hugsa um hvar ástandið býr. Rofar fyrir útlit skjáborðsins sitja við hliðina á honum, undir _Appearance_.

Frá skipanalínunni eru sömu rofarnir `omarchy toggle <thing>`. Keyrðu `omarchy toggle` eitt og sér til að sjá allan hópinn.

| Rofi | Flýtilykill | Skipun |
| ------ | ------ | ------- |
| Næturljós | — | `omarchy toggle nightlight` |
| Þagga tilkynningar | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Haltu þér vakandi (engin læsing við aðgerðaleysi) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Hrunsöfnun | — | `omarchy toggle crash-capture` |
| Skjávörn | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) samstilling þema | — | `omarchy toggle theme sync` |
| Valmyndaslá | `Super + Shift + Space` | `omarchy toggle bar` |
| Skjáborð í fullum skjá (engin slá, engin bil) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Hreyfimyndir, þoka og skuggar | — | `omarchy toggle animations` |
| Snertiflötur | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Snertiskjár | — | `omarchy device touchscreen` |
| Svæfa | — | `omarchy toggle suspend` |
| Blönduð GPU | — | `omarchy device gpu hybrid` |

Rofarnir fyrir snertiflöt, snertiskjá og blandaða GPU búa undir _Trigger > Hardware_ (`Super + Ctrl + H`) frekar en undir Toggle, þar sem þeir birtast aðeins þegar þú ert raunverulega með þann vélbúnað. Rofarnir fyrir snertiflöt og snertiskjá lifa Hyprland endurhleðslu af — nafn óvirka tækisins er vistað í litla ástandsskrá sem Hyprland les við ræsingu til að gera það óvirkt aftur.

_Appearance_ geymir valmyndaslána og hreyfimyndirnar, auk nokkurra hluta sem eru ekki `omarchy toggle` skipanir en hegða sér eins: rafhlöðuprósentu í slánni, sjálfgefið skipulag vinnusvæða og, undir _Windows_, bil milli glugga (`Super + Shift + Backspace`) og ferningshlutfallið fyrir 1 glugga (`Super + Ctrl + Backspace`).

Þegar Hyprland hefur enga GPU til að teikna með og teiknar í staðinn á CPU (llvmpipe), eins og á Mac-tölvum þar sem GPU er ekki enn studd, í flestum sýndarvélum, eða þegar grafíkreki tekst ekki að hlaðast, slekkur Omarchy á hreyfimyndum, þoku og skuggum fyrir þá lotu og lætur þig vita einu sinni með tilkynningu. _Appearance > Animations On_ kveikir á þeim aftur, og Omarchy man það líka fyrir síðari lotur.

Flestir þeirra eru bara fánaskrá undir `~/.local/state/omarchy/toggles/`. Ef þú vilt greina á einum í forskrift gefur `omarchy-toggle-enabled` þér útgöngukóða í stað þess að láta þig fara að leita:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Fánarnir eru nefndir eftir slökkta ástandinu — `screensaver-off`, `suspend-off`, `bar-off` — svo tilvist þeirra þýðir að eiginleikinn er óvirkur.

### Vísar í slánni

Þegar hamur er á færðu lítið tákn í miðri efstu slánni við hliðina á klukkunni. Það er vísagræjan, og hún ber skjáupptöku, væntanlegar áminningar, næturljós, truflaðu ekki og haltu þér vakandi, auk viðvarana á meðan lykilorðalaus sudo er á eða einhver er tengdur við fjarlotu.

Óvirkir vísar eru faldir. Sveimaðu hvar sem er yfir slánni og þeir birtast daufir, svo þú getir smellt á einn til að kveikja á honum án þess að þekkja flýtilykilinn hans. Að smella á virkan einn slekkur á honum aftur. Ef þú vilt frekar sjá þá alla alltaf skaltu stilla `alwaysShow` á `true` á `omarchy.indicators` færslunni í `~/.config/omarchy/shell.json` — sjá [efstu slána](05-the-top-bar.md) um hvernig slágræjur eru stilltar.

### Næturljós

Næturljós hitar skjáinn í 4000K, og að víxla því aftur setur hann aftur í 6500K. Víxlaðu því úr rofavalmyndinni (`Super + Ctrl + O`) eða með `omarchy toggle nightlight`. Það er knúið af hyprsunset, sem rofinn ræsir fyrir þig ef það er ekki þegar í gangi.

Sjálfgefið gerir hyprsunset alls ekkert við skjáinn þinn. `~/.config/hypr/hyprsunset.conf` fylgir með auðkennissnið nákvæmlega til þess að skjárinn haldist ósnortinn þar til þú biður um hlýju. Ef þú vilt frekar að það skipti eftir klukkunni skaltu skipta því út fyrir tímasnið:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ræstu síðan hyprsunset við innskráningu með því að bæta `o.launch_on_start("hyprsunset")` við `~/.config/hypr/autostart.lua`. 4000K/6500K parið sem rofinn notar er fast, svo stillingaskráin er staðurinn þangað sem þú ferð ef þú vilt annað hitastig.

### Truflaðu ekki

`Super + Ctrl + Alt + ,` þaggar tilkynningar. Engin skilaboð birtast á meðan það er á, og vísirinn með yfirstrikuðu bjöllunni situr í slánni til að minna þig á hvers vegna skjáborðið er orðið hljótt.

Ekkert glatast þó. Þögguðum tilkynningum er haldið eftir: settu síðustu nokkrar aftur á skjáinn með `Super + Shift + Alt + ,`. Sjá [tilkynningar](10-notices.md) um restina.

Þrjár tegundir skilaboða komast samt í gegn: eigin staðfestingarskilaboð Omarchy fyrir eitthvað sem þú varst að gera ("Þema breytt", "Skjámynd vistuð"), mikilvæg viðvörun send úr skipanalínunni og staðfestingarkóðar. Spjallforrit sem merkja allt mikilvægt til að þvinga sig fram fyrir þig teljast ekki með.

### Aðgerðaleysi

Omarchy-skelin á aðgerðaleysishegðunina, og tímasetningarnar eru efstastigs `idle` blokk í `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Báðar tölurnar eru sekúndur taldar frá augnablikinu þegar þú varðst aðgerðalaus — ekki hvor frá annarri. Svo með sjálfgefnum gildum kemur skjávörnin upp eftir tvær og hálfa mínútu og lásaskjárinn tekur við eftir fimm mínútur, hvort sem skjávörnin keyrði eða ekki. Vistaðu skrána og skelin tekur upp nýju tímasetningarnar strax.

Ef þú vísar skjávörninni frá áður en lásafresturinn rennur út telst það sem virkni og væntanleg læsing er aflýst. Þér verður ekki læst úti fyrir að líta á vélina þína.

Til að hætta alveg að læsa við aðgerðaleysi kveikir `Super + Ctrl + I` — eða `omarchy toggle idle` — á haltu þér vakandi, og kaffibollavísirinn birtist í slánni. Það er sá sem á að ýta á fyrir langa kynningu eða byggingu sem þú vilt fylgjast með. Ýttu á hann aftur til að fara aftur í eðlilegt ástand. `omarchy toggle idle status` prentar núverandi ástand sem JSON ef þú þarft það úr forskrift.

Þetta snýst um læsingu og skjávörnina, ekki orku. Svæfing og dvali hafa sína eigin uppsetningu í [kerfissvefn](36-system-sleep.md).

### Skjávörnin

Skjávörn Omarchy er ASCII-list sem keyrir í gegnum handahófskennd textaáhrif, eitt tilvik á hvern skjá. Sérhver lykill eða músahreyfing fer úr henni.

Þú getur ræst hana eftir þörfum úr _System > Screensaver_ (`Super + Esc`), sem þvingar hana upp jafnvel þótt þú hafir slökkt á aðgerðaleysis-skjávörninni. Enginn flýtilykill er sjálfgefið bundinn við hana.

`omarchy toggle screensaver` er það sem slekkur á þeirri aðgerðaleysu, ef þú vilt frekar fara beint frá vinnu í læst ástand. Sérhver lykill, smellur, skrun eða músahreyfing lokar henni.

Merkið sem hún teiknar er þitt að breyta, undir _Appearance > Branding > Screensaver_. Hladdu upp png eða svg og Omarchy breytir því í ASCII. Sjá [vörumerki](41-branding.md).

### Lásaskjárinn

`Super + Ctrl + L` læsir vélinni. Það keyrir lásaskjáinn úr Omarchy-skelinni, slekkur á skjánum, endurstillir lyklaborðsuppsetninguna þína á þá fyrstu svo þú sért ekki að slá inn lykilorðið þitt í röngu stafrófi, og — ef þú ert með það í gangi — læsir 1Password á leiðinni út.

Lásaskjárinn tekur lykilorð, og hann tekur líka fingrafar þegar þú hefur sett eitt upp. Það, og hinar leiðirnar til að auðkenna þig, er fjallað um í [vélbúnaðarauðkenningu](37-hardware-authentication.md).
