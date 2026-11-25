# Razvojni alati

## Alternativni uređivači

Omarchy na novim instalacijama dolazi s uređivačem Plain kao zadanim uređivačem i unaprijed instaliranim [Neovimom](https://neovim.io/), ali ako želite nešto malo uobičajenije i poznatije, možete pokrenuti Omarchy Menu (`Super + Space`) i pogledati opcije pod _Install > Editor_. Ondje su navedeni VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Ako ne pronađete ono što tražite, pogledajte _Install > Package_ i provjerite nije li u nekom Arch paketu (a ako nije, pokušajte s _Install > AUR_ da provjerite AUR).

Izvorni uređivač `vi` također je dostupan odmah po instalaciji. Pokrenite `vi filename` da biste uredili datoteku u terminalu.

Usklađivanje teme nudi se za `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Zadani uređivač za cijeli sustav možete postaviti pod `Setup > Defaults > Editor`.

## Okruženje

Omarchy podržava postavljanje cijelog niza razvojnih okruženja putem odjeljka _Install > Development_ u izborniku Omarchy Menu (`Super + Space`). Ondje ćete, naravno, pronaći _Ruby on Rails_, ali i sva tri glavna runtime okruženja za JavaScript (Node.js, Bun, Deno), kao i popularne PHP frameworke poput Laravela i Symfonyja. Oh, a tu su i Go, Rust, Python, Java, Elixir (s Phoenixom), .NET, OCaml, Zig, Clojure i Scala. Izbor je doista vrlo širok!

Većinom tih okruženja upravlja [Mise](https://mise.jdx.dev/). To je alat koji vam omogućuje instaliranje i pokretanje više verzija programskog jezika na istom računalu. Poput je rbenva ili rvma za Ruby ili virtualenva za Python, ali radi za hrpu različitih okruženja.

Da biste instalirali, recimo, Ruby, pokrenuli biste `mise use -g ruby`, čime ćete Ruby i instalirati i postaviti kao globalno zadani. Ili, ako vaš projekt ima datoteku .ruby-version, možete jednostavno pokrenuti `mise i` u korijenu tog projekta.

## Unaprijed instalirani CLI alati

`uv`, Node.js i `playwright-cli` (da agenti mogu upravljati preglednikom pomoću instaliranog Chromea) dolaze instalirani kao paketi, a `omarchy update` održava ih ažurnima zajedno s ostatkom sustava. [Hunk](https://github.com/modem-dev/hunk) te GitHub, Basecamp, Cloudflare i HEY CLI-jevi udaljeni su samo jedan odabir pod _Install > CLI_, a [agenti za programiranje](17-ai.md) pod _Install > AI > CLI_.

mise upravlja samo runtime okruženjima koja postavite iz _Install > Development_; Omarchy sam putem njega ništa ne instalira. Pokrenite `omarchy update` da biste ih ažurirali zajedno s ostatkom Omarchyja; alias `mup` ažurira samo alate kojima upravlja mise. Da biste u vlastitu konfiguraciju dodali još jedan alat, upotrijebite `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) teško da treba ikakvo predstavljanje. Omogućuje vam pokretanje izoliranih spremnika, a Omarchy instalira sve što je potrebno da bi dobro radio, uključujući sam Docker i [Docker Compose](https://docs.docker.com/compose/).

Vaš korisnik prema zadanim postavkama *nije* u grupi `docker`. Ta je grupa zapravo root bez lozinke — sve što je u njoj može pokrenuti `docker run -v /:/host` i preuzeti računalo — pa bi inače jedna jedina zlonamjerna skripta ili ovisnost koja se pokreće pod vašim korisnikom bila samo jednu naredbu udaljena od roota. Zato u naredbenom retku Docker pokrećete sa `sudo` (`sudo docker ps`, `sudo docker compose up`), a grafički alati koji komuniciraju s demonom — Windows VM — traže autorizaciju kada im je potrebna. Ako želite natrag praktičnost postavke bez grupe i razumijete kompromis, omogućite je iz **Setup > Security > Sudoless Docker** (ili pokrenite `omarchy-setup-security-sudoless-docker`), čime ćete nakon upozorenja biti dodani u grupu `docker`; tada običan `docker` i alias `d` ponovno rade bez `sudo`.

Uobičajene baze podataka za lokalni razvoj u Dockeru možete postaviti pomoću _Install > Development > Docker DB_ u izborniku Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je `gh`, za rad s repozitorijima, issueima i pull requestovima iz terminala. _Setup > Git_ instalira ga kada se ondje odlučite prijaviti na GitHub, ili ga instalirajte zasebno iz _Install > CLI > GitHub_. Zatim `gh repo clone org/repo` klonira repozitorij; pokrenite `gh --help` da biste istražili njegove naredbe.

[Lazygit](https://github.com/jesseduffield/lazygit) unaprijed je instaliran za rad sa samim Gitom.
