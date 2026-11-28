# Biežākie pielāgojumi

Šī ir biežāko Omarchy iestatījuma pielāgojumu kolekcija. Ņem vērā, ka sistēmas atjauninājumiem reizēm var būt nepieciešams atjaunot noteiktas konfigurācijas to sākotnējā stāvoklī. Ja tā notiek, tavas izmaiņas nepazudīs, bet tiks ievietotas `.bak.<timestamp>` failā blakus oriģinālam.

Ja kaut ko sabojā, atsevišķas konfigurācijas to sākotnējā iestatījumā vari atjaunot Omarchy izvēlnē, izmantojot _Update > Config_. Ja visu sabojā _pa īstam_, visas konfigurācijas vari atiestatīt ar `omarchy reinstall configs` vai pārinstalēt visas noklusējuma pakotnes un konfigurācijas ar `omarchy reinstall`.

### Parādīt visas paplātes ikonas visu laiku

Pēc noklusējuma paplātes ikonas, piemēram, Dropbox, 1password vai Steam, ir paslēptas aiz paplātes izvēršanas bultiņas, kas tās parāda, kad pār to novieto kursoru. Ja vēlies, lai tās visu laiku būtu atklātas, ar labo pogu noklikšķini uz izvēršanas bultiņas, lai atvērtu paplātes ikonu pārvaldnieku, un pēc tam piespraud ikonas, kuras vēlies paturēt redzamas (vari arī paslēpt tās, kuras nekad nevēlies redzēt).

### Noapaļoti logu stūri

Omarchy noklusējuma dizains ir ar kvadrātveida stūriem, bet, ja vēlies to mazliet mīkstināt, Omarchy izvēlnē izvēlies _Appearance > Windows > Window Corners > Rounded Corners_ vai palaid `omarchy hyprland corners rounded`. _Theme Corners_ atgriežas pie tā, ko izmanto tēma. Lai izvēlētos savu rādiusu, paliec pie _Theme Corners_ (`omarchy hyprland corners theme`), jo Rounded un Sharp tiek ielādēti pēc tavas konfigurācijas un to pārraksta, un noņem komentāru no noapaļošanas iestatījuma failā `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Noņemt logu atstarpes

Klēpjdatoru ekrānos daži cilvēki dod priekšroku netērēt nevienu pikseli logu atstarpēm (vai pat augšējai joslai, kuru vari izslēgt ar `Super + Shift + Space`). Visas atstarpes un apmales vari ieslēgt un izslēgt ar `Super + Shift + Backspace` vai noņemt tās uz visiem laikiem, noņemot komentārus šajā sadaļā failā `~/.config/hypr/looknfeel.lua`:

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
