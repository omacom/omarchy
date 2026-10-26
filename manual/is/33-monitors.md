# Skjáir

Omarchy gerir sjálfgefið ráð fyrir að þú notir skjá í retina-flokki með 2x-getu. Þetta er það sem þú þarft til að fá þessi fallegu, skarpu forritaraletur. Þetta er það sem næstum allar nýjar úrvals fartölvur með háupplausnarskjám eru fínstilltar fyrir. Þetta er það sem þú myndir vilja nota á 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eða 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

En ef þú ert ekki að nota skjá með PPI upp á 218 eða hærra viltu breyta skjákjástillingunum. Ef þú ert til dæmis með 27" eða 32" 4K geturðu notað brotakvörðun með því að opna `~/.config/hypr/monitors.lua` (í gegnum _Uppsetning > Skjáir_ í Omarchy-valmyndinni) og skipta yfir í ráðlegginguna fyrir þá samsetningu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ef þú notar 1080p eða 1440p skjá viltu líklega bara nota 1x kvörðun, svo þú getur notað:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Breytingar á `GDK_SCALE` gilda um forrit sem ræst eru eftir breytinguna (og GTK virðir aðeins heilar tölur, svo haltu því við næstu heilu tölu skjávörðunarinnar). Svo vertu viss um að loka gluggunum sem þú ert með og eru of stórir eftir breytinguna (eða lokaðu öllum gluggum með `Ctrl + Alt + Del`!).

Þú getur líka stigið hratt í gegnum helstu kvörðunarhlutföll skjáa (1x, 1.25x, 1.6x, 2x, 3x, 4x) með `Super + /` til að fara hærra og `Super + Alt + /` til að fara lægra. Ef þú ert með sjálfgefnu stillinguna varðveitast þessar breytingar líka eftir endurræsingu.

### Að stækka eða minnka texta

Skjákvörðun breytir stærð alls. Ef allt sem þú vilt er stærri eða minni _texti_ er einn hnappur fyrir því:

```
omarchy display text size 14
```

Það tekur pixlastærð á milli 9 og 20 og færir Omarchy-skelina, GTK-forrit og útstöðina þína saman, svo allt skjáborðið helst í réttum hlutföllum. Keyrðu það án viðfangs til að sjá hvar þú ert staddur, og `omarchy display text size reset` til að fara aftur í sjálfgefið gildi. Foot er eini eftirbáturinn: það hefur enga leið til að endurhlaða stillingum sínum, svo útstöðvar sem þegar eru í gangi halda gömlu stærðinni þar til þú opnar nýja.

### Að útvíkka og spegla skjái fartölvu

Þegar þú tengir ytri skjá við fartölvuna þína er skjárinn sjálfkrafa útvíkkaður. En þú getur breytt því í speglun í staðinn með því að nota _Ræsir > Vélbúnaður_ í Omarchy-valmyndinni eða `Super + Ctrl + Alt + Delete`. Þetta er sérstaklega gagnlegt ef sá ytri skjár er skjávarpi og þú vilt sýna eitthvað á meðan þú vinnur.

Þegar þú ert að útvíkka slekkur það sjálfkrafa á innri skjánum þegar þú lokar lokinu á fartölvunni. Það kviknar aftur á honum þegar þú opnar lokið. Þú getur líka stjórnað þessu handvirkt með því að nota _Ræsir > Vélbúnaður_ í Omarchy-valmyndinni eða `Super + Ctrl + Delete`.

### Að raða mörgum skjám

Hyprland virkar frábærlega með mörgum skjám. Lestu meira um hvernig á að raða þeim upp í [skjölum Hyprland um skjái](https://wiki.hypr.land/Configuring/Basics/Monitors/). Í Omarchy fara þetta í `~/.config/hypr/monitors.lua` sem `hl.monitor` færslur — skráin fylgir með dæmum í athugasemdum um að festa ákveðinn skjá við upplausn, staðsetningu og snúning.

Sérhver skjár hefur vinnusvæði 1 til 10 fyrir sig, svo `Super + 1` þýðir alltaf fyrsta vinnusvæði skjásins sem þú ert á. Á bak við tjöldin númerar Hyprland samt vinnusvæði þvert yfir alla skjái: fartölvuskjárinn þinn (eða fyrsti skjárinn) fær 1–10, næsti skjár 11–20, og svo framvegis, og sérhver skjár heldur sínum blokk í hvert skipti sem þú tengir hann. Notaðu þessar tölur ef þú skrifar [vinnusvæðisreglur](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eða gluggareglur fyrir ákveðinn skjá, svo vinnusvæði 12 er annað vinnusvæði annars skjásins þíns. `~/.local/state/omarchy/monitor-workspaces` sýnir hvaða blokk sérhver skjár hefur.

Örvalyklarnir virka þvert yfir skjái sem deila brún í uppröðuninni þinni. Skjáir sem snertast aðeins á horni, eða sem hafa bil á milli sín, eru ekki nágrannar, svo notaðu `Ctrl + Alt + Tab` til að komast á milli þeirra.

| Flýtilykill | Á milli skjáa |
| --- | --- |
| `Super + Arrow` | Færir fókusinn á skjáinn þeim megin þegar enginn gluggi er lengur eftir í þá átt |
| `Super + Shift + Arrow` | Skiptir á við glugga á skjánum þeim megin |
| `Super + Alt + Arrow` | Færir gluggann inn í hóp á skjánum þeim megin |
| `Super + Shift + Ctrl + Arrow` | Færir gluggann á skjáinn þeim megin, inn á vinnusvæðið sem hann sýnir |
| `Super + Shift + Alt + Arrow` | Færir vinnusvæðið á skjáinn þeim megin og heldur númerinu sínu ef það er laust |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Færir fókusinn á næsta eða fyrri skjá, hver svo sem uppröðunin er |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Vera á skjánum sem þú ert á |

Þú getur líka prófað [Hyprmon](https://github.com/erans/hyprmon/), ef þú vilt TUI til að hjálpa þér við staðsetningu margra skjáa.

### Að stjórna birtustigi

Birtustigi skjás er stjórnað með sérstökum aðgerðarlyklum fyrir birtustig upp/niður. Ef þú heldur shift inni á meðan þú ýtir á þessa ferðu í hámarks- eða lágmarksbirtu. Lyklarnir stjórna skjánum sem þú hefur fókus á, svo ytri skjáir sem tala DDC/CI eru stilltir á sama hátt og fartölvuskjárinn.

### Apple-skjáir

Ef þú notar Apple-skjá munu venjulegu birtustigslyklarnir á lyklaborðinu líka virka sjálfkrafa, ef þú hefur fókus á Apple-skjánum. Þetta er gert í gegnum `asdcontrol` skipunina.

Athugaðu að ef þú notar Apple 6K XDR skjá gætir þú séð draugaskjá í `hyprctl monitors` listanum þínum. Þú getur slökkt á þessu með einhverju á borð við `hl.monitor({ output = "DP-2", disabled = true })` í gegnum _Uppsetning > Skjáir_.

Á Intel-vélum ættir þú að tengjast Apple-skjám með venjulegri Thunderbolt-snúru. Á öðrum vélum án Thunderbolt þarftu yfirleitt að nota [DP + USB-A -> USB-C snúru](https://www.amazon.com/dp/B0BNX7MS6N) til að láta það virka.
