# Razvojna orodja

## Alternativni urejevalniki

Omarchy privzeto dobavlja [Neovim](https://neovim.io/), če pa želite nekaj bolj običajnega in znanega, zaženite meni Omarchy (`Super + Space`) in si oglejte možnosti pod _Namesti > Urejevalnik_. Tam so na voljo VSCode, Cursor, Zed, Sublime Text, Helix, Vim in Emacs. Če ne najdete, kar iščete, preverite _Namesti > Paket_ in preverite, ali je morda v paketu Arch (če ni, poskusite _Namesti > AUR_, da preverite AUR).

Izvirni urejevalnik `vi` je prav tako na voljo kar iz škatle. Za urejanje datoteke v terminalu zaženite `vi filename`.

Ujemanje teme je na voljo za `VSCode`, `Cursor`, `VSCodium` in `Helix`.

Privzeti urejevalnik za celoten sistem lahko nastavite pod `Nastavitve > Privzeto > Urejevalnik`.

## Okolja

Omarchy podpira nastavitev cele vrste razvojnih okolij prek razdelka _Namesti > Razvoj_ v meniju Omarchy (`Super + Space`). Tam boste seveda našli _Ruby on Rails_, pa tudi vse tri glavne izvajalne čase za JavaScript (Node.js, Bun, Deno) ter priljubljena ogrodja PHP, kot sta Laravel in Symfony. Oh, tu so še Go, Rust, Python, Java, Elixir (s Phoenixom), .NET, OCaml, Zig, Clojure in Scala. Izbira je res široka!

Večino teh okolij upravlja [Mise](https://mise.jdx.dev/). To je orodje, ki omogoča namestitev in zagon več različic programskega jezika na istem računalniku. Je kot rbenv ali rvm za Ruby ali virtualenv za Python, le da deluje za kopico različnih okolij.

Za namestitev, recimo, Rubyja zaženete `mise use -g ruby`, kar Ruby namesti in ga nastavi kot globalno privzeto vrednost. Če ima vaš projekt datoteko .ruby-version, pa lahko preprosto zaženete `mise i` v korenu tega projekta.

## Docker

[Docker](https://www.docker.com/) težko potrebuje predstavitev. Omogoča zagon izoliranih vsebnikov, Omarchy pa namesti vse potrebno za dober zagon, vključno z Dockerjem samim in [Docker Compose](https://docs.docker.com/compose/).

Privzeto vaš uporabnik *ni* v skupini `docker`. Ta skupina je dejansko root brez gesla — vse v njej lahko zažene `docker run -v /:/host` in prevzame računalnik —, tako da bi bil en sam podivjan skript ali odvisnost, ki teče kot vi, sicer le en ukaz oddaljena od roota. V ukazni vrstici zato Docker zaganjate s `sudo` (`sudo docker ps`, `sudo docker compose up`), grafična orodja, ki se pogovarjajo z demonom — Windows VM — pa po potrebi prosijo za avtorizacijo. Če želite nazaj udobje namestitve brez skupine in razumete kompromis, ga omogočite v **Nastavitve > Varnost > Sudoless Docker** (ali zaženite `omarchy-setup-security-sudoless-docker`), kar vas po opozorilu doda v skupino `docker`; nato navaden `docker` in vzdevek `d` spet delujeta brez `sudo`.

Pogoste podatkovne zbirke za lokalni razvoj v Dockerju lahko nastavite prek _Namesti > Razvoj > Docker DB_ v meniju Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) omogoča avtentikacijo z računom GitHub in kloniranje zasebnih repozitorijev z njim. Povezan je kot eden od leno nalagajočih se zaganjalcev mise, tako da se ob prvem zagonu `gh` namesti sam. Za avtentikacijo zaženite `gh auth login`. Nato lahko zasebne repozitorije prevzamete z `gh repo clone org/repo`.

S tem ukazom lahko izvedete tudi kup drugih operacij GitHub. Samo zaženite `gh`, da vidite vse možnosti.

Na voljo je tudi leno nameščujoč se zaganjalec za `ghui` za upravljanje vaših pull requestov v TUI. In [lazygit](https://github.com/jesseduffield/lazygit) je prednameščen, če želite tudi git sam poganjati iz TUI.
