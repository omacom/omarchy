# Razvojna orodja

## Alternativni urejevalniki

Omarchy ima na novih namestitvah privzeto Plain kot urejevalnik in prednameščen [Neovim](https://neovim.io/), če pa želite nekaj bolj uveljavljenega in domačega, lahko odprete meni Omarchy (`Super + Space`) in si ogledate možnosti pod _Install > Editor_. Tam so navedeni VSCode, Cursor, Zed, Sublime Text, Helix, Vim in Emacs. Če ne najdete, kar iščete, poglejte pod _Install > Package_ in preverite, ali je na voljo v kakem paketu Arch (če ni, pa pod _Install > AUR_ preverite AUR).

Izvirni urejevalnik `vi` je prav tako na voljo takoj po namestitvi. Za urejanje datoteke v terminalu zaženite `vi filename`.

Ujemanje tem je na voljo za `VSCode`, `Cursor`, `VSCodium` in `Helix`.

Privzeti urejevalnik za celoten sistem lahko nastavite pod `Setup > Defaults > Editor`.

## Okolje

Omarchy omogoča nastavitev cele vrste razvojnih okolij v razdelku _Install > Development_ menija Omarchy (`Super + Space`). Tam boste seveda našli _Ruby on Rails_, pa tudi vsa tri glavna izvajalna okolja za JavaScript (Node.js, Bun, Deno) ter priljubljena ogrodja PHP, kot sta Laravel in Symfony. Aja, na voljo so tudi Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure in Scala. Izbor je res zelo širok!

Večino teh okolij upravlja [Mise](https://mise.jdx.dev/). To je orodje, ki vam omogoča namestitev in uporabo več različic programskega jezika na istem računalniku. Podobno je kot rbenv ali rvm za Ruby ali virtualenv za Python, le da deluje za cel kup različnih okolij.

Če želite namestiti na primer Ruby, zaženete `mise use -g ruby`, kar bo Ruby namestilo in ga nastavilo kot globalno privzetega. Če pa ima vaš projekt datoteko .ruby-version, lahko v korenu tega projekta preprosto zaženete `mise i`.

## Prednameščena orodja CLI

`uv`, Node.js in `playwright-cli` (da lahko agenti upravljajo brskalnik z nameščenim Chrome) so nameščeni kot paketi, `omarchy update` pa skrbi, da ostanejo posodobljeni skupaj s preostalim sistemom. [Hunk](https://github.com/modem-dev/hunk) ter CLI-ji za GitHub, Basecamp, Cloudflare in HEY so na dosegu enega izbora pod _Install > CLI_, [kodirni agenti](17-ai.md) pa pod _Install > AI > CLI_.

mise upravlja samo izvajalna okolja, ki jih nastavite pod _Install > Development_; Omarchy sam prek njega ne namesti ničesar. Zaženite `omarchy update`, da jih posodobite skupaj s preostalim Omarchyjem; vzdevek `mup` posodobi samo orodja, ki jih upravlja mise. Če želite svoji konfiguraciji dodati drugo orodje, uporabite `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) najbrž ne potrebuje posebne predstavitve. Omogoča vam izvajanje izoliranih vsebnikov, Omarchy pa namesti vse, kar potrebujete za njegovo dobro delovanje, vključno s samim Dockerjem in [Docker Compose](https://docs.docker.com/compose/).

Privzeto vaš uporabnik *ni* v skupini `docker`. Ta skupina je dejansko root brez gesla — vse, kar je v njej, lahko zažene `docker run -v /:/host` in prevzame računalnik — zato bi bil en sam zlonameren skript ali odvisnost, ki se izvaja kot vi, sicer le en ukaz oddaljen od roota. Zato v ukazni vrstici Docker poganjate s `sudo` (`sudo docker ps`, `sudo docker compose up`), grafična orodja, ki komunicirajo z demonom — Windows VM — pa po potrebi zaprosijo za pooblastilo. Če želite nazaj udobje nastavitve brez skupine in razumete kompromis, jo omogočite pod **Setup > Security > Sudoless Docker** (ali zaženite `omarchy-setup-security-sudoless-docker`), kar vas po opozorilu doda v skupino `docker`; nato navadni `docker` in vzdevek `d` spet delujeta brez `sudo`.

Pogoste podatkovne zbirke za lokalni razvoj v Dockerju lahko nastavite pod _Install > Development > Docker DB_ v meniju Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je `gh`, za delo z repozitoriji, opravili in pull requesti iz terminala. _Setup > Git_ ga namesti, ko se tam odločite za prijavo v GitHub, ali pa ga namestite samostojno pod _Install > CLI > GitHub_. Nato `gh repo clone org/repo` klonira repozitorij; zaženite `gh --help`, da raziščete njegove ukaze.

[Lazygit](https://github.com/jesseduffield/lazygit) je prednameščen za delo s samim Gitom.
