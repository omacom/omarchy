# Utviklingsverktøy

## Alternative teksteditorer

Omarchy leveres med Plain som standardeditor på nye installasjoner og [Neovim](https://neovim.io/) forhåndsinstallert, men hvis du vil ha noe litt mer vanlig og kjent, kan du kjøre Omarchy Menu (`Super + Space`) og se alternativene under _Install > Editor_. Der har vi VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs listet opp. Hvis du ikke finner det du leter etter, sjekk _Install > Package_, og se om det ikke finnes i en Arch-pakke (og hvis ikke, prøv _Install > AUR_ for å sjekke AUR).

Den originale `vi`-editoren er også tilgjengelig rett ut av boksen. Kjør `vi filename` for å redigere en fil i terminalen.

Tematilpasning tilbys for `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Du kan angi standardeditor for hele systemet under `Setup > Defaults > Editor`.

## Miljø

Omarchy støtter oppsett av en hel rekke utviklingsmiljøer gjennom delen _Install > Development_ i Omarchy Menu (`Super + Space`). Der finner du selvfølgelig _Ruby on Rails_, men også alle de tre store kjøretidsmiljøene for JavaScript (Node.js, Bun, Deno), samt populære PHP-rammeverk som Laravel og Symfony. Å, og det finnes Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure og Scala også. Det er et veldig bredt utvalg!

De fleste av disse miljøene administreres av [Mise](https://mise.jdx.dev/). Det er et verktøy som lar deg installere og kjøre flere versjoner av et programmeringsspråk på samme maskin. Det er som rbenv eller rvm for Ruby eller virtualenv for Python, men det fungerer for en hel haug med forskjellige miljøer.

For å installere for eksempel Ruby kjører du `mise use -g ruby`, som både installerer Ruby og angir den som global standard. Eller, hvis prosjektet ditt har en .ruby-version-fil, kan du bare kjøre `mise i` i roten av det prosjektet.

## Forhåndsinstallerte CLI-verktøy

Omarchy gjør verktøy som `gh`, `uv` og de fleste [kodeagenter](17-ai.md) tilgjengelige gjennom [den late installasjonen til mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Første gang du kjører ett av dem, installerer mise det. Kodeagenter sjekker deretter etter en oppdatering før de kjører, høyst én gang hver fjerde time; andre verktøy, som `gh` og `uv`, gjenbruker den installerte versjonen til du oppdaterer.

Du kan også se på standardoppsettet eller installere dem på forhånd:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Kjør `omarchy update` for å oppdatere installerte verktøy sammen med resten av Omarchy. Aliaset `mup` oppdaterer bare mise-administrerte verktøy. For å legge til et annet verktøy i ditt eget oppsett bruker du `mise use -g <tool>`.

Python-oppsettet installerer også `uv` gjennom mise. Å fjerne Python-utviklingsmiljøet etterlater `uv` tilgjengelig som et uavhengig verktøy.

### Bruke din egen installasjon

Kommandoene til mise kommer før `~/.local/bin` i `PATH`, så et verktøy du installerte selv, for eksempel med Claude Code eller Cursor sitt eget installasjonsprogram, kjører fortsatt kopien til mise. Apper som startes fra skrivebordet, finner også kommandoene til mise før systempakkene, så en app som kjører `gh`, får kopien til mise selv om du installerte `github-cli` med pacman, og mise installerer den kopien første gang. For å bruke din egen i stedet deaktiverer du kopien til mise i `~/.config/mise/config.toml`. For eksempel, hvis du installerte Cursor CLI selv:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Hvis du allerede har en `[settings]`-tabell, legger du til oppføringen der; utvid en eksisterende `disable_tools`-liste i stedet for å erstatte den. Sørg for at installasjonen din er i `PATH`. Bruk verktøynavnet til mise, som kan være forskjellig fra kommandoen dens: `oh-my-pi` tilbyr for eksempel `omp`. Startprogrammet for standardagenten foretrekker også en brukerinstallert Cursor eller Muse i `~/.local/bin`.

### Fjerne og gjenopprette standardoppsett

_Remove > Preinstalls_ fjerner Omarchys forhåndsinstallerte webapper, TUIer og apper, og får mise til å hoppe over Omarchys verktøydeklarasjoner for brukeren din, ved å legge dem til i `ignored_config_paths` i `~/.config/mise/miserc.toml`. _Install > Preinstalls_ bringer dem tilbake og fjerner den linjen igjen. Verktøy du deklarerer selv, i ditt eget oppsett eller i et prosjekts `mise.toml`, fortsetter å fungere uansett. Hvis du velger en standardagent eller setter opp Python etter å ha fjernet forhåndsinstallasjonene, legges det verktøyet til i ditt eget oppsett. Innstillingen i mise gjelder bare for brukeren din, og andre brukere beholder sitt eget valg; appene er imidlertid pakker, så å fjerne eller gjenopprette dem endrer dem for alle på maskinen.

## Docker

[Docker](https://www.docker.com/) trenger knapt noen introduksjon. Den lar deg kjøre isolerte containere, og Omarchy installerer alt som trengs for å kjøre den godt, inkludert selve Docker og [Docker Compose](https://docs.docker.com/compose/).

Som standard er brukeren din *ikke* i `docker`-gruppen. Den gruppen er i praksis passordløs root — alt i den kan kjøre `docker run -v /:/host` og ta over maskinen — så et enkelt useriøst skript eller en avhengighet som kjører som deg, ville ellers vært én kommando unna root. Så på kommandolinjen kjører du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), og de grafiske verktøyene som snakker med daemonen — Windows VM-en — ber om autorisasjon når de trenger det. Hvis du vil ha bekvemmeligheten med et oppsett uten gruppe tilbake og forstår avveiningen, aktiverer du det fra **Setup > Security > Sudoless Docker** (eller kjører `omarchy-setup-security-sudoless-docker`), som legger deg til i `docker`-gruppen etter en advarsel; da fungerer vanlig `docker` og aliaset `d` uten `sudo` igjen.

Du kan sette opp de vanlige databasene for lokal utvikling i Docker ved hjelp av _Install > Development > Docker DB_ i Omarchy-menyen.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er tilgjengelig som `gh` for å jobbe med repositorier, issues og pull requests fra terminalen. Kjør `gh auth login` for å installere den ved første bruk og autentisere deg, og deretter `gh repo clone org/repo` for å klone et repositorium. Kjør `gh --help` for å utforske kommandoene dens.

For et terminalgrensesnitt til pull requests kjører du `ghui`; mise installerer den også ved første bruk. [Lazygit](https://github.com/jesseduffield/lazygit) er forhåndsinstallert for å jobbe med selve Git.
