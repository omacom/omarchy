# Algengar lagfæringar

Þetta er safn algengra sérsníðninga á Omarchy-uppsetningunni. Hafðu í huga að það gæti stöku sinnum verið nauðsynlegt fyrir kerfisuppfærslur að endurheimta ákveðnar stillingar í upprunalegt ástand. Ef það gerist týnast breytingarnar þínar ekki, heldur fara í `.bak` skrá í sömu möppu.

Ef þú klúðrar einhverju geturðu endurheimt einstakar stillingar í upprunalega uppsetningu með _Uppfæra > Stillingar_ í Omarchy-valmyndinni. Ef þú _virkilega_ klúðrar öllu geturðu endurstillt allar stillingar með `omarchy-reinstall`.

### Sýna öll bakkatákn alltaf

Sjálfgefið eru bakkatákn, eins og Dropbox, 1password eða Steam, falin á bak við útvíkkunarörina, sem sýnir þau þegar þú heldur bendlinum yfir henni. Ef þú vilt hafa þau opin alltaf skaltu hægrismella á útvíkkunarörina til að opna bakkatáknastjórann og festa svo táknin sem þú vilt hafa sýnileg (þú getur líka falið þau sem þú vilt aldrei sjá).

### Rúnnuð gluggahorn

Sjálfgefin hönnun Omarchy er ferköntuð horn, en ef þér finnst gott að mýkja það aðeins geturðu breytt `~/.config/hypr/looknfeel.lua` svo rúnun sé ekki lengur athugasemd:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Fjarlægja gluggabil

Á fartölvuskjám kjósa sumir að sóa ekki pixlum í gluggabil (eða jafnvel valmyndastiku, sem þú getur slökkt á með `Super + Shift + Space`). Þú getur slökkt á öllum bilum og römmum með `Super + Shift + Backspace`, eða fjarlægt þau varanlega með því að fjarlægja athugasemdirnar í þessum hluta `~/.config/hypr/looknfeel.lua`:

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
