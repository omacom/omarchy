# Udviklingsværktøjer

## Alternative editorer

Omarchy leveres med Plain som standardeditor på nye installationer og [Neovim](https://neovim.io/) forudinstalleret, men hvis du gerne vil have noget lidt mere mainstream og velkendt, kan du åbne Omarchy-menuen (`Super + Space`) og se mulighederne under _Install > Editor_. Der har vi VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs på listen. Hvis du ikke finder det, du leder efter, så tjek _Install > Package_, og se, om det ikke findes i en Arch-pakke (og hvis ikke, så prøv _Install > AUR_ for at tjekke AUR).

Den oprindelige `vi`-editor er også tilgængelig lige fra start. Kør `vi filename` for at redigere en fil i terminalen.

Tema-matchning tilbydes til `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Du kan indstille den systemomfattende standardeditor under `Setup > Defaults > Editor`.

## Miljø

Omarchy understøtter opsætning af en hel række udviklingsmiljøer gennem afsnittet _Install > Development_ i Omarchy-menuen (`Super + Space`). Du finder selvfølgelig _Ruby on Rails_, men også alle tre store runtimes til JavaScript (Node.js, Bun, Deno) samt populære PHP-frameworks som Laravel og Symfony. Åh, og der er også Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure og Scala. Det er et meget bredt udvalg!

Størstedelen af disse miljøer administreres af [Mise](https://mise.jdx.dev/). Det er et værktøj, der lader dig installere og køre flere versioner af et programmeringssprog på den samme maskine. Det er ligesom rbenv eller rvm til Ruby eller virtualenv til Python, men det virker til en hel masse forskellige miljøer.

For at installere f.eks. Ruby skal du køre `mise use -g ruby`, hvilket både installerer Ruby og sætter det som den globale standard. Eller, hvis dit projekt har en .ruby-version-fil, kan du bare køre `mise i` i roden af det projekt.

## Forudinstallerede CLI-værktøjer

Omarchy gør værktøjer som `gh`, `uv` og de fleste [kodeagenter](17-ai.md) tilgængelige gennem [lazy installation i mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Første gang du kører et af dem, installerer mise det. Kodeagenter tjekker derefter for en opdatering, før de kører, højst én gang hver fjerde time; andre værktøjer, som `gh` og `uv`, genbruger den installerede version, indtil du opdaterer.

Du kan også inspicere standarderne eller installere dem på forhånd:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Kør `omarchy update` for at opdatere installerede værktøjer sammen med resten af Omarchy. Aliasset `mup` opdaterer kun mise-administrerede værktøjer. For at tilføje et andet værktøj til din egen konfiguration skal du bruge `mise use -g <tool>`.

Python-opsætning installerer også `uv` gennem mise. Hvis du fjerner Python-udviklingsmiljøet, forbliver `uv` tilgængelig som et uafhængigt værktøj.

### Brug af din egen installation

Mises kommandoer kommer før `~/.local/bin` på `PATH`, så et værktøj, du selv har installeret, f.eks. med Claude Codes eller Cursors eget installationsprogram, kører stadig mises kopi. Apps, der startes fra skrivebordet, finder også mises kommandoer før systempakker, så en app, der kører `gh`, får mises kopi, selv hvis du installerede `github-cli` med pacman, og mise installerer den kopi første gang. For at bruge din egen i stedet skal du deaktivere mises kopi i `~/.config/mise/config.toml`. Hvis du f.eks. selv har installeret Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Hvis du allerede har en `[settings]`-tabel, skal du tilføje posten der; udvid en eksisterende `disable_tools`-liste i stedet for at erstatte den. Sørg for, at din installation er på `PATH`. Brug mise-værktøjsnavnet, som kan være forskelligt fra dets kommando: `oh-my-pi` leverer f.eks. `omp`. Starteren til standardagenten foretrækker også en brugerinstalleret Cursor eller Muse i `~/.local/bin`.

### Fjernelse og gendannelse af standarder

_Remove > Preinstalls_ fjerner Omarchys forudinstallerede webapps, TUI'er og apps og får mise til at springe Omarchys værktøjserklæringer over for din bruger ved at tilføje dem til `ignored_config_paths` i `~/.config/mise/miserc.toml`. _Install > Preinstalls_ bringer dem tilbage og fjerner den linje igen. Værktøjer, du selv erklærer, i din egen konfiguration eller i et projekts `mise.toml`, bliver ved med at virke i begge tilfælde. Hvis du vælger en standardagent eller sætter Python op efter at have fjernet de forudinstallerede, bliver det værktøj tilføjet til din egen konfiguration. Mise-indstillingen gælder kun for din bruger, og andre brugere beholder deres eget valg; appsene er dog pakker, så fjernelse eller gendannelse af dem ændrer dem for alle på maskinen.

## Docker

[Docker](https://www.docker.com/) behøver næppe nogen introduktion. Det lader dig køre isolerede containere, og Omarchy installerer alt, hvad der skal til for at køre det godt, inklusive Docker selv og [Docker Compose](https://docs.docker.com/compose/).

Som standard er din bruger *ikke* i `docker`-gruppen. Den gruppe er reelt passwordless root — alt i den kan `docker run -v /:/host` og overtage maskinen — så et enkelt useriøst script eller en afhængighed, der kører som dig, ville ellers være én kommando fra root. Så på kommandolinjen kører du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), og de grafiske værktøjer, der taler med daemonen — Windows VM'en — beder om autorisation, når de har brug for det. Hvis du vil have bekvemmeligheden ved en opsætning uden gruppe tilbage og forstår kompromiset, kan du aktivere det fra **Setup > Security > Sudoless Docker** (eller køre `omarchy-setup-security-sudoless-docker`), hvilket tilføjer dig til `docker`-gruppen efter en advarsel; derefter virker almindelig `docker` og aliasset `d` igen uden `sudo`.

Du kan sætte de almindelige databaser til lokal udvikling op i Docker ved hjælp af _Install > Development > Docker DB_ i Omarchy-menuen.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er tilgængelig som `gh` til at arbejde med repositorier, issues og pull requests fra terminalen. Kør `gh auth login` for at installere den ved første brug og autentificere, og derefter `gh repo clone org/repo` for at klone et repositorium. Kør `gh --help` for at udforske dens kommandoer.

For en terminalgrænseflade til pull requests skal du køre `ghui`; mise installerer den også ved første brug. [Lazygit](https://github.com/jesseduffield/lazygit) er forudinstalleret til at arbejde med Git selv.
