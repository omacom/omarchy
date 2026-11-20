# Dažni patobulinimai

Tai dažniausių „Omarchy“ sąrankos pritaikymų rinkinys. Žinokite, kad kartais sistemos atnaujinimams gali prireikti atkurti tam tikrų konfigūracijų pradinę būseną. Jei taip nutiks, jūsų pakeitimai nedings, bet bus perkelti į `.bak.<timestamp>` failą šalia originalo.

Jei ką nors sugadinsite, atskiras konfigūracijas į pradinę sąranką galite atkurti per _Update > Config_ „Omarchy“ meniu. Jei _tikrai_ viską sugadinsite, visas konfigūracijas galite iš naujo nustatyti su `omarchy reinstall configs` arba iš naujo įdiegti kiekvieną numatytąjį paketą ir konfigūraciją su `omarchy reinstall`.

### Visada rodyti visas dėklo piktogramas

Pagal numatytuosius nustatymus dėklo piktogramos, pavyzdžiui, Dropbox, 1password ar Steam, yra paslėptos už dėklo išskleidimo rodyklės, kuri jas parodo, kai užvedate ant jos žymeklį. Jei norite, kad jos visą laiką būtų matomos, dešiniuoju pelės mygtuku spustelėkite išskleidimo rodyklę, kad atidarytumėte dėklo piktogramų tvarkytuvę, tada prisekite piktogramas, kurias norite nuolat matyti (taip pat galite paslėpti tas, kurių niekada nenorite matyti).

### Užapvalinti langų kampai

Numatytasis „Omarchy“ dizainas yra su stačiais kampais, bet jei norite jį šiek tiek sušvelninti, „Omarchy“ meniu pasirinkite _Appearance > Windows > Window Corners > Rounded Corners_ arba paleiskite `omarchy hyprland corners rounded`. _Theme Corners_ grąžina tai, ką naudoja tema. Norėdami pasirinkti savo spindulį, likite ties _Theme Corners_ (`omarchy hyprland corners theme`), nes Rounded ir Sharp įkeliami po jūsų konfigūracijos ir ją perrašo, ir atkomentuokite užapvalinimą faile `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Pašalinti langų tarpus

Nešiojamųjų kompiuterių ekranuose kai kurie žmonės mieliau nešvaisto nė vieno pikselio langų tarpams (ar net viršutinei juostai, kurią galite įjungti ir išjungti su `Super + Shift + Space`). Visus tarpus ir kraštines galite įjungti ir išjungti su `Super + Shift + Backspace` arba pašalinti juos visam laikui, atkomentavę šią `~/.config/hypr/looknfeel.lua` sekciją:

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
