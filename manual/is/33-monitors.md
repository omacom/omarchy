# Skjáir

Omarchy gerir sjálfgefið ráð fyrir að þú sért að keyra á 2x-hæfum skjá í retina-flokki. Þetta er það sem þú þarft til að fá þessi fínu, skarpu forritaraletur. Það er það sem næstum allar nýjar úrvalsfartölvur með háupplausnarskjám eru fínstilltar fyrir. Það er það sem þú vildir keyra á 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eða 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

En ef þú ert ekki að keyra skjá með PPI 218 eða hærra viltu breyta skjáastillingunum. Til dæmis, ef þú ert með 27" eða 32" 4K, geturðu notað brotakennda kvörðun með því að opna `~/.config/hypr/monitors.lua` (í gegnum _Uppsetning > Skjár_ í Omarchy-valmyndinni) og skipta yfir í tilmælin fyrir þá samsetningu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ef þú ert að nota 1080p eða 1440p skjá viltu líklega bara nota 1x kvörðun, þannig að þú getur notað:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Breytingar á `GDK_SCALE` eiga við forrit sem ræst eru eftir breytinguna (og GTK heiðrar aðeins heilar tölur, þannig að haltu því við næstu heiltölu skjákvarðans þíns). Þannig að vertu viss um að hætta í gluggunum sem þú átt sem eru of stórir eftir breytinguna (eða loka öllum gluggum með `Ctrl + Alt + Del`!).

Þú getur líka fljótt stigið í gegnum helstu skjákvörðunarhlutföllin (1x, 1.25x, 1.6x, 2x, 3x, 4x) með `Super + /` til að fara hærra og `Super + Alt + /` til að fara lægra. Ef þú ert með sjálfgefnu stillinguna munu þessar breytingar líka varðveitast eftir endurræsingu.

### Að gera texta stærri eða minni

Skjákvörðun breytir stærð alls. Ef þú vilt bara stærri eða minni _texta_ er einn takki fyrir það:

```
omarchy display text size 14
```

Það tekur pixlastærð á milli 9 og 20, og færir Omarchy-shellið, GTK-forrit og terminalið þitt saman, þannig að allt skjáborðið helst í réttum hlutföllum. Keyrðu það án viðfangs til að sjá hvar þú ert staddur, og `omarchy display text size reset` til að fara aftur í sjálfgildið. Foot er eini eftirbáturinn: það hefur enga leið til að endurhlaða stillinguna sína, þannig að keyrandi terminalar halda gömlu stærðinni þar til þú opnar nýjan.

### Að útvíkka og spegla fartölvuskjái

Þegar þú tengir ytri skjá við fartölvuna þína er skjárinn sjálfkrafa útvíkkaður. En þú getur breytt því í speglun í staðinn með _Kveikja > Vélbúnaður_ í Omarchy-valmyndinni eða `Super + Ctrl + Alt + Delete`. Þetta er sérstaklega gagnlegt ef sá ytri skjár er skjávarpi, og þú vilt sýna eitthvað á meðan þú vinnur.

Þegar þú ert að útvíkka mun það að loka lokinu á fartölvunni sjálfkrafa slökkva á innra skjánum. Að opna lokið mun kveikja á honum aftur. Þú getur líka stjórnað þessu handvirkt með _Kveikja > Vélbúnaður_ í Omarchy-valmyndinni eða `Super + Ctrl + Delete`.

### Að raða mörgum skjám

Hyprland virkar frábærlega með marga skjái. Lestu meira um hvernig á að leggja þá út í [Hyprland-skjákjölunum](https://wiki.hypr.land/Configuring/Basics/Monitors/). Þú getur líka [bundið ákveðin vinnusvæði við ákveðna skjái](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). Í Omarchy fara þessar reglur í `~/.config/hypr/monitors.lua` sem `hl.monitor`-færslur — skráin kemur með útkommentuðum dæmum um að festa ákveðinn skjá við upplausn, stöðu og snúning.

Þú getur líka skoðað [Hyprmon](https://github.com/erans/hyprmon/), ef þú vilt TUI til að hjálpa þér við staðsetningu margra skjáa.

### Að stjórna birtu

Skjábirtustigi er stjórnað af sérstökum aðgerðarlyklum fyrir birtu upp/niður. Ef þú heldur shift niðri á meðan þú ýtir á þessa ferðu í hámarks- eða lágmarksbirt. Lyklarnir stjórna skjánum sem þú hefur fókus á, þannig að ytri skjáir sem tala DDC/CI eru stilltir á sama hátt og fartölvuskjárinn.

### Apple-skjáir

Ef þú ert að nota Apple-skjá munu venjulegu birtulyklar lyklaborðsins líka sjálfkrafa virka, ef þú hefur fókus á Apple-skjánum. Þetta er gert í gegnum skipunina `asdcontrol`.

Athugaðu að ef þú ert að nota Apple 6K XDR-skjá gætir þú séð draugaskjá í listanum `hyprctl monitors` hjá þér. Þú getur slökkt á þessu með einhverju á borð við `hl.monitor({ output = "DP-2", disabled = true })` í gegnum _Uppsetning > Skjár_.

Á Intel-vélum ættir þú að tengjast Apple-skjám með venjulegri Thunderbolt-snúru. Á öðrum vélum án Thunderbolt verðurðu venjulega að nota [DP + USB-A -> USB-C snúru](https://www.amazon.com/dp/B0BNX7MS6N) til að láta það virka.
