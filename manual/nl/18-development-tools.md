# Ontwikkeltools

## Alternatieve editors

Omarchy wordt standaard geleverd met [Neovim](https://neovim.io/), maar als je iets mainstreamers en vertrouwders wilt, kun je het Omarchy Menu (`Super + Space`) openen en de opties onder _Install > Editor_ bekijken. Daar staan VSCode, Cursor, Zed, Sublime Text, Helix, Vim en Emacs voor je klaar. Als je niet vindt wat je zoekt, kijk dan bij _Install > Package_ of het niet in een Arch-pakket zit (en zo niet, probeer _Install > AUR_ om in de AUR te zoeken).

De originele `vi`-editor is ook standaard beschikbaar. Voer `vi filename` uit om een bestand in de terminal te bewerken.

Thema-afstemming wordt aangeboden voor `VSCode`, `Cursor`, `VSCodium` en `Helix`.

Je kunt de systeemwijde standaardeditor instellen via `Setup > Defaults > Editor`.

## Omgeving

Omarchy ondersteunt het instellen van een hele reeks ontwikkelomgevingen via de sectie _Install > Development_ van het Omarchy Menu (`Super + Space`). Je vindt er natuurlijk _Ruby on Rails_, maar ook alle drie de grote runtimes voor JavaScript (Node.js, Bun, Deno), evenals populaire PHP-frameworks zoals Laravel en Symfony. Oh, en er zijn ook Go, Rust, Python, Java, Elixir (met Phoenix), .NET, OCaml, Zig, Clojure en Scala. Het is een zeer brede selectie!

De meeste van deze omgevingen worden beheerd door [Mise](https://mise.jdx.dev/). Het is een tool waarmee je meerdere versies van een programmeertaal op dezelfde machine kunt installeren en uitvoeren. Het is net als rbenv of rvm voor Ruby of virtualenv voor Python, maar dan voor een heleboel verschillende omgevingen.

Om bijvoorbeeld Ruby te installeren, voer je `mise use -g ruby` uit. Daarmee installeer je Ruby én stel je het in als de globale standaard. Of, als je project een .ruby-version-bestand heeft, kun je gewoon `mise i` uitvoeren in de hoofdmap van dat project.

## Vooraf geïnstalleerde CLI-tools

Omarchy maakt tools zoals `gh`, `uv` en de meeste [codeeragents](17-ai.md) beschikbaar via [mise's lazy installation](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). De eerste keer dat je er een uitvoert, installeert mise deze. Latere uitvoeringen hergebruiken de geïnstalleerde versie; ze controleren niet bij elke start op een update.

Je kunt ook de standaardinstellingen bekijken of ze vooraf installeren:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Voer `omarchy update` uit om geïnstalleerde tools bij te werken samen met de rest van Omarchy. De alias `mup` werkt alleen mise-beheerde tools bij. Om nog een tool aan je eigen configuratie toe te voegen, gebruik je `mise use -g <tool>`.

De Python-installatie installeert ook `uv` via mise. Als je de Python-ontwikkelomgeving verwijdert, blijft `uv` beschikbaar als onafhankelijke tool.

### Je eigen installatie gebruiken

De commando's van mise komen vóór `~/.local/bin` in `PATH`, dus een tool die je zelf hebt geïnstalleerd, bijvoorbeeld met de eigen installer van Claude Code of Cursor, voert nog steeds de kopie van mise uit. Apps die vanaf het bureaublad worden gestart, vinden de commando's van mise ook vóór systeempakketten, dus een app die `gh` uitvoert, krijgt de kopie van mise, zelfs als je `github-cli` met pacman hebt geïnstalleerd, en mise installeert die kopie bij de eerste uitvoering. Om in plaats daarvan de jouwe te gebruiken, schakel je de kopie van mise uit in `~/.config/mise/config.toml`. Bijvoorbeeld, als je Cursor CLI zelf hebt geïnstalleerd:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Als je al een `[settings]`-tabel hebt, voeg je het item daar toe; breid een bestaande `disable_tools`-lijst uit in plaats van deze te vervangen. Zorg ervoor dat je installatie in `PATH` staat. Gebruik de mise-toolnaam, die kan verschillen van het bijbehorende commando: `oh-my-pi` levert bijvoorbeeld `omp`. De launcher voor de standaardagent geeft ook de voorkeur aan een door de gebruiker geïnstalleerde Cursor of Muse in `~/.local/bin`.

### Standaardinstellingen verwijderen en herstellen

_Remove Preinstalls_ zorgt ervoor dat mise Omarchy's tooldeclaraties voor jouw gebruiker overslaat, door ze toe te voegen aan `ignored_config_paths` in `~/.config/mise/miserc.toml`. _Restore Preinstalls_ verwijdert die regel weer. Tools die je zelf declareert, in je eigen configuratie of in de `mise.toml` van een project, blijven in beide gevallen werken. Als je een standaardagent kiest of Python instelt nadat je de preinstalls hebt verwijderd, wordt die tool toegevoegd aan je eigen configuratie. Beide gelden alleen voor jouw gebruiker; andere gebruikers op de machine behouden hun eigen keuze.

## Docker

[Docker](https://www.docker.com/) behoeft nauwelijks introductie. Hiermee kun je geïsoleerde containers draaien, en Omarchy installeert alles wat nodig is om het goed te laten werken, inclusief Docker zelf en [Docker Compose](https://docs.docker.com/compose/).

Standaard zit je gebruiker *niet* in de groep `docker`. Die groep is in feite root zonder wachtwoord — alles wat erin zit, kan `docker run -v /:/host` uitvoeren en de machine overnemen — dus één enkel kwaadaardig script of één enkele afhankelijkheid die als jou draait, zou anders met één commando root kunnen worden. Dus op de commandoregel voer je Docker uit met `sudo` (`sudo docker ps`, `sudo docker compose up`), en de grafische tools die met de daemon praten — de Windows VM — vragen om autorisatie wanneer ze die nodig hebben. Als je het gemak van een setup zonder groep terug wilt en de afweging begrijpt, schakel dit dan in via **Setup > Security > Sudoless Docker** (of voer `omarchy-setup-security-sudoless-docker` uit). Daarmee word je na een waarschuwing toegevoegd aan de groep `docker`; daarna werken gewoon `docker` en de alias `d` weer zonder `sudo`.

Je kunt de gangbare databases voor lokale ontwikkeling in Docker instellen via _Install > Development > Docker DB_ in het Omarchy-menu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) is beschikbaar als `gh` om vanuit de terminal met repositories, issues en pull requests te werken. Voer `gh auth login` uit om het bij het eerste gebruik te installeren en je te authenticeren, en daarna `gh repo clone org/repo` om een repository te klonen. Voer `gh --help` uit om de commando's te verkennen.

Voor een terminalinterface voor pull requests voer je `ghui` uit; mise installeert dit ook bij het eerste gebruik. [Lazygit](https://github.com/jesseduffield/lazygit) is vooraf geïnstalleerd om met Git zelf te werken.
