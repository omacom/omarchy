# Alati za razvoj

## Alternativni uređivači

Omarchy dolazi s [Neovim](https://neovim.io/) prema zadanim postavkama, ali ako želiš nešto malo mainstream i poznatije, možeš pokrenuti izbornik Omarchy (`Super + Space`) i vidjeti opcije pod _Instaliraj > Editor_. Tamo imamo VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Ako ne pronađeš ono što tražiš, pogledaj _Instaliraj > Package_ i provjeri je li u Arch paketu (a ako nije, probaj _Instaliraj > AUR_ za provjeru AUR-a).

Izvorni uređivač `vi` također je dostupan odmah po instalaciji. Pokreni `vi filename` za uređivanje datoteke u terminalu.

Usklađivanje teme nudi se za `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Zadani uređivač za cijeli sustav možeš postaviti pod `Postavke > Defaults > Editor`.

## Okruženje

Omarchy podržava postavljanje cijelog niza razvojnih okruženja putem odjeljka _Instaliraj > Development_ u izborniku Omarchy (`Super + Space`). Naravno, tamo ćeš pronaći _Ruby on Rails_, ali i sva tri glavna runtimea za JavaScript (Node.js, Bun, Deno), kao i popularne PHP framewokre poput Laravela i Symfonyja. Oh, a tu su i Go, Rust, Python, Java, Elixir (s Phoenixom), .NET, OCaml, Zig, Clojure i Scala. Vrlo širok izbor!

Većinu ovih okruženja upravlja [Mise](https://mise.jdx.dev/). To je alat koji ti omogućuje instalaciju i pokretanje više verzija programskog jezika na istom računalu. Nešto je poput rbenv ili rvm za Ruby ili virtualenv za Python, ali radi za hrpu različitih okruženja.

Za instalaciju, recimo, Rubyja, pokreni `mise use -g ruby`, što će instalirati Ruby i postaviti ga kao globalni zadani. Ili, ako tvoj projekt ima datoteku .ruby-version, možeš jednostavno pokrenuti `mise i` u korijenu tog projekta.

## Docker

[Docker](https://www.docker.com/) jedva treba uvod. Omogućuje ti pokretanje izoliranih spremnika, a Omarchy instalira sve što je potrebno za dobro pokretanje, uključujući sam Docker i [Docker Compose](https://docs.docker.com/compose/).

Prema zadanim postavkama tvoj korisnik *nije* u grupi `docker`. Ta grupa je zapravo root bez zaporke — bilo što u njoj može `docker run -v /:/host` i preuzeti računalo — pa bi jedan jedini odmetnuti skript ili ovisnost koja se pokreće kao ti inače bio jednu naredbu udaljen od roota. Zato u naredbenom retku Docker pokrećeš sa `sudo` (`sudo docker ps`, `sudo docker compose up`), a grafički alati koji komuniciraju s daemonom — Windows VM — traže autorizaciju kad im je potrebna. Ako želiš udobnost postave bez grupe natrag i razumiješ kompromis, omogući je iz **Postavke > Security > Sudoless Docker** (ili pokreni `omarchy-setup-security-sudoless-docker`), što te dodaje u grupu `docker` nakon upozorenja; tada obični `docker` i alias `d` opet rade bez `sudo`.

Uobičajene baze podataka za lokalni razvoj u Dockeru možeš postaviti koristeći _Instaliraj > Development > Docker DB_ u izborniku Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) omogućuje ti autentifikaciju s tvojim GitHub računom i kloniranje privatnih repozitorija koristeći ga. Spojen je kao jedan od mise stubova s lijenim učitavanjem, pa se prvi put kad pokreneš `gh`, sam instalira. Za autentifikaciju pokreni `gh auth login`. Zatim možeš preuzeti privatne repozitorije koristeći `gh repo clone org/repo`.

S ovom naredbom možeš izvršiti i hrpu drugih GitHub operacija. Samo pokreni `gh` da vidiš sve što je moguće.

Tu je i stub s lijenom instalacijom za `ghui` za upravljanje tvojim pull requestovima u TUI-ju. A [lazygit](https://github.com/jesseduffield/lazygit) je predinstaliran, ako želiš upravljati i samim gitom iz TUI-ja.
