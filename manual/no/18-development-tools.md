# Utviklingsverktøy

## Alternative redigeringsprogrammer

Omarchy leveres med Plain som standard redigeringsprogram på nye installasjoner og [Neovim](https://neovim.io/) forhåndsinstallert, men hvis du vil ha noe litt mer vanlig og kjent, kan du kjøre Omarchy Menu (`Super + Space`) og se alternativene under _Install > Editor_. Vi har VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs listet der. Hvis du ikke finner det du leter etter, sjekk _Install > Package_, og se om det ikke finnes i en Arch-pakke (og hvis ikke, prøv _Install > AUR_ for å sjekke AUR).

Den originale `vi`-editoren er også tilgjengelig rett ut av boksen. Kjør `vi filename` for å redigere en fil i terminalen.

Tematilpasning tilbys for `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Du kan angi standard redigeringsprogram for hele systemet under `Setup > Defaults > Editor`.

## Miljø

Omarchy støtter oppsett av en hel rekke utviklingsmiljøer gjennom _Install > Development_-delen av Omarchy Menu (`Super + Space`). Du finner selvfølgelig _Ruby on Rails_, men også alle de tre store kjøretidsmiljøene for JavaScript (Node.js, Bun, Deno), samt populære PHP-rammeverk som Laravel og Symfony. Åh, og det finnes Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure og Scala også. Det er et veldig bredt utvalg!

De fleste av disse miljøene administreres av [Mise](https://mise.jdx.dev/). Det er et verktøy som lar deg installere og kjøre flere versjoner av et programmeringsspråk på samme maskin. Det er som rbenv eller rvm for Ruby eller virtualenv for Python, men det fungerer for en hel haug forskjellige miljøer.

For å installere for eksempel Ruby kjører du `mise use -g ruby`, som både installerer Ruby og angir det som global standard. Eller, hvis prosjektet ditt har en .ruby-version-fil, kan du bare kjøre `mise i` i roten av det prosjektet.

## Forhåndsinstallerte CLI-verktøy

`uv`, Node.js og `playwright-cli` (for at agenter skal kunne styre en nettleser, ved hjelp av den installerte Chrome) leveres installert som pakker, og `omarchy update` holder dem oppdatert sammen med resten av systemet. `ghui`, [Hunk](https://github.com/modem-dev/hunk) og Basecamp-, Cloudflare- og HEY-CLI-ene er bare et valg unna under _Install > CLI_, og [kodeagenter](17-ai.md) under _Install > AI > CLI_.

mise administrerer bare kjøretidsmiljøene du setter opp fra _Install > Development_; Omarchy installerer ikke noe gjennom det på egen hånd. Kjør `omarchy update` for å oppdatere dem sammen med resten av Omarchy; `mup`-aliaset oppdaterer bare mise-administrerte verktøy. For å legge til et annet verktøy i din egen konfigurasjon bruker du `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) trenger knapt noen introduksjon. Den lar deg kjøre isolerte containere, og Omarchy installerer alt som trengs for å kjøre den godt, inkludert Docker selv og [Docker Compose](https://docs.docker.com/compose/).

Som standard er brukeren din *ikke* i `docker`-gruppen. Den gruppen er i praksis passordløs root — alt i den kan `docker run -v /:/host` og ta over maskinen — så et enkelt useriøst skript eller en avhengighet som kjører som deg, ville ellers vært én kommando unna root. Så på kommandolinjen kjører du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), og de grafiske verktøyene som snakker med daemonen — Windows VM-en — ber om autorisasjon når de trenger det. Hvis du vil ha tilbake bekvemmeligheten med et oppsett uten gruppe og forstår avveiningen, aktiver det fra **Setup > Security > Sudoless Docker** (eller kjør `omarchy-setup-security-sudoless-docker`), som legger deg til i `docker`-gruppen etter en advarsel; da fungerer vanlig `docker` og `d`-aliaset uten `sudo` igjen.

Du kan sette opp de vanlige databasene for lokal utvikling i Docker ved hjelp av _Install > Development > Docker DB_ i Omarchy-menyen.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er `gh`, for å jobbe med repoer, issues og pull requests fra terminalen. _Setup > Git_ installerer den når du velger å logge inn på GitHub der, deretter kloner `gh repo clone org/repo` et repo. Kjør `gh --help` for å utforske kommandoene.

_Install > CLI > GitHub_ installerer GitHub CLI, `gh`, sammen med `ghui`, et terminalgrensesnitt for pull requests. [Lazygit](https://github.com/jesseduffield/lazygit) er forhåndsinstallert for å jobbe med Git selv.
