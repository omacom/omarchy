# Skjermer

Omarchy forutsetter som standard at du kjører på en retina-klasse-skjerm med støtte for 2x. Det er det du trenger for å få de fine, skarpe programmeringsfontene. Det er det nesten alle nye premium-bærbare med høyoppløselige skjermer er optimalisert for. Det er det du vil kjøre på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men hvis du ikke kjører en skjerm med en PPI på 218 eller høyere, vil du endre skjerminnstillingene. Hvis du for eksempel har en 27" eller 32" 4K, kan du bruke fraksjonell skalering ved å åpne `~/.config/hypr/monitors.lua` (via _Oppsett > Skjermer_ i Omarchy-menyen) og bytte til anbefalingen for den kombinasjonen:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Hvis du bruker en 1080p- eller 1440p-skjerm, vil du sannsynligvis bare bruke 1x-skalering, så du kan bruke:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Endringer i `GDK_SCALE` gjelder for applikasjoner som startes etter endringen (og GTK respekterer bare hele tall, så hold den på nærmeste heltall av skjermskaleringen din). Så pass på at du avslutter vinduene du har som er for store etter endringen (eller lukk alle vinduer med `Ctrl + Alt + Del`!).

Du kan også raskt gå gjennom de viktigste skaleringene for skjermer (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` for å gå høyere og `Super + Alt + /` for å gå lavere, eller velge en fra skjermpanelet i topplinjen. Disse endrer bare skjermen du har fokus på, så en bærbar-skjerm og en ekstern skjerm kan hver ha sin egen skalering. Valget lagres i `~/.config/hypr/monitors.lua` som en `hl.monitor`-regel for den skjermen, så det varer over omstart og går foran `omarchy_monitor_scale`, som forblir skaleringen for hver skjerm uten en egen regel. Siden `GDK_SCALE` er én verdi for alle skjermer, setter disse endringene den ut fra skjermen med lavest skalering, så X11-apper blir litt små på den tettere skjermen i stedet for for store på den andre.

### Gjør teksten større eller mindre

Skjermskalering endrer størrelsen på alt. Hvis du bare vil ha større eller mindre _tekst_, finnes det én enkelt bryter for det:

```
omarchy display text size 14
```

Det tar en pikselstørrelse mellom 9 og 20, og flytter Omarchy-skallet, GTK-applikasjoner og terminalen din sammen, slik at hele skrivebordet holder seg i proporsjon. Kjør den uten argument for å se hvor du ligger, og `omarchy display text size reset` for å gå tilbake til standarden. Foot er den ene etternøleren: den har ingen måte å laste inn konfigurasjonen sin på nytt, så terminaler som kjører, beholder den gamle størrelsen til du åpner en ny.

### Utvide og speile skjermer på bærbare

Når du kobler en ekstern skjerm til den bærbare, utvides skjermen automatisk. Men du kan endre det til speiling i stedet via _Utløser > Maskinvare_ i Omarchy-menyen eller `Super + Ctrl + Alt + Delete`. Dette er spesielt nyttig hvis den eksterne skjermen er en projektor, og du vil vise noe mens du jobber.

Når du utvider, slår det å lukke lokket på den bærbare automatisk av den interne skjermen. Å åpne lokket slår den på igjen. Du kan også styre dette manuelt via _Utløser > Maskinvare_ i Omarchy-menyen eller `Super + Ctrl + Delete`.

### Ordne flere skjermer

Hyprland fungerer utmerket med flere skjermer. Les mer om hvordan du legger dem ut i [Hyprland-dokumentasjonen for skjermer](https://wiki.hypr.land/Configuring/Basics/Monitors/). I Omarchy legges disse i `~/.config/hypr/monitors.lua` som `hl.monitor`-oppføringer — filen leveres med utkommenterte eksempler for å feste en bestemt skjerm til en oppløsning, posisjon og rotasjon.

Hver skjerm har sine egne arbeidsområder 1 til 10, så `Super + 1` betyr alltid det første arbeidsområdet på skjermen du er på. Bak kulissene nummererer Hyprland fortsatt arbeidsområder på tvers av alle skjermer: den bærbare skjermen din (eller den første skjermen) får 1–10, den neste skjermen 11–20, og så videre, og hver skjerm beholder blokken sin hver gang du kobler den til. Bruk de numrene hvis du skriver [regler for arbeidsområder](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eller vindusregler for en bestemt skjerm, så arbeidsområde 12 er det andre arbeidsområdet på den andre skjermen din. `~/.local/state/omarchy/monitor-workspaces` lister opp hvilken blokk hver skjerm har.

Piltastene fungerer på tvers av skjermer som deler en kant i oppsettet ditt. Skjermer som bare berører hverandre i et hjørne, eller som har et gap mellom seg, er ikke naboer, så bruk `Ctrl + Alt + Tab` for å komme mellom dem.

| Hurtigtast | På tvers av skjermer |
| --- | --- |
| `Super + Arrow` | Flytter fokus til skjermen på den siden når det ikke er noe vindu igjen i den retningen |
| `Super + Shift + Arrow` | Bytter med et vindu på skjermen på den siden |
| `Super + Alt + Arrow` | Flytter vinduet inn i en gruppe på skjermen på den siden |
| `Super + Shift + Ctrl + Arrow` | Flytter vinduet til skjermen på den siden, til arbeidsområdet den viser |
| `Super + Shift + Alt + Arrow` | Flytter arbeidsområdet til skjermen på den siden, og beholder nummeret hvis det er ledig |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Flytter fokus til neste eller forrige skjerm, uansett oppsett |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Blir på skjermen du er på |

Du kan også sjekke ut [Hyprmon](https://github.com/erans/hyprmon/), hvis du vil ha en TUI som hjelper deg med plasseringen av flere skjermer.

### Styre lysstyrken

Skjermens lysstyrke styres med de dedikerte funksjonstastene for lysstyrke opp/ned. Hvis du holder Shift nede mens du trykker på disse, går du til maksimal eller minimal lysstyrke. Tastene styrer skjermen du har fokus på, så eksterne skjermer som snakker DDC/CI justeres på samme måte som den bærbare skjermen.

### Apple-skjermer

Hvis du bruker en Apple-skjerm, vil de vanlige lysstyrketastene på tastaturet også automatisk fungere, hvis du har fokus på Apple-skjermen. Dette gjøres gjennom `asdcontrol`-kommandoen.

Merk at hvis du bruker en Apple 6K XDR-skjerm, kan du se en fantomskjerm i `hyprctl monitors`-listen din. Du kan slå dette av med noe slikt som `hl.monitor({ output = "DP-2", disabled = true })` via _Oppsett > Skjermer_.

På Intel-maskiner bør du koble til Apple-skjermer med en vanlig Thunderbolt-kabel. På andre maskiner uten Thunderbolt må du vanligvis bruke en [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) for å få det til å fungere.
