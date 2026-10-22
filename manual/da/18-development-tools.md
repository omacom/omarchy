# Udviklingsværktøjer

## Alternative editorer

Omarchy leveres som standard med [Neovim](https://neovim.io/), men hvis du gerne vil have noget lidt mere mainstream og velkendt, kan du åbne Omarchy-menuen (`Super + Space`) og se mulighederne under _Installer > Editor_. Vi har VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs på listen der. Hvis du ikke finder det, du leder efter, så kig under _Installer > Package_ og se, om det ikke findes som en Arch-pakke (og hvis ikke, så prøv _Installer > AUR_ for at tjekke AUR).

Den oprindelige `vi`-editor er også tilgængelig ud af boksen. Kør `vi filename` for at redigere en fil i terminalen.

Tematilpasning tilbydes til `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Du kan indstille standardeditoren for hele systemet under `Opsætning > Defaults > Editor`.

## Miljø

Omarchy understøtter opsætning af en lang række udviklingsmiljøer gennem afsnittet _Installer > Development_ i Omarchy-menuen (`Super + Space`). Du finder selvfølgelig _Ruby on Rails_, men også alle tre store runtimes til JavaScript (Node.js, Bun, Deno) samt populære PHP-frameworks som Laravel og Symfony. Åh, og der er også Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure og Scala. Det er et meget bredt udvalg!

De fleste af disse miljøer administreres af [Mise](https://mise.jdx.dev/). Det er et værktøj, der lader dig installere og køre flere versioner af et programmeringssprog på den samme maskine. Det er ligesom rbenv eller rvm til Ruby eller virtualenv til Python, men det virker til en masse forskellige miljøer.

For at installere for eksempel Ruby skal du køre `mise use -g ruby`, hvilket både installerer Ruby og sætter det som den globale standard. Eller, hvis dit projekt har en .ruby-version-fil, kan du bare køre `mise i` i roden af det projekt.

## Docker

[Docker](https://www.docker.com/) behøver næppe nogen introduktion. Det lader dig køre isolerede containere, og Omarchy installerer alt, hvad der skal til for at køre det godt, inklusive Docker selv og [Docker Compose](https://docs.docker.com/compose/).

Som standard er din bruger *ikke* i gruppen `docker`. Den gruppe er i praksis root uden adgangskode — alt i den kan køre `docker run -v /:/host` og overtage maskinen — så et enkelt løbsk script eller en afhængighed, der kører som dig, ville ellers være én kommando fra root. Så på kommandolinjen kører du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), og de grafiske værktøjer, der taler med daemonen — Windows VM'en — beder om autorisation, når de har brug for det. Hvis du ønsker bekvemmeligheden ved en opsætning uden gruppe tilbage og forstår kompromiset, kan du aktivere det fra **Opsætning > Security > Sudoless Docker** (eller køre `omarchy-setup-security-sudoless-docker`), som tilføjer dig til gruppen `docker` efter en advarsel; derefter virker almindelig `docker` og aliasset `d` igen uden `sudo`.

Du kan opsætte de almindelige databaser til lokal udvikling i Docker ved hjælp af _Installer > Development > Docker DB_ i Omarchy-menuen.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) lader dig autentificere dig med din GitHub-konto og klone private repositories med det. Det er sat op som en af de dovne mise-stubs, så første gang du kører `gh`, installerer det sig selv. For at autentificere dig skal du køre `gh auth login`. Derefter kan du checke private repositories ud ved hjælp af `gh repo clone org/repo`.

Du kan også udføre en masse andre GitHub-operationer med denne kommando. Kør bare `gh` for at se alt, hvad der er muligt.

Der findes også en doven stub til `ghui` til at administrere dine pull requests i et TUI. Og [lazygit](https://github.com/jesseduffield/lazygit) er forudinstalleret, hvis du også gerne vil styre git selv fra et TUI.
