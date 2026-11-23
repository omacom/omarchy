# Skjáir

Omarchy gerir sjálfgefið ráð fyrir að þú sért að nota skjá í retina-flokki með 2x-getu. Það er það sem þú þarft til að fá þessi fallegu, skörpu forritaraletur. Það er það sem næstum allar nýjar úrvals fartölvur með háupplausnarskjám eru fínstilltar fyrir. Það er það sem þú myndir vilja keyra á 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eða 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

En ef þú ert ekki að nota skjá með PPI 218 eða hærra muntu vilja breyta stillingum skjásins. Ef þú ert til dæmis með 27" eða 32" 4K geturðu valið brotakvarða fyrir hann á skjáborðinu í efstu stikunni, eða stillt sjálfgefna gildið fyrir hvern skjá með því að opna `~/.config/hypr/monitors.lua` og skipta yfir í ráðlegginguna fyrir þá samsetningu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ef þú ert að nota 1080p eða 1440p skjá munt þú líklega bara vilja nota 1x-kvarða, og það sama fyrir GTK og X11 forrit, svo þú getur notað:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Breytingar á `GDK_SCALE` gilda um forrit sem ræst eru eftir breytinguna (og GTK virðir aðeins heilar tölur, svo haltu því við næstu heilu tölu skjástærðarhlutfallsins). Svo vertu viss um að loka gluggunum sem þú ert með og eru of stórir eftir breytinguna (eða lokaðu öllum gluggum með `Ctrl + Alt + Del`!).

Þú getur líka fljótt skrefað í gegnum helstu skjástærðarhlutföllin (1x, 1.25x, 1.6x, 2x, 3x, 4x) með `Super + /` til að fara hærra og `Super + Alt + /` til að fara lægra, eða valið eitt á skjáborðinu í efstu stikunni. Þetta breytir aðeins skjánum sem þú ert með í fókus, svo skjár fartölvu og ytri skjár geta hvor haft sitt eigið hlutfall. Borðið stillir líka upplausn, endurnýjunartíðni og snúning hvers skjás. Val þitt er vistað fyrir þann tiltekna skjá í `~/.local/state/omarchy/monitors/settings`, svo það helst eftir endurræsingu og fylgir skjánum í hvaða tengi eða dokku hann er næst tengdur við. Það hefur forgang fram yfir allar reglur fyrir sama skjá í `~/.config/hypr/monitors.lua`, sem Omarchy breytir aldrei. Ef þú vilt frekar stilla skjáina þína alfarið í þeirri skrá skaltu bæta `omarchy_monitor_panel_settings = false` við hana, og þá endast breytingar borðsins aðeins þar til Hyprland endurhleður. Þar sem `GDK_SCALE` er eitt gildi fyrir alla skjái setur valið hlutfall það út frá skjánum með lægsta hlutfallið, svo X11 forrit verða aðeins of lítil á þéttari skjánum frekar en of stór á hinum.

### Að stækka eða minnka texta

Skjástærðarhlutfall breytir stærð alls. Ef þú vilt aðeins stærri eða minni _texta_ er til ein stilling fyrir það:

```
omarchy display text size 14
```

Það tekur pixlastærð á milli 9 og 20 og færir Omarchy skelina, GTK forrit og útstöðina þína saman, svo allt skjáborðið helst í réttu hlutfalli. Keyrðu það án viðfangs til að sjá hvar þú ert, og `omarchy display text size reset` til að fara aftur í sjálfgefna gildið. Foot er eina eftirlegukindin: það hefur enga leið til að endurhlaða stillingum sínum, svo útstöðvar sem þegar eru í gangi halda gömlu stærðinni þar til þú opnar nýja.

### Að útvíkka og spegla skjái fartölvu

Þegar þú tengir ytri skjá við fartölvuna þína er skjárinn sjálfkrafa útvíkkaður. En þú getur breytt því í speglun í staðinn með _Útvíkka_ | _Spegla_ á skjáborðinu í efstu stikunni, _Trigger > Hardware_ í Omarchy valmyndinni, eða `Super + Ctrl + Alt + Delete`. Þetta er sérstaklega gagnlegt ef ytri skjárinn er skjávarpi og þú vilt sýna eitthvað á meðan þú vinnur.

