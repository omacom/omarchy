# Víxlar, aðgerðaleysi og skjávarinn

Mikið af því sem þú breytir dag frá degi er í raun ekki stilling. Það er hamur sem þú kveikir á í klukkustund og slekkur svo aftur: náttljós á meðan þú vinnur seint, ekki trufla á meðan þú ert með kynningu, halda vakandi á meðan þú horfir á eitthvað. Omarchy kallar þetta víxla, og þeir virka allir eins — flýtilykill, valmyndaratriði og skipun, allt að ýta á sama rofann.

### Víxlavalmyndin

`Super + Ctrl + O` opnar _Trigger > Toggle_ beint, eða þú getur gengið þangað úr Omarchy-valmyndinni (`Super + Space`). Allt á þeim lista er rofi sem þú getur víxlað án þess að hugsa um hvar ástandið býr. Rofar fyrir útlit skjáborðsins sitja við hliðina á honum, undir _Appearance_.

Frá skipanalínunni eru sömu rofarnir `omarchy toggle <thing>`. Keyrðu `omarchy toggle` eitt og sér til að sjá allan hópinn.

| Víxl | Flýtilykill | Skipun |
| ------ | ------ | ------- |
| Náttljós | — | `omarchy toggle nightlight` |
| Þagga tilkynningar | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Halda vakandi (engin læsing við aðgerðaleysi) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Hrunskráning | — | `omarchy toggle crash-capture` |
| Skjávarí | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) samstilling þema | — | `omarchy toggle theme sync` |
| Valmyndastika | `Super + Shift + Space` | `omarchy toggle bar` |
| Snertipúði | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Snertiskjár | — | `omarchy toggle touchscreen` |
| Biðstaða | — | `omarchy toggle suspend` |
| Blönduð GPU | — | `omarchy toggle hybrid gpu` |

Víxlarnir fyrir snertipúða, snertiskjá og blandaða GPU búa undir _Trigger > Hardware_ (`Super + Ctrl + H`) frekar en undir Toggle, þar sem þeir birtast aðeins þegar þú ert raunverulega með þann vélbúnað. Víxlarnir fyrir snertipúða og snertiskjá lifa endurræsingu Hyprland af — nafn óvirka tækisins er vistað í litla ástandsskrá sem Hyprland les við ræsingu til að gera það óvirkt aftur.

_Appearance_ geymir valmyndastikuna og hreyfimyndir, auk nokkurra hluta sem eru ekki `omarchy toggle` skipanir en hegða sér eins: prósentu rafhlöðu í stikunni, sjálfgefið skipulag vinnusvæða, og undir _Windows_, bil í gluggum (`Super + Shift + Backspace`) og ferningslaga hlutfall fyrir einn glugga (`Super + Ctrl + Backspace`).

Þegar Hyprland hefur enga GPU til að teikna með og teiknar í staðinn á CPU (llvmpipe), eins og á Mac-tölvum þar sem GPU er ekki enn studd, í flestum sýndarvélum, eða þegar grafíkreklinn hleðst ekki inn, slekkur Omarchy á hreyfimyndum, þoku og skuggum í þeirri lotu og lætur þig vita einu sinni með tilkynningu. _Appearance > Animations On_ kveikir á þeim aftur, og Omarchy man það líka fyrir síðari lotur.

Flestir þeirra eru bara fánaskrá undir `~/.local/state/omarchy/toggles/`. Ef þú vilt greina á einn í forskrift gefur `omarchy-toggle-enabled` þér útgöngukóða í stað þess að láta þig fara að leita:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Fánarnir eru nefndir eftir slökktu ástandinu — `screensaver-off`, `suspend-off`, `bar-off` — svo tilvist þeirra þýðir að eiginleikinn er óvirkur.

### Vísar í stikunni

Þegar hamur er virkur færðu lítið tákn í miðri efstu stikunni við hliðina á klukkunni. Það er vísaforritshlutinn, og hann geymir talinnslátt, skjáupptöku, áminningar í bið, náttljós, ekki trufla og halda vakandi.

Óvirkir vísar eru faldir. Þegar þú sveimar yfir stikuna einhvers staðar birtast þeir dofnaðir inn, svo þú getur smellt á einn til að kveikja á honum án þess að þekkja flýtilykilinn hans. Að smella á virkan einn slekkur á honum aftur. Ef þú vilt frekar sjá þá alla alltaf skaltu stilla `alwaysShow` á `true` á `omarchy.indicators` færslunni í `~/.config/omarchy/shell.json` — sjá [efstu stikuna](05-the-top-bar.md) um hvernig forritshlutar stikunnar eru stilltir.

### Náttljós

Náttljós hitar skjáinn í 4000K, og að víxla því aftur setur hann aftur í 6500K. Víxlaðu því úr víxlavalmyndinni (`Super + Ctrl + O`) eða með `omarchy toggle nightlight`. Það er knúið af hyprsunset, sem víxillinn ræsir fyrir þig ef það er ekki þegar í gangi.

