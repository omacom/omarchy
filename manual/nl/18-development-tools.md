# Ontwikkeltools

## Alternatieve editors

Omarchy levert Plain als standaardeditor op nieuwe installaties en met [Neovim](https://neovim.io/) voorgeïnstalleerd, maar als je liever iets gangbaarders en vertrouwders hebt, kun je het Omarchy Menu (`Super + Space`) openen en de opties bekijken onder _Installeren > Editor_. Daar staan VSCode, Cursor, Zed, Sublime Text, Helix, Vim en Emacs voor je klaar. Vind je niet wat je zoekt, kijk dan onder _Installeren > Pakket_ of het niet in een Arch-pakket zit (en zo niet, probeer dan _Installeren > AUR_ om de AUR te controleren).

De originele `vi`-editor is ook standaard beschikbaar. Voer `vi filename` uit om een bestand in de terminal te bewerken.

Thema-afstemming wordt aangeboden voor `VSCode`, `Cursor`, `VSCodium` en `Helix`.

Je kunt de systeembrede standaardeditor instellen onder `Setup > Defaults > Editor`.

## Omgeving

Omarchy ondersteunt het opzetten van een hele reeks ontwikkelomgevingen via het gedeelte _Installeren > Ontwikkeling_ van het Omarchy Menu (`Super + Space`). Je vindt er natuurlijk _Ruby on Rails_, maar ook alle drie de grote runtimes voor JavaScript (Node.js, Bun, Deno), plus populaire PHP-frameworks zoals Laravel en Symfony. Oh, en er zijn ook Go, Rust, Python, Java, Elixir (met Phoenix), .NET, OCaml, Zig, Clojure en Scala. Het is een zeer brede selectie!

De meeste van deze omgevingen worden beheerd door [Mise](https://mise.jdx.dev/). Het is een tool waarmee je meerdere versies van een programmeertaal op dezelfde machine kunt installeren en uitvoeren. Het is als rbenv of rvm voor Ruby of virtualenv voor Python, maar dan voor een heleboel verschillende omgevingen.

Om bijvoorbeeld Ruby te installeren, voer je `mise use -g ruby` uit, waarmee Ruby zowel wordt geïnstalleerd als ingesteld als de globale standaard. Of, als je project een .ruby-version-bestand heeft, kun je gewoon `mise i` uitvoeren in de hoofdmap van dat project.

## Voorgeïnstalleerde CLI-tools

Omarchy stelt tools zoals `gh`, `uv` en de meeste [codeeragents](17-ai.md) beschikbaar via de [luie installatie van mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). De eerste keer dat je er een uitvoert, installeert mise die. Codeeragents controleren vervolgens vóór het uitvoeren op een update, hooguit eens per vier uur; andere tools, zoals `gh` en `uv`, blijven de geïnstalleerde versie gebruiken totdat je bijwerkt.

Je kunt de standaardinstellingen ook bekijken of ze vooraf installeren:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Voer `omarchy update` uit om geïnstalleerde tools samen met de rest van Omarchy bij te werken. De alias `mup` werkt alleen mise-beheerde tools bij. Gebruik `mise use -g <tool>` om een andere tool aan je eigen configuratie toe te voegen.

De Python-configuratie installeert via mise ook `uv`. Als je de Python-ontwikkelomgeving verwijdert, blijft `uv` als onafhankelijke tool beschikbaar.

### Je eigen installatie gebruiken

De commando's van mise staan vóór `~/.local/bin` op `PATH`, dus een tool die je zelf hebt geïnstalleerd, bijvoorbeeld met de eigen installer van Claude Code of Cursor, voert nog steeds de kopie van mise uit. Apps die vanaf het bureaublad worden gestart, vinden de commando's van mise ook vóór systeempakketten, dus een app die `gh` uitvoert, krijgt de kopie van mise, zelfs als je `github-cli` met pacman hebt geïnstalleerd, en mise installeert die kopie de eerste keer. Om in plaats daarvan de jouwe te gebruiken, schakel je de kopie van mise uit in `~/.config/mise/config.toml`. Bijvoorbeeld als je Cursor CLI zelf hebt geïnstalleerd:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Als je al een `[settings]`-tabel hebt, voeg je daar de vermelding toe; breid een bestaande `disable_tools`-lijst uit in plaats van die te vervangen. Zorg ervoor dat je installatie op `PATH` staat. Gebruik de naam van de mise-tool, die kan verschillen van het bijbehorende commando: `oh-my-pi` levert bijvoorbeeld `omp`. De launcher voor de standaardagent geeft ook de voorkeur aan een door de gebruiker geïnstalleerde Cursor of Muse in `~/.local/bin`.

### Standaardinstellingen verwijderen en herstellen

_Verwijderen > Voorinstallaties_ verwijdert de voorgeïnstalleerde webapps, TUI's en apps van Omarchy en laat mise de tooldeclaraties van Omarchy voor jouw gebruiker overslaan door ze toe te voegen aan `ignored_config_paths` in `~/.config/mise/miserc.toml`. _Installeren > Voorinstallaties_ brengt ze terug en verwijdert die regel weer. Tools die je zelf declareert, in je eigen configuratie of in de `mise.toml` van een project, blijven in beide gevallen werken. Als je een standaardagent kiest of Python instelt nadat je de voorinstallaties hebt verwijderd, wordt die tool toegevoegd aan je eigen configuratie. De mise-instelling geldt alleen voor jouw gebruiker en andere gebruikers behouden hun eigen keuze; de apps zijn echter pakketten, dus door ze te verwijderen of te herstellen verander je ze voor iedereen op de machine.

## Docker

[Docker](https://www.docker.com/) behoeft nauwelijks introductie. Hiermee kun je geïsoleerde containers draaien, en Omarchy installeert alles wat nodig is om dat goed te laten werken, inclusief Docker zelf en [Docker Compose](https://docs.docker.com/compose/).

Standaard zit je gebruiker *niet* in de `docker`-groep. Die groep is in feite root zonder wachtwoord — alles in die groep kan `docker run -v /:/host` uitvoeren en de machine overnemen — dus een enkel kwaadaardig script of een dependency die als jou draait, zou anders één commando verwijderd zijn van root. Dus voer je Docker op de commandoregel uit met `sudo` (`sudo docker ps`, `sudo docker compose up`), en de grafische tools die met de daemon praten — de Windows VM — vragen om autorisatie wanneer dat nodig is. Als je het gemak van een opstelling zonder groep terug wilt en de afweging begrijpt, schakel je dat in via **Instellen > Beveiliging > Sudoless Docker** (of voer je `omarchy-setup-security-sudoless-docker` uit), waarmee je na een waarschuwing aan de `docker`-groep wordt toegevoegd; daarna werken gewone `docker` en de alias `d` weer zonder `sudo`.

Je kunt de gangbare databases voor lokale ontwikkeling in Docker instellen via _Installeren > Ontwikkeling > Docker DB_ in het Omarchy-menu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) is beschikbaar als `gh` om vanuit de terminal met repositories, issues en pull requests te werken. Voer `gh auth login` uit om het bij het eerste gebruik te installeren en te authenticeren, en daarna `gh repo clone org/repo` om een repository te klonen. Voer `gh --help` uit om de commando's te verkennen.

Voor een terminalinterface voor pull requests voer je `ghui` uit; mise installeert dat ook bij het eerste gebruik. [Lazygit](https://github.com/jesseduffield/lazygit) is voorgeïnstalleerd om met Git zelf te werken.
