# Udviklingsværktøjer

## Alternative editorer

Omarchy leveres med Plain som standardeditor på nye installationer og [Neovim](https://neovim.io/) forudinstalleret, men hvis du gerne vil have noget lidt mere mainstream og velkendt, kan du åbne Omarchy Menu (`Super + Space`) og se mulighederne under _Install > Editor_. Der har vi VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs på listen. Hvis du ikke finder det, du leder efter, så tjek _Install > Package_, og se, om det ikke findes som en Arch-pakke (og hvis ikke, så prøv _Install > AUR_ for at tjekke AUR).

Den originale `vi`-editor er også tilgængelig fra start. Kør `vi filename` for at redigere en fil i terminalen.

Temamatchning tilbydes til `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Du kan indstille den systemomfattende standardeditor under `Setup > Defaults > Editor`.

## Miljø

Omarchy understøtter opsætning af en hel række udviklingsmiljøer gennem afsnittet _Install > Development_ i Omarchy Menu (`Super + Space`). Du finder selvfølgelig _Ruby on Rails_, men også alle tre store runtimes til JavaScript (Node.js, Bun, Deno) samt populære PHP-frameworks som Laravel og Symfony. Åh, og der er også Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure og Scala. Det er et meget bredt udvalg!

Størstedelen af disse miljøer administreres af [Mise](https://mise.jdx.dev/). Det er et værktøj, der lader dig installere og køre flere versioner af et programmeringssprog på den samme maskine. Det er ligesom rbenv eller rvm til Ruby eller virtualenv til Python, men det virker til en hel masse forskellige miljøer.

For at installere f.eks. Ruby kører du `mise use -g ruby`, hvilket både installerer Ruby og sætter den som global standard. Eller hvis dit projekt har en .ruby-version-fil, kan du bare køre `mise i` i roden af det projekt.

## Forudinstallerede CLI-værktøjer

`uv`, Node.js og `playwright-cli` (så agenter kan styre en browser ved hjælp af den installerede Chrome) leveres installeret som pakker, og `omarchy update` holder dem opdaterede sammen med resten af systemet. `ghui`, [Hunk](https://github.com/modem-dev/hunk) og Basecamp-, Cloudflare- og HEY-CLI'erne er kun et valg væk under _Install > CLI_, og [kodeagenter](17-ai.md) under _Install > AI > CLI_.

mise administrerer kun de runtimes, du sætter op fra _Install > Development_; Omarchy installerer ikke noget gennem det på egen hånd. Kør `omarchy update` for at opdatere dem sammen med resten af Omarchy; aliasset `mup` opdaterer kun mise-administrerede værktøjer. For at føje et andet værktøj til din egen konfiguration skal du bruge `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) behøver næppe nogen introduktion. Det lader dig køre isolerede containere, og Omarchy installerer alt, hvad der skal til for at køre det godt, herunder selve Docker og [Docker Compose](https://docs.docker.com/compose/).

Som standard er din bruger *ikke* i gruppen `docker`. Den gruppe er reelt adgangskodefri root — alt i den kan køre `docker run -v /:/host` og overtage maskinen — så et enkelt useriøst script eller en enkelt afhængighed, der kører som dig, ville ellers være én kommando fra root. Så på kommandolinjen kører du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), og de grafiske værktøjer, der taler med daemonen — Windows VM'en — beder om autorisation, når de har brug for det. Hvis du vil have bekvemmeligheden ved en gruppeløs opsætning tilbage og forstår kompromiset, kan du aktivere det fra **Setup > Security > Sudoless Docker** (eller køre `omarchy-setup-security-sudoless-docker`), hvilket føjer dig til gruppen `docker` efter en advarsel; så virker almindelig `docker` og aliasset `d` igen uden `sudo`.

Du kan sætte de almindelige databaser til lokal udvikling op i Docker ved hjælp af _Install > Development > Docker DB_ i Omarchy-menuen.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er `gh` til at arbejde med repositorier, issues og pull requests fra terminalen. _Setup > Git_ installerer det, når du vælger at logge ind på GitHub der, og derefter kloner `gh repo clone org/repo` et repositorie. Kør `gh --help` for at udforske dets kommandoer.

_Install > CLI > GitHub_ installerer GitHub CLI, `gh`, sammen med `ghui`, en terminalgrænseflade til pull requests. [Lazygit](https://github.com/jesseduffield/lazygit) er forudinstalleret til at arbejde med selve Git.
