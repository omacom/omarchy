# Skjermer

Omarchy antar at du som standard kjører på en 2x-kapabel skjerm i retina-klassen. Det er det du trenger for de fine, skarpe programmeringskriftene. Det er det nesten alle nye bærbare datamaskiner av premiumklasse med høyoppløselige skjermer er optimert for. Det er det du vil kjøre på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men hvis du ikke kjører en skjerm med en PPI på 218 eller mer, vil du endre skjerminnstillingene. For eksempel, hvis du har en 27" eller 32" 4K, kan du bruke brøkskalering ved å åpne `~/.config/hypr/monitors.lua` (via _Oppsett > Skjermer_ i Omarchy-menyen) og bytte til anbefalingen for den kombinasjonen:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Hvis du bruker en 1080p- eller 1440p-skjerm, vil du sannsynligvis bare bruke 1x-skalering, så du kan bruke:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Endringer i `GDK_SCALE` gjelder for applikasjoner som startes etter endringen (og GTK respekterer bare hele tall, så hold den på det nærmeste heltallet til skjermskaleringen din). Så sørg for å avslutte vinduene du har som er overdrevne etter endringen (eller lukk alle vinduer med `Ctrl + Alt + Del`!).

Du kan også raskt bla gjennom de viktigste skjermskaleringsforholdene (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` for å gå høyere og `Super + Alt + /` for å gå lavere. Hvis du har standardkonfigurasjonen, vedvarer disse endringene også etter omstart.

### Gjøre tekst større eller mindre

Skjermskalering endrer størrelsen på alt. Hvis alt du vil ha er større eller mindre _tekst_, finnes det én enkelt knott for det:

```
omarchy display text size 14
```

Det tar en pikselstørrelse mellom 9 og 20, og flytter Omarchy-skallet, GTK-applikasjoner og terminalen din sammen, så hele skrivebordet holder seg i proporsjon. Kjør den uten argument for å se hvor du er, og `omarchy display text size reset` for å gå tilbake til standarden. Foot er den ene etternøleren: den har ingen måte å laste konfigurasjonen på nytt, så kjørende terminaler beholder den gamle størrelsen til du åpner en ny.

### Utvide og speile bærbare skjermer

Når du kobler en ekstern skjerm til den bærbare datamaskinen din, utvides visningen automatisk. Men du kan endre den til speiling i stedet med _Utløs > Maskinvare_ i Omarchy-menyen eller `Super + Ctrl + Alt + Delete`. Dette er spesielt nyttig hvis den eksterne skjermen er en prosjektor, og du vil vise noe mens du jobber.

Når du utvider, slås den interne skjermen automatisk av når du lukker lokket på den bærbare. Åpner du lokket, slår den seg på igjen. Du kan også styre dette manuelt med _Utløs > Maskinvare_ i Omarchy-menyen eller `Super + Ctrl + Delete`.

### Arrangere flere skjermer

Hyprland fungerer flott med flere skjermer. Les mer om hvordan du legger dem ut i [Hyprlands skjermdokumentasjon](https://wiki.hypr.land/Configuring/Basics/Monitors/). Du kan også [binde spesifikke arbeidsområder til spesifikke skjermer](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). I Omarchy legges disse reglene i `~/.config/hypr/monitors.lua` som `hl.monitor`-oppføringer — filen leveres med utkommenterte eksempler for å feste en spesifikk skjerm til en oppløsning, posisjon og rotasjon.

Du kan også sjekke ut [Hyprmon](https://github.com/erans/hyprmon/), hvis du vil ha et TUI til å hjelpe deg med posisjoneringen av flere skjermer.

### Styre lysstyrke

Skjermens lysstyrke styres av de dedikerte funksjonstastene for lysstyrke opp/ned. Hvis du holder inne Shift mens du trykker på disse, går du til maksimal eller minimal lysstyrke. Tastene styrer skjermen du er fokusert på, så eksterne skjermer som snakker DDC/CI justeres på samme måte som skjermen på den bærbare.

### Apple-skjermer

Hvis du bruker en Apple-skjerm, fungerer de vanlige tastaturtastene for lysstyrke også automatisk, hvis du er fokusert på Apple-skjermen. Dette gjøres via `asdcontrol`-kommandoen.

Merk at hvis du bruker en Apple 6K XDR-skjerm, kan du se en fantomskjerm i `hyprctl monitors`-oppføringen din. Du kan slå den av med noe som `hl.monitor({ output = "DP-2", disabled = true })` via _Oppsett > Skjermer_.

På Intel-maskiner bør du koble til Apple-skjermer med en vanlig Thunderbolt-kabel. På andre maskiner uten Thunderbolt må du typisk bruke en [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) for å få det til å fungere.
