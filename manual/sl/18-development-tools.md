# Razvojna orodja

## Alternativni urejevalniki

Omarchy pri novih namestitvah privzeto prinaša Plain kot urejevalnik in ima prednameščen [Neovim](https://neovim.io/), če pa želite nekaj bolj uveljavljenega in domačega, lahko zaženete Omarchy Menu (`Super + Space`) in si ogledate možnosti pod _Install > Editor_. Tam so navedeni VSCode, Cursor, Zed, Sublime Text, Helix, Vim in Emacs. Če ne najdete, kar iščete, poglejte pod _Install > Package_ in preverite, ali ni na voljo v kakšnem Arch paketu (če ni, poskusite z _Install > AUR_ in preverite AUR).

Izvirni urejevalnik `vi` je prav tako na voljo takoj po namestitvi. Za urejanje datoteke v terminalu zaženite `vi filename`.

Ujemanje tem je na voljo za `VSCode`, `Cursor`, `VSCodium` in `Helix`.

Privzeti urejevalnik za celoten sistem lahko nastavite pod `Setup > Defaults > Editor`.

## Okolje

Omarchy omogoča nastavitev cele vrste razvojnih okolij prek razdelka _Install > Development_ v Omarchy Menu (`Super + Space`). Seveda boste tam našli _Ruby on Rails_, pa tudi vse tri glavne izvajalne okolje za JavaScript (Node.js, Bun, Deno) ter priljubljena PHP ogrodja, kot sta Laravel in Symfony. Aja, na voljo so tudi Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure in Scala. Izbira je res zelo široka!

Večino teh okolij upravlja [Mise](https://mise.jdx.dev/). To je orodje, ki omogoča namestitev in zagon več različic programskega jezika na istem računalniku. Je kot rbenv ali rvm za Ruby ali virtualenv za Python, le da deluje za cel kup različnih okolij.

Če želite na primer namestiti Ruby, zaženete `mise use -g ruby`, kar bo Ruby namestilo in ga nastavilo kot globalno privzeto možnost. Če ima vaš projekt datoteko .ruby-version, pa lahko v korenu tega projekta preprosto zaženete `mise i`.

## Prednameščena orodja CLI

`uv`, Node.js in `playwright-cli` (da lahko agenti upravljajo brskalnik z nameščenim Chromom) so nameščeni kot paketi, `omarchy update` pa jih ohranja posodobljene skupaj s preostalim sistemom. `ghui`, [Hunk](https://github.com/modem-dev/hunk) ter CLI-ji za Basecamp, Cloudflare in HEY so le eno izbiro stran pod _Install > CLI_, [agentje za programiranje](17-ai.md) pa pod _Install > AI > CLI_.

mise upravlja samo izvajalna okolja, ki jih nastavite prek _Install > Development_; Omarchy prek njega sam ne namesti ničesar. Zaženite `omarchy update`, da jih posodobite skupaj s preostalim Omarchyjem; vzdevek `mup` posodobi samo orodja, ki jih upravlja mise. Če želite svoji konfiguraciji dodati še kakšno orodje, uporabite `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) skoraj ne potrebuje predstavitve. Omogoča zagon izoliranih vsebnikov, Omarchy pa namesti vse, kar potrebujete za njegovo dobro delovanje, vključno s samim Dockerjem in [Docker Compose](https://docs.docker.com/compose/).

Vaš uporabnik privzeto *ni* v skupini `docker`. Ta skupina je dejansko root brez gesla — vse v njej lahko zažene `docker run -v /:/host` in prevzame računalnik — zato bi bil sicer en sam zlonameren skript ali odvisnost, ki se izvaja kot vi, le en ukaz oddaljena od root. Zato v ukazni vrstici Docker uporabljate s `sudo` (`sudo docker ps`, `sudo docker compose up`), grafična orodja, ki komunicirajo z demonom — VM z Windows — pa po potrebi zahtevajo avtorizacijo. Če želite nazaj udobje nastavitve brez skupine in razumete kompromis, jo omogočite prek **Setup > Security > Sudoless Docker** (ali zaženite `omarchy-setup-security-sudoless-docker`), kar vas po opozorilu doda v skupino `docker`; potem navadni `docker` in vzdevek `d` spet delujeta brez `sudo`.

Pogoste podatkovne zbirke za lokalni razvoj v Dockerju lahko nastavite z _Install > Development > Docker DB_ v meniju Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je `gh` za delo z repozitoriji, zadevami in zahtevki pull request iz terminala. _Setup > Git_ ga namesti, ko se tam odločite prijaviti v GitHub, nato `gh repo clone org/repo` klonira repozitorij. Za raziskovanje njegovih ukazov zaženite `gh --help`.

_Install > CLI > GitHub_ namesti GitHub CLI, `gh`, skupaj z `ghui`, terminalskim vmesnikom za zahtevke pull request. [Lazygit](https://github.com/jesseduffield/lazygit) je prednameščen za delo s samim Gitom.