Þegar þú ert að útvíkka slekkur það sjálfkrafa á innbyggða skjánum að loka lokinu á fartölvunni. Að opna lokið kveikir á honum aftur. Þú getur líka stjórnað þessu handvirkt með _Trigger > Hardware_ í Omarchy valmyndinni eða `Super + Ctrl + Delete`.

### Að raða mörgum skjám

Hyprland virkar frábærlega með mörgum skjám. Skjáborðið í efstu stikunni teiknar þá þar sem þeir sitja: dragðu einn upp að hlið annars til að færa hann þangað, og uppröðunin er vistuð með öðrum stillingum hvers skjás. Um allt sem borðið nær ekki yfir skaltu lesa meira um hvernig á að raða þeim upp í [skjágögnum Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Í Omarchy fara þetta í `~/.config/hypr/monitors.lua` sem `hl.monitor` færslur — skráin fylgir með dæmum í athugasemdum um að halda skjá slökktum, stillingum sem borðið býður ekki upp á, 10-bita lit og breytilega endurnýjunartíðni.

Hver skjár hefur vinnusvæði 1 til 10 fyrir sig, svo `Super + 1` þýðir alltaf fyrsta vinnusvæði skjásins sem þú ert á. Á bak við tjöldin númerar Hyprland samt vinnusvæði þvert yfir alla skjái: skjár fartölvunnar (eða fyrsti skjárinn) fær 1–10, næsti skjár 11–20, og svo framvegis, og hver skjár heldur sínum blokk í hvert skipti sem þú tengir hann. Notaðu þessar tölur ef þú skrifar [reglur fyrir vinnusvæði](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eða gluggareglur fyrir tiltekinn skjá, svo vinnusvæði 12 er annað vinnusvæði annars skjásins þíns. `~/.local/state/omarchy/monitors/workspaces` sýnir hvaða blokk hver skjár hefur.

Örvalyklarnir virka þvert yfir skjái sem deila brún í uppröðuninni þinni. Skjáir sem snertast aðeins á horni, eða sem hafa bil á milli sín, eru ekki nágrannar, svo notaðu `Ctrl + Alt + Tab` til að komast á milli þeirra.

| Flýtilykill | Milli skjáa |
| --- | --- |
| `Super + Arrow` | Færir fókus á skjáinn þeim megin þegar enginn gluggi er eftir í þá átt |
| `Super + Shift + Arrow` | Skiptir við glugga á skjánum þeim megin |
| `Super + Alt + Arrow` | Færir gluggann í hóp á skjánum þeim megin |
| `Super + Shift + Ctrl + Arrow` | Færir gluggann á skjáinn þeim megin, á vinnusvæðið sem hann sýnir |
| `Super + Shift + Alt + Arrow` | Færir vinnusvæðið á skjáinn þeim megin og heldur númeri þess ef það er laust |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Færir fókus á næsta eða fyrri skjá, hver sem uppröðunin er |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Verða áfram á skjánum sem þú ert á |

Þú getur líka skoðað [Hyprmon](https://github.com/erans/hyprmon/), ef þú vilt TUI til að hjálpa þér við staðsetningu margra skjáa.

### Að stjórna birtustigi

Birtustigi skjás er stjórnað með sérstökum aðgerðalyklum fyrir birtu upp/niður. Ef þú heldur shift inni á meðan þú ýtir á þá ferðu í hámarks- eða lágmarksbirtu. Lyklarnir stjórna skjánum sem þú ert með í fókus, svo ytri skjáir sem tala DDC/CI eru stilltir á sama hátt og skjár fartölvunnar.

### Apple-skjáir

Ef þú ert að nota Apple skjá munu venjulegu birtulyklar lyklaborðsins líka sjálfkrafa virka, ef þú ert með Apple skjáinn í fókus. Þetta er gert með `asdcontrol` skipuninni.

Athugaðu að ef þú ert að nota Apple 6K XDR skjá gætirðu séð draugaskjá í `hyprctl monitors` listanum þínum. Þú getur slökkt á þessu með einhverju á borð við `hl.monitor({ output = "DP-2", disabled = true })` í `~/.config/hypr/monitors.lua`.

Á Intel vélum ættirðu að tengjast Apple skjám með venjulegri Thunderbolt snúru. Á öðrum vélum án Thunderbolt þarftu venjulega að nota [DP + USB-A -> USB-C snúru](https://www.amazon.com/dp/B0BNX7MS6N) til að fá þetta til að virka.
