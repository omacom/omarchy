# Utviklingsverktøy

## Alternative tekstbehandlere

Omarchy leveres med [Neovim](https://neovim.io/) som standard, men hvis du ønsker noe mer vanlig og velkjent, kan du åpne Omarchy-menyen (`Super + Space`) og se alternativene under _Installer > Editor_. Der finner du VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs. Hvis du ikke finner det du leter etter, sjekk _Installer > Pakke_ og se om det ikke finnes som Arch-pakke (og hvis ikke, prøv _Installer > AUR_ for å sjekke AUR).

Den opprinnelige `vi`-editoren er også tilgjengelig rett ut av esken. Kjør `vi filename` for å redigere en fil i terminalen.

Tematilpasning tilbys for `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Du kan angi standardeditor for hele systemet under `Oppsett > Standarder > Editor`.

## Miljø

Omarchy støtter oppsett av en hel rekke utviklingsmiljøer via _Installer > Utvikling_-delen av Omarchy-menyen (`Super + Space`). Du finner selvsagt _Ruby on Rails_, men også alle tre store kjøremiljøene for JavaScript (Node.js, Bun, Deno), i tillegg til populære PHP-rammeverk som Laravel og Symfony. Og så er det Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure og Scala også. Det er et svært bredt utvalg!

De fleste av disse miljøene administreres av [Mise](https://mise.jdx.dev/). Det er et verktøy som lar deg installere og kjøre flere versjoner av et programmeringsspråk på samme maskin. Det er som rbenv eller rvm for Ruby eller virtualenv for Python, men det fungerer for en hel gjeng forskjellige miljøer.

For å installere for eksempel Ruby, kjører du `mise use -g ruby`, som både installerer Ruby og setter den som global standard. Eller hvis prosjektet ditt har en .ruby-version-fil, kan du bare kjøre `mise i` i roten av prosjektet.

## Docker

[Docker](https://www.docker.com/) trenger knapt noen introduksjon. Det lar deg kjøre isolerte containere, og Omarchy installerer alt som trengs for å kjøre det skikkelig, inkludert Docker selv og [Docker Compose](https://docs.docker.com/compose/).

Som standard er brukeren din *ikke* i `docker`-gruppen. Den gruppen er i praksis passordfri root — alle i den kan kjøre `docker run -v /:/host` og ta over maskinen — så ett enkelt skript eller en avhengighet kjørt som deg ville ellers vært én kommando unna root. Så på kommandolinjen kjører du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), og de grafiske verktøyene som snakker med daemonen — Windows-VM-en — ber om autorisasjon når de trenger det. Hvis du vil ha tilbake bekvemmeligheten av et gruppeløst oppsett og forstår avveiningen, aktiver det fra **Oppsett > Sikkerhet > Sudoless Docker** (eller kjør `omarchy-setup-security-sudoless-docker`), som legger deg til i `docker`-gruppen etter en advarsel; da fungerer ren `docker` og `d`-aliaset igjen uten `sudo`.

Du kan sette opp de vanlige databasene for lokal utvikling i Docker med _Installer > Utvikling > Docker DB_ i Omarchy-menyen.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) lar deg autentisere med GitHub-kontoen din og klone private repoer med den. Den er koplet til som en av mise-stubbene som laster lat, så første gang du kjører `gh`, installerer den seg selv. For å autentisere, kjør `gh auth login`. Deretter kan du hente ut private repoer med `gh repo clone org/repo`.

Du kan også utføre en hel haug andre GitHub-operasjoner med denne kommandoen. Bare kjør `gh` for å se alt som er mulig.

Det finnes også en lat-installerende stub for `ghui` for å administrere pull request-ene dine i et TUI. Og [lazygit](https://github.com/jesseduffield/lazygit) er forhåndsinstallert, om du også vil styre selve git fra et TUI.
