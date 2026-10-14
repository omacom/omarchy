# Biežākie pielāgojumi

Šī ir biežāko Omarchy iestatījumu pielāgojumu kolekcija. Ziniet, ka sistēmas atjauninājumiem reizēm var būt nepieciešams atjaunot noteiktas konfigurācijas to sākotnējā stāvoklī. Ja tā notiek, jūsu izmaiņas netiks zaudētas, bet ieliktas `.bak` failā tajā pašā direktorijā.

Ja kaut ko sabojājat, atsevišķas konfigurācijas to sākotnējā iestatījumā varat atjaunot Omarchy izvēlnē sadaļā _Atjaunināt > Konfigurācija_. Ja _patiešām_ sabojājat visu, visas konfigurācijas varat atiestatīt ar `omarchy-reinstall`.

### Rādīt visas teknes ikonas vienmēr

Pēc noklusējuma teknes ikonas, piemēram, Dropbox, 1password vai Steam, ir paslēptas aiz teknes izvērsēja bultiņas, kas tās atklāj, kad tai uzbraucat. Ja vēlaties, lai tās būtu redzamas vienmēr, ar labo pogu noklikšķiniet izvērsēja bultiņu, lai atvērtu teknes ikonu pārvaldnieku, pēc tam piespraudiet ikonas, ko vēlaties paturēt redzamas (varat arī paslēpt tās, ko nekad nevēlaties redzēt).

### Noapaļoti logu stūri

Omarchy noklusējuma dizains ir kvadrātveida stūri, bet, ja vēlaties to nedaudz mīkstināt, varat mainīt failu `~/.config/hypr/looknfeel.lua`, lai noapaļošana vairs nebūtu komentēta:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Logu atstarpju noņemšana

Klēpjdatoru displejos daži cilvēki nevēlas tērēt nevienu pikseli logu atstarpēm (vai pat augšējai joslai, ko varat izslēgt ar `Super + Shift + Space`). Visas atstarpes un apmales varat izslēgt ar `Super + Shift + Backspace` vai noņemt tās pavisam, noņemot komentārus šajā faila `~/.config/hypr/looknfeel.lua` sadaļā:

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
