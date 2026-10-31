# Skjáir

Omarchy gerir ráð fyrir að þú sért að keyra á 2x-hæfum retina-flokks skjá sjálfgefið. Þetta er það sem þú þarft til að fá þessi fallegu, skarpu forritaraleturgerðir. Þetta er það sem næstum allar nýjar úrvals fartölvur með háupplausnarskjá eru besta fyrir. Þetta er það sem þú vilt keyra á 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eða 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

En ef þú ert ekki að keyra skjá með PPI 218 eða hærra, viltu breyta skjástillingunum. Til dæmis, ef þú ert með 27" eða 32" 4K, getur þú valið brotakvarða fyrir hann á skjáborðinu í efstu stikunni, eða stillt sjálfgefna gildið fyrir hvern skjá með því að opna `~/.config/hypr/monitors.lua` og skipta yfir í ráðlegginguna fyrir þá samsetningu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ef þú notar 1080p eða 1440p skjá, vilt þú líklega bara nota 1x kvörðun, og það sama fyrir GTK og X11 forrit, svo þú getur notað:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Breytingar á `GDK_SCALE` gilda fyrir forrit sem ræst eru eftir breytinguna (og GTK virðir aðeins heilar tölur, svo haltu því við næstu heiltölu af skjákvarðanum þínum). Svo vertu viss um að loka gluggunum sem þú ert með sem eru of stórir eftir breytinguna (eða loka öllum gluggum með `Ctrl + Alt + Del`!).

Þú getur líka fljótt stigið í gegnum helstu skjákvörðunarhlutföllin (1x, 1.25x, 1.6x, 2x, 3x, 4x) með því að nota `Super + /` til að fara hærra og `Super + Alt + /` til að fara lægra, eða valið eitt á skjáborðinu í efstu stikunni. Þetta breytir aðeins skjánum sem þú ert með fókus á, svo fartölvuskjár og ytri skjár geta hvor haft sinn kvarða. Borðið stillir líka upplausn hvers skjás. Val þitt er vistað fyrir þann tiltekna líkamlega skjá í `~/.local/state/omarchy/monitors/settings`, svo þau haldast eftir endurræsingu og fylgja skjánum í hvaða tengi eða bryggju hann er næst tengdur við. Þau ganga framar öllum reglum fyrir sama skjá í `~/.config/hypr/monitors.lua`, sem Omarchy breytir aldrei. Þar sem `GDK_SCALE` er eitt gildi fyrir alla skjái, er valinn kvarði stilltur út frá skjánum með lægsta kvarðann, svo X11 forrit koma út aðeins smá á þéttari skjánum frekar en of stór á hinum.

### Að gera texta stærri eða minni

Skjákvörðun breytir stærð alls. Ef allt sem þú vilt er stærri eða minni _texti_, þá er einn takki fyrir því:

```
omarchy display text size 14
```

Það tekur pixlastærð á milli 9 og 20, og færir Omarchy skelina, GTK forrit og skipanalínuna þína saman, svo allt skjáborðið haldist í hlutföllum. Keyrðu það án viðfangs til að sjá hvar þú ert, og `omarchy display text size reset` til að fara aftur í sjálfgefna stillingu. Foot er eina eftirlegukindin: það hefur enga leið til að endurhlaða stillingum sínum, svo keyrandi skipanalínur halda gömlu stærðinni þar til þú opnar nýja.

### Að útvíkka og spegla fartölvuskjái

Þegar þú tengir ytri skjá við fartölvuna þína er skjárinn sjálfkrafa útvíkkaður. En þú getur breytt því í speglun í staðinn með því að nota _Trigger > Hardware_ í Omarchy valmyndinni eða `Super + Ctrl + Alt + Delete`. Þetta er sérstaklega gagnlegt ef sá ytri skjár er skjávarpi, og þú vilt sýna eitthvað á meðan þú vinnur.

Þegar þú ert að útvíkka, að loka lokinu á fartölvunni slekkur sjálfkrafa á innbyggða skjánum. Að opna lokið kveikir á honum aftur. Þú getur líka stjórnað þessu handvirkt með því að nota _Trigger > Hardware_ í Omarchy valmyndinni eða `Super + Ctrl + Delete`.

