# Utviklingsverktøy

## Alternative redigeringsprogrammer

Omarchy leveres med Plain som standard redigeringsprogram på nye installasjoner og [Neovim](https://neovim.io/) forhåndsinstallert, men hvis du vil ha noe litt mer vanlig og velkjent, kan du kjøre Omarchy Menu (`Super + Space`) og se alternativene under _Install > Editor_. Vi har VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs oppført der. Hvis du ikke finner det du leter etter, sjekk _Install > Package_ og se om det ikke finnes i en Arch-pakke (og hvis ikke, prøv _Install > AUR_ for å sjekke AUR).

Det originale `vi`-redigeringsprogrammet er også tilgjengelig rett ut av boksen. Kjør `vi filename` for å redigere en fil i terminalen.

Det tilbys tematilpasning for `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Du kan angi standard redigeringsprogram for hele systemet under `Setup > Defaults > Editor`.

## Miljø

Omarchy støtter oppsett av en hel rekke utviklingsmiljøer gjennom _Install > Development_-delen av Omarchy Menu (`Super + Space`). Der finner du selvsagt _Ruby on Rails_, men også alle de tre store kjøretidsmiljøene for JavaScript (Node.js, Bun, Deno), samt populære PHP-rammeverk som Laravel og Symfony. Å, og det finnes Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure og Scala også. Det er et svært bredt utvalg!

De fleste av disse miljøene administreres av [Mise](https://mise.jdx.dev/). Det er et verktøy som lar deg installere og kjøre flere versjoner av et programmeringsspråk på samme maskin. Det er som rbenv eller rvm for Ruby eller virtualenv for Python, men det fungerer for en hel rekke forskjellige miljøer.

For å installere for eksempel Ruby kjører du `mise use -g ruby`, som både installerer Ruby og angir den som global standard. Eller, hvis prosjektet ditt har en .ruby-version-fil, kan du bare kjøre `mise i` i roten av det prosjektet.

## Forhåndsinstallerte CLI-verktøy

`uv`, Node.js og `playwright-cli` (slik at agenter kan styre en nettleser ved hjelp av den installerte Chrome) kommer installert som pakker, og `omarchy update` holder dem oppdatert sammen med resten av systemet. [Hunk](https://github.com/modem-dev/hunk) og GitHub-, Basecamp-, Cloudflare- og HEY-CLI-ene er bare ett valg unna under _Install > CLI_, og [kodeagenter](17-ai.md) under _Install > AI > CLI_.

mise administrerer bare kjøretidsmiljøene du setter opp fra _Install > Development_; Omarchy installerer ingenting gjennom det på egen hånd. Kjør `omarchy update` for å oppdatere dem sammen med resten av Omarchy; `mup`-aliaset oppdaterer bare verktøy som administreres av mise. For å legge til et annet verktøy i din egen konfigurasjon bruker du `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) trenger knapt noen introduksjon. Det lar deg kjøre isolerte containere, og Omarchy installerer alt som trengs for å kjøre det bra, inkludert selve Docker og [Docker Compose](https://docs.docker.com/compose/).

Som standard er brukeren din *ikke* i `docker`-gruppen. Den gruppen er i praksis passordløs root — alle i den kan kjøre `docker run -v /:/host` og ta over maskinen — så et enkelt useriøst skript eller en avhengighet som kjører som deg, ville ellers vært én kommando unna root. Så på kommandolinjen kjører du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), og de grafiske verktøyene som snakker med daemonen — Windows VM-en — ber om autorisasjon når de trenger det. Hvis du vil ha tilbake bekvemmeligheten med et gruppefritt oppsett og forstår avveiningen, aktiverer du det fra **Setup > Security > Sudoless Docker** (eller kjører `omarchy-setup-security-sudoless-docker`), som legger deg til i `docker`-gruppen etter en advarsel; da fungerer vanlig `docker` og `d`-aliaset uten `sudo` igjen.

Du kan sette opp de vanlige databasene for lokal utvikling i Docker ved hjelp av _Install > Development > Docker DB_ i Omarchy-menyen.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er `gh`, til å jobbe med repoer, issues og pull requests fra terminalen. _Setup > Git_ installerer det når du velger å logge inn på GitHub der, eller installer det på egen hånd fra _Install > CLI > GitHub_. Deretter kloner `gh repo clone org/repo` et repo; kjør `gh --help` for å utforske kommandoene i det.

[Lazygit](https://github.com/jesseduffield/lazygit) er forhåndsinstallert for å jobbe med selve Git.
