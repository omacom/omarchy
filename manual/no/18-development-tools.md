# Utviklingsverktøy

## Alternative redigeringsprogrammer

Omarchy leveres med [Neovim](https://neovim.io/) som standard, men hvis du vil ha noe litt mer vanlig og velkjent, kan du kjøre Omarchy Menu (`Super + Space`) og se alternativene under _Install > Editor_. Der finner du VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs. Hvis du ikke finner det du leter etter, kan du ta en titt på _Install > Package_ og se om det ikke finnes i en Arch-pakke (og hvis ikke, kan du prøve _Install > AUR_ for å sjekke AUR).

Den opprinnelige `vi`-editoren er også tilgjengelig rett ut av boksen. Kjør `vi filename` for å redigere en fil i terminalen.

Tematilpasning tilbys for `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Du kan angi standardeditor for hele systemet under `Setup > Defaults > Editor`.

## Miljø

Omarchy støtter oppsett av en hel rekke utviklingsmiljøer gjennom _Install > Development_-delen av Omarchy Menu (`Super + Space`). Der finner du selvsagt _Ruby on Rails_, men også alle de tre store kjøretidsmiljøene for JavaScript (Node.js, Bun, Deno), samt populære PHP-rammeverk som Laravel og Symfony. Å ja, og der finnes også Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure og Scala. Det er et svært bredt utvalg!

De fleste av disse miljøene administreres av [Mise](https://mise.jdx.dev/). Det er et verktøy som lar deg installere og kjøre flere versjoner av et programmeringsspråk på samme maskin. Det er som rbenv eller rvm for Ruby eller virtualenv for Python, men det fungerer for en hel haug ulike miljøer.

For å installere for eksempel Ruby kjører du `mise use -g ruby`, som både installerer Ruby og setter den som global standard. Eller, hvis prosjektet ditt har en .ruby-version-fil, kan du bare kjøre `mise i` i roten av det prosjektet.

## Forhåndsinstallerte CLI-verktøy

Omarchy gjør verktøy som `gh`, `uv` og de fleste [kodeagenter](17-ai.md) tilgjengelige gjennom [mises late installasjon](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Første gang du kjører et av dem, installerer mise det. Senere kjøringer gjenbruker den installerte versjonen; de sjekker ikke etter en oppdatering ved hver oppstart.

Du kan også inspisere standardene eller installere dem på forhånd:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Kjør `omarchy update` for å oppdatere installerte verktøy sammen med resten av Omarchy. `mup`-aliaset oppdaterer bare mise-administrerte verktøy. For å legge til et annet verktøy i din egen konfigurasjon bruker du `mise use -g <tool>`.

Python-oppsettet installerer også `uv` gjennom mise. Hvis du fjerner Python-utviklingsmiljøet, forblir `uv` tilgjengelig som et uavhengig verktøy.

### Bruke din egen installasjon

mises kommandoer kommer før `~/.local/bin` på `PATH`, så et verktøy du har installert selv, for eksempel med Claude Codes eller Cursors eget installasjonsprogram, kjører fortsatt mises kopi. Apper som startes fra skrivebordet, finner også mises kommandoer før systempakker, så en app som kjører `gh`, får mises kopi selv om du installerte `github-cli` med pacman, og mise installerer den kopien første gang. For å bruke din egen i stedet deaktiverer du mises kopi i `~/.config/mise/config.toml`. Hvis du for eksempel har installert Cursor CLI selv:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Hvis du allerede har en `[settings]`-tabell, legger du oppføringen til der; utvid en eksisterende `disable_tools`-liste i stedet for å erstatte den. Sørg for at installasjonen din ligger på `PATH`. Bruk mise-verktøynavnet, som kan avvike fra kommandoen: `oh-my-pi` gir for eksempel `omp`. Standardagent-starteren foretrekker også en brukerinstallert Cursor eller Muse i `~/.local/bin`.

### Fjerne og gjenopprette standarder

_Remove Preinstalls_ får mise til å hoppe over Omarchys verktøyerklæringer for brukeren din, ved å legge dem til i `ignored_config_paths` i `~/.config/mise/miserc.toml`. _Restore Preinstalls_ fjerner den linjen igjen. Verktøy du erklærer selv, i din egen konfigurasjon eller i et prosjekts `mise.toml`, fortsetter å fungere uansett. Hvis du velger en standardagent eller setter opp Python etter å ha fjernet forhåndsinstallasjonene, legges det verktøyet til i din egen konfigurasjon. Begge gjelder bare for brukeren din; andre brukere på maskinen beholder sitt eget valg.

## Docker

[Docker](https://www.docker.com/) trenger knapt noen introduksjon. Den lar deg kjøre isolerte containere, og Omarchy installerer alt som trengs for å kjøre den godt, inkludert Docker selv og [Docker Compose](https://docs.docker.com/compose/).

Som standard er brukeren din *ikke* i `docker`-gruppen. Den gruppen er i praksis passordløs root — alt i den kan kjøre `docker run -v /:/host` og ta over maskinen — så et enkelt useriøst skript eller en avhengighet som kjører som deg, ville ellers vært én kommando unna root. Så på kommandolinjen kjører du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), og de grafiske verktøyene som snakker med daemonen — Windows VM-en — ber om autorisasjon når de trenger det. Hvis du vil ha tilbake bekvemmeligheten med et oppsett uten gruppe og forstår avveiningen, kan du aktivere det fra **Setup > Security > Sudoless Docker** (eller kjøre `omarchy-setup-security-sudoless-docker`), som legger deg til i `docker`-gruppen etter en advarsel; da fungerer vanlig `docker` og `d`-aliaset igjen uten `sudo`.

Du kan sette opp de vanlige databasene for lokal utvikling i Docker ved hjelp av _Install > Development > Docker DB_ i Omarchy-menyen.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er tilgjengelig som `gh` for å jobbe med repoer, issues og pull requests fra terminalen. Kjør `gh auth login` for å installere den ved første bruk og autentisere deg, og deretter `gh repo clone org/repo` for å klone et repo. Kjør `gh --help` for å utforske kommandoene.

For et terminalgrensesnitt for pull requests kjører du `ghui`; mise installerer den også ved første bruk. [Lazygit](https://github.com/jesseduffield/lazygit) er forhåndsinstallert for å jobbe med Git selv.
