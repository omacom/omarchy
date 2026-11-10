# Razvojni alati

## Alternativni uređivači

Omarchy prema zadanim postavkama dolazi s [Neovimom](https://neovim.io/), ali ako želite nešto malo raširenije i poznatije, možete pokrenuti Omarchy Menu (`Super + Space`) i pogledati mogućnosti pod _Install > Editor_. Tamo su navedeni VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Ako ne pronađete ono što tražite, pogledajte _Install > Package_ i provjerite nije li to u nekom Arch paketu (a ako nije, pokušajte s _Install > AUR_ kako biste provjerili AUR).

Izvorni uređivač `vi` također je dostupan odmah po instalaciji. Pokrenite `vi filename` kako biste uredili datoteku u terminalu.

Usklađivanje tema nudi se za `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Zadani uređivač za cijeli sustav možete postaviti pod `Setup > Defaults > Editor`.

## Razvojna okruženja

Omarchy podržava postavljanje cijelog niza razvojnih okruženja putem odjeljka _Install > Development_ u Omarchy Menuu (`Super + Space`). Ondje ćete, naravno, pronaći _Ruby on Rails_, ali i sva tri glavna izvršna okruženja za JavaScript (Node.js, Bun, Deno), kao i popularne PHP okvire poput Laravela i Symfonyja. Oh, tu su i Go, Rust, Python, Java, Elixir (s Phoenixom), .NET, OCaml, Zig, Clojure i Scala. Izbor je doista vrlo širok!

Većinom tih okruženja upravlja [Mise](https://mise.jdx.dev/). To je alat koji vam omogućuje instaliranje i pokretanje više verzija programskog jezika na istom računalu. Sličan je alatima rbenv ili rvm za Ruby ili virtualenv za Python, ali radi s nizom različitih okruženja.

Kako biste instalirali, recimo, Ruby, pokrenuli biste `mise use -g ruby`, čime ćete Ruby i instalirati i postaviti kao globalnu zadanu verziju. Ili, ako vaš projekt ima datoteku .ruby-version, možete jednostavno pokrenuti `mise i` u korijenu tog projekta.

## Unaprijed instalirani CLI alati

Omarchy alate kao što su `gh`, `uv` i većinu [agenata za programiranje](17-ai.md) čini dostupnima putem [miseove lijene instalacije](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Kada neki od njih pokrenete prvi put, mise će ga instalirati. Kasnija pokretanja upotrebljavaju instaliranu verziju; ne provjeravaju postoji li ažuriranje pri svakom pokretanju.

Zadane alate možete i pregledati ili ih instalirati unaprijed:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Pokrenite `omarchy update` kako biste instalirane alate ažurirali zajedno s ostatkom Omarchyja. Alias `mup` ažurira samo alate kojima upravlja mise. Kako biste u vlastitu konfiguraciju dodali još jedan alat, upotrijebite `mise use -g <tool>`.

Postavljanje Pythona putem misea instalira i `uv`. Uklanjanje razvojnog okruženja za Python ostavlja `uv` dostupan kao neovisan alat.

### Korištenje vlastite instalacije

miseove naredbe dolaze prije `~/.local/bin` na `PATH`, pa će alat koji ste sami instalirali, primjerice vlastitim instalacijskim programom Claude Codea ili Cursora, i dalje pokretati miseovu kopiju. Aplikacije pokrenute s radne površine također pronalaze miseove naredbe prije paketa sustava, pa aplikacija koja pokrene `gh` dobiva miseovu kopiju čak i ako ste `github-cli` instalirali pacmanom, a mise tu kopiju instalira pri prvom pokretanju. Kako biste umjesto toga koristili svoju, onemogućite miseovu kopiju u `~/.config/mise/config.toml`. Primjerice, ako ste sami instalirali Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ako već imate tablicu `[settings]`, unos dodajte ondje; proširite postojeći popis `disable_tools`, a nemojte ga zamijeniti. Pobrinite se da je vaša instalacija na `PATH`. Upotrijebite naziv mise alata, koji se može razlikovati od njegove naredbe: `oh-my-pi`, primjerice, pruža `omp`. Pokretač zadanog agenta također daje prednost Cursoru ili Claude Codeu koje je korisnik instalirao u `~/.local/bin`.

### Uklanjanje i vraćanje zadanih alata

_Remove Preinstalls_ čini da mise za vašeg korisnika preskoči Omarchyjeve deklaracije alata tako da ih doda u `ignored_config_paths` u `~/.config/mise/miserc.toml`. _Restore Preinstalls_ ponovno uklanja taj redak. Alati koje sami deklarirate, u vlastitoj konfiguraciji ili u projektnoj datoteci `mise.toml`, u oba slučaja nastavljaju raditi. Ako nakon uklanjanja unaprijed instaliranih alata odaberete zadanog agenta ili postavite Python, taj će se alat dodati u vašu vlastitu konfiguraciju. Oboje se primjenjuje samo na vašeg korisnika; ostali korisnici na računalu zadržavaju vlastiti izbor.

## Docker

[Docker](https://www.docker.com/) gotovo da i ne treba predstavljati. Omogućuje vam pokretanje izoliranih spremnika, a Omarchy instalira sve što je potrebno za njegov dobar rad, uključujući sam Docker i [Docker Compose](https://docs.docker.com/compose/).

Prema zadanim postavkama vaš korisnik *nije* u grupi `docker`. Ta je grupa zapravo root bez lozinke — sve u njoj može pokrenuti `docker run -v /:/host` i preuzeti računalo — pa bi jedan jedini zlonamjerni skript ili ovisnost pokrenuta pod vašim korisnikom inače bio na samo jednu naredbu od roota. Zato Docker na naredbenom retku pokrećete sa `sudo` (`sudo docker ps`, `sudo docker compose up`), a grafički alati koji komuniciraju s pozadinskim procesom — Windows VM — traže autorizaciju kada im je potrebna. Ako želite natrag praktičnost postavljanja bez grupe i razumijete kompromis, omogućite ga putem **Setup > Security > Sudoless Docker** (ili pokrenite `omarchy-setup-security-sudoless-docker`), čime ćete nakon upozorenja biti dodani u grupu `docker`; tada obični `docker` i alias `d` ponovno rade bez `sudo`.

Uobičajene baze podataka za lokalni razvoj u Dockeru možete postaviti putem _Install > Development > Docker DB_ u Omarchy izborniku.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) dostupan je kao `gh` za rad s repozitorijima, problemima i zahtjevima za povlačenje iz terminala. Pokrenite `gh auth login` kako biste ga instalirali pri prvoj upotrebi i autentificirali se, zatim `gh repo clone org/repo` kako biste klonirali repozitorij. Pokrenite `gh --help` kako biste istražili njegove naredbe.

Za terminalsko sučelje za zahtjeve za povlačenje pokrenite `ghui`; mise ga također instalira pri prvoj upotrebi. [Lazygit](https://github.com/jesseduffield/lazygit) unaprijed je instaliran za rad sa samim Gitom.
