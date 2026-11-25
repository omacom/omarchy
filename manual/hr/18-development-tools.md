# Razvojni alati

## Alternativni uređivači

Omarchy se na novim instalacijama isporučuje s Plain kao zadanim uređivačem i predinstaliranim [Neovim](https://neovim.io/), ali ako želite nešto malo više mainstream i poznatije, možete pokrenuti Omarchy Menu (`Super + Space`) i pogledati opcije pod _Install > Editor_. Tamo su navedeni VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Ako ne pronađete ono što tražite, pogledajte _Install > Package_ i provjerite nije li u nekom Arch paketu (a ako nije, pokušajte _Install > AUR_ da provjerite AUR).

Izvorni uređivač `vi` također je dostupan odmah po instalaciji. Pokrenite `vi filename` da uredite datoteku u terminalu.

Usklađivanje teme nudi se za `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Zadani uređivač za cijeli sustav možete postaviti pod `Setup > Defaults > Editor`.

## Okruženje

Omarchy podržava postavljanje čitavog niza razvojnih okruženja kroz odjeljak _Install > Development_ u Omarchy Menu (`Super + Space`). Ondje ćete, naravno, pronaći _Ruby on Rails_, ali i sva tri glavna runtime okruženja za JavaScript (Node.js, Bun, Deno), kao i popularne PHP frameworke poput Laravela i Symfonyja. Oh, a tu su i Go, Rust, Python, Java, Elixir (s Phoenixom), .NET, OCaml, Zig, Clojure i Scala. Izbor je doista vrlo širok!

Većinom tih okruženja upravlja [Mise](https://mise.jdx.dev/). To je alat koji vam omogućuje instaliranje i pokretanje više verzija programskog jezika na istom računalu. Poput je rbenv ili rvm za Ruby ili virtualenv za Python, ali radi za gomilu različitih okruženja.

Da biste instalirali, recimo, Ruby, pokrenuli biste `mise use -g ruby`, što će Ruby i instalirati i postaviti kao globalno zadanu verziju. Ili, ako vaš projekt ima datoteku .ruby-version, možete jednostavno pokrenuti `mise i` u korijenu tog projekta.

## Predinstalirani CLI alati

`uv`, Node.js i `playwright-cli` (da agenti mogu upravljati preglednikom pomoću instaliranog Chromea) dolaze instalirani kao paketi, a `omarchy update` održava ih ažurnima zajedno s ostatkom sustava. `ghui`, [Hunk](https://github.com/modem-dev/hunk) i Basecamp, Cloudflare i HEY CLI-jevi udaljeni su samo jedan odabir pod _Install > CLI_, a [agenti za kodiranje](17-ai.md) pod _Install > AI > CLI_.

mise upravlja samo runtime okruženjima koje postavite iz _Install > Development_; Omarchy sam kroz njega ništa ne instalira. Pokrenite `omarchy update` da ih ažurirate zajedno s ostatkom Omarchyja; alias `mup` ažurira samo alate kojima upravlja mise. Da biste u vlastitu konfiguraciju dodali još jedan alat, upotrijebite `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) jedva da treba ikakvo predstavljanje. Omogućuje vam pokretanje izoliranih kontejnera, a Omarchy instalira sve što je potrebno da dobro radi, uključujući sam Docker i [Docker Compose](https://docs.docker.com/compose/).

Vaš korisnik prema zadanim postavkama *nije* u grupi `docker`. Ta je grupa zapravo root bez lozinke — sve u njoj može pokrenuti `docker run -v /:/host` i preuzeti računalo — pa bi jedna jedina nevaljala skripta ili ovisnost koja se pokreće pod vašim korisnikom inače bila samo jednu naredbu udaljena od roota. Zato na naredbenom retku Docker pokrećete sa `sudo` (`sudo docker ps`, `sudo docker compose up`), a grafički alati koji komuniciraju s daemonom — Windows VM — traže autorizaciju kad im zatreba. Ako želite natrag praktičnost postavke bez grupe i razumijete kompromis, omogućite je iz **Setup > Security > Sudoless Docker** (ili pokrenite `omarchy-setup-security-sudoless-docker`), što vas nakon upozorenja dodaje u grupu `docker`; tada obični `docker` i alias `d` ponovno rade bez `sudo`.

Uobičajene baze podataka za lokalni razvoj u Dockeru možete postaviti pomoću _Install > Development > Docker DB_ u Omarchy izborniku.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je `gh`, za rad s repozitorijima, issueima i pull requestovima iz terminala. _Setup > Git_ ga instalira kada se ondje odlučite prijaviti na GitHub, a zatim `gh repo clone org/repo` klonira repozitorij. Pokrenite `gh --help` da istražite njegove naredbe.

_Install > CLI > GitHub_ instalira GitHub CLI, `gh`, zajedno s `ghui`, terminalskim sučeljem za pull requestove. [Lazygit](https://github.com/jesseduffield/lazygit) je predinstaliran za rad sa samim Gitom.
