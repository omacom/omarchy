# Skjermer

Omarchy forutsetter som standard at du bruker en 2x-kapabel skjerm i retina-klassen. Det er det du trenger for å få de fine, skarpe programmeringsfontene. Det er det nesten alle nye premium-bærbare med høyoppløselige skjermer er optimalisert for. Det er det du vil bruke på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men hvis du ikke bruker en skjerm med en PPI på 218 eller høyere, bør du endre skjerminnstillingene. Hvis du for eksempel har en 27" eller 32" 4K, kan du velge en brøkskalering for den fra skjermpanelet i topplinjen, eller angi standarden for hver skjerm ved å åpne `~/.config/hypr/monitors.lua` og bytte til anbefalingen for den kombinasjonen:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Hvis du bruker en 1080p- eller 1440p-skjerm, vil du sannsynligvis bare bruke 1x-skalering, og det samme for GTK- og X11-apper, så du kan bruke:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Endringer i `GDK_SCALE` gjelder for applikasjoner som startes etter endringen (og GTK godtar bare hele tall, så hold den på nærmeste heltall av skjermskaleringen din). Så sørg for at du avslutter vinduene du har som er for store etter endringen (eller lukk alle vinduer med `Ctrl + Alt + Del`!).

Du kan også raskt gå gjennom de viktigste skaleringene for skjermer (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` for å gå høyere og `Super + Alt + /` for å gå lavere, eller velge en fra skjermpanelet i topplinjen. Disse endrer bare skjermen du har fokus på, så en bærbar skjerm og en ekstern skjerm kan hver ha sin egen skalering. Panelet angir også hver skjerms oppløsning, oppdateringsfrekvens og rotasjon. Valgene dine lagres for den fysiske skjermen i `~/.local/state/omarchy/monitors/settings`, så de overlever omstart og følger skjermen til uansett hvilken port eller dokk den kobles til neste gang. De har forrang over enhver regel for samme skjerm i `~/.config/hypr/monitors.lua`, som Omarchy aldri redigerer. Hvis du heller vil angi skjermene dine helt i den filen, legger du til `omarchy_monitor_panel_settings = false` i den, og panelets endringer varer bare til Hyprland lastes inn på nytt. Siden `GDK_SCALE` er én verdi for alle skjermer, setter en valgt skalering den fra skjermen med lavest skalering, så X11-apper blir litt små på den tettere skjermen i stedet for for store på den andre.

### Gjøre tekst større eller mindre

Skjermskalering endrer størrelsen på alt. Hvis alt du vil ha er større eller mindre _tekst_, finnes det én enkelt bryter for det:

```
omarchy display text size 14
```

Den tar en pikselstørrelse mellom 9 og 20, og flytter Omarchy-skallet, GTK-applikasjoner og terminalen din sammen, så hele skrivebordet holder seg proporsjonalt. Kjør den uten argument for å se hvor du ligger, og `omarchy display text size reset` for å gå tilbake til standarden. Foot er den ene etternøleren: den har ingen måte å laste inn konfigurasjonen sin på nytt på, så terminaler som kjører, beholder den gamle størrelsen til du åpner en ny.

### Utvide og speile skjermer på den bærbare

Når du kobler en ekstern skjerm til den bærbare PC-en din, utvides skjermen automatisk. Men du kan endre det til speiling i stedet med _Utvid_ | _Speil_ i skjermpanelet i topplinjen, _Trigger > Hardware_ i Omarchy-menyen, eller `Super + Ctrl + Alt + Delete`. Dette er spesielt nyttig hvis den eksterne skjermen er en projektor, og du vil vise noe mens du jobber.

Når du utvider, slår du automatisk av den interne skjermen når du lukker lokket på den bærbare. Når du åpner lokket, slås den på igjen. Du kan også styre dette manuelt med _Trigger > Hardware_ i Omarchy-menyen eller `Super + Ctrl + Delete`.

Mens den bærbare er koblet til strøm, setter den seg aldri i dvale når du lukker lokket, så en dokket bærbar holder seg våken selv om den eksterne skjermen kobles fra et øyeblikk. Uten noen ekstern skjerm tilkoblet låser den seg bare når du lukker lokket på strøm. På batteri hviler den som vanlig når du lukker lokket.

### Arrangere flere skjermer

Hyprland fungerer flott med flere skjermer. Skjermpanelet i topplinjen tegner dem der de står: dra en mot siden av en annen for å flytte den dit, og arrangementet lagres sammen med hver skjerms andre innstillinger. For alt panelet ikke dekker, kan du lese mer om hvordan du legger dem ut i [Hyprland-dokumentasjonen for skjermer](https://wiki.hypr.land/Configuring/Basics/Monitors/). I Omarchy legges disse i `~/.config/hypr/monitors.lua` som `hl.monitor`-oppføringer — filen leveres med kommenterte eksempler for å holde en skjerm av, moduser panelet ikke tilbyr, 10-bit farge og variabel oppdateringsfrekvens.

Hver skjerm har sine egne arbeidsområder 1 til 10, så `Super + 1` betyr alltid det første arbeidsområdet på skjermen du er på. Bak kulissene nummererer Hyprland fortsatt arbeidsområder på tvers av alle skjermer: skjermen på den bærbare (eller første skjerm) får 1–10, neste skjerm 11–20, og så videre, og hver skjerm beholder blokken sin hver gang du kobler den til. Bruk disse numrene hvis du skriver [regler for arbeidsområder](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eller vindusregler for en bestemt skjerm, så arbeidsområde 12 er det andre arbeidsområdet på den andre skjermen din. `~/.local/state/omarchy/monitors/workspaces` lister hvilken blokk hver skjerm har.

Piltastene fungerer på tvers av skjermer som deler en kant i oppsettet ditt. Skjermer som bare berører hverandre i et hjørne, eller som har et gap mellom seg, er ikke naboer, så bruk `Ctrl + Alt + Tab` for å komme mellom dem.

| Hurtigtast | På tvers av skjermer |
| --- | --- |
| `Super + Arrow` | Flytter fokus til skjermen på den siden når det ikke er flere vinduer igjen i den retningen |
| `Super + Shift + Arrow` | Bytter med et vindu på skjermen på den siden |
| `Super + Alt + Arrow` | Flytter vinduet inn i en gruppe på skjermen på den siden |
| `Super + Shift + Ctrl + Arrow` | Flytter vinduet til skjermen på den siden, til arbeidsområdet den viser |
| `Super + Shift + Alt + Arrow` | Flytter arbeidsområdet til skjermen på den siden, og beholder nummeret hvis det er ledig |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Flytter fokus til neste eller forrige skjerm, uansett oppsett |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Blir på skjermen du er på |

Du kan også sjekke ut [Hyprmon](https://github.com/erans/hyprmon/), hvis du vil ha et TUI til å hjelpe deg med plasseringen av flere skjermer.

### Styre lysstyrke

Skjermens lysstyrke styres av de dedikerte funksjonstastene for lysstyrke opp/ned. Hvis du holder nede shift mens du trykker på disse, går du til maksimal eller minimal lysstyrke. Tastene styrer skjermen du har fokus på, så eksterne skjermer som snakker DDC/CI justeres på samme måte som skjermen på den bærbare.

### Apple-skjermer

Hvis du bruker en Apple-skjerm, vil de vanlige lysstyrketastene på tastaturet også automatisk fungere, hvis du har fokus på Apple-skjermen. Dette gjøres gjennom `asdcontrol`-kommandoen.

Merk at hvis du bruker en Apple 6K XDR-skjerm, kan du se en fantomskjerm i `hyprctl monitors`-listen din. Du kan slå denne av med noe sånt som `hl.monitor({ output = "DP-2", disabled = true })` i `~/.config/hypr/monitors.lua`.

På Intel-maskiner bør du koble til Apple-skjermer med en vanlig Thunderbolt-kabel. På andre maskiner uten Thunderbolt må du vanligvis bruke en [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) for å få det til å fungere.