Sjálfgefið gerir hyprsunset alls ekkert við skjáinn þinn. `~/.config/hypr/hyprsunset.conf` fylgir með auðkennissnið nákvæmlega til þess að skjárinn haldist ósnertur þar til þú biður um hlýju. Ef þú vilt frekar að það skipti eftir klukkunni skaltu skipta því út fyrir tímasnið:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ræstu síðan hyprsunset við innskráningu með því að bæta `o.launch_on_start("hyprsunset")` við `~/.config/hypr/autostart.lua`. 4000K/6500K parið sem víxillinn notar er fast, svo stillingaskráin er staðurinn þangað sem þú ferð ef þú vilt annan hita.

### Ekki trufla

`Super + Ctrl + Alt + ,` þaggar tilkynningar. Engar tilkynningar birtast á meðan það er virkt, og vísirinn með yfirstrikaða bjöllu situr í stikunni til að minna þig á af hverju skjáborðið er orðið hljótt.

Ekkert tapast þó. Þaggaðar tilkynningar eru haldnar til baka: settu síðustu nokkrar aftur á skjáinn með `Super + Shift + Alt + ,`. Sjá [tilkynningar](10-notices.md) fyrir restina.

Tvær tegundir skilaboða komast samt í gegn: staðfestingartilkynningar Omarchy sjálfs fyrir eitthvað sem þú varst að gera ("Theme changed", "Screenshot saved"), og mikilvægar viðvaranir sendar frá skipanalínunni. Spjallforrit sem merkja allt mikilvægt til að þvinga sig fram fyrir þig eiga það ekki skilið.

### Aðgerðaleysi

Omarchy-skelin á aðgerðaleysishegðunina, og tímarnir eru `idle` blokk á efsta stigi í `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Báðar tölurnar eru sekúndur taldar frá augnablikinu þegar þú varðst aðgerðalaus — ekki hver frá annarri. Svo með sjálfgefnum gildum kemur skjávarinn upp eftir tvær og hálfa mínútu og læsingarskjárinn tekur við eftir fimm mínútur, hvort sem skjávarinn keyrði eða ekki. Vistaðu skrána og skelin tekur upp nýju tímana strax.

Ef þú vísar skjávaranum frá áður en læsingarfresturinn rennur út telst það sem virkni og læsingin í bið er aflýst. Þú læsist ekki úti fyrir að kíkja á vélina þína.

Til að hætta alveg að læsa við aðgerðaleysi kveikir `Super + Ctrl + I` — eða `omarchy toggle idle` — á halda vakandi, og kaffibollavísirinn birtist í stikunni. Það er sá sem á að ýta á fyrir langa kynningu eða byggingu sem þú vilt fylgjast með. Ýttu á hann aftur til að fara aftur í eðlilegt ástand. `omarchy toggle idle status` prentar núverandi ástand sem JSON ef þú þarft það úr forskrift.

Þetta snýst um læsingu og skjávarann, ekki orku. Biðstaða og dvali hafa sína eigin uppsetningu í [kerfissvefni](36-system-sleep.md).

### Skjávarinn

Skjávarí Omarchy er ASCII-list sem keyrir í gegnum handahófskennd textaáhrif, eitt tilvik á hvern skjá. Sérhver lykill eða hreyfing músar fer út úr honum.

Þú getur ræst hann eftir þörfum úr _System > Screensaver_ (`Super + Esc`), sem þvingar hann upp jafnvel þó þú hafir slökkt á aðgerðaleysis-skjávaranum. Enginn flýtilykill er sjálfgefið bundinn við hann.

`omarchy toggle screensaver` er það sem slekkur á aðgerðaleysis-skjávaranum, ef þú vilt frekar fara beint úr vinnu í læst ástand. Sérhver lykill, smellur, skrun eða hreyfing músar lokar honum.

Merkið sem hann teiknar er þitt að breyta, undir _Appearance > Branding > Screensaver_. Hladdu upp png eða svg og Omarchy breytir því í ASCII. Sjá [vörumerki](41-branding.md).

### Læsingarskjárinn

`Super + Ctrl + L` læsir vélinni. Það keyrir læsingarskjáinn úr Omarchy-skelinni, slekkur á skjánum, endurstillir lyklaborðsuppsetninguna þína á þá fyrstu svo þú sért ekki að slá inn lykilorðið þitt í röngu stafrófi, og — ef þú ert með það í gangi — læsir 1Password á leiðinni út.

Læsingarskjárinn tekur lykilorð, og hann tekur líka fingrafar þegar þú hefur sett eitt upp. Það, og hinar leiðirnar til að auðkenna þig, er fjallað um í [auðkenningu með vélbúnaði](37-hardware-authentication.md).
