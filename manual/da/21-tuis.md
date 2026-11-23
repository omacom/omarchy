# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) er et dejligt alternativ til noget som GitHub Desktop-applikationen, og det kører inde i terminalen.

Du kan køre det direkte ved at gå til en hvilken som helst mappe, der administreres af git, og køre `lazygit`. Eller du kan køre det inde i Neovim, hvor det kan startes med `Space G G`.

Du hopper mellem de forskellige paneler med `Tab`. I panelet Files vælger du filer til staging med `Space`, og derefter kan du oprette et nyt commit med `c`. Du kan se alle de tilgængelige kommandoer med `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) er en smuk ressourcehåndtering, der viser forbrug af hukommelse, CPU, disk og netværk. Den viser også alle aktive processer og lader dig administrere dem.

Omarchy kalder den Activity Monitor, og du starter den fra appstarteren eller ved at trykke på `Super + Shift + T`. Den åbner som et flydende vindue, som du kan lægge som flise med `Super + T`.

## Herdr

[Herdr](https://herdr.dev) er en arbejdsområdehåndtering til terminalen, der giver dig arbejdsområder, faner og paneler og holder dem alle kørende i en vedvarende session, du kan koble fra og vende tilbage til senere.

Du starter den (eller genopretter forbindelsen til din eksisterende session) fra appstarteren eller med `Super + Ctrl + Return`. Omarchy leverer en Herdr-konfiguration, der spejler dens Tmux-konfiguration, så prefix-tasten også her er `Ctrl + Space`. Du kan gennemse alle tastebindingerne med `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) viser systemoplysninger som kerneversion, oppetid, tema, CPU, hukommelse og mere. Det er en efterfølger til det populære neofetch-værktøj.

Omarchy har pakket dette som _System > Om_ i Omarchy-menuen (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) er en retro musikafspiller til terminalen inspireret af Winamp 2.x, komplet med indbyggede radiostationer til lo-fi-beats. Start den med `Super + Shift + Alt + M` eller fra Omarchy-menuen under _Apps_. Tryk på `?` for at få den fulde liste over tastebindinger.

## Hvad med Wi-Fi og Bluetooth?

Du finder ikke TUIs til Wi-Fi og Bluetooth — de opgaver tilhører Omarchy-skallen. Klik på Wi-Fi-ikonet i den øverste bjælke (eller tryk på `Super + Ctrl + N`) for at se netværk og oprette forbindelse, og klik på Bluetooth-ikonet (eller tryk på `Super + Ctrl + B`) for at parre og tilslutte enheder. Se [netværk](35-networking.md) for hele historien.

## Tilføj dine egne

Ethvert terminalprogram kan få den fulde app-behandling. Gå til _Installer > TUI_ i Omarchy-menuen (`Super + Space`), giv det et navn, en startkommando, en vinduesstil og et ikon, og så dukker det op i appstarteren ligesom enhver anden applikation. Du kan fjerne det igen under _Fjern > TUI_.
