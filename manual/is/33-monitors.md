# Skjáir

Omarchy gerir sjálfgefið ráð fyrir að þú sért að keyra á 2x-hæfum skjá í retina-flokki. Þetta er það sem þú þarft til að fá þessi fínu, skarpu forritaraleturtýpur. Það er það sem nánast allar nýjar úrvals fartölvur með háupplausnarskjái eru fínstilltar fyrir. Það er það sem þú myndir vilja keyra á 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eða 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

En ef þú ert ekki að keyra skjá með PPI 218 eða hærra viltu breyta skjástillingunum. Til dæmis, ef þú ert með 27" eða 32" 4K geturðu valið brotakvarða fyrir hann úr skjáborðinu í efstu stikunni, eða stillt sjálfgefið gildi fyrir hvern skjá með því að opna `~/.config/hypr/monitors.lua` og skipta yfir í ráðlegginguna fyrir þá samsetningu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ef þú notar 1080p eða 1440p skjá viltu líklega bara nota 1x kvarðann, og það sama fyrir GTK og X11 forrit, svo þú getur notað:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Breytingar á `GDK_SCALE` gilda fyrir forrit sem ræst eru eftir breytinguna (og GTK virðir aðeins heilar tölur, svo haltu því við næstu heilu tölu við skjákvarðann þinn). Svo vertu viss um að loka gluggunum sem þú átt sem eru of stórir eftir breytinguna (eða lokaðu öllum gluggum með `Ctrl + Alt + Del`!).

Þú getur líka stigið hratt í gegnum helstu kvarðahlutföll skjáa (1x, 1.25x, 1.6x, 2x, 3x, 4x) með `Super + /` til að fara hærra og `Super + Alt + /` til að fara lægra, eða valið eitt úr skjáborðinu í efstu stikunni. Þetta breytir aðeins skjánum sem þú ert með í fókus, svo fartölvuskjár og ytri skjár geta hvor haft sinn kvarða. Borðið stillir líka upplausn, endurnýjunartíðni og snúning hvers skjás. Val þitt er vistað fyrir þann tiltekna skjá í `~/.local/state/omarchy/monitors/settings`, svo það helst eftir endurræsingu og fylgir skjánum í hvaða tengi eða dokku hann er næst tengdur við. Það hefur forgang fram yfir allar reglur fyrir sama skjá í `~/.config/hypr/monitors.lua`, sem Omarchy breytir aldrei. Ef þú vilt frekar stilla skjáina þína alfarið í þeirri skrá skaltu bæta `omarchy_monitor_panel_settings = false` við hana, og breytingar borðsins endast þá aðeins þar til Hyprland endurhleður. Þar sem `GDK_SCALE` er eitt gildi fyrir alla skjái setur valinn kvarði það út frá skjánum með lægsta kvarðann, svo X11 forrit verða aðeins lítil á þéttari skjánum frekar en of stór á hinum.

### Að stækka eða minnka texta

Kvarðun skjás breytir stærð alls. Ef allt sem þú vilt er stærri eða minni _texti_ er til ein stilling fyrir það:

```
omarchy display text size 14
```

Það tekur pixlastærð á milli 9 og 20 og færir Omarchy skelina, GTK forrit og útstöðina þína saman, svo allt skjáborðið helst í réttu hlutfalli. Keyrðu það án viðfangs til að sjá hvar þú ert, og `omarchy display text size reset` til að fara aftur í sjálfgefið gildi. Foot er eini eftirbáturinn: það hefur enga leið til að endurhlaða stillingum sínum, svo útstöðvar sem þegar eru í gangi halda gömlu stærðinni þar til þú opnar nýja.

### Að útvíkka og spegla fartölvuskjái

Þegar þú tengir ytri skjá við fartölvuna þína er skjárinn sjálfkrafa útvíkkaður. En þú getur breytt því í speglun í staðinn með _Trigger > Hardware_ í Omarchy valmyndinni eða `Super + Ctrl + Alt + Delete`. Þetta er sérstaklega gagnlegt ef sá ytri skjár er skjávarpi og þú vilt sýna eitthvað á meðan þú vinnur.

Þegar þú útvíkkar slokknar sjálfkrafa á innri skjánum þegar þú lokar lokinu á fartölvunni. Þegar þú opnar lokið kviknar á honum aftur. Þú getur líka stjórnað þessu handvirkt með _Trigger > Hardware_ í Omarchy valmyndinni eða `Super + Ctrl + Delete`.

