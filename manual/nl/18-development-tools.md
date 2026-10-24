# Ontwikkeltools

## Alternatieve editors

Omarchy wordt standaard geleverd met [Neovim](https://neovim.io/), maar als je iets gangbaarders en vertrouwders wilt, open je het Omarchy-menu (`Super + Space`) en bekijk je de opties onder _Installeren > Editor_. Daar staan VSCode, Cursor, Zed, Sublime Text, Helix, Vim en Emacs vermeld. Als je niet vindt wat je zoekt, kijk dan bij _Installeren > Pakket_ en controleer of het niet in een Arch-pakket zit (en zo niet, probeer dan _Installeren > AUR_ om de AUR te controleren).

De originele `vi`-editor is ook direct beschikbaar. Voer `vi filename` uit om een bestand in de terminal te bewerken.

Thema-afstemming wordt aangeboden voor `VSCode`, `Cursor`, `VSCodium` en `Helix`.

Je kunt de systeemwijde standaardeditor instellen onder `Instellen > Standaardwaarden > Editor`.

## Omgeving

Omarchy ondersteunt het opzetten van een hele reeks ontwikkelomgevingen via de sectie _Installeren > Ontwikkeling_ van het Omarchy-menu (`Super + Space`). Je vindt daar natuurlijk _Ruby on Rails_, maar ook alle drie de grote runtimes voor JavaScript (Node.js, Bun, Deno), evenals populaire PHP-frameworks zoals Laravel en Symfony. Oh, en er zijn ook Go, Rust, Python, Java, Elixir (met Phoenix), .NET, OCaml, Zig, Clojure en Scala. Het is een zeer brede selectie!

De meeste van deze omgevingen worden beheerd door [Mise](https://mise.jdx.dev/). Het is een tool waarmee je meerdere versies van een programmeertaal op dezelfde machine kunt installeren en uitvoeren. Het is als rbenv of rvm voor Ruby of virtualenv voor Python, maar het werkt voor een heleboel verschillende omgevingen.

Om bijvoorbeeld Ruby te installeren, voer je `mise use -g ruby` uit, waarmee Ruby zowel wordt geïnstalleerd als als globale standaard wordt ingesteld. Of, als je project een .ruby-version-bestand heeft, kun je gewoon `mise i` uitvoeren in de root van dat project.

## Docker

[Docker](https://www.docker.com/) behoeft nauwelijks introductie. Hiermee kun je geïsoleerde containers uitvoeren, en Omarchy installeert alles wat nodig is om het goed te laten draaien, inclusief Docker zelf en [Docker Compose](https://docs.docker.com/compose/).

Standaard zit je gebruiker *niet* in de `docker`-groep. Die groep is in feite root zonder wachtwoord — alles daarin kan `docker run -v /:/host` uitvoeren en de machine overnemen — dus een enkel malafide script of een malafide afhankelijkheid die als jou draait, zou anders één commando verwijderd zijn van root. Dus op de commandoregel voer je Docker uit met `sudo` (`sudo docker ps`, `sudo docker compose up`), en de grafische tools die met de daemon praten — de Windows-VM — vragen om autorisatie wanneer ze dat nodig hebben. Als je het gemak van een groeploze opstelling terug wilt en de afweging begrijpt, schakel het dan in via **Instellen > Beveiliging > Docker zonder sudo** (of voer `omarchy-setup-security-sudoless-docker` uit), waarmee je na een waarschuwing aan de `docker`-groep wordt toegevoegd; dan werken gewone `docker` en de `d`-alias weer zonder `sudo`.

Je kunt de gangbare databases voor lokale ontwikkeling in Docker opzetten via _Installeren > Ontwikkeling > Docker DB_ in het Omarchy-menu.

## GitHub CLI

[De GitHub CLI](https://cli.github.com/) laat je authenticeren met je GitHub-account en er private repositories mee klonen. Het is aangesloten als een van de lui-ladende mise-stubs, dus de eerste keer dat je `gh` uitvoert, installeert het zichzelf. Voer `gh auth login` uit om te authenticeren. Daarna kun je private repositories uitchecken met `gh repo clone org/repo`.

Je kunt met dit commando ook een heleboel andere GitHub-bewerkingen uitvoeren. Voer gewoon `gh` uit om alles te zien wat mogelijk is.

Er is ook een lui-installerende stub voor `ghui` om je pull requests in een TUI te beheren. En [lazygit](https://github.com/jesseduffield/lazygit) is vooraf geïnstalleerd, als je git zelf ook vanuit een TUI wilt aansturen.
