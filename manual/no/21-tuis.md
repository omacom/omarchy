# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) er et herlig alternativ til noe sånt som GitHub Desktop-applikasjonen, og det kjører inne i terminalen.

Du kan kjøre det direkte, ved å gå til en hvilken som helst mappe som administreres av git og kjøre `lazygit`. Eller du kan kjøre det inne i Neovim, der det kan startes med `Space G G`.

Du hopper mellom de ulike panelene med `Tab`. I Files-panelet velger du filer for staging med `Space`, og deretter kan du opprette en ny commit med `c`. Du kan se alle tilgjengelige kommandoer med `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) er en vakker ressursbehandler som viser minne, CPU, disk og nettverksbruk. Den lister også opp alle aktive prosesser, og lar deg administrere dem.

Omarchy kaller den Activity Monitor, og du starter den fra appstarteren eller ved å trykke `Super + Shift + T`. Den åpnes som et flytende vindu, som du kan tile med `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) er en terminalbasert arbeidsområdebehandler som gir deg arbeidsområder, faner og paneler, og holder dem alle kjørende i en vedvarende økt du kan koble fra og komme tilbake til senere.

Du starter den (eller kobler deg tilbake til den eksisterende økten din) fra appstarteren eller med `Super + Ctrl + Return`. Omarchy leverer en Herdr-konfigurasjon som speiler Tmux-konfigurasjonen sin, så prefikstasten er `Ctrl + Space` her også. Du kan bla gjennom alle tastatursnarveiene med `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) viser systeminformasjon, som kjerneversjon, oppetid, tema, CPU, minne og mer. Det er en etterfølger til det populære neofetch-verktøyet.

Omarchy har pakket dette som _System > Om_ i Omarchy-menyen (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) er en retro terminalmusikkspiller inspirert av Winamp 2.x, komplett med innebygde radiostasjoner for lo-fi beats. Start den med `Super + Shift + Alt + M`, eller fra Omarchy-menyen under _Apper_. Trykk `?` for den fullstendige listen over tastatursnarveier.

## Hva med Wi-Fi og Bluetooth?

Du finner ingen TUIs for Wi-Fi og Bluetooth — de jobbene tilhører Omarchy-skallet. Klikk på Wi-Fi-ikonet i topplinjen (eller trykk `Super + Ctrl + N`) for å se nettverk og koble til, og klikk på Bluetooth-ikonet (eller trykk `Super + Ctrl + B`) for å pare og koble til enheter. Se [nettverk](35-networking.md) for hele historien.

## Legge til dine egne

Ethvert terminalprogram kan få den fulle appbehandlingen. Gå til _Installer > TUI_ i Omarchy-menyen (`Super + Space`), gi det et navn, en startkommando, en vindusstil og et ikon, og det vil dukke opp i appstarteren som enhver annen applikasjon. Du kan fjerne det igjen under _Fjern > TUI_.
