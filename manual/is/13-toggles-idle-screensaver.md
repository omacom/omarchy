# Víxlar, aðgerðaleysi og skjáverjinn

Mikið af því sem þú breytir frá degi til dags er í alvöru ekki stilling. Það er hamur sem þú kveikir á í klukkutíma og slekkur á aftur: næturljós á meðan þú vinnur seint, ekki trufla á meðan þú kynnir, halda vakandi á meðan þú horfir á eitthvað. Omarchy kallar þá víxla, og þeir virka allir eins — flýtilykill, valmyndarfærsla og skipun, öll að hitta sama rofann.

### Víxlvalmyndin

`Super + Ctrl + O` opnar _Kveikja > Víxla_ beint, eða þú getur gengið þangað úr Omarchy-valmyndinni (`Super + Space`). Allt á þeim lista er rofi sem þú getur slegið án þess að hugsa um hvar ástandið býr. Rofar fyrir útlit skjáborðsins sitja við hliðina á því, undir _Kveikja > Útlit_.

Úr terminal eru sömu rofar `omarchy toggle <thing>`. Keyrðu `omarchy toggle` eitt og sér til að sjá allan hópinn.

| Víxill | Flýtilykill | Skipun |
| ------ | ------ | ------- |
| Næturljós | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Þagga tilkynningar | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Halda vakandi (engin læsing við aðgerðaleysi) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Hrungrip | — | `omarchy toggle crash-capture` |
| Skjáverji | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) þemasamstilling | — | `omarchy toggle theme sync` |
| Valmyndastika | `Super + Shift + Space` | `omarchy toggle bar` |
| Snertiflötur | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Snertiskjár | — | `omarchy toggle touchscreen` |
| Svefn | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Rofarnir fyrir snertiflöt, snertiskjá og hybrid GPU búa undir _Kveikja > Vélbúnaður_ (`Super + Ctrl + H`) frekar en undir Víxla, þar sem þeir birtast aðeins þegar þú hefur þann vélbúnað í alvöru. Rofarnir fyrir snertiflöt og snertiskjá lifa endurhleðslu Hyprland — nafn óvirka tækisins er vistað í litla stöðuskrá sem Hyprland les við ræsingu til að slökkva á því aftur.

_Kveikja > Útlit_ geymir valmyndastikuna og hreyfingarnar, auk nokkurra hluta sem eru ekki `omarchy toggle`-skipanir en haga sér eins: rafhlöðuhlutfall í stikunni, sjálfgefið vinnusvæðaskipulag, gluggabil (`Super + Shift + Backspace`) og ferkantað hlutfall eins glugga (`Super + Ctrl + Backspace`).

Flestir af þessum eru bara fánaskrá undir `~/.local/state/omarchy/toggles/`. Ef þú vilt greina á einum í forskrift gefur `omarchy-toggle-enabled` þér útgangskóða í stað þess að láta þig fara að leita:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Fánarnir eru nefndir fyrir slökkt ástand — `screensaver-off`, `suspend-off`, `bar-off` — svo tilvist þeirra þýðir að eiginleikinn er óvirkur.

### Vísar í stikunni

Þegar hamur er á færðu lítið tákn í miðju valmyndastikunnar við hlið klukkunnar. Það er vísagræjan, og hún ber upplesningu, skjáupptöku, áminningar í bið, næturljós, ekki trufla og halda vakandi.

Óvirkir vísar eru huldir. Sveimðu yfir svæðið í kringum þá og þeir dofna inn daufir, svo þú getur smellt á einn til að kveikja á honum án þess að vita flýtilykilinn hans. Að smella á virkan slekkur á honum aftur. Ef þú vilt frekar sjá þá alla alltaf skaltu stilla `alwaysShow` á `true` á `omarchy.indicators`-færslunni í `~/.config/omarchy/shell.json` — sjá [valmyndastikuna](05-the-top-bar.md) um hvernig stikugræjur eru stilltar.

### Næturljós

`Super + Ctrl + N` hitar skjáinn í 4000K, og að ýta á það aftur setur hann aftur í 6500K. Það er knúið af hyprsunset, sem víxillinn ræsir fyrir þig ef það er ekki þegar í gangi.

Sjálfgefið gerir hyprsunset alls ekkert við skjáinn þinn. `~/.config/hypr/hyprsunset.conf` kemur með auðkennisniði einmitt til að skjárinn haldist ósnertur þar til þú biður um hlýju. Ef þú vilt frekar að það skipti eftir klukkunni skaltu skipta því út fyrir tímasnið:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ræstu síðan hyprsunset við innskráningu með því að bæta `o.launch_on_start("hyprsunset")` við `~/.config/hypr/autostart.lua`. 4000K/6500K parið sem víxillinn notar er fast, svo stillingarskráin er staðurinn ef þú vilt annað hitastig.

