# TUI'er

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) er et dejligt alternativ til noget som GitHub Desktop-applikationen, og det kører inde i terminalen.

Du kan køre det direkte ved at gå til en vilkårlig mappe, der administreres af git, og køre `lazygit`. Eller du kan køre det inde i Neovim, hvor det kan startes med `Space G G`.

Du hopper mellem de forskellige ruder ved hjælp af `Tab`. I ruden Files vælger du filer til staging ved hjælp af `Space`, og derefter kan du oprette et nyt commit ved hjælp af `c`. Du kan se alle de tilgængelige kommandoer ved hjælp af `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) er en smuk ressourcehåndtering, der viser hukommelse, CPU, disk og netværksforbrug. Den viser også alle aktive processer og lader dig administrere dem.

Omarchy kalder det Activity, og du starter det ved at trykke på `Super + Ctrl + T`. Det åbner som et flydende vindue, som du kan fliselægge med `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) er en terminal-arbejdsområdehåndtering, der giver dig arbejdsområder, faner og ruder og holder dem alle kørende i en vedvarende session, som du kan koble fra og komme tilbage til senere.

Du starter det (eller genkobler til din eksisterende session) med `Super + Ctrl + Return`. Omarchy leverer en Herdr-konfiguration, der spejler dets Tmux-konfiguration, så præfikstasten også her er `Ctrl + Space`. Du kan gennemse alle tastaturgenvejene med `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) viser systeminformation, som kerneversion, oppetid, tema, CPU, hukommelse og mere. Det er en efterfølger til det populære neofetch-værktøj.

Omarchy har pakket dette som _Om_ i Omarchy-menuen (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) er en retro terminalmusikafspiller inspireret af Winamp 2.x, komplet med indbyggede radiostationer til lo-fi beats. Start den med `Super + Shift + Alt + M` eller fra Omarchy-menuen under _Apps_. Tryk på `?` for den fulde liste over tastaturgenveje.

## Hvad med Wi-Fi og Bluetooth?

Du finder ingen TUI'er til Wi-Fi og Bluetooth — de opgaver tilhører Omarchy-skallen. Klik på Wi-Fi-ikonet i menulinjen (eller tryk på `Super + Ctrl + W`) for at se netværk og oprette forbindelse, og klik på Bluetooth-ikonet (eller tryk på `Super + Ctrl + B`) for at parre og oprette forbindelse til enheder. Se [netværk](35-networking.md) for hele historien.

## Tilføj dine egne

Ethvert terminalprogram kan få den fulde app-behandling. Gå til _Installer > TUI_ i Omarchy-menuen (`Super + Space`), giv det et navn, en startkommando, en vinduesstil og et ikon, og det vil dukke op i app-starteren som enhver anden applikation. Du kan fjerne det igen under _Fjern > TUI_.
