# Algengar aðlaganir

Þetta er safn algengra aðlagana að Omarchy uppsetningunni. Hafðu í huga að stundum getur verið nauðsynlegt vegna kerfisuppfærslna að endurstilla tilteknar stillingar í upprunalegt horf. Ef það gerist munu breytingarnar þínar ekki tapast, heldur verða settar í `.bak.<timestamp>` skrá við hliðina á upprunalegu skránni.

Ef þú klúðrar einhverju getur þú endurstillt einstakar stillingar í upprunalega uppsetningu í gegnum _Uppfæra > Stillingar_ í Omarchy valmyndinni. Ef þú _virkilega_ klúðrar öllu getur þú endurstillt allar stillingar með `omarchy reinstall configs`, eða sett upp aftur alla sjálfgefna pakka og stillingar með `omarchy reinstall`.

### Sýna öll bakkatákn alltaf

Sjálfgefið eru bakkatákn, eins og Dropbox, 1password eða Steam, falin á bak við stækkunarör bakkans, sem sýnir þau þegar þú heldur bendlinum yfir henni. Ef þú vilt hafa þau sýnileg alltaf skaltu hægrismella á stækkunarörina til að opna stjórnun bakkatákna og festa síðan táknin sem þú vilt halda sýnilegum (þú getur líka falið þau sem þú vilt aldrei sjá).

### Ávöl gluggahorn

Sjálfgefna hönnun Omarchy er með ferköntuð horn, en ef þú vilt mýkja það aðeins skaltu velja _Útlit > Gluggar > Gluggahorn > Ávöl horn_ í Omarchy valmyndinni, eða keyra `omarchy hyprland corners rounded`. _Þemahorn_ fer aftur í það sem þemað notar. Til að velja þinn eigin radíus skaltu halda þig við _Þemahorn_ (`omarchy hyprland corners theme`), þar sem Ávöl og Skörp hlaðast eftir stillingunni þinni og hnekkja henni, og taka athugasemdina af ávölun í `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Fjarlægja bil á milli glugga

Á fartölvuskjám kjósa sumir að sóa engum pixlum í bil á milli glugga (eða jafnvel efstu stikuna, sem þú getur slökkt á með `Super + Shift + Space`). Þú getur slökkt á öllum bilum og röndum með `Super + Shift + Backspace`, eða fjarlægt þau varanlega með því að fjarlægja athugasemdirnar í þessum hluta `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
