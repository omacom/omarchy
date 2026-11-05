# Vanlige justeringer

Dette er en samling av vanlige tilpasninger av Omarchy-oppsettet. Vit at det av og til kan være nødvendig for systemoppdateringer å gjenopprette visse konfigurasjoner til opprinnelig tilstand. Hvis dette skjer, går ikke endringene dine tapt, men legges i en `.bak`-fil i samme mappe.

Hvis du roter noe til, kan du gjenopprette individuelle konfigurasjoner til det opprinnelige oppsettet via _Oppdater > Konfigurasjon_ i Omarchy-menyen. Hvis du _virkelig_ roter alt til, kan du nullstille alle konfigurasjoner via `omarchy-reinstall`.

### Vis alle systemstatusikoner hele tiden

Som standard er systemstatusikoner, som Dropbox, 1password eller Steam, skjult bak utvidelsespilen for systemstatusfeltet, som avslører dem når du holder musepekeren over den. Hvis du vil ha dem eksponert hele tiden, høyreklikk på utvidelsespilen for å åpne behandleren for systemstatusikoner, og fest deretter ikonene du vil holde synlige (du kan også skjule dem du aldri vil se).

### Avrundede vindushjørner

Omarchys standarddesign er ett med firkantede hjørner, men hvis du liker å myke det opp litt, kan du endre `~/.config/hypr/looknfeel.lua` slik at avrunding ikke lenger er kommentert ut:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Fjern vindusmellomrom

På bærbare skjermer foretrekker noen å ikke kaste bort piksler på vindusmellomrom (eller til og med en menylinje, som du kan slå av med `Super + Shift + Space`). Du kan slå alle mellomrom og kanter av med `Super + Shift + Backspace`, eller fjerne dem permanent ved å fjerne kommentarene i denne delen av `~/.config/hypr/looknfeel.lua`:

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