### Að raða mörgum skjám

Hyprland virkar frábærlega með mörgum skjám. Skjáborðið í efstu stikunni teiknar þá þar sem þeir sitja: dragðu einn upp að hlið annars til að færa hann þangað, og uppröðunin er vistuð með öðrum stillingum hvers skjás. Fyrir allt sem borðið nær ekki yfir skaltu lesa meira um hvernig á að raða þeim í [skjölun Hyprland um skjái](https://wiki.hypr.land/Configuring/Basics/Monitors/). Í Omarchy fara þetta í `~/.config/hypr/monitors.lua` sem `hl.monitor` færslur — skráin fylgir með útskýrðum dæmum um að halda skjá slökktum, stillingum sem borðið býður ekki upp á, 10-bita liti og breytilega endurnýjunartíðni.

Hver skjár hefur vinnusvæði 1 til 10 út af fyrir sig, svo `Super + 1` þýðir alltaf fyrsta vinnusvæði skjásins sem þú ert á. Á bak við tjöldin númerar Hyprland samt vinnusvæði þvert yfir alla skjái: fartölvuskjárinn þinn (eða fyrsti skjárinn) fær 1–10, næsti skjár 11–20, og svo framvegis, og hver skjár heldur sínum blokk í hvert skipti sem þú tengir hann. Notaðu þessar tölur ef þú skrifar [reglur um vinnusvæði](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eða gluggareglur fyrir ákveðinn skjá, svo vinnusvæði 12 er annað vinnusvæði annars skjásins þíns. `~/.local/state/omarchy/monitors/workspaces` telur upp hvaða blokk hver skjár hefur.

Örvalyklarnir virka á milli skjáa sem deila brún í uppröðuninni þinni. Skjáir sem snertast aðeins í horni, eða sem hafa bil á milli sín, eru ekki nágrannar, svo notaðu `Ctrl + Alt + Tab` til að komast á milli þeirra.

| Flýtilykill | Á milli skjáa |
| --- | --- |
| `Super + Arrow` | Færir fókusinn á skjáinn á þeirri hlið þegar enginn gluggi er eftir í þá átt |
| `Super + Shift + Arrow` | Skiptir við glugga á skjánum á þeirri hlið |
| `Super + Alt + Arrow` | Færir gluggann í hóp á skjánum á þeirri hlið |
| `Super + Shift + Ctrl + Arrow` | Færir gluggann á skjáinn á þeirri hlið, inn á vinnusvæðið sem hann sýnir |
| `Super + Shift + Alt + Arrow` | Færir vinnusvæðið á skjáinn á þeirri hlið og heldur númeri þess ef það er laust |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Færir fókusinn á næsta eða fyrri skjá, hvernig sem uppröðunin er |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Vertu áfram á skjánum sem þú ert á |

Þú getur líka skoðað [Hyprmon](https://github.com/erans/hyprmon/) ef þú vilt TUI til að hjálpa þér við staðsetningu margra skjáa.

### Að stjórna birtustigi

Birtustigi skjás er stjórnað með sérstökum aðgerðarlyklum fyrir birtu upp/niður. Ef þú heldur Shift inni á meðan þú ýtir á þá ferðu í hámarks- eða lágmarksbirtu. Lyklarnir stjórna skjánum sem þú ert með í fókus, svo ytri skjáir sem tala DDC/CI eru stilltir á sama hátt og fartölvuskjárinn.

### Apple-skjáir

Ef þú notar Apple skjá munu venjulegu birtulyklarnir á lyklaborðinu líka virka sjálfkrafa ef þú ert með fókus á Apple skjánum. Þetta er gert með `asdcontrol` skipuninni.

Athugaðu að ef þú notar Apple 6K XDR skjá gætirðu séð draugaskjá í `hyprctl monitors` listanum þínum. Þú getur slökkt á þessu með einhverju á borð við `hl.monitor({ output = "DP-2", disabled = true })` í `~/.config/hypr/monitors.lua`.

Á Intel vélum ættirðu að tengjast Apple skjám með venjulegri Thunderbolt snúru. Á öðrum vélum án Thunderbolt þarftu yfirleitt að nota [DP + USB-A -> USB-C snúru](https://www.amazon.com/dp/B0BNX7MS6N) til að láta þetta virka.
