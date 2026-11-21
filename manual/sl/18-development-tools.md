# Razvojna orodja

## Alternativni urejevalniki

Omarchy je pri novih namestitvah privzeto opremljen z urejevalnikom Plain in prednameščenim urejevalnikom [Neovim](https://neovim.io/), če pa želite nekaj bolj običajnega in znanega, lahko zaženete Omarchy Menu (`Super + Space`) in si ogledate možnosti pod _Install > Editor_. Tam so navedeni VSCode, Cursor, Zed, Sublime Text, Helix, Vim in Emacs. Če ne najdete, kar iščete, poglejte pod _Install > Package_ in preverite, ali je na voljo kot paket Arch (če ni, poskusite z _Install > AUR_ in preverite AUR).

Izvirni urejevalnik `vi` je prav tako na voljo takoj po namestitvi. Za urejanje datoteke v terminalu zaženite `vi filename`.

Ujemanje tem je na voljo za `VSCode`, `Cursor`, `VSCodium` in `Helix`.

Privzeti urejevalnik za celoten sistem lahko nastavite pod `Setup > Defaults > Editor`.

## Okolje

Omarchy omogoča nastavitev cele vrste razvojnih okolij v razdelku _Install > Development_ v Omarchy Menu (`Super + Space`). Tam boste seveda našli _Ruby on Rails_, pa tudi vse tri glavne izvajalne okolja za JavaScript (Node.js, Bun, Deno) ter priljubljeni ogrodji PHP, kot sta Laravel in Symfony. Aja, na voljo so tudi Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure in Scala. Izbira je res zelo široka!

Večino teh okolij upravlja [Mise](https://mise.jdx.dev/). To je orodje, ki omogoča namestitev in zagon več različic programskega jezika na istem računalniku. Je kot rbenv ali rvm za Ruby ali virtualenv za Python, le da deluje za cel kup različnih okolij.

Če želite namestiti na primer Ruby, zaženete `mise use -g ruby`, kar bo Ruby namestilo in ga nastavilo kot globalno privzetega. Če ima vaš projekt datoteko .ruby-version, pa lahko v korenu tega projekta preprosto zaženete `mise i`.

## Prednameščena orodja CLI

Omarchy omogoča dostop do orodij, kot so `gh`, `uv` in večina [kodirnih agentov](17-ai.md), z [lenim nameščanjem v mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Ko eno prvič zaženete, ga mise namesti. Kodirni agenti nato pred zagonom preverijo, ali je na voljo posodobitev, največ enkrat na štiri ure; druga orodja, kot sta `gh` in `uv`, uporabljajo nameščeno različico, dokler je ne posodobite.

Privzete nastavitve lahko tudi pregledate ali jih namestite vnaprej:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Zaženite `omarchy update`, da nameščena orodja posodobite skupaj s preostalim sistemom Omarchy. Vzdevek `mup` posodobi samo orodja, ki jih upravlja mise. Če želite svoji konfiguraciji dodati še eno orodje, uporabite `mise use -g <tool>`.

Pri nastavitvi Pythona se prek mise namesti tudi `uv`. Če odstranite razvojno okolje Python, `uv` ostane na voljo kot neodvisno orodje.

### Uporaba lastne namestitve

Ukazi mise so na `PATH` pred `~/.local/bin`, zato orodje, ki ste ga namestili sami, na primer z namestitvenim programom Claude Code ali Cursor, še vedno zažene kopijo mise. Tudi aplikacije, zagnane z namizja, najdejo ukaze mise pred sistemskimi paketi, zato aplikacija, ki zažene `gh`, dobi kopijo mise, tudi če ste `github-cli` namestili s pacman, mise pa to kopijo namesti ob prvem zagonu. Če želite namesto tega uporabljati svojo, onemogočite kopijo mise v `~/.config/mise/config.toml`. Če ste na primer sami namestili Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Če tabela `[settings]` že obstaja, vnos dodajte vanjo; obstoječi seznam `disable_tools` razširite, namesto da ga zamenjate. Poskrbite, da bo vaša namestitev na `PATH`. Uporabite ime orodja mise, ki se lahko razlikuje od njegovega ukaza: `oh-my-pi` na primer zagotavlja `omp`. Zaganjalnik privzetega agenta prav tako daje prednost uporabniško nameščenemu Cursorju ali Claude Code v `~/.local/bin`.

### Odstranjevanje in obnavljanje privzetih nastavitev

_Remove > Preinstalls_ odstrani prednameščene spletne aplikacije, TUI-je in aplikacije Omarchy ter povzroči, da mise za vašega uporabnika preskoči deklaracije orodij Omarchy, tako da jih doda v `ignored_config_paths` v `~/.config/mise/miserc.toml`. _Install > Preinstalls_ jih vrne in to vrstico znova odstrani. Orodja, ki jih deklarirate sami, v svoji konfiguraciji ali v projektni datoteki `mise.toml`, v obeh primerih delujejo naprej. Če po odstranitvi prednameščenih orodij izberete privzetega agenta ali nastavite Python, se to orodje doda vaši konfiguraciji. Nastavitev mise velja samo za vašega uporabnika, drugi uporabniki pa obdržijo svojo izbiro; aplikacije pa so paketi, zato njihova odstranitev ali obnova vpliva na vse uporabnike računalnika.

## Docker

[Docker](https://www.docker.com/) skoraj ne potrebuje predstavitve. Omogoča zagon izoliranih vsebnikov, Omarchy pa namesti vse, kar potrebujete za dobro delovanje, vključno s samim Dockerjem in [Docker Compose](https://docs.docker.com/compose/).

Vaš uporabnik privzeto *ni* v skupini `docker`. Ta skupina je dejansko root brez gesla — vse v njej lahko izvede `docker run -v /:/host` in prevzame računalnik — zato bi bil en sam škodljiv skript ali odvisnost, ki teče kot vi, sicer le en ukaz oddaljen od roota. V ukazni vrstici torej Docker poganjate s `sudo` (`sudo docker ps`, `sudo docker compose up`), grafična orodja, ki komunicirajo z demonom — Windows VM — pa po potrebi zahtevajo avtorizacijo. Če želite nazaj udobje nastavitve brez skupine in razumete kompromis, jo omogočite pod **Setup > Security > Sudoless Docker** (ali zaženite `omarchy-setup-security-sudoless-docker`), kar vas po opozorilu doda v skupino `docker`; nato navadni `docker` in vzdevek `d` znova delujeta brez `sudo`.

Običajne podatkovne baze za lokalni razvoj v Dockerju lahko nastavite z _Install > Development > Docker DB_ v meniju Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je na voljo kot `gh` za delo s skladišči, težavami in zahtevami za združitev iz terminala. Zaženite `gh auth login`, da ga ob prvi uporabi namestite in se overite, nato pa zaženite `gh repo clone org/repo`, da klonirate skladišče. Zaženite `gh --help`, da raziščete njegove ukaze.

Za terminalski vmesnik za zahteve za združitev zaženite `ghui`; tudi to orodje mise namesti ob prvi uporabi. [Lazygit](https://github.com/jesseduffield/lazygit) je prednameščen za delo s samim Gitom.
