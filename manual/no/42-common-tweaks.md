# Vanlige justeringer

Dette er en samling vanlige tilpasninger av Omarchy-oppsettet. Vær klar over at det av og til kan være nødvendig for systemoppdateringer å tilbakestille visse konfigurasjoner til original tilstand. Hvis dette skjer, går ikke endringene dine tapt, men legges i en `.bak.<timestamp>`-fil ved siden av originalen.

Hvis du roter det til, kan du tilbakestille enkeltkonfigurasjoner til originaloppsettet via _Update > Config_ i Omarchy-menyen. Hvis du _virkelig_ roter alt til, kan du tilbakestille alle konfigurasjoner via `omarchy reinstall configs`, eller installere alle standardpakker og -konfigurasjoner på nytt med `omarchy reinstall`.

### Vis alle ikoner i systemstatusfeltet hele tiden

Som standard er ikoner i systemstatusfeltet, som Dropbox, 1password eller Steam, skjult bak pilen for å utvide systemstatusfeltet, som viser dem når du holder musepekeren over den. Hvis du vil ha dem synlige hele tiden, høyreklikker du på utvidelsespilen for å åpne behandleren for ikoner i systemstatusfeltet, og fester deretter ikonene du vil holde synlige (du kan også skjule dem du aldri vil se).

### Avrundede vindushjørner

Omarchys standarddesign har firkantede hjørner, men hvis du vil myke det opp litt, velger du _Appearance > Windows > Window Corners > Rounded Corners_ i Omarchy-menyen, eller kjører `omarchy hyprland corners rounded`. _Theme Corners_ går tilbake til det temaet bruker. For å velge din egen radius blir du på _Theme Corners_ (`omarchy hyprland corners theme`), siden Rounded og Sharp lastes etter konfigurasjonen din og overstyrer den, og fjerner kommentartegnet for rounding i `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Fjern vindusgap

På bærbare skjermer foretrekker noen å ikke kaste bort en eneste piksel på vindusgap (eller til og med en topplinje, som du kan slå av med `Super + Shift + Space`). Du kan slå alle gap og kanter av og på med `Super + Shift + Backspace`, eller fjerne dem permanent ved å fjerne kommentarene i denne delen av `~/.config/hypr/looknfeel.lua`:

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