### Að raða mörgum skjám

Hyprland virkar frábærlega með mörgum skjám. Skjáborðið í efstu stikunni teiknar þá þar sem þeir sitja: dragðu einn að hlið annars til að færa hann þangað, og fyrirkomulagið er vistað með öðrum stillingum hvers skjás. Fyrir allt sem borðið nær ekki yfir, lestu meira um hvernig á að raða þeim í [skjölum Hyprland um skjái](https://wiki.hypr.land/Configuring/Basics/Monitors/). Í Omarchy fara þessi í `~/.config/hypr/monitors.lua` sem `hl.monitor` færslur — skráin fylgir með dæmum í athugasemdum um að festa ákveðinn skjá við upplausn, staðsetningu og snúning.

Hver skjár hefur vinnusvæði 1 til 10 sín eigin, svo `Super + 1` þýðir alltaf fyrsta vinnusvæði skjásins sem þú ert á. Á bak við tjöldin númerar Hyprland samt vinnusvæði yfir alla skjái: fartölvuskjárinn þinn (eða fyrsti skjárinn) fær 1–10, næsti skjár 11–20, og svo framvegis, og hver skjár heldur blokkinni sinni í hvert skipti sem þú tengir hann inn. Notaðu þessar tölur ef þú skrifar [vinnusvæðareglur](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eða gluggareglur fyrir ákveðinn skjá, svo vinnusvæði 12 er annað vinnusvæði annars skjás þíns. `~/.local/state/omarchy/monitors/workspaces` listar hvaða blokk hver skjár hefur.

Örvatakkarnir virka yfir skjái sem deila brún í uppsetningunni þinni. Skjáir sem snertast aðeins á horni, eða sem hafa bil á milli sín, eru ekki nágrannar, svo notaðu `Ctrl + Alt + Tab` til að komast á milli þeirra.

| Flýtilykill | Yfir skjái |
| --- | --- |
| `Super + Arrow` | Færir fókus á skjáinn á þeirri hlið þegar enginn gluggi er eftir í þá átt |
| `Super + Shift + Arrow` | Skiptir við glugga á skjánum á þeirri hlið |
| `Super + Alt + Arrow` | Færir gluggann inn í hóp á skjánum á þeirri hlið |
| `Super + Shift + Ctrl + Arrow` | Færir gluggann á skjáinn á þeirri hlið, inn á vinnusvæðið sem hann er að sýna |
| `Super + Shift + Alt + Arrow` | Færir vinnusvæðið á skjáinn á þeirri hlið, og heldur númeri þess ef það er laust |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Færir fókus á næsta eða fyrri skjá, hver sem uppsetningin er |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Verða áfram á skjánum sem þú ert á |

Þú getur líka kíkt á [Hyprmon](https://github.com/erans/hyprmon/), ef þú vilt TUI til að hjálpa þér við staðsetningu margra skjáa.

### Að stjórna birtustigi

Birtustigi skjás er stjórnað með sérstöku aðgerðalyklunum fyrir birtustig upp/niður. Ef þú heldur inni shift á meðan þú ýtir á þessa, ferðu í hámarks- eða lágmarksbirtustig. Lyklarnir stjórna skjánum sem þú ert með fókus á, svo ytri skjáir sem tala DDC/CI eru stilltir á sama hátt og fartölvuskjárinn.

### Apple-skjáir

Ef þú notar Apple skjá munu venjulegir lyklaborðslyklar fyrir birtustig líka virka sjálfkrafa, ef þú ert með fókus á Apple skjánum. Þetta er gert í gegnum `asdcontrol` skipunina.

Athugaðu að ef þú notar Apple 6K XDR skjá, gætir þú séð draugaskjá í `hyprctl monitors` skránni þinni. Þú getur slökkt á þessu með einhverju eins og `hl.monitor({ output = "DP-2", disabled = true })` í `~/.config/hypr/monitors.lua`.

Á Intel vélum ættir þú að tengjast Apple skjám með venjulegri Thunderbolt snúru. Á öðrum vélum án Thunderbolt þarftu venjulega að nota [DP + USB-A -> USB-C snúru](https://www.amazon.com/dp/B0BNX7MS6N) til að láta það virka.
