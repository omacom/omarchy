# Udviklingsværktøjer

## Alternative editorer

Omarchy leveres med [Neovim](https://neovim.io/) som standard, men hvis du gerne vil have noget lidt mere mainstream og velkendt, kan du åbne Omarchy Menu (`Super + Space`) og se mulighederne under _Install > Editor_. Der har vi VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs på listen. Hvis du ikke finder det, du leder efter, kan du kigge under _Install > Package_ og se, om det ikke findes som en Arch-pakke (og hvis ikke, kan du prøve _Install > AUR_ for at tjekke AUR).

Den oprindelige `vi`-editor er også tilgængelig fra start. Kør `vi filename` for at redigere en fil i terminalen.

Tematilpasning tilbydes til `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Du kan indstille standardeditoren for hele systemet under `Setup > Defaults > Editor`.

## Miljø

Omarchy understøtter opsætning af en lang række udviklingsmiljøer via afsnittet _Install > Development_ i Omarchy Menu (`Super + Space`). Her finder du naturligvis _Ruby on Rails_, men også alle tre store runtimes til JavaScript (Node.js, Bun, Deno) samt populære PHP-frameworks som Laravel og Symfony. Åh, og der er også Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure og Scala. Det er et meget bredt udvalg!

De fleste af disse miljøer administreres af [Mise](https://mise.jdx.dev/). Det er et værktøj, der lader dig installere og køre flere versioner af et programmeringssprog på den samme maskine. Det er ligesom rbenv eller rvm til Ruby eller virtualenv til Python, men det virker til en hel masse forskellige miljøer.

Hvis du f.eks. vil installere Ruby, kører du `mise use -g ruby`, hvilket både installerer Ruby og indstiller den som den globale standard. Eller hvis dit projekt har en .ruby-version-fil, kan du bare køre `mise i` i roden af det pågældende projekt.

## Forudinstallerede CLI-værktøjer

Omarchy gør værktøjer som `gh`, `uv` og de fleste [coding agents](17-ai.md) tilgængelige via [mises lazy installation](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Første gang du kører et af dem, installerer mise det. Senere kørsler genbruger den installerede version; de tjekker ikke for en opdatering ved hver start.

Du kan også se standardindstillingerne eller installere dem på forhånd:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Kør `omarchy update` for at opdatere installerede værktøjer sammen med resten af Omarchy. Aliasset `mup` opdaterer kun mise-administrerede værktøjer. Hvis du vil føje et andet værktøj til din egen konfiguration, skal du bruge `mise use -g <tool>`.

Python-opsætningen installerer også `uv` via mise. Hvis du fjerner Python-udviklingsmiljøet, forbliver `uv` tilgængeligt som et uafhængigt værktøj.

### Brug af din egen installation

mises kommandoer står før `~/.local/bin` i `PATH`, så et værktøj, du selv har installeret, f.eks. med Claude Codes eller Cursors eget installationsprogram, stadig kører mises kopi. Apps, der startes fra skrivebordet, finder også mises kommandoer før systempakker, så en app, der kører `gh`, får mises kopi, selv hvis du installerede `github-cli` med pacman, og mise installerer den kopi første gang. Hvis du vil bruge din egen i stedet, skal du deaktivere mises kopi i `~/.config/mise/config.toml`. Hvis du f.eks. selv har installeret Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Hvis du allerede har en `[settings]`-tabel, skal du tilføje posten dér; udvid en eksisterende `disable_tools`-liste i stedet for at erstatte den. Sørg for, at din installation er i `PATH`. Brug mise-værktøjets navn, som kan adskille sig fra dets kommando: `oh-my-pi` leverer f.eks. `omp`. Standardagentens starter foretrækker også en brugerinstalleret Cursor eller Muse i `~/.local/bin`.

### Fjernelse og gendannelse af standardindstillinger

_Remove Preinstalls_ får mise til at springe Omarchys værktøjserklæringer over for din bruger ved at føje dem til `ignored_config_paths` i `~/.config/mise/miserc.toml`. _Restore Preinstalls_ fjerner den linje igen. Værktøjer, du selv erklærer, i din egen konfiguration eller i et projekts `mise.toml`, bliver ved med at virke i begge tilfælde. Hvis du vælger en standardagent eller sætter Python op efter at have fjernet de forudinstallerede værktøjer, føjes det pågældende værktøj til din egen konfiguration. Begge gælder kun for din bruger; andre brugere på maskinen beholder deres eget valg.

## Docker

[Docker](https://www.docker.com/) behøver næppe nogen introduktion. Det lader dig køre isolerede containere, og Omarchy installerer alt, hvad der skal til for at køre det godt, herunder selve Docker og [Docker Compose](https://docs.docker.com/compose/).

Som standard er din bruger *ikke* i gruppen `docker`. Den gruppe er i praksis root uden adgangskode — alt i den kan køre `docker run -v /:/host` og overtage maskinen — så et enkelt ondsindet script eller en enkelt ondsindet afhængighed, der kører som dig, ville ellers være én kommando fra root. Så på kommandolinjen kører du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), og de grafiske værktøjer, der taler med daemonen — Windows VM'en — beder om autorisation, når de har brug for det. Hvis du vil have bekvemmeligheden ved en opsætning uden gruppe tilbage og forstår afvejningen, kan du aktivere den fra **Setup > Security > Sudoless Docker** (eller køre `omarchy-setup-security-sudoless-docker`), hvilket føjer dig til gruppen `docker` efter en advarsel; derefter virker almindelig `docker` og aliasset `d` igen uden `sudo`.

Du kan sætte de almindelige databaser til lokal udvikling op i Docker ved hjælp af _Install > Development > Docker DB_ i Omarchy-menuen.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er tilgængelig som `gh` til at arbejde med repositories, issues og pull requests fra terminalen. Kør `gh auth login` for at installere det ved første brug og autentificere dig, og derefter `gh repo clone org/repo` for at klone et repository. Kør `gh --help` for at udforske dets kommandoer.

Hvis du vil have en terminalgrænseflade til pull requests, kan du køre `ghui`; mise installerer det også ved første brug. [Lazygit](https://github.com/jesseduffield/lazygit) er forudinstalleret til at arbejde med selve Git.
