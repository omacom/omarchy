# TUI-er

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) er et herlig alternativ til noe som GitHub Desktop-applikasjonen, og det kjører inne i terminalen.

Du kan kjøre det direkte ved å gå til en hvilken som helst mappe administrert av git og kjøre `lazygit`. Eller du kan kjøre det inne i Neovim, der det kan startes med `Space G G`.

Du hopper mellom de ulike rutene med `Tab`. I Filer-ruten velger du filer for staging med `Space`, og deretter kan du opprette en ny commit med `c`. Du kan se alle tilgjengelige kommandoer med `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) er en vakker ressursforvalter som viser minne-, CPU-, disk- og nettverksbruk. Den lister også opp alle aktive prosesser og lar deg administrere dem.

Omarchy kaller den Aktivitet, og du starter den med `Super + Ctrl + T`. Den åpnes som et flytende vindu, som du kan flislegge med `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) er en terminal-arbeidsområdeforvalter som gir deg arbeidsområder, faner og ruter, og holder dem alle i gang i en vedvarende økt du kan koble fra og komme tilbake til senere.

Du starter den (eller kopler til den eksisterende økten din igjen) med `Super + Ctrl + Return`. Omarchy leverer en Herdr-konfigurasjon som speiler Tmux-konfigurasjonen, så prefikstasten er `Ctrl + Space` her også. Du kan bla gjennom alle tastatursnarveiene med `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) viser systeminformasjon, som kjerneversjon, oppetid, tema, CPU, minne og mer. Den er en etterfølger til det populære neofetch-verktøyet.

Omarchy har pakket dette som _Om_ i Omarchy-menyen (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) er en retro terminal-musikkspiller inspirert av Winamp 2.x, komplett med innebygde radiostasjoner for lo-fi beats. Start den med `Super + Shift + Alt + M`, eller fra Omarchy-menyen under _Apper_. Trykk `?` for hele listen over tastatursnarveier.

## Hva med Wi-Fi og Bluetooth?

Du finner ikke TUI-er for Wi-Fi og Bluetooth — de jobbene tilhører Omarchy-skallet. Klikk på Wi-Fi-ikonet i menylinjen (eller trykk `Super + Ctrl + W`) for å se nettverk og koble til, og klikk på Bluetooth-ikonet (eller trykk `Super + Ctrl + B`) for å pare og koble til enheter. Se [nettverk](35-networking.md) for hele historien.

## Legge til dine egne

Ethvert terminalprogram kan få full app-behandling. Gå til _Installer > TUI_ i Omarchy-menyen (`Super + Space`), gi det et navn, en startkommando, en vindusstil og et ikon, så dukker det opp i appstarteren som en hvilken som helst annen applikasjon. Du kan fjerne det igjen under _Fjern > TUI_.
