# Utvecklingsverktyg

## Alternativa editorer

Omarchy levereras med [Neovim](https://neovim.io/) som standard, men om du vill ha något lite mer mainstream och bekant kan du öppna Omarchy Menu (`Super + Space`) och se alternativen under _Install > Editor_. Där har vi VSCode, Cursor, Zed, Sublime Text, Helix, Vim och Emacs listade. Om du inte hittar det du letar efter, titta under _Install > Package_ och se om det inte finns som ett Arch-paket (och om inte, prova _Install > AUR_ för att kontrollera AUR).

Den ursprungliga `vi`-editorn finns också tillgänglig direkt från start. Kör `vi filename` för att redigera en fil i terminalen.

Temamatchning erbjuds för `VSCode`, `Cursor`, `VSCodium` och `Helix`.

Du kan ställa in systemets standardeditor under `Setup > Defaults > Editor`.

## Miljöer

Omarchy har stöd för att sätta upp en hel uppsjö utvecklingsmiljöer genom avsnittet _Install > Development_ i Omarchy Menu (`Super + Space`). Där hittar du naturligtvis _Ruby on Rails_, men också alla tre stora runtimes för JavaScript (Node.js, Bun, Deno), liksom populära PHP-ramverk som Laravel och Symfony. Åh, och det finns Go, Rust, Python, Java, Elixir (med Phoenix), .NET, OCaml, Zig, Clojure och Scala också. Det är ett mycket brett urval!

Majoriteten av dessa miljöer hanteras av [Mise](https://mise.jdx.dev/). Det är ett verktyg som låter dig installera och köra flera versioner av ett programmeringsspråk på samma dator. Det är som rbenv eller rvm för Ruby eller virtualenv för Python, men det fungerar för en hel massa olika miljöer.

För att installera till exempel Ruby kör du `mise use -g ruby`, vilket både installerar Ruby och ställer in det som globalt standardval. Eller, om ditt projekt har en .ruby-version-fil, kan du bara köra `mise i` i roten av det projektet.

## Förinstallerade CLI-verktyg

Omarchy gör verktyg som `gh`, `uv` och de flesta [kodagenter](17-ai.md) tillgängliga genom [mises lata installation](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Första gången du kör ett av dem installerar mise det. Senare körningar återanvänder den installerade versionen; de kontrollerar inte efter en uppdatering vid varje start.

Du kan också inspektera standardverktygen eller installera dem i förväg:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Kör `omarchy update` för att uppdatera installerade verktyg tillsammans med resten av Omarchy. Aliaset `mup` uppdaterar endast mise-hanterade verktyg. För att lägga till ett annat verktyg i din egen konfiguration använder du `mise use -g <tool>`.

Python-uppsättningen installerar också `uv` genom mise. Om du tar bort Python-utvecklingsmiljön förblir `uv` tillgängligt som ett oberoende verktyg.

### Använda din egen installation

mises kommandon kommer före `~/.local/bin` i `PATH`, så ett verktyg som du installerat själv, till exempel med Claude Codes eller Cursors egna installerare, kör ändå mises kopia. Appar som startas från skrivbordet hittar också mises kommandon före systempaket, så en app som kör `gh` får mises kopia även om du installerade `github-cli` med pacman, och mise installerar den kopian första gången. För att använda din egen i stället inaktiverar du mises kopia i `~/.config/mise/config.toml`. Om du till exempel installerade Cursor CLI själv:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Om du redan har en `[settings]`-tabell lägger du till posten där; utöka en befintlig `disable_tools`-lista i stället för att ersätta den. Se till att din installation finns i `PATH`. Använd mise-verktygets namn, som kan skilja sig från dess kommando: `oh-my-pi` tillhandahåller till exempel `omp`. Standardagentens startprogram föredrar också en användarinstallerad Cursor eller Muse i `~/.local/bin`.

### Ta bort och återställa standardverktyg

_Remove Preinstalls_ gör att mise hoppar över Omarchys verktygsdeklarationer för din användare, genom att lägga till dem i `ignored_config_paths` i `~/.config/mise/miserc.toml`. _Restore Preinstalls_ tar bort den raden igen. Verktyg som du deklarerar själv, i din egen konfiguration eller i ett projekts `mise.toml`, fortsätter att fungera oavsett. Om du väljer en standardagent eller sätter upp Python efter att du tagit bort de förinstallerade verktygen läggs det verktyget till i din egen konfiguration. Båda gäller endast för din användare; andra användare på datorn behåller sina egna val.

## Docker

[Docker](https://www.docker.com/) behöver knappast någon introduktion. Det låter dig köra isolerade containers, och Omarchy installerar allt som behövs för att köra det bra, inklusive Docker självt och [Docker Compose](https://docs.docker.com/compose/).

Som standard tillhör din användare *inte* gruppen `docker`. Den gruppen är i praktiken root utan lösenord — allt i den kan köra `docker run -v /:/host` och ta över datorn — så ett enda oseriöst skript eller beroende som körs som du skulle annars vara ett kommando från root. Så på kommandoraden kör du Docker med `sudo` (`sudo docker ps`, `sudo docker compose up`), och de grafiska verktyg som pratar med daemonen — Windows VM:en — ber om auktorisering när de behöver det. Om du vill ha tillbaka bekvämligheten med en grupplös uppsättning och förstår kompromissen aktiverar du den från **Setup > Security > Sudoless Docker** (eller kör `omarchy-setup-security-sudoless-docker`), vilket lägger till dig i gruppen `docker` efter en varning; sedan fungerar vanligt `docker` och aliaset `d` utan `sudo` igen.

Du kan sätta upp de vanliga databaserna för lokal utveckling i Docker med _Install > Development > Docker DB_ i Omarchy-menyn.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) finns tillgängligt som `gh` för att arbeta med repositoryn, issues och pull requests från terminalen. Kör `gh auth login` för att installera det vid första användningen och autentisera dig, och sedan `gh repo clone org/repo` för att klona ett repository. Kör `gh --help` för att utforska dess kommandon.

För ett terminalgränssnitt för pull requests kör du `ghui`; mise installerar det också vid första användningen. [Lazygit](https://github.com/jesseduffield/lazygit) är förinstallerat för att arbeta med Git självt.
