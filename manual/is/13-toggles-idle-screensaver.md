# Rofar, aðgerðaleysi og skjáhvílan

Mikið af því sem þú breytir frá degi til dags er í rauninni ekki stilling. Það er hamur sem þú kveikir á í klukkustund og slekkur á aftur: næturljós á meðan þú vinnur seint, truflaðu ekki á meðan þú heldur kynningu, halda vöku á meðan þú horfir á eitthvað. Omarchy kallar þá rofa og þeir virka allir á sama hátt — flýtilykill, valmyndaratriði og skipun, allt smellir á sama rofann.

### Rofavalmyndin

`Super + Ctrl + O` opnar _Trigger > Toggle_ beint, eða þú getur farið þangað úr Omarchy-valmyndinni (`Super + Space`). Allt á þeim lista er rofi sem þú getur flett án þess að hugsa um hvar staðan býr. Rofar fyrir útlit skjáborðsins sitja við hliðina á því, undir _Appearance_.

Úr skipanalínunni eru sömu rofar `omarchy toggle <thing>`. Keyrðu `omarchy toggle` út af fyrir sig til að sjá allan hópinn.

| Rofi | Flýtilykill | Skipun |
| ------ | ------ | ------- |
| Næturljós | — | `omarchy toggle nightlight` |
| Þagga tilkynningar | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Halda vöku (engin læsing við aðgerðaleysi) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Hrunupptaka | — | `omarchy toggle crash-capture` |
| Skjáhvíla | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) þemasamstilling | — | `omarchy toggle theme sync` |
| Valmyndarslá | `Super + Shift + Space` | `omarchy toggle bar` |
| Snertiflötur | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Snertiskjár | — | `omarchy toggle touchscreen` |
| Svefn | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Rofarnir fyrir snertiflöt, snertiskjá og Hybrid GPU búa undir _Trigger > Hardware_ (`Super + Ctrl + H`) frekar en undir Toggle, enda birtast þeir aðeins þegar þú ert raunverulega með þann vélbúnað. Rofarnir fyrir snertiflöt og snertiskjá lifa af endurhleðslu Hyprland — nafn óvirka tækisins er vistað í litla stöðuskrá sem Hyprland les við ræsingu til að gera það óvirkt aftur.

_Appearance_ geymir valmyndarslána og hreyfingar, auk nokkurra hluta sem eru ekki `omarchy toggle`-skipanir en hegða sér á sama hátt: prósenta rafhlöðu í slánni, sjálfgefið skipulag vinnusvæðis og, undir _Windows_, bil milli glugga (`Super + Shift + Backspace`) og ferningslaga hlutfall fyrir 1 glugga (`Super + Ctrl + Backspace`).

Flestir þessara eru bara merkjaskrá undir `~/.local/state/omarchy/toggles/`. Ef þú vilt greina á einn í forskrift gefur `omarchy-toggle-enabled` þér útgöngukóða í stað þess að láta þig fara að leita:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Fánarnir eru nefndir fyrir slökktu stöðuna — `screensaver-off`, `suspend-off`, `bar-off` — svo nærvera þeirra þýðir að eiginleikinn er óvirkur.

### Vísar í slánni

Þegar hamur er virkur færðu lítið tákn í miðri efstu slánni við hliðina á klukkunni. Það er vísahlutinn og hann geymir raddinnslátt, skjáupptöku, áminningar í bið, næturljós, truflaðu ekki og halda vöku.

Óvirkir vísar eru faldir. Færðu bendilinn yfir slána hvar sem er og þeir birtast daufir, svo þú getir smellt á einn til að kveikja á honum án þess að þekkja flýtilykilinn hans. Að smella á virkan vís slær aftur af honum. Ef þú vilt frekar sjá þá alla alltaf skaltu stilla `alwaysShow` á `true` á `omarchy.indicators`-færsluna í `~/.config/omarchy/shell.json` — sjá [efstu slána](05-the-top-bar.md) um hvernig íhlutir slárinnar eru stilltir.

### Næturljós

Næturljós hitar skjáinn í 4000K og að fletta því aftur setur hann aftur í 6500K. Flettu því úr rofavalmyndinni (`Super + Ctrl + O`) eða með `omarchy toggle nightlight`. Það er knúið af hyprsunset, sem rofinn ræsir fyrir þig ef það er ekki þegar í gangi.

