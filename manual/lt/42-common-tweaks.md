# Dažni patobulinimai

Tai dažnų Omarchy sąrankos pritaikymų rinkinys. Žinok, kad sistemos naujinimams kartais gali prireikti tam tikras konfigūracijas grąžinti į pradinę būseną. Jei taip atsitiks, tavo pakeitimai nedings, o bus padėti į `.bak` failą tame pačiame kataloge.

Jei ką sugadinsi, atskiras konfigūracijas į pradinę sąranką gali atkurti Omarchy meniu per _Atnaujinti > Konfigūracija_. Jei _iš tikrųjų_ viską sugadinsi, visas konfigūracijas gali iš naujo nustatyti su `omarchy-reinstall`.

### Visada rodyti visas dėklo piktogramas

Pagal numatytuosius dėklo piktogramos, tokios kaip Dropbox, 1password ar Steam, slepiasi už dėklo išskleidimo rodyklės, kuri jas parodo, kai ant jos užvedi. Jei norėtum jas matyti visada, dešiniuoju pelės klavišu spustelėk išskleidimo rodyklę, kad atidarytum dėklo piktogramų tvarkyklę, tada prisek piktogramas, kurias nori laikyti matomas (gali paslėpti ir tas, kurių niekada nenori matyti).

### Užapvalinti langų kampai

Numatytasis Omarchy dizainas yra kvadratinių kampų, bet jei mėgsti tai šiek tiek sušvelninti, gali pakeisti `~/.config/hypr/looknfeel.lua`, kad rounding nebebūtų užkomentuotas:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Langų tarpų pašalinimas

Nešiojamųjų ekranuose kai kurie žmonės mieliau nešvaisto nė vieno pikselio langų tarpams (ar net viršutinei juostai, kurią gali išjungti su `Super + Shift + Space`). Visus tarpus ir rėmelius gali išjungti su `Super + Shift + Backspace` arba pašalinti visam laikui pašalinęs komentarus šioje `~/.config/hypr/looknfeel.lua` skiltyje:

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
