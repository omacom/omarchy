# Skærme

Omarchy antager som standard, at du kører på en skærm i retina-klassen, der klarer 2x. Det er det, du skal bruge for at få de der flotte, skarpe programmørskrifttyper. Det er det, næsten alle nye premium-laptops med højtopløselige skærme er optimeret til. Det er det, du vil køre på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men hvis du ikke kører en skærm med en PPI på 218 eller derover, vil du gerne ændre skærmindstillingerne. Hvis du for eksempel har en 27" eller 32" 4K, kan du vælge en brøkskalering til den fra skærmpanelet i topbjælken eller indstille standarden for alle skærme ved at åbne `~/.config/hypr/monitors.lua` og skifte til anbefalingen for den kombination:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Hvis du bruger en 1080p- eller 1440p-skærm, vil du sandsynligvis bare bruge 1x-skalering, og det samme for GTK- og X11-apps, så du kan bruge:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Ændringer af `GDK_SCALE` gælder for applikationer, der startes efter ændringen (og GTK respekterer kun hele tal, så hold den på det nærmeste heltal af din skærmskalering). Så sørg for at lukke de vinduer, du har, som er for store efter ændringen (eller luk alle vinduer med `Ctrl + Alt + Del`!).

Du kan også hurtigt træde gennem de vigtigste skærmskaleringsforhold (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` for at gå højere og `Super + Alt + /` for at gå lavere eller vælge et fra skærmpanelet i topbjælken. Disse ændrer kun den skærm, du er fokuseret på, så en laptopskærm og en ekstern skærm kan hver have deres egen skalering. Panelet indstiller også hver skærms opløsning. Dine valg gemmes for den fysiske skærm i `~/.local/state/omarchy/monitors/settings`, så de overlever en genstart og følger skærmen til den port eller dock, den tilsluttes næste gang. De har forrang over enhver regel for den samme skærm i `~/.config/hypr/monitors.lua`, som Omarchy aldrig redigerer. Da `GDK_SCALE` er én værdi for alle skærme, sætter en valgt skalering den ud fra skærmen med den laveste skalering, så X11-apps bliver en smule små på den tættere skærm frem for for store på den anden.

### Sådan gør du tekst større eller mindre

Skærmskalering ændrer størrelsen på alting. Hvis alt, du ønsker, er større eller mindre _tekst_, er der en enkelt knap til det:

```
omarchy display text size 14
```

Den tager en pixelstørrelse mellem 9 og 20 og flytter Omarchy-shellen, GTK-applikationer og din terminal sammen, så hele skrivebordet forbliver i proportion. Kør den uden et argument for at se, hvor du er, og `omarchy display text size reset` for at gå tilbage til standarden. Foot er den ene efternøler: den har ingen måde at genindlæse sin konfiguration på, så kørende terminaler beholder deres gamle størrelse, indtil du åbner en ny.

### Udvidelse og spejling af laptopskærme

Når du tilslutter en ekstern skærm til din laptop, udvides skærmen automatisk. Men du kan ændre det til spejling i stedet ved at bruge _Trigger > Hardware_ i Omarchy-menuen eller `Super + Ctrl + Alt + Delete`. Det er især nyttigt, hvis den eksterne skærm er en projektor, og du vil vise noget, mens du arbejder.

Når du udvider, slukker det automatisk for den interne skærm at lukke låget på laptopen. Åbner du låget, tænder den igen. Du kan også styre det manuelt ved at bruge _Trigger > Hardware_ i Omarchy-menuen eller `Super + Ctrl + Delete`.

### Arrangering af flere skærme

Hyprland fungerer godt med flere skærme. Skærmpanelet i topbjælken tegner dem, hvor de sidder: træk en mod siden af en anden for at flytte den dertil, og arrangementet gemmes sammen med hver skærms øvrige indstillinger. Til alt det, panelet ikke dækker, kan du læse mere om, hvordan du lægger dem ud, i [dokumentationen til Hyprland-skærme](https://wiki.hypr.land/Configuring/Basics/Monitors/). I Omarchy hører disse hjemme i `~/.config/hypr/monitors.lua` som `hl.monitor`-poster — filen leveres med kommenterede eksempler på at fastlåse en bestemt skærm til en opløsning, position og rotation.

Hver skærm har sine egne arbejdsområder 1 til 10, så `Super + 1` altid betyder det første arbejdsområde på den skærm, du er på. Bag kulisserne nummererer Hyprland stadig arbejdsområder på tværs af alle skærme: din laptopskærm (eller første skærm) får 1–10, den næste skærm 11–20 og så videre, og hver skærm beholder sin blok, hver gang du tilslutter den. Brug de numre, hvis du skriver [regler for arbejdsområder](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eller vinduesregler for en bestemt skærm, så arbejdsområde 12 er det andet arbejdsområde på din anden skærm. `~/.local/state/omarchy/monitors/workspaces` viser, hvilken blok hver skærm har.

Piletasterne virker på tværs af skærme, der deler en kant i dit layout. Skærme, der kun rører hinanden i et hjørne, eller som har et mellemrum mellem sig, er ikke naboer, så brug `Ctrl + Alt + Tab` for at komme mellem dem.

| Genvejstast | På tværs af skærme |
| --- | --- |
| `Super + Arrow` | Flytter fokus til skærmen på den side, når der ikke er flere vinduer tilbage i den retning |
| `Super + Shift + Arrow` | Bytter med et vindue på skærmen på den side |
| `Super + Alt + Arrow` | Flytter vinduet ind i en gruppe på skærmen på den side |
| `Super + Shift + Ctrl + Arrow` | Flytter vinduet til skærmen på den side, til det arbejdsområde, den viser |
| `Super + Shift + Alt + Arrow` | Flytter arbejdsområdet til skærmen på den side og beholder dets nummer, hvis det er ledigt |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Flytter fokus til den næste eller forrige skærm, uanset layoutet |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Bliver på den skærm, du er på |

Du kan også tjekke [Hyprmon](https://github.com/erans/hyprmon/), hvis du gerne vil have en TUI til at hjælpe dig med placeringen af flere skærme.

### Styring af lysstyrke

Skærmens lysstyrke styres med de dedikerede funktionstaster for lysstyrke op/ned. Hvis du holder Shift nede, mens du trykker på disse, går du til maksimal eller minimal lysstyrke. Tasterne styrer den skærm, du er fokuseret på, så eksterne skærme, der taler DDC/CI, justeres på samme måde som laptopskærmen.

### Apple-skærme

Hvis du bruger en Apple-skærm, fungerer de almindelige lysstyrketaster på tastaturet også automatisk, hvis du er fokuseret på Apple-skærmen. Det sker via kommandoen `asdcontrol`.

Bemærk, at hvis du bruger en Apple 6K XDR-skærm, kan du se en fantomskærm i din oversigt fra `hyprctl monitors`. Du kan slå den fra med noget som `hl.monitor({ output = "DP-2", disabled = true })` i `~/.config/hypr/monitors.lua`.

På Intel-maskiner bør du tilslutte Apple-skærme med et almindeligt Thunderbolt-kabel. På andre maskiner uden Thunderbolt skal du typisk bruge et [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) for at få det til at fungere.
