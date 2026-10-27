# Skærme

Omarchy antager som standard, at du kører på en 2x-kompatibel skærm i retina-klassen. Det er det, du skal bruge for at få de lækre, skarpe programmeringsfonte. Det er det, næsten alle nye premium-bærbare med højtopløselige skærme er optimeret til. Det er det, du vil køre på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men hvis du ikke kører en skærm med en PPI på 218 eller derover, vil du gerne ændre skærmindstillingerne. Hvis du for eksempel har en 27" eller 32" 4K, kan du bruge fraktioneret skalering ved at åbne `~/.config/hypr/monitors.lua` (via _Setup > Monitors_ i Omarchy-menuen) og skifte til anbefalingen for den kombination:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Hvis du bruger en 1080p- eller 1440p-skærm, vil du sandsynligvis bare bruge 1x-skalering, så du kan bruge:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Ændringer af `GDK_SCALE` gælder for programmer, der startes efter ændringen (og GTK accepterer kun hele tal, så hold den på det nærmeste hele tal i forhold til din skærmskalering). Så sørg for at lukke de vinduer, du har åbne, som er for store efter ændringen (eller luk alle vinduer med `Ctrl + Alt + Del`!).

Du kan også hurtigt træde gennem de vigtigste skærmskaleringsforhold (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` for at gå op og `Super + Alt + /` for at gå ned. Hvis du har standardkonfigurationen, vil disse ændringer også blive bevaret efter en genstart.

### Sådan gør du teksten større eller mindre

Skærmskalering ændrer størrelsen på alt. Hvis du kun vil have større eller mindre _tekst_, findes der en enkelt knap til det:

```
omarchy display text size 14
```

Den tager en pixelstørrelse mellem 9 og 20 og flytter Omarchy-skallen, GTK-programmer og din terminal sammen, så hele skrivebordet forbliver i proportion. Kør den uden et argument for at se, hvor du er, og `omarchy display text size reset` for at vende tilbage til standarden. Foot er den ene efternøler: Den har ingen måde at genindlæse sin konfiguration på, så kørende terminaler beholder deres gamle størrelse, indtil du åbner en ny.

### Udvidelse og spejling af bærbare skærme

Når du tilslutter en ekstern skærm til din bærbare, udvides skærmen automatisk. Men du kan ændre det til spejling i stedet via _Trigger > Hardware_ i Omarchy-menuen eller `Super + Ctrl + Alt + Delete`. Det er især nyttigt, hvis den eksterne skærm er en projektor, og du vil vise noget, mens du arbejder.

Når du udvider, slukkes den interne skærm automatisk, når du lukker låget på den bærbare. Når du åbner låget, tændes den igen. Du kan også styre det manuelt via _Trigger > Hardware_ i Omarchy-menuen eller `Super + Ctrl + Delete`.

### Opsætning af flere skærme

Hyprland fungerer fremragende med flere skærme. Læs mere om, hvordan du lægger dem ud, i [Hyprlands dokumentation om skærme](https://wiki.hypr.land/Configuring/Basics/Monitors/). I Omarchy hører de hjemme i `~/.config/hypr/monitors.lua` som `hl.monitor`-poster — filen leveres med udkommenterede eksempler på at fastgøre en bestemt skærm til en opløsning, position og rotation.

Hver skærm har sine egne arbejdsområder 1 til 10, så `Super + 1` altid betyder det første arbejdsområde på den skærm, du befinder dig på. Bag kulisserne nummererer Hyprland stadig arbejdsområder på tværs af alle skærme: Din bærbare skærm (eller første skærm) får 1–10, den næste skærm 11–20 og så videre, og hver skærm beholder sin blok, hver gang du tilslutter den. Brug de numre, hvis du skriver [regler for arbejdsområder](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eller vinduesregler for en bestemt skærm, så arbejdsområde 12 er det andet arbejdsområde på din anden skærm. `~/.local/state/omarchy/monitor-workspaces` viser, hvilken blok hver skærm har.

Piletasterne fungerer på tværs af skærme, der deler en kant i dit layout. Skærme, der kun rører hinanden ved et hjørne, eller som har et mellemrum mellem sig, er ikke naboer, så brug `Ctrl + Alt + Tab` til at komme mellem dem.

| Hotkey | På tværs af skærme |
| --- | --- |
| `Super + Arrow` | Flytter fokus til skærmen på den side, når der ikke er flere vinduer tilbage i den retning |
| `Super + Shift + Arrow` | Bytter med et vindue på skærmen på den side |
| `Super + Alt + Arrow` | Flytter vinduet ind i en gruppe på skærmen på den side |
| `Super + Shift + Ctrl + Arrow` | Flytter vinduet til skærmen på den side, til det arbejdsområde, den viser |
| `Super + Shift + Alt + Arrow` | Flytter arbejdsområdet til skærmen på den side og beholder dets nummer, hvis det er ledigt |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Flytter fokus til den næste eller forrige skærm, uanset layoutet |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Bliver på den skærm, du befinder dig på |

Du kan også tjekke [Hyprmon](https://github.com/erans/hyprmon/), hvis du gerne vil have en TUI til at hjælpe dig med placeringen af flere skærme.

### Styring af lysstyrke

Skærmens lysstyrke styres med de dedikerede funktionstaster til lysstyrke op/ned. Hvis du holder shift nede, mens du trykker på dem, går du til maksimal eller minimal lysstyrke. Tasterne styrer den skærm, du har fokus på, så eksterne skærme, der taler DDC/CI, justeres på samme måde som den bærbare skærm.

### Apple-skærme

Hvis du bruger en Apple-skærm, vil de almindelige lysstyrketaster på tastaturet også automatisk fungere, hvis du har fokus på Apple-skærmen. Det sker via kommandoen `asdcontrol`.

Bemærk, at hvis du bruger en Apple 6K XDR-skærm, kan du se en fantomskærm i din `hyprctl monitors`-liste. Du kan slå den fra med noget som `hl.monitor({ output = "DP-2", disabled = true })` via _Setup > Monitors_.

På Intel-maskiner bør du tilslutte Apple-skærme med et almindeligt Thunderbolt-kabel. På andre maskiner uden Thunderbolt skal du typisk bruge et [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) for at få det til at fungere.
