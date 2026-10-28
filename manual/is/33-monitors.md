# Skjáir

Omarchy gerir sjálfgefið ráð fyrir að þú sért með skjá í retina-flokki sem styður 2x. Það er það sem þú þarft til að fá þessi fallegu, skarpu forritaraletur. Það er það sem næstum allar nýjar úrvals fartölvur með háupplausnarskjám eru fínstilltar fyrir. Það er það sem þú myndir vilja keyra á 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eða 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

En ef þú ert ekki með skjá með PPI upp á 218 eða meira viltu breyta skjástillingunum. Til dæmis, ef þú ert með 27" eða 32" 4K, geturðu notað brotakvörðun með því að opna `~/.config/hypr/monitors.lua` (í gegnum _Setup > Monitors_ í Omarchy valmyndinni) og skipta yfir í ráðlegginguna fyrir þá samsetningu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ef þú notar 1080p eða 1440p skjá viltu líklega bara nota 1x kvörðun, svo þú getur notað:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Breytingar á `GDK_SCALE` gilda fyrir forrit sem eru ræst eftir breytinguna (og GTK virðir aðeins heilar tölur, svo haltu því við næstu heiltölu skjávörðunarinnar þinnar). Svo vertu viss um að loka gluggunum sem þú ert með og eru of stórir eftir breytinguna (eða lokaðu öllum gluggum með `Ctrl + Alt + Del`!).

Þú getur líka farið hratt í gegnum helstu kvörðunarhlutföll skjáa (1x, 1.25x, 1.6x, 2x, 3x, 4x) með `Super + /` til að fara hærra og `Super + Alt + /` til að fara lægra, eða valið eitt úr skjáborðinu í efstu stikunni. Þessar breyta aðeins skjánum sem þú ert með í fókus, svo fartölvuskjár og ytri skjár geta hvor haft sinn kvarða. Valið er vistað í `~/.config/hypr/monitors.lua` sem `hl.monitor` regla fyrir þann skjá, svo það helst eftir endurræsingu og hefur forgang fram yfir `omarchy_monitor_scale`, sem áfram er kvarðinn fyrir hvern skjá sem hefur ekki sína eigin reglu.

### Að gera texta stærri eða minni

Skjákvörðun breytir stærð alls. Ef allt sem þú vilt er stærri eða minni _texti_ er ein stilling fyrir það:

```
omarchy display text size 14
```

Það tekur pixlastærð á milli 9 og 20 og færir Omarchy skelina, GTK forrit og útstöðina þína saman, svo allt skjáborðið haldist í réttum hlutföllum. Keyrðu það án viðfangs til að sjá hvar þú ert, og `omarchy display text size reset` til að fara aftur í sjálfgefið. Foot er eini eftirlegukindin: það hefur enga leið til að endurhlaða stillingunum sínum, svo útstöðvar sem þegar eru í gangi halda gömlu stærðinni þar til þú opnar nýja.

### Að útvíkka og spegla fartölvuskjái

Þegar þú tengir ytri skjá við fartölvuna þína er skjáborðið sjálfkrafa útvíkkað. En þú getur breytt því í speglun í staðinn með _Trigger > Hardware_ í Omarchy valmyndinni eða `Super + Ctrl + Alt + Delete`. Þetta er sérstaklega gagnlegt ef sá ytri skjár er skjávarpi og þú vilt sýna eitthvað á meðan þú vinnur.

Þegar þú ert að útvíkka mun það að loka lokinu á fartölvunni sjálfkrafa slökkva á innbyggða skjánum. Að opna lokið mun kveikja á honum aftur. Þú getur líka stjórnað þessu handvirkt með _Trigger > Hardware_ í Omarchy valmyndinni eða `Super + Ctrl + Delete`.

### Að raða mörgum skjám

Hyprland virkar frábærlega með mörgum skjám. Lestu meira um hvernig á að raða þeim upp í [skjölun Hyprland um skjái](https://wiki.hypr.land/Configuring/Basics/Monitors/). Í Omarchy fara þessi í `~/.config/hypr/monitors.lua` sem `hl.monitor` færslur — skráin kemur með dæmum í athugasemdum til að festa ákveðinn skjá við upplausn, staðsetningu og snúning.

Hver skjár hefur sín eigin vinnusvæði 1 til 10, svo `Super + 1` þýðir alltaf fyrsta vinnusvæði skjásins sem þú ert á. Á bak við tjöldin númerar Hyprland samt vinnusvæði þvert á alla skjái: fartölvuskjárinn þinn (eða fyrsti skjárinn) fær 1–10, næsti skjár 11–20, og svo framvegis, og hver skjár heldur sínum blokk í hvert skipti sem þú tengir hann. Notaðu þær tölur ef þú skrifar [reglur fyrir vinnusvæði](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eða gluggareglur fyrir ákveðinn skjá, svo vinnusvæði 12 er annað vinnusvæði annars skjásins þíns. `~/.local/state/omarchy/monitor-workspaces` sýnir hvaða blokk hver skjár hefur.

Örvatakkarnir virka þvert á skjái sem deila brún í uppsetningunni þinni. Skjáir sem snertast aðeins á horni, eða sem hafa bil á milli sín, eru ekki nágrannar, svo notaðu `Ctrl + Alt + Tab` til að komast á milli þeirra.

| Flýtilykill | Þvert á skjái |
| --- | --- |
| `Super + Arrow` | Færir fókus á skjáinn þeim megin þegar enginn gluggi er eftir í þá átt |
| `Super + Shift + Arrow` | Skiptir við glugga á skjánum þeim megin |
| `Super + Alt + Arrow` | Færir gluggann í hóp á skjánum þeim megin |
| `Super + Shift + Ctrl + Arrow` | Færir gluggann á skjáinn þeim megin, inn á vinnusvæðið sem hann sýnir |
| `Super + Shift + Alt + Arrow` | Færir vinnusvæðið á skjáinn þeim megin og heldur númerinu sínu ef það er laust |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Færir fókus á næsta eða fyrri skjá, óháð uppsetningu |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Halda sig á skjánum sem þú ert á |

Þú getur líka skoðað [Hyprmon](https://github.com/erans/hyprmon/), ef þú vilt TUI til að hjálpa þér við staðsetningu margra skjáa.

### Að stjórna birtustigi

Birtustigi skjás er stjórnað með sérstökum aðgerðatökkum fyrir birtu upp/niður. Ef þú heldur Shift niðri á meðan þú ýtir á þá ferðu í hámarks- eða lágmarksbirtu. Takkarnir stjórna skjánum sem þú ert með í fókus, svo ytri skjáir sem tala DDC/CI eru stilltir á sama hátt og fartölvuskjárinn.

### Apple skjáir

Ef þú notar Apple skjá munu venjulegu birtutakkar lyklaborðsins líka virka sjálfkrafa ef þú ert með fókus á Apple skjánum. Þetta er gert í gegnum `asdcontrol` skipunina.

Athugaðu að ef þú notar Apple 6K XDR skjá gætirðu séð draugaskjá í `hyprctl monitors` listanum þínum. Þú getur slökkt á þessu með einhverju á borð við `hl.monitor({ output = "DP-2", disabled = true })` í gegnum _Setup > Monitors_.

Á Intel vélum ættirðu að tengjast Apple skjáum með venjulegri Thunderbolt snúru. Á öðrum vélum án Thunderbolt þarftu yfirleitt að nota [DP + USB-A -> USB-C snúru](https://www.amazon.com/dp/B0BNX7MS6N) til að láta það virka.