### Ekki trufla

`Super + Ctrl + ,` þaggar tilkynningar. Engir sprettigluggar birtast á meðan það er á, og útkrossaða bjölluvísirinn situr í stikunni til að minna þig á af hverju skjáborðið er orðið hljótt.

Ekkert tapast þó. Þögguð tilkynning er skrifuð beint í tilkynningasöguna þína, sem er nákvæmlega sú skrá sem þú vilt þegar þú kemur til baka og veltir fyrir þér hvað þú misstir af. Opnaðu hana með `Super + Shift + Alt + ,`. Sjá [tilkynningar](10-notices.md) fyrir restina af tilkynningasögunni.

Tvær gerðir skilaboða komast samt í gegn: eigin staðfestingarsprettigluggar Omarchy fyrir eitthvað sem þú varst að gera („Þema breytt“, „Skjámynd vistuð“) og mikilvægar viðvaranir sendar frá skipanalínunni. Spjallforrit sem merkja allt sem mikilvægt til að þvinga sig fram fyrir þig eiga ekki rétt á því.

### Aðgerðaleysi

Omarchy-skelin á hegðun við aðgerðaleysi, og tímarnir eru `idle`-blokk á efsta stigi í `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Báðar tölurnar eru sekúndur taldar frá því augnabliki sem þú varðst óvirkur — ekki frá hvorri annarri. Svo með sjálfgefnunum kemur skjáverjinn eftir tvær og hálfa mínútu og læsingarskjárinn tekur yfir eftir fimm mínútur, hvort sem skjáverjinn keyrði eða ekki. Vistaðu skrána og skelin tekur upp nýju tímana strax.

Ef þú hafnar skjáverjanum fyrir læsingarfrestinn telst það sem virkni og læsingin í bið er aflýst. Þú verður ekki læstur úti fyrir að líta á vélina þína.

Til að hætta að læsa við aðgerðaleysi alveg slær `Super + Ctrl + I` — eða `omarchy toggle idle` — halda vakandi á, og kaffibollavísirinn birtist í stikunni. Það er sá sem á að ýta á fyrir langa kynningu eða byggingu sem þú vilt fylgjast með. Ýttu á hann aftur til að fara aftur í eðlilegt horf. `omarchy toggle idle status` prentar núverandi ástand sem JSON ef þú þarft það úr forskrift.

Þetta snýst um læsingu og skjáverjann, ekki orku. Svefn og dvala hafa sína eigin uppsetningu í [kerfissvefni](36-system-sleep.md).

### Skjáverjinn

Skjáverji Omarchy er ASCII-list sem keyrir í gegnum handahófskennd textaáhrif, eitt tilvik á hvern skjá. Sérhver lykill eða músarhreyfing fer út úr honum.

Þú getur ræst hann eftir þörfum úr _Kerfi > Skjáverji_ (`Super + Esc`), sem þvingar hann upp jafnvel þó þú hafir slökkt á aðgerðaleysis-skjáverjanum. Enginn flýtilykill er tengdur við hann sjálfgefið.

`omarchy toggle screensaver` er það sem slekkur á aðgerðaleysis-einingunni, ef þú vilt frekar fara beint úr vinnu í læst. Hann þarf terminal sem hann kann að stilla — Alacritty, Foot, Ghostty eða Kitty — og lætur þig vita ef sjálfgefinn terminalinn þinn er eitthvað annað.

Merkið sem hann teiknar er þitt að breyta, undir _Stíll > Skjáverji_. Hladdu upp png eða svg og Omarchy breytir því í ASCII. Sjá [vörumerki](41-branding.md).

### Læsingarskjárinn

`Super + Ctrl + L` læsir vélinni. Það keyrir læsingarskjáinn úr Omarchy-skelinni, slekkur á skjánum, endurstillir lyklaborðsskipanina á þá fyrstu svo þú sért ekki að slá inn lykilorðið þitt á röngu stafrófi, og — ef þú hefur það í gangi — læsir 1Password á leiðinni út.

Læsingarskjárinn tekur lykilorð, og hann tekur líka fingrafar þegar þú hefur sett það upp. Það, og hinar leiðirnar til að auðkenna, eru teknar fyrir í [vélbúnaðsauðkenningu](37-hardware-authentication.md).
