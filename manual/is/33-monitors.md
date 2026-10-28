# Skjáir

Omarchy gerir sjálfgefið ráð fyrir að þú notir skjá í retina-flokki sem ræður við 2x. Þetta er það sem þú þarft til að fá þessi fallegu, skarpu forritaraletur. Þetta er það sem næstum allar nýjar úrvals fartölvur með háupplausnarskjám eru fínstilltar fyrir. Þetta er það sem þú vilt nota á 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eða 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

En ef þú ert ekki með skjá með PPI upp á 218 eða meira munt þú vilja breyta skjá stillingunum. Ef þú ert til dæmis með 27" eða 32" 4K getur þú notað brotaskölun með því að opna `~/.config/hypr/monitors.lua` (í gegnum _Setup > Monitors_ í Omarchy-valmyndinni) og skipta yfir í ráðlegginguna fyrir þá samsetningu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ef þú notar 1080p eða 1440p skjá viltu líklega bara nota 1x skölun, svo þú getur notað:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Breytingar á `GDK_SCALE` gilda fyrir forrit sem ræst eru eftir breytinguna (og GTK virðir aðeins heilar tölur, svo haltu því við næstu heiltölu skjá skölunarinnar þinnar). Svo vertu viss um að loka gluggunum sem þú ert með og eru of stórir eftir breytinguna (eða lokaðu öllum gluggum með `Ctrl + Alt + Del`!).

Þú getur líka farið hratt í gegnum helstu skölunarhlutföll skjáa (1x, 1.25x, 1.6x, 2x, 3x, 4x) með `Super + /` til að fara hærra og `Super + Alt + /` til að fara lægra, eða valið eitt úr skjáborðinu í efstu stikunni. Þetta breytir aðeins skjánum sem þú ert með fókus á, svo fartölvuskjár og ytri skjár geta hvor haft sína skölun. Valið er vistað í `~/.config/hypr/monitors.lua` sem `hl.monitor` regla fyrir þann skjá, svo það helst eftir endurræsingu og tekur forgang fram yfir `omarchy_monitor_scale`, sem áfram er skölunin fyrir hvern skjá sem hefur ekki eigin reglu. Þar sem `GDK_SCALE` er eitt gildi fyrir alla skjái setja þessar breytingar það út frá skjánum með lægstu skölunina, svo X11-forrit verða aðeins of lítil á þéttari skjánum frekar en of stór á hinum.

### Að gera texta stærri eða minni

Skjá skölun breytir stærð alls. Ef allt sem þú vilt er stærri eða minni _texti_ er einn hnappur fyrir það:

```
omarchy display text size 14
```

Það tekur pixlastærð á milli 9 og 20 og færir Omarchy-skelina, GTK-forrit og útstöðina þína saman, svo allt skjáborðið helst í réttum hlutföllum. Keyrðu það án viðfangs til að sjá hvar þú ert, og `omarchy display text size reset` til að fara aftur í sjálfgefið gildi. Foot er eini eftirbáturinn: það hefur enga leið til að endurhlaða stillingum sínum, svo útstöðvar sem þegar eru í gangi halda gömlu stærðinni þar til þú opnar nýja.

### Að útvíkka og spegla skjái fartölvu

Þegar þú tengir ytri skjá við fartölvuna þína er skjárinn sjálfkrafa útvíkkaður. En þú getur breytt því í speglun í staðinn með _Trigger > Hardware_ í Omarchy-valmyndinni eða `Super + Ctrl + Alt + Delete`. Þetta er sérstaklega gagnlegt ef sá ytri skjár er skjávarpi og þú vilt sýna eitthvað á meðan þú vinnur.

Þegar þú ert að útvíkka mun það að loka lokinu á fartölvunni sjálfkrafa slökkva á innri skjánum. Að opna lokið kveikir á honum aftur. Þú getur líka stjórnað þessu handvirkt með _Trigger > Hardware_ í Omarchy-valmyndinni eða `Super + Ctrl + Delete`.

