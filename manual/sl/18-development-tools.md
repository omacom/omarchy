# Razvojna orodja

## Alternativni urejevalniki

Omarchy privzeto vključuje [Neovim](https://neovim.io/), če pa želite nekaj bolj običajnega in znanega, lahko odprete Meni Omarchy (`Super + Space`) in si ogledate možnosti pod _Namesti > Urejevalnik_. Tam so navedeni VSCode, Cursor, Zed, Sublime Text, Helix, Vim in Emacs. Če ne najdete, kar iščete, preverite _Namesti > Paket_ in poglejte, ali ni na voljo kot paket Arch (če ni, poskusite _Namesti > AUR_, da preverite AUR).

Izvirni urejevalnik `vi` je prav tako na voljo takoj po namestitvi. Za urejanje datoteke v terminalu zaženite `vi filename`.

Ujemanje tem je na voljo za `VSCode`, `Cursor`, `VSCodium` in `Helix`.

Privzeti urejevalnik za celoten sistem lahko nastavite pod `Setup > Defaults > Editor`.

## Okolje

Omarchy podpira nastavitev cele vrste razvojnih okolij prek razdelka _Namesti > Razvoj_ v Meniju Omarchy (`Super + Space`). Tam boste seveda našli _Ruby on Rails_, pa tudi vse tri glavne izvajalne čase za JavaScript (Node.js, Bun, Deno) ter priljubljeni ogrodji PHP, kot sta Laravel in Symfony. Oh, na voljo so tudi Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure in Scala. Izbira je res zelo široka!

Večino teh okolij upravlja [Mise](https://mise.jdx.dev/). To je orodje, ki omogoča namestitev in uporabo več različic programskega jezika na istem računalniku. Je kot rbenv ali rvm za Ruby ali virtualenv za Python, vendar deluje za vrsto različnih okolij.

Če želite namestiti na primer Ruby, zaženete `mise use -g ruby`, kar bo Ruby namestilo in ga nastavilo kot globalno privzeto različico. Če ima vaš projekt datoteko .ruby-version, lahko v korenu tega projekta preprosto zaženete `mise i`.

## Vnaprej nameščena orodja CLI

Omarchy prek [lenobne namestitve mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) daje na voljo orodja, kot so `gh`, `uv`, in večino [agentov za programiranje](17-ai.md). Ko eno prvič zaženete, ga mise namesti. Poznejši zagoni znova uporabijo nameščeno različico; ob vsakem zagonu ne preverjajo, ali je na voljo posodobitev.

Ogledate si lahko tudi privzete nastavitve ali jih namestite vnaprej:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Zaženite `omarchy update`, da posodobite nameščena orodja skupaj s preostalim sistemom Omarchy. Vzdevek `mup` posodobi samo orodja, ki jih upravlja mise. Če želite svoji konfiguraciji dodati drugo orodje, uporabite `mise use -g <tool>`.

Nastavitev Pythona prek mise namesti tudi `uv`. Če odstranite razvojno okolje Python, ostane `uv` na voljo kot samostojno orodje.

### Uporaba lastne namestitve

Ukazi mise so na `PATH` pred `~/.local/bin`, zato orodje, ki ste ga namestili sami, na primer z namestitvenim programom Claude Code ali Cursor, še vedno zažene kopijo mise. Aplikacije, zagnane z namizja, prav tako najdejo ukaze mise pred sistemskimi paketi, zato aplikacija, ki zažene `gh`, dobi kopijo mise, tudi če ste `github-cli` namestili s pacman, in mise to kopijo namesti ob prvem zagonu. Če želite namesto tega uporabljati svojo, onemogočite kopijo mise v `~/.config/mise/config.toml`. Če ste na primer sami namestili Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Če tabela `[settings]` že obstaja, vnos dodajte vanjo; obstoječi seznam `disable_tools` razširite, namesto da ga zamenjate. Poskrbite, da bo vaša namestitev na `PATH`. Uporabite ime orodja mise, ki se lahko razlikuje od njegovega ukaza: `oh-my-pi` na primer ponuja `omp`. Zaganjalnik privzetega agenta prav tako daje prednost Cursorju ali Claude Code, ki ju je namestil uporabnik in sta v `~/.local/bin`.

### Odstranjevanje in obnavljanje privzetih orodij

_Odstrani prednamestitve_ povzroči, da mise za vašega uporabnika preskoči deklaracije orodij Omarchy, tako da jih doda v `ignored_config_paths` v `~/.config/mise/miserc.toml`. _Obnovi prednamestitve_ to vrstico znova odstrani. Orodja, ki jih deklarirate sami, v svoji konfiguraciji ali v projektni datoteki `mise.toml`, delujejo v obeh primerih. Če po odstranitvi prednamestitev izberete privzetega agenta ali nastavite Python, se to orodje doda vaši konfiguraciji. Oboje velja samo za vašega uporabnika; drugi uporabniki na računalniku obdržijo svojo izbiro.

## Docker

[Docker](https://www.docker.com/) skoraj ne potrebuje predstavitve. Omogoča zagon izoliranih vsebnikov, Omarchy pa namesti vse, kar je potrebno za njegovo dobro delovanje, vključno s samim Dockerjem in [Docker Compose](https://docs.docker.com/compose/).

Privzeto vaš uporabnik *ni* v skupini `docker`. Ta skupina je dejansko enakovredna rootu brez gesla — vse v njej lahko zažene `docker run -v /:/host` in prevzame računalnik — zato bi bil en sam zlonameren skript ali odvisnost, ki se izvaja pod vašim uporabnikom, sicer le en ukaz oddaljen od roota. Na ukazni vrstici zato Docker uporabljate s `sudo` (`sudo docker ps`, `sudo docker compose up`), grafična orodja, ki komunicirajo z demonom — VM z Windows — pa po potrebi zahtevajo avtorizacijo. Če želite nazaj priročnost nastavitve brez skupine in razumete kompromis, jo omogočite v **Nastavitev > Varnost > Sudoless Docker** (ali zaženite `omarchy-setup-security-sudoless-docker`), kar vas po opozorilu doda v skupino `docker`; nato preprosti `docker` in vzdevek `d` znova delujeta brez `sudo`.

Običajne podatkovne zbirke za lokalni razvoj v Dockerju lahko nastavite z _Namesti > Razvoj > Docker DB_ v meniju Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je na voljo kot `gh` za delo z repozitoriji, težavami in pull requesti iz terminala. Zaženite `gh auth login`, da ga ob prvi uporabi namestite in se prijavite, nato zaženite `gh repo clone org/repo`, da klonirate repozitorij. Za raziskovanje njegovih ukazov zaženite `gh --help`.

Za terminalski vmesnik za pull requeste zaženite `ghui`; tudi tega mise namesti ob prvi uporabi. [Lazygit](https://github.com/jesseduffield/lazygit) je vnaprej nameščen za delo s samim Gitom.
