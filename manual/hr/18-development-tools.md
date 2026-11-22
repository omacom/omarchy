# Razvojni alati

## Alternativni uređivači

Omarchy na novim instalacijama dolazi s uređivačem Plain kao zadanim uređivačem i s predinstaliranim [Neovim](https://neovim.io/), ali ako želite nešto malo mainstream i poznatije, možete pokrenuti Omarchy Menu (`Super + Space`) i pogledati opcije pod _Install > Editor_. Tamo su navedeni VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Ako ne pronađete ono što tražite, pogledajte _Install > Package_ i provjerite nije li u nekom Arch paketu (a ako nije, pokušajte _Install > AUR_ da provjerite AUR).

Izvorni uređivač `vi` također je dostupan odmah po instalaciji. Pokrenite `vi filename` da biste uredili datoteku u terminalu.

Usklađivanje teme nudi se za `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Zadani uređivač za cijeli sustav možete postaviti pod `Setup > Defaults > Editor`.

## Okruženje

Omarchy podržava postavljanje čitavog niza razvojnih okruženja kroz odjeljak _Install > Development_ izbornika Omarchy Menu (`Super + Space`). Naravno, pronaći ćete _Ruby on Rails_, ali i sva tri glavna runtimea za JavaScript (Node.js, Bun, Deno), kao i popularne PHP frameworke poput Laravela i Symfonyja. Oh, a tu su i Go, Rust, Python, Java, Elixir (s Phoenixom), .NET, OCaml, Zig, Clojure i Scala. Izbor je doista vrlo širok!

Većinom tih okruženja upravlja [Mise](https://mise.jdx.dev/). To je alat koji vam omogućuje instaliranje i pokretanje više verzija programskog jezika na istom računalu. Poput je rbenva ili rvma za Ruby ili virtualenva za Python, ali radi za čitav niz različitih okruženja.

Da biste instalirali, recimo, Ruby, pokrenuli biste `mise use -g ruby`, čime se Ruby i instalira i postavlja kao globalna zadana verzija. Ili, ako vaš projekt ima datoteku .ruby-version, možete jednostavno pokrenuti `mise i` u korijenu tog projekta.

## Predinstalirani CLI alati

Omarchy alate kao što su `gh`, `uv` i većinu [agenata za programiranje](17-ai.md) čini dostupnima kroz [miseovu lijenu instalaciju](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Kad neki od njih prvi put pokrenete, mise ga instalira. Agenti za programiranje zatim prije pokretanja provjeravaju ima li ažuriranja, najviše jednom svaka četiri sata; ostali alati, poput `gh` i `uv`, koriste instaliranu verziju dok je ne ažurirate.

Također možete pregledati zadane alate ili ih instalirati unaprijed:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Pokrenite `omarchy update` da biste ažurirali instalirane alate zajedno s ostatkom Omarchyja. Alias `mup` ažurira samo alate kojima upravlja mise. Da biste u vlastitu konfiguraciju dodali još jedan alat, upotrijebite `mise use -g <tool>`.

Postavljanje Pythona kroz mise instalira i `uv`. Uklanjanje Python razvojnog okruženja ostavlja `uv` dostupan kao neovisan alat.

### Upotreba vlastite instalacije

miseove naredbe dolaze prije `~/.local/bin` na `PATH`-u, pa alat koji ste sami instalirali, na primjer vlastitim instalacijskim programom Claude Codea ili Cursora, i dalje pokreće miseovu kopiju. Aplikacije pokrenute s radne površine također pronalaze miseove naredbe prije paketa sustava, pa aplikacija koja pokrene `gh` dobiva miseovu kopiju čak i ako ste `github-cli` instalirali pacmanom, a mise tu kopiju instalira pri prvom pokretanju. Da biste umjesto toga koristili svoju, onemogućite miseovu kopiju u `~/.config/mise/config.toml`. Na primjer, ako ste sami instalirali Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ako već imate tablicu `[settings]`, dodajte unos tamo; proširite postojeći popis `disable_tools`, a nemojte ga zamijeniti. Pobrinite se da je vaša instalacija na `PATH`-u. Upotrijebite naziv mise alata, koji se može razlikovati od njegove naredbe: `oh-my-pi`, na primjer, pruža `omp`. Pokretač zadanog agenta također daje prednost Cursoru ili Claude Codeu koji je korisnik instalirao u `~/.local/bin`.

### Uklanjanje i vraćanje zadanih postavki

_Remove > Preinstalls_ uklanja Omarchyjeve predinstalirane web-aplikacije, TUI-je i aplikacije te navodi mise da za vašeg korisnika preskoči Omarchyjeve deklaracije alata, tako da ih doda u `ignored_config_paths` u `~/.config/mise/miserc.toml`. _Install > Preinstalls_ ih vraća i ponovno uklanja taj redak. Alati koje sami deklarirate, u vlastitoj konfiguraciji ili u projektovu `mise.toml`, rade u oba slučaja. Ako nakon uklanjanja predinstalacija odaberete zadanog agenta ili postavite Python, taj se alat dodaje u vašu vlastitu konfiguraciju. Postavka misea vrijedi samo za vašeg korisnika, a ostali korisnici zadržavaju vlastiti izbor; aplikacije su, međutim, paketi, pa njihovo uklanjanje ili vraćanje mijenja ih za sve na računalu.

## Docker

[Docker](https://www.docker.com/) gotovo da i ne treba predstavljati. Omogućuje vam pokretanje izoliranih spremnika, a Omarchy instalira sve što je potrebno da bi dobro radio, uključujući sam Docker i [Docker Compose](https://docs.docker.com/compose/).

Prema zadanim postavkama vaš korisnik *nije* u skupini `docker`. Ta je skupina zapravo root bez lozinke — sve u njoj može pokrenuti `docker run -v /:/host` i preuzeti računalo — pa bi jedan jedini zlonamjerni skript ili ovisnost pokrenuta pod vašim korisnikom inače bio samo jednu naredbu udaljen od roota. Zato na naredbenom retku Docker pokrećete sa `sudo` (`sudo docker ps`, `sudo docker compose up`), a grafički alati koji komuniciraju s daemonom — Windows VM — traže autorizaciju kad im je potrebna. Ako želite natrag praktičnost postava bez skupine i razumijete kompromis, omogućite ga pod **Setup > Security > Sudoless Docker** (ili pokrenite `omarchy-setup-security-sudoless-docker`), čime vas se nakon upozorenja dodaje u skupinu `docker`; tada običan `docker` i alias `d` ponovno rade bez `sudo`.

Uobičajene baze podataka za lokalni razvoj u Dockeru možete postaviti pomoću _Install > Development > Docker DB_ u izborniku Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) dostupan je kao `gh` za rad s repozitorijima, prijavama problema i pull requestovima s terminala. Pokrenite `gh auth login` da biste ga instalirali pri prvoj upotrebi i autentificirali se, zatim `gh repo clone org/repo` da biste klonirali repozitorij. Pokrenite `gh --help` da biste istražili njegove naredbe.

Za terminalsko sučelje za pull requestove pokrenite `ghui`; mise ga također instalira pri prvoj upotrebi. [Lazygit](https://github.com/jesseduffield/lazygit) predinstaliran je za rad sa samim Gitom.
