# Utvecklingsverktyg

## Alternativa editorer

Omarchy levereras med [Neovim](https://neovim.io/) som standard, men om du vill ha något lite mer etablerat och bekant kan du öppna Omarchy-menyn (`Super + Space`) och se alternativen under _Installera > Editor_. Där finns VSCode, Cursor, Zed, Sublime Text, Helix, Vim och Emacs. Om du inte hittar det du letar efter kan du titta under _Installera > Package_ och se om det finns som ett Arch-paket (och om inte, prova _Installera > AUR_ för att söka i AUR).

Den ursprungliga `vi`-editorn finns också tillgänglig direkt från start. Kör `vi filename` för att redigera en fil i terminalen.

Temamatchning erbjuds för `VSCode`, `Cursor`, `VSCodium` och `Helix`.

Du kan ange systemets standardeditor under `Installation > Standards > Editor`.

## Miljö

Omarchy stöder att sätta upp en hel mängd utvecklingsmiljöer via avsnittet _Installera > Development_ i Omarchy-menyn (`Super + Space`). Där hittar du förstås _Ruby on Rails_, men också alla tre stora körtidsmiljöerna för JavaScript (Node.js, Bun, Deno), liksom populära PHP-ramverk som Laravel och Symfony. Ja, och det finns Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure och Scala också. Det är ett väldigt brett urval!

Merparten av dessa miljöer hanteras av [Mise](https://mise.jdx.dev/). Det är ett verktyg som låter dig installera och köra flera versioner av ett programmeringsspråk på samma maskin. Det är som rbenv eller rvm för Ruby eller virtualenv för Python, men det fungerar för en massa olika miljöer.

För att installera till exempel Ruby kör du `mise use -g ruby`, vilket både installerar Ruby och sätter det som globalt standardval. Eller, om ditt projekt har en .ruby-version-fil, kan du bara köra `mise i` i projektets rot.

## Docker

[Docker](https://www.docker.com/) behöver knappast någon introduktion. Det låter dig köra isolerade containrar, och Omarchy installerar allt som behövs för att köra det ordentligt, inklusive själva Docker och [Docker Compose](https://docs.docker.com/compose/).

Som standard är din användare *inte* med i gruppen `docker`. Den gruppen är i praktiken lösenordsfri root — allt i den kan köra `docker run -v /:/host` och ta över maskinen — så ett enda skurkaktigt skript eller beroende som körs som du skulle annars vara ett kommando från root. Så på kommandoraden kör du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), och de grafiska verktyg som pratar med daemonen — Windows-VM:en — ber om behörighet när de behöver det. Om du vill ha bekvämligheten med en grupplös uppsättning tillbaka och förstår kompromissen kan du aktivera det från **Installation > Security > Sudoless Docker** (eller köra `omarchy-setup-security-sudoless-docker`), vilket lägger till dig i gruppen `docker` efter en varning; sedan fungerar vanlig `docker` och aliaset `d` utan `sudo` igen.

Du kan sätta upp de vanliga databaserna för lokal utveckling i Docker via _Installera > Development > Docker DB_ i Omarchy-menyn.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) låter dig autentisera dig med ditt GitHub-konto och klona privata repositories med det. Det är inkopplat som en av de lazy-loading mise-stubbarna, så första gången du kör `gh` installerar det sig själv. För att autentisera dig, kör `gh auth login`. Sedan kan du klona privata repositories med `gh repo clone org/repo`.

Du kan också utföra en massa andra GitHub-åtgärder med det här kommandot. Kör bara `gh` för att se allt som är möjligt.

Det finns också en lazy-installerad stubbe för `ghui` för att hantera dina pull requests i ett TUI. Och [lazygit](https://github.com/jesseduffield/lazygit) är förinstallerat, om du vill köra git självt från ett TUI också.
