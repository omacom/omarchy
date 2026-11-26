# Ontwikkeltools

## Alternatieve editors

Omarchy wordt op nieuwe installaties geleverd met Plain als standaardeditor en [Neovim](https://neovim.io/) vooraf geïnstalleerd, maar als je liever iets gangbaarders en vertrouwders hebt, kun je het Omarchy Menu (`Super + Space`) openen en de opties bekijken onder _Install > Editor_. Daar vind je VSCode, Cursor, Zed, Sublime Text, Helix, Vim en Emacs. Als je niet vindt wat je zoekt, kijk dan bij _Install > Package_ of het niet in een Arch-pakket zit (en zo niet, probeer dan _Install > AUR_ om de AUR te controleren).

De originele `vi`-editor is ook direct beschikbaar. Voer `vi filename` uit om een bestand in de terminal te bewerken.

Voor `VSCode`, `Cursor`, `VSCodium` en `Helix` wordt thema-afstemming aangeboden.

Je kunt de systeemwijde standaardeditor instellen onder `Setup > Defaults > Editor`.

## Omgeving

Via het onderdeel _Install > Development_ van het Omarchy Menu (`Super + Space`) kun je met Omarchy een hele reeks ontwikkelomgevingen instellen. Je vindt er uiteraard _Ruby on Rails_, maar ook alle drie de grote runtimes voor JavaScript (Node.js, Bun, Deno), evenals populaire PHP-frameworks zoals Laravel en Symfony. Oh, en er zijn ook Go, Rust, Python, Java, Elixir (met Phoenix), .NET, OCaml, Zig, Clojure en Scala. Het is een zeer brede selectie!

Het merendeel van deze omgevingen wordt beheerd door [Mise](https://mise.jdx.dev/). Het is een tool waarmee je meerdere versies van een programmeertaal op dezelfde machine kunt installeren en uitvoeren. Het lijkt op rbenv of rvm voor Ruby of virtualenv voor Python, maar het werkt voor een heleboel verschillende omgevingen.

Om bijvoorbeeld Ruby te installeren, voer je `mise use -g ruby` uit, waarmee Ruby zowel wordt geïnstalleerd als als globale standaard wordt ingesteld. Of, als je project een .ruby-version-bestand heeft, kun je gewoon `mise i` uitvoeren in de hoofdmap van dat project.

## Vooraf geïnstalleerde CLI-tools

`uv`, Node.js en `playwright-cli` (waarmee agents een browser kunnen aansturen, met de geïnstalleerde Chrome) worden als pakketten geïnstalleerd, en `omarchy update` houdt ze samen met de rest van het systeem actueel. [Hunk](https://github.com/modem-dev/hunk) en de GitHub-, Basecamp-, Cloudflare- en HEY-CLI's zijn één keuze verwijderd onder _Install > CLI_, en [codeeragents](17-ai.md) onder _Install > AI > CLI_.

mise beheert alleen de runtimes die je instelt via _Install > Development_; Omarchy installeert er zelf niets mee. Voer `omarchy update` uit om ze samen met de rest van Omarchy bij te werken; de alias `mup` werkt alleen door mise beheerde tools bij. Om nog een tool aan je eigen configuratie toe te voegen, gebruik je `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) behoeft nauwelijks introductie. Daarmee kun je geïsoleerde containers draaien, en Omarchy installeert alles wat nodig is om het goed te laten werken, inclusief Docker zelf en [Docker Compose](https://docs.docker.com/compose/).

Standaard zit je gebruiker *niet* in de `docker`-groep. Die groep is in feite root zonder wachtwoord — alles daarin kan `docker run -v /:/host` uitvoeren en de machine overnemen — dus anders zou één enkel malafide script of één dependency die als jou draait, maar één commando verwijderd zijn van root. Op de commandoregel draai je Docker dus met `sudo` (`sudo docker ps`, `sudo docker compose up`), en de grafische tools die met de daemon praten — de Windows VM — vragen om autorisatie wanneer ze die nodig hebben. Als je het gemak van een opstelling zonder groep terug wilt en de afweging begrijpt, schakel dat dan in via **Setup > Security > Sudoless Docker** (of voer `omarchy-setup-security-sudoless-docker` uit), waarmee je na een waarschuwing aan de `docker`-groep wordt toegevoegd; daarna werken gewone `docker` en de alias `d` weer zonder `sudo`.

Je kunt de gangbare databases voor lokale ontwikkeling in Docker instellen via _Install > Development > Docker DB_ in het Omarchy-menu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) is `gh`, om vanuit de terminal met repositories, issues en pull requests te werken. _Setup > Git_ installeert het wanneer je ervoor kiest om je daar bij GitHub aan te melden, of installeer het afzonderlijk via _Install > CLI > GitHub_. Vervolgens kloont `gh repo clone org/repo` een repository; voer `gh --help` uit om de commando's te verkennen.

[Lazygit](https://github.com/jesseduffield/lazygit) is vooraf geïnstalleerd om met Git zelf te werken.
