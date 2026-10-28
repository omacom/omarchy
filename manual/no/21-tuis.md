# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) er et herlig alternativ til noe som GitHub Desktop-applikasjonen, og det kjører inne i terminalen.

Du kan kjøre det direkte ved å gå til en hvilken som helst mappe som administreres av git og kjøre `lazygit`. Eller du kan kjøre det inne i Neovim, der det kan startes med `Space G G`.

Du hopper mellom de forskjellige rutene med `Tab`. I Files-ruten velger du filer for staging med `Space`, og deretter kan du opprette en ny commit med `c`. Du kan se alle tilgjengelige kommandoer med `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) er en vakker ressursbehandler som viser bruk av minne, CPU, disk og nettverk. Den lister også opp alle aktive prosesser og lar deg administrere dem.

Omarchy kaller den Activity, og du starter den ved å trykke `Super + Shift + T`. Den åpnes som et flytende vindu, som du kan flislegge med `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) er en arbeidsområdebehandler for terminalen som gir deg arbeidsområder, faner og ruter, og holder dem alle kjørende i en vedvarende økt du kan koble fra og komme tilbake til senere.

Du starter den (eller kobler deg til den eksisterende økten din igjen) med `Super + Ctrl + Return`. Omarchy leveres med en Herdr-konfigurasjon som speiler Tmux-konfigurasjonen, så prefiks-tasten er `Ctrl + Space` her også. Du kan bla gjennom alle tastebindingene med `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) viser systeminformasjon, som kjerneversjon, oppetid, tema, CPU, minne og mer. Det er en etterfølger til det populære neofetch-verktøyet.

Omarchy har pakket dette som _About_ i Omarchy-menyen (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) er en retro musikkspiller for terminalen inspirert av Winamp 2.x, komplett med innebygde radiostasjoner for lo-fi beats. Start den med `Super + Shift + Alt + M`, eller fra Omarchy-menyen under _Apps_. Trykk `?` for den fullstendige listen over tastebindinger.

## Hva med Wi-Fi og Bluetooth?

Du finner ingen TUIs for Wi-Fi og Bluetooth — de jobbene tilhører Omarchy-skallet. Klikk på Wi-Fi-ikonet i topplinjen (eller trykk `Super + Ctrl + N`) for å se nettverk og koble til, og klikk på Bluetooth-ikonet (eller trykk `Super + Ctrl + B`) for å pare og koble til enheter. Se [nettverk](35-networking.md) for hele historien.

## Legge til dine egne

Ethvert terminalprogram kan få full app-behandling. Gå til _Install > TUI_ i Omarchy-menyen (`Super + Space`), gi det et navn, en oppstartskommando, en vindusstil og et ikon, så dukker det opp i appstarteren som enhver annen applikasjon. Du kan fjerne det igjen under _Remove > TUI_.
