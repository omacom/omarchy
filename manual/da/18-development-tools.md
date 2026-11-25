# Udviklingsværktøjer

## Alternative editorer

Omarchy leveres med Plain som standardeditor på nye installationer og [Neovim](https://neovim.io/) forudinstalleret, men hvis du vil have noget lidt mere mainstream og velkendt, kan du åbne Omarchy Menu (`Super + Space`) og se mulighederne under _Install > Editor_. Vi har VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs på listen der. Hvis du ikke finder det, du leder efter, så tjek _Install > Package_, og se, om det ikke findes i en Arch-pakke (og hvis ikke, så prøv _Install > AUR_ for at tjekke AUR).

Den originale `vi`-editor er også tilgængelig fra start. Kør `vi filename` for at redigere en fil i terminalen.

Tematilpasning tilbydes til `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Du kan indstille standardeditoren for hele systemet under `Setup > Defaults > Editor`.

## Udviklingsmiljøer

Omarchy understøtter opsætning af en hel række udviklingsmiljøer via afsnittet _Install > Development_ i Omarchy Menu (`Super + Space`). Du finder selvfølgelig _Ruby on Rails_, men også alle tre store runtimes til JavaScript (Node.js, Bun, Deno) samt populære PHP-frameworks som Laravel og Symfony. Åh, og der er også Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure og Scala. Det er et meget bredt udvalg!

Størstedelen af disse miljøer administreres af [Mise](https://mise.jdx.dev/). Det er et værktøj, der lader dig installere og køre flere versioner af et programmeringssprog på den samme maskine. Det er ligesom rbenv eller rvm til Ruby eller virtualenv til Python, men det virker til en hel masse forskellige miljøer.

Hvis du for eksempel vil installere Ruby, kører du `mise use -g ruby`, hvilket både installerer Ruby og sætter det som global standard. Eller, hvis dit projekt har en .ruby-version-fil, kan du bare køre `mise i` i roden af det projekt.

## Forudinstallerede CLI-værktøjer

`uv`, Node.js og `playwright-cli` (så agenter kan styre en browser ved hjælp af den installerede Chrome) leveres installeret som pakker, og `omarchy update` holder dem opdaterede sammen med resten af systemet. [Hunk](https://github.com/modem-dev/hunk) og CLI'erne til GitHub, Basecamp, Cloudflare og HEY er kun et valg væk under _Install > CLI_, og [kodningsagenter](17-ai.md) under _Install > AI > CLI_.

mise administrerer kun de runtimes, du sætter op fra _Install > Development_; Omarchy installerer ikke noget gennem det på egen hånd. Kør `omarchy update` for at opdatere dem sammen med resten af Omarchy; aliasset `mup` opdaterer kun mise-administrerede værktøjer. Hvis du vil tilføje et andet værktøj til din egen konfiguration, skal du bruge `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) behøver næppe nogen introduktion. Det lader dig køre isolerede containere, og Omarchy installerer alt, hvad der skal til for at køre det ordentligt, herunder selve Docker og [Docker Compose](https://docs.docker.com/compose/).

Som standard er din bruger *ikke* i gruppen `docker`. Den gruppe er reelt root uden adgangskode — alt i den kan køre `docker run -v /:/host` og overtage maskinen — så et enkelt ondsindet script eller en enkelt afhængighed, der kører som dig, ville ellers være én kommando fra root. Så på kommandolinjen kører du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), og de grafiske værktøjer, der taler med daemonen — Windows VM'en — beder om autorisation, når de har brug for det. Hvis du vil have bekvemmeligheden ved en sudo-fri opsætning tilbage og forstår kompromiset, kan du aktivere det fra **Setup > Security > Sudoless Docker** (eller køre `omarchy-setup-security-sudoless-docker`), hvilket føjer dig til gruppen `docker` efter en advarsel; så virker almindelig `docker` og aliasset `d` igen uden `sudo`.

Du kan opsætte de almindelige databaser til lokal udvikling i Docker ved hjælp af _Install > Development > Docker DB_ i Omarchy-menuen.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er `gh` til at arbejde med repositories, issues og pull requests fra terminalen. _Setup > Git_ installerer det, når du vælger at logge ind på GitHub der, eller du kan installere det for sig selv fra _Install > CLI > GitHub_. Derefter kloner `gh repo clone org/repo` et repository; kør `gh --help` for at udforske dets kommandoer.

[Lazygit](https://github.com/jesseduffield/lazygit) er forudinstalleret til at arbejde med selve Git.
