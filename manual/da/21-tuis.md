# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) er et dejligt alternativ til noget som GitHub Desktop-applikationen, og det kører inde i terminalen.

Du kan køre det direkte ved at gå til en vilkårlig mappe, der administreres af git, og køre `lazygit`. Eller du kan køre det inde i Neovim, hvor det kan startes med `Space G G`.

Du hopper mellem de forskellige ruder ved hjælp af `Tab`. I Files-ruden vælger du filer til staging ved hjælp af `Space`, og derefter kan du oprette et nyt commit ved hjælp af `c`. Du kan se alle de tilgængelige kommandoer ved hjælp af `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) er en smuk ressourcehåndtering, der viser hukommelse, CPU, disk og netværksforbrug. Den viser også alle aktive processer og giver dig mulighed for at administrere dem.

Omarchy kalder den Activity Monitor, og du starter den fra app-starteren eller ved at trykke på `Super + Shift + T`. Den åbner som et flydende vindue, som du kan tile med `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) er en håndtering af arbejdsområder til terminalen, der giver dig arbejdsområder, faner og ruder og holder dem alle kørende i en vedvarende session, du kan koble dig fra og komme tilbage til senere.

Du starter den (eller genopretter forbindelsen til din eksisterende session) fra app-starteren eller med `Super + Ctrl + Return`. Omarchy leveres med en Herdr-konfiguration, der spejler dens Tmux-konfiguration, så præfikstasten er også her `Ctrl + Space`. Du kan gennemse alle tastaturgenvejene med `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) viser systeminformation som kerneversion, oppetid, tema, CPU, hukommelse og mere. Det er en efterfølger til det populære neofetch-værktøj.

Omarchy har pakket dette som _About_ i Omarchy-menuen (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) er en retro musikafspiller til terminalen inspireret af Winamp 2.x, komplet med indbyggede radiostationer til lo-fi beats. Start den med `Super + Shift + Alt + M`, eller fra Omarchy-menuen under _Apps_. Tryk på `?` for den fulde liste over tastaturgenveje.

## Hvad med Wi-Fi og Bluetooth?

Du finder ikke TUIs til Wi-Fi og Bluetooth — de opgaver hører til Omarchy-shellen. Klik på Wi-Fi-ikonet i den øverste bjælke (eller tryk på `Super + Ctrl + N`) for at se netværk og oprette forbindelse, og klik på Bluetooth-ikonet (eller tryk på `Super + Ctrl + B`) for at parre og tilslutte enheder. Se [netværk](35-networking.md) for hele historien.

## Tilføj dine egne

Ethvert terminalprogram kan få den fulde app-behandling. Gå til _Install > TUI_ i Omarchy-menuen (`Super + Space`), giv det et navn, en startkommando, en vinduesstil og et ikon, og så dukker det op i app-starteren ligesom enhver anden applikation. Du kan fjerne det igen under _Remove > TUI_.
