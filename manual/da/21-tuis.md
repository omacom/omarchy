# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) er et herligt alternativ til noget som GitHub Desktop-applikationen, og det kører inde i terminalen.

Du kan køre det direkte ved at gå til en vilkårlig mappe, der administreres af git, og køre `lazygit`. Eller du kan køre det inde i Neovim, hvor det kan startes med `Space G G`.

Du hopper mellem de forskellige paneler med `Tab`. I Files-panelet vælger du filer til staging med `Space`, og derefter kan du oprette en ny commit med `c`. Du kan se alle de tilgængelige kommandoer med `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) er en smuk ressourcehåndtering, der viser hukommelse, CPU, disk og netværksforbrug. Den viser også alle aktive processer og giver dig mulighed for at administrere dem.

Omarchy kalder den Activity Monitor, og du starter den fra app-launcheren eller ved at trykke på `Super + Shift + T`. Den åbner som et flydende vindue, som du kan tile med `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) er en terminal workspace manager, der giver dig workspaces, tabs og panes og holder dem alle kørende i en vedvarende session, du kan detach fra og vende tilbage til senere.

Du starter den (eller reattacher til din eksisterende session) med `Super + Ctrl + Return`. Omarchy leverer en Herdr-konfiguration, der spejler dets Tmux config, så prefix-tasten også er `Ctrl + Space` her. Du kan gennemse alle keybindings med `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) viser systeminformation som kerneversion, uptime, tema, CPU, hukommelse og mere. Det er en efterfølger til det populære neofetch-værktøj.

Omarchy har pakket dette som _About_ i Omarchy-menuen (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) er en retro terminal musikafspiller inspireret af Winamp 2.x, komplet med indbyggede radiostationer til lo-fi beats. Start den med `Super + Shift + Alt + M`, eller fra Omarchy-menuen under _Apps_. Tryk på `?` for den fulde liste over keybindings.

## Hvad med Wi-Fi og Bluetooth?

Du finder ikke TUIs til Wi-Fi og Bluetooth — de opgaver tilhører Omarchy-skallen. Klik på Wi-Fi-ikonet i den øverste bjælke (eller tryk på `Super + Ctrl + N`) for at se netværk og oprette forbindelse, og klik på Bluetooth-ikonet (eller tryk på `Super + Ctrl + B`) for at parre og forbinde enheder. Se [netværk](35-networking.md) for hele historien.

## Tilføj dine egne

Ethvert terminalprogram kan få den fulde app-behandling. Gå til _Install > TUI_ i Omarchy-menuen (`Super + Space`), giv det et navn, en launch-kommando, en vinduesstil og et ikon, og det dukker op i app-launcheren som enhver anden applikation. Du kan fjerne det igen under _Remove > TUI_.