Sjálfgefið gerir hyprsunset ekki neitt við skjáinn þinn. `~/.config/hypr/hyprsunset.conf` kemur með „identity“-snið einmitt svo skjárinn haldist ósnertur þar til þú biður um hlýju. Ef þú vilt frekar að það skipti eftir klukkunni skaltu skipta því út fyrir tímasnið:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ræstu síðan hyprsunset við innskráningu með því að bæta `o.launch_on_start("hyprsunset")` við `~/.config/hypr/autostart.lua`. 4000K/6500K parið sem rofinn notar er fast, svo stillingarskráin er staðurinn þangað sem þú ferð ef þú vilt annað hitastig.

### Truflaðu ekki

`Super + Ctrl + Alt + ,` þaggar tilkynningar. Engar tilkynningar spretta upp á meðan það er á og yfirstrikaða bjöllutáknið situr í slánni til að minna þig á af hverju skjáborðið er orðið hljótt.

Ekkert glatast þó. Þögguðum tilkynningum er haldið aftur: settu síðustu nokkrar aftur á skjáinn með `Super + Shift + Alt + ,`. Sjá [tilkynningar](10-notices.md) fyrir restina.

Tvær tegundir skilaboða komast samt í gegn: eigin staðfestingartilkynningar Omarchy fyrir eitthvað sem þú gerðir rétt í þessu ("Theme changed", "Screenshot saved") og mikilvægar viðvaranir sendar frá skipanalínunni. Spjallforrit sem merkja allt sem mikilvægt til að þvinga sig fram fyrir þig teljast ekki til þeirra.

### Aðgerðaleysi

Omarchy-skelin á aðgerðaleysishegðunina og tímarnir eru `idle`-blokk á efsta stigi í `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Báðar tölurnar eru sekúndur taldar frá augnablikinu þegar þú varðst aðgerðalaus — ekki hver frá annarri. Svo með sjálfgefnu gildunum kemur skjáhvílan upp eftir tvær og hálfa mínútu og læsiskjárinn tekur við eftir fimm mínútur, hvort sem skjáhvílan keyrði eða ekki. Vistaðu skrána og skelin tekur upp nýju tímana strax.

Ef þú vísar skjáhvílunni frá áður en læsingarfresturinn rennur út telst það sem virkni og læsingin í bið er aflýst. Þú verður ekki læstur úti fyrir að kíkja á vélina þína.

Til að hætta alveg að læsa við aðgerðaleysi flettir `Super + Ctrl + I` — eða `omarchy toggle idle` — halda vöku á og kaffibollatáknið birtist í slánni. Það er sá sem á að ýta á fyrir langa kynningu eða byggingu sem þú vilt fylgjast með. Ýttu á hann aftur til að fara aftur í eðlilegt ástand. `omarchy toggle idle status` prentar núverandi stöðu sem JSON ef þú þarft hana úr forskrift.

Þetta snýst um læsingu og skjáhvíluna, ekki afl. Svefn og dvali hafa sína eigin uppsetningu í [kerfissvefn](36-system-sleep.md).

### Skjáhvílan

Skjáhvíla Omarchy er ASCII-list sem keyrir í gegnum handahófskennd textaáhrif, eitt tilvik á hvern skjá. Hvaða lykill eða músarhreyfing sem er fer úr henni.

Þú getur ræst hana eftir þörfum úr _System > Screensaver_ (`Super + Esc`), sem þvingar hana upp jafnvel þótt þú hafir slökkt á skjáhvílu við aðgerðaleysi. Enginn flýtilykill er sjálfgefið bundinn við hana.

`omarchy toggle screensaver` er það sem slekkur á þeirri sem fer í gang við aðgerðaleysi, ef þú vilt frekar fara beint úr vinnu í læst ástand. Hvaða lykill, smellur, skrun eða músarhreyfing sem er lokar henni.

Merkið sem hún teiknar er þitt að breyta, undir _Appearance > Branding > Screensaver_. Hlæddu upp png eða svg og Omarchy breytir því í ASCII. Sjá [vörumerking](41-branding.md).

### Læsiskjárinn

`Super + Ctrl + L` læsir vélinni. Það keyrir læsiskjáinn úr Omarchy-skelinni, gerir skjáinn auðan, endurstillir lyklaborðsuppsetninguna þína á þá fyrstu svo þú sért ekki að slá inn lykilorðið þitt í röngu stafrófi og — ef þú ert með það í gangi — læsir 1Password á leiðinni út.

Læsiskjárinn tekur við lykilorði og hann tekur líka við fingrafari þegar þú hefur sett eitt upp. Það, og hinar leiðirnar til að auðkenna þig, er fjallað um í [auðkenningu með vélbúnaði](37-hardware-authentication.md).
