# Skiptirofar, aðgerðaleysi og skjásvarinn

Margt af því sem þú breytir frá degi til dags er eiginlega ekki stilling. Það er hamur sem þú kveikir á í klukkutíma og slekkur svo á aftur: næturljós á meðan þú vinnur seint, trufluð ekki á meðan þú ert með kynningu, haltu þér vakandi á meðan þú horfir á eitthvað. Omarchy kallar þetta skiptirofa, og þeir virka allir á sama hátt — flýtilykill, valmyndarfærsla og skipun, sem öll lenda á sama rofanum.

### Skiptirofavalmyndin

`Super + Ctrl + O` opnar _Trigger > Toggle_ beint, eða þú getur gengið þangað úr Omarchy valmyndinni (`Super + Space`). Allt á þeim lista er rofi sem þú getur slegið um án þess að hugsa um hvar ástandið býr. Rofar fyrir það hvernig skjáborðið lítur út sitja við hliðina á honum, undir _Appearance_.

Frá skipanalínunni eru sömu rofarnir `omarchy toggle <thing>`. Keyrðu `omarchy toggle` út af fyrir sig til að sjá allan hópinn.

| Skiptirofi | Flýtilykill | Skipun |
| ------ | ------ | ------- |
| Næturljós | — | `omarchy toggle nightlight` |
| Þagga niður tilkynningar | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Haltu þér vakandi (engin læsing við aðgerðaleysi) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Hrunskráning | — | `omarchy toggle crash-capture` |
| Skjásvari | — | `omarchy toggle screensaver` |
| Samstilling þema [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Valmyndastika | `Super + Shift + Space` | `omarchy toggle bar` |
| Snertiplatti | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Snertiskjár | — | `omarchy device touchscreen` |
| Svæfing | — | `omarchy toggle suspend` |
| Blönduð GPU | — | `omarchy toggle hybrid gpu` |

Rofarnir fyrir snertiplatta, snertiskjá og blandaða GPU búa undir _Trigger > Hardware_ (`Super + Ctrl + H`) frekar en undir Toggle, þar sem þeir birtast aðeins þegar þú ert raunverulega með þann vélbúnað. Rofarnir fyrir snertiplatta og snertiskjá lifa endurræsingu Hyprland af — nafn slökktu tækisins er vistað í litla ástandsskrá sem Hyprland les við ræsingu til að slökkva á því aftur.

_Appearance_ geymir stikuna og hreyfimyndirnar, auk nokkurra hluta sem eru ekki `omarchy toggle` skipanir en hegða sér eins: rafhlöðuprósentu á stikunni, sjálfgefið skipulag vinnusvæða, og undir _Windows_, bil á milli glugga (`Super + Shift + Backspace`) og ferningshlutfallið fyrir 1 glugga (`Super + Ctrl + Backspace`).

Þegar Hyprland hefur enga GPU til að teikna með og teiknar þess í stað á CPU (llvmpipe), eins og á Mac tölvum þar sem GPU er ekki studd ennþá, í flestum sýndarvélum, eða þegar ekki tekst að hlaða inn grafíkreklum, slekkur Omarchy á hreyfimyndum, þoku og skuggum fyrir þá setu og lætur þig vita af því einu sinni með tilkynningu. _Appearance > Animations On_ kveikir á þeim aftur, og Omarchy man það líka fyrir síðari setur.

Flestir þessara eru bara fánaskrá undir `~/.local/state/omarchy/toggles/`. Ef þú vilt greina á einum í forskrift, þá gefur `omarchy-toggle-enabled` þér lokakóða í stað þess að láta þig fara að leita:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Fánarnir eru nefndir eftir slökktu ástandinu — `screensaver-off`, `suspend-off`, `bar-off` — svo það að þeir séu til staðar þýðir að eiginleikinn er óvirkur.

### Vísar á stikunni

Þegar hamur er virkur færðu lítið tákn í miðju efri stikunnar við hliðina á klukkunni. Það er vísagræjan, og hún ber upptöku innlesturs, skjáupptöku, væntanlegar áminningar, næturljós, trufluð ekki, og haltu þér vakandi.

Óvirkir vísar eru faldir. Sveimaðu hvar sem er yfir stikunni og þeir birtast daufir, svo þú getur smellt á einn til að kveikja á honum án þess að þekkja flýtilykilinn hans. Að smella á virkan einn slekkur á honum aftur. Ef þú vilt frekar sjá þá alla alltaf, stilltu `alwaysShow` á `true` á `omarchy.indicators` færslunni í `~/.config/omarchy/shell.json` — sjá [efri stikuna](05-the-top-bar.md) um hvernig græjur á stikunni eru stilltar.

### Næturljós

Næturljós hitar skjáinn upp í 4000K, og að slá því um aftur færir hann aftur í 6500K. Sláðu því um úr skiptirofavalmyndinni (`Super + Ctrl + O`) eða með `omarchy toggle nightlight`. Það er knúið áfram af hyprsunset, sem skiptirofinn ræsir fyrir þig ef það er ekki þegar í gangi.

Sjálfgefið gerir hyprsunset nákvæmlega ekkert við skjáinn þinn. `~/.config/hypr/hyprsunset.conf` kemur með auðkennisprófil einmitt til þess að skjárinn haldist ósnertur þar til þú biður um hlýju. Ef þú vilt frekar að það skipti eftir klukkunni, skiptu því þá út fyrir tímaprófíl:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ræstu svo hyprsunset við innskráningu með því að bæta `o.launch_on_start("hyprsunset")` við `~/.config/hypr/autostart.lua`. 4000K/6500K parið sem skiptirofinn notar er fast, svo stillingaskráin er staðurinn þangað sem þú ferð ef þú vilt annað hitastig.

### Trufluð ekki

`Super + Ctrl + Alt + ,` þaggar niður tilkynningar. Engir sprettigluggar birtast á meðan það er virkt, og vísirinn með yfirstrikuðu bjöllunni situr á stikunni til að minna þig á af hverju skjáborðið er orðið svona hljóðlátt.

Ekkert tapast þó. Þögguðum tilkynningum er haldið eftir: settu síðustu fáu aftur á skjáinn með `Super + Shift + Alt + ,`. Sjá [tilkynningar](10-notices.md) fyrir restina.

Tvenns konar skilaboð komast samt í gegn: eigin staðfestingarsprettigluggar Omarchy fyrir eitthvað sem þú varst að gera ("Theme changed", "Screenshot saved"), og alvarlegar viðvaranir sendar frá skipanalínunni. Spjallforrit sem merkja allt alvarlegt til að þvinga sig fram fyrir þig eiga ekki heima þar.

### Aðgerðaleysi

Omarchy skelin á hegðun við aðgerðaleysi, og tímasetningarnar eru `idle` blokk á efsta stigi í `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Báðar tölurnar eru sekúndur taldar frá því augnabliki sem þú varðst aðgerðalaus — ekki hver frá annarri. Svo með sjálfgefnu stillingunum kemur skjásvarinn upp eftir tvær og hálfa mínútu og læsingarskjárinn tekur við eftir fimm mínútur, hvort sem skjásvarinn keyrði eða ekki. Vistaðu skrána og skelin tekur upp nýju tímasetningarnar strax.

Ef þú vísar skjásvaranum frá áður en læsingarfresturinn rennur út, þá telst það sem virkni og væntanlegu læsingunni er aflýst. Þú læsist ekki úti fyrir að kíkja á vélina þína.

Til að hætta alveg við læsingu við aðgerðaleysi, þá slær `Super + Ctrl + I` — eða `omarchy toggle idle` — haltu þér vakandi á, og kaffibollavísirinn birtist á stikunni. Það er sá sem þú átt að slá á fyrir langa kynningu eða byggingu sem þú vilt fylgjast með. Sláðu á hann aftur til að fara aftur í eðlilegt horf. `omarchy toggle idle status` prentar núverandi ástand sem JSON ef þú þarft það úr forskrift.

Þetta snýst um læsingu og skjásvarann, ekki rafmagn. Svæfing og dvali hafa sína eigin uppsetningu í [kerfissvefni](36-system-sleep.md).

### Skjásvarinn

Skjásvari Omarchy er ASCII list sem keyrir í gegnum handahófskennd textaáhrif, eitt eintak á hvern skjá. Hvaða lykill sem er eða hreyfing með músinni hættir honum.

Þú getur ræst hann eftir þörfum úr _System > Screensaver_ (`Super + Esc`), sem þvingar hann upp jafnvel þó þú hafir slökkt á skjásvaranum við aðgerðaleysi. Sjálfgefið er enginn flýtilykill bundinn við hann.

`omarchy toggle screensaver` er það sem slekkur á honum við aðgerðaleysi, ef þú vilt frekar fara beint úr vinnu í læst ástand. Hvaða lykill, smellur, skrun eða hreyfing með músinni sem er lokar honum.

Merkið sem hann teiknar er þitt að breyta, undir _Appearance > Branding > Screensaver_. Halaðu upp png eða svg og Omarchy breytir því í ASCII. Sjá [auðkenningu](41-branding.md).

### Læsingarskjárinn

`Super + Ctrl + L` læsir vélinni. Það keyrir læsingarskjáinn úr Omarchy skelinni, slekkur á skjánum, endurstillir lyklaborðsskipulagið þitt á það fyrsta svo þú sért ekki að slá lykilorðið þitt inn í röngu stafrófi, og — ef þú ert með það í gangi — læsir 1Password á leiðinni út.

Læsingarskjárinn tekur við lykilorði, og hann mun líka taka við fingrafari þegar þú hefur sett eitt upp. Það, og hinar leiðirnar til að auðkenna þig, er fjallað um í [auðkenningu með vélbúnaði](37-hardware-authentication.md).