### Að raða upp mörgum skjám

Hyprland virkar frábærlega með mörgum skjám. Lestu meira um hvernig á að raða þeim upp í [skjölum Hyprland um skjái](https://wiki.hypr.land/Configuring/Basics/Monitors/). Í Omarchy fara þetta í `~/.config/hypr/monitors.lua` sem `hl.monitor` færslur — skráin fylgir með dæmum í athugasemdum um að festa ákveðinn skjá við upplausn, staðsetningu og snúning.

Hver skjár hefur sín eigin vinnusvæði 1 til 10, svo `Super + 1` þýðir alltaf fyrsta vinnusvæði skjásins sem þú ert á. Á bak við tjöldin númerar Hyprland samt vinnusvæði á milli allra skjáa: fartölvuskjárinn þinn (eða fyrsti skjárinn) fær 1–10, næsti skjár 11–20, og svo framvegis, og hver skjár heldur sínum blokk í hvert skipti sem þú tengir hann. Notaðu þessar tölur ef þú skrifar [reglur um vinnusvæði](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eða gluggareglur fyrir ákveðinn skjá, svo vinnusvæði 12 er annað vinnusvæði annars skjásins þíns. `~/.local/state/omarchy/monitor-workspaces` listar hvaða blokk hver skjár hefur.

Örvalyklarnir virka á milli skjáa sem deila brún í uppsetningunni þinni. Skjáir sem snertast aðeins á horni, eða sem hafa bil á milli sín, eru ekki nágrannar, svo notaðu `Ctrl + Alt + Tab` til að komast á milli þeirra.

| Flýtilykill | Á milli skjáa |
| --- | --- |
| `Super + Arrow` | Færir fókus á skjáinn á þeirri hlið þegar enginn gluggi er lengur eftir í þá átt |
| `Super + Shift + Arrow` | Skiptir við glugga á skjánum á þeirri hlið |
| `Super + Alt + Arrow` | Færir gluggann inn í hóp á skjánum á þeirri hlið |
| `Super + Shift + Ctrl + Arrow` | Færir gluggann á skjáinn á þeirri hlið, inn á vinnusvæðið sem hann sýnir |
| `Super + Shift + Alt + Arrow` | Færir vinnusvæðið á skjáinn á þeirri hlið og heldur númerinu sínu ef það er laust |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Færir fókus á næsta eða fyrri skjá, hver sem uppsetningin er |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Halda sig á skjánum sem þú ert á |

Þú getur líka skoðað [Hyprmon](https://github.com/erans/hyprmon/), ef þú vilt TUI til að hjálpa þér við staðsetningu margra skjáa.

### Að stjórna birtustigi

Birtustigi skjás er stjórnað með sérstökum aðgerðalyk lum fyrir birtu upp/niður. Ef þú heldur niðri Shift á meðan þú ýtir á þessa ferðu í hámarks- eða lágmarksbirtu. Lyklarnir stjórna skjánum sem þú ert með fókus á, svo ytri skjáir sem tala DDC/CI eru stilltir á sama hátt og fartölvuskjárinn.

### Apple-skjáir

Ef þú notar Apple-skjá munu venjulegu birtulyklar lyklaborðsins líka virka sjálfkrafa, ef þú ert með fókus á Apple-skjánum. Þetta er gert með `asdcontrol` skipuninni.

Athugaðu að ef þú notar Apple 6K XDR skjá gætir þú séð draugaskjá í `hyprctl monitors` listanum þínum. Þú getur slökkt á þessu með einhverju á borð við `hl.monitor({ output = "DP-2", disabled = true })` í gegnum _Setup > Monitors_.

Á Intel-vélum ættir þú að tengjast Apple-skjám með venjulegri Thunderbolt-snúru. Á öðrum vélum án Thunderbolt þarftu yfirleitt að nota [DP + USB-A -> USB-C snúru](https://www.amazon.com/dp/B0BNX7MS6N) til að fá þetta til að virka.
