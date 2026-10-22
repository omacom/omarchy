# Skærme

Omarchy antager, at du som standard kører på en 2x-kapabel retina-klasse skærm. Det er, hvad du har brug for til at få de fine, skarpe programmørskrifttyper. Det er, hvad næsten alle nye premium bærbare computere med højtopløsningsskærme er optimeret til. Det er, hvad du ville ønske at køre på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men hvis du ikke kører en skærm med en PPI på 218 eller derover, vil du ønske at ændre skærmindstillingerne. For eksempel, hvis du har en 27" eller 32" 4K, kan du bruge brøkskalering ved at åbne `~/.config/hypr/monitors.lua` (via _Opsætning > Monitors_ i Omarchy-menuen) og skifte til anbefalingen for den kombination:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Hvis du bruger en 1080p- eller 1440p-skærm, vil du sandsynligvis bare ønske at bruge 1x-skalering, så du kan bruge:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Ændringer til `GDK_SCALE` gælder for applikationer startet efter ændringen (og GTK respekterer kun hele tal, så hold den på det nærmeste heltal af din skærmskala). Så sørg for, at du afslutter de vinduer, du har, der er for store efter ændringen (eller luk alle vinduer med `Ctrl + Alt + Del`!).

Du kan også hurtigt træde gennem de store skærmskaleringsforhold (1x, 1.25x, 1.6x, 2x, 3x, 4x) ved hjælp af `Super + /` for at gå højere og `Super + Alt + /` for at gå lavere. Hvis du har standardkonfigurationen, vil disse ændringer også vare ved efter genstart.

### Gøre tekst større eller mindre

Skærmskalering ændrer størrelsen på alt. Hvis alt, hvad du ønsker, er større eller mindre _tekst_, er der en enkelt knap til det:

```
omarchy display text size 14
```

Det tager en pixelstørrelse mellem 9 og 20 og flytter Omarchy-skallen, GTK-applikationer og din terminal sammen, så hele skrivebordet forbliver i proportion. Kør den uden et argument for at se, hvor du er, og `omarchy display text size reset` for at gå tilbage til standarden. Foot er den ene efternøler: den har ingen måde at genindlæse sin konfiguration på, så kørende terminaler beholder deres gamle størrelse, indtil du åbner en ny.

### Udvidelse og spejling af bærbare skærme

Når du tilslutter en ekstern skærm til din bærbare computer, udvides skærmen automatisk. Men du kan ændre det til spejling i stedet ved hjælp af _Udløs > Hardware_ i Omarchy-menuen eller `Super + Ctrl + Alt + Delete`. Dette er især nyttigt, hvis den eksterne skærm er en projektor, og du vil vise noget, mens du arbejder.

Når du udvider, vil lukning af låget på den bærbare computer automatisk slukke for den interne skærm. Åbning af låget tænder den igen. Du kan også styre dette manuelt ved hjælp af _Udløs > Hardware_ i Omarchy-menuen eller `Super + Ctrl + Delete`.

### Arrangere flere skærme

Hyprland fungerer fantastisk med flere skærme. Læs mere om, hvordan du lægger dem ud, i [dokumentationen om Hyprland-skærme](https://wiki.hypr.land/Configuring/Basics/Monitors/). Du kan også [binde specifikke arbejdsområder til specifikke skærme](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). I Omarchy går disse regler i `~/.config/hypr/monitors.lua` som `hl.monitor`-poster — filen leveres med kommenterede eksempler på at fastgøre en specifik skærm til en opløsning, position og rotation.

Du kan også tjekke [Hyprmon](https://github.com/erans/hyprmon/), hvis du gerne vil have et TUI til at hjælpe dig med positioneringen af flere skærme.

### Styre lysstyrke

Skærmens lysstyrke styres af de dedikerede funktionstaster til lysstyrke op/ned. Hvis du holder shift nede, mens du trykker på disse, går du til maksimal eller minimal lysstyrke. Tasterne styrer den skærm, du er fokuseret på, så eksterne skærme, der taler DDC/CI, justeres på samme måde som den bærbare computers skærm.

### Apple-skærme

Hvis du bruger en Apple-skærm, vil de almindelige tastaturtaster til lysstyrke også automatisk virke, hvis du er fokuseret på Apple-skærmen. Dette gøres gennem kommandoen `asdcontrol`.

Bemærk, at hvis du bruger en Apple 6K XDR-skærm, kan du se en fantomskærm i din `hyprctl monitors`-liste. Du kan slukke for dette med noget som `hl.monitor({ output = "DP-2", disabled = true })` via _Opsætning > Monitors_.

På Intel-maskiner bør du forbinde til Apple-skærme ved hjælp af et almindeligt Thunderbolt-kabel. På andre maskiner uden Thunderbolt skal du typisk bruge et [DP + USB-A -> USB-C kabel](https://www.amazon.com/dp/B0BNX7MS6N) for at få det til at virke.
