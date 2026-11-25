# Utvecklingsverktyg

## Alternativa redigerare

Omarchy levereras med Plain som standardredigerare på nya installationer och [Neovim](https://neovim.io/) förinstallerat, men om du vill ha något lite mer mainstream och bekant kan du köra Omarchy Menu (`Super + Space`) och se alternativen under _Install > Editor_. Vi har VSCode, Cursor, Zed, Sublime Text, Helix, Vim och Emacs listade där. Om du inte hittar det du letar efter, kolla _Install > Package_, och se om det inte finns i ett Arch-paket (och om inte, prova _Install > AUR_ för att kolla i AUR).

Den ursprungliga `vi`-redigeraren finns också tillgänglig direkt från start. Kör `vi filename` för att redigera en fil i terminalen.

Temamatchning erbjuds för `VSCode`, `Cursor`, `VSCodium` och `Helix`.

Du kan ställa in systemets standardredigerare under `Setup > Defaults > Editor`.

## Utvecklingsmiljöer

Omarchy stöder att sätta upp en hel uppsättning utvecklingsmiljöer via avsnittet _Install > Development_ i Omarchy Menu (`Super + Space`). Där hittar du förstås _Ruby on Rails_, men också alla tre stora runtime-miljöer för JavaScript (Node.js, Bun, Deno), samt populära PHP-ramverk som Laravel och Symfony. Åh, och det finns Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure och Scala också. Det är ett väldigt brett urval!

Majoriteten av dessa miljöer hanteras av [Mise](https://mise.jdx.dev/). Det är ett verktyg som låter dig installera och köra flera versioner av ett programmeringsspråk på samma maskin. Det är som rbenv eller rvm för Ruby eller virtualenv för Python, men det fungerar för en massa olika miljöer.

För att installera, säg, Ruby, kör du `mise use -g ruby`, vilket både installerar Ruby och ställer in den som globalt standardval. Eller, om ditt projekt har en .ruby-version-fil, kan du bara köra `mise i` i roten av det projektet.

## Förinstallerade CLI-verktyg

`uv`, Node.js och `playwright-cli` (för att agenter ska kunna styra en webbläsare, med den installerade Chrome) kommer installerade som paket, och `omarchy update` håller dem uppdaterade tillsammans med resten av systemet. `ghui`, [Hunk](https://github.com/modem-dev/hunk) och CLI:erna för Basecamp, Cloudflare och HEY finns ett val bort under _Install > CLI_, och [kodningsagenter](17-ai.md) under _Install > AI > CLI_.

mise hanterar bara de runtime-miljöer du sätter upp från _Install > Development_; Omarchy installerar ingenting genom det på egen hand. Kör `omarchy update` för att uppdatera dem tillsammans med resten av Omarchy; aliaset `mup` uppdaterar bara mise-hanterade verktyg. För att lägga till ett annat verktyg i din egen konfiguration, använd `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) behöver knappast någon introduktion. Det låter dig köra isolerade containers, och Omarchy installerar allt som behövs för att köra det bra, inklusive Docker självt och [Docker Compose](https://docs.docker.com/compose/).

Som standard är din användare *inte* med i gruppen `docker`. Den gruppen är i praktiken root utan lösenord — allt i den kan köra `docker run -v /:/host` och ta över maskinen — så ett enda illvilligt skript eller beroende som körs som du skulle annars vara ett enda kommando från root. Så på kommandoraden kör du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), och de grafiska verktygen som pratar med daemonen — Windows VM:en — ber om auktorisering när de behöver det. Om du vill ha bekvämligheten med en grupplös uppsättning tillbaka och förstår avvägningen, aktivera den från **Setup > Security > Sudoless Docker** (eller kör `omarchy-setup-security-sudoless-docker`), vilket lägger till dig i gruppen `docker` efter en varning; då fungerar vanligt `docker` och aliaset `d` utan `sudo` igen.

Du kan sätta upp de vanliga databaserna för lokal utveckling i Docker med _Install > Development > Docker DB_ i Omarchy-menyn.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) är `gh`, för att arbeta med repositories, issues och pull requests från terminalen. _Setup > Git_ installerar det när du väljer att logga in på GitHub där, sedan klonar `gh repo clone org/repo` ett repository. Kör `gh --help` för att utforska dess kommandon.

_Install > CLI > GitHub_ installerar GitHub CLI, `gh`, tillsammans med `ghui`, ett terminalgränssnitt för pull requests. [Lazygit](https://github.com/jesseduffield/lazygit) är förinstallerat för att arbeta med Git självt.
