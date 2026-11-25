# Ontwikkeltools

## Alternatieve editors

Omarchy wordt op nieuwe installaties geleverd met Plain als standaardeditor en [Neovim](https://neovim.io/) vooraf geïnstalleerd, maar als je iets wilt dat wat gangbaarder en vertrouwder is, kun je het Omarchy Menu (`Super + Space`) openen en de opties bekijken onder _Install > Editor_. We hebben daar VSCode, Cursor, Zed, Sublime Text, Helix, Vim en Emacs staan. Als je niet vindt wat je zoekt, kijk dan bij _Install > Package_ en kijk of het niet in een Arch-pakket zit (en zo niet, probeer dan _Install > AUR_ om de AUR te controleren).

De oorspronkelijke `vi`-editor is ook direct uit de doos beschikbaar. Voer `vi filename` uit om een bestand in de terminal te bewerken.

Themakoppeling wordt aangeboden voor `VSCode`, `Cursor`, `VSCodium` en `Helix`.

Je kunt de systeembrede standaardeditor instellen onder `Setup > Defaults > Editor`.

## Omgeving

Omarchy ondersteunt het instellen van een hele reeks ontwikkelomgevingen via de sectie _Install > Development_ van het Omarchy Menu (`Super + Space`). Je vindt daar natuurlijk _Ruby on Rails_, maar ook alle drie de grote runtimes voor JavaScript (Node.js, Bun, Deno), evenals populaire PHP-frameworks zoals Laravel en Symfony. Oh, en er is ook Go, Rust, Python, Java, Elixir (met Phoenix), .NET, OCaml, Zig, Clojure en Scala. Het is een zeer brede selectie!

Het merendeel van deze omgevingen wordt beheerd door [Mise](https://mise.jdx.dev/). Het is een tool waarmee je meerdere versies van een programmeertaal op dezelfde machine kunt installeren en uitvoeren. Het is als rbenv of rvm voor Ruby of virtualenv voor Python, maar het werkt voor een heleboel verschillende omgevingen.

Om bijvoorbeeld Ruby te installeren, voer je `mise use -g ruby` uit, waarmee Ruby zowel wordt geïnstalleerd als als globale standaard wordt ingesteld. Of, als je project een .ruby-version-bestand heeft, kun je gewoon `mise i` uitvoeren in de root van dat project.

## Vooraf geïnstalleerde CLI-tools

`uv`, Node.js en `playwright-cli` (zodat agents een browser kunnen aansturen, met de geïnstalleerde Chrome) worden als pakketten geïnstalleerd, en `omarchy update` houdt ze samen met de rest van het systeem actueel. `ghui`, [Hunk](https://github.com/modem-dev/hunk) en de Basecamp-, Cloudflare- en HEY-CLI's zijn met één keuze te installeren onder _Install > CLI_, en [codeeragents](17-ai.md) onder _Install > AI > CLI_.

mise beheert alleen de runtimes die je instelt via _Install > Development_; Omarchy installeert er zelf niets mee. Voer `omarchy update` uit om ze samen met de rest van Omarchy bij te werken; de alias `mup` werkt alleen mise-beheerde tools bij. Om een andere tool aan je eigen configuratie toe te voegen, gebruik je `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) behoeft nauwelijks introductie. Hiermee kun je geïsoleerde containers draaien, en Omarchy installeert alles wat nodig is om het goed te draaien, inclusief Docker zelf en [Docker Compose](https://docs.docker.com/compose/).

Standaard zit je gebruiker *niet* in de `docker`-groep. Die groep is in feite root zonder wachtwoord — alles daarin kan `docker run -v /:/host` uitvoeren en de machine overnemen — dus een enkel malafide script of een dependency die als jou draait, zou anders één commando verwijderd zijn van root. Dus op de commandoregel voer je Docker uit met `sudo` (`sudo docker ps`, `sudo docker compose up`), en de grafische tools die met de daemon praten — de Windows VM — vragen om autorisatie wanneer ze die nodig hebben. Als je het gemak van een groeploze setup terug wilt en de afweging begrijpt, schakel het dan in via **Setup > Security > Sudoless Docker** (of voer `omarchy-setup-security-sudoless-docker` uit), waarmee je na een waarschuwing aan de `docker`-groep wordt toegevoegd; daarna werken gewone `docker` en de alias `d` weer zonder `sudo`.

Je kunt de gangbare databases voor lokale ontwikkeling in Docker instellen via _Install > Development > Docker DB_ in het Omarchy-menu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) is `gh`, om vanuit de terminal met repositories, issues en pull requests te werken. _Setup > Git_ installeert het wanneer je ervoor kiest om je daar bij GitHub aan te melden, daarna kloont `gh repo clone org/repo` een repository. Voer `gh --help` uit om de commando's ervan te verkennen.

_Install > CLI > GitHub_ installeert de GitHub CLI, `gh`, samen met `ghui`, een terminalinterface voor pull requests. [Lazygit](https://github.com/jesseduffield/lazygit) is vooraf geïnstalleerd om met Git zelf te werken.
