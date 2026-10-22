# Arendustööriistad

## Alternatiivsed redaktorid

Omarchy tuleb vaikimisi koos [Neovimiga](https://neovim.io/), kuid kui soovid midagi peavoolule lähedasemat ja tuttavamat, saad avada Omarchy menüü (`Super + Space`) ja vaadata valikuid jaotises _Paigalda > Editor_. Seal on loetletud VSCode, Cursor, Zed, Sublime Text, Helix, Vim ja Emacs. Kui sa ei leia otsitavat, vaata jaotisesse _Paigalda > Package_ ja kontrolli, kas see pole mõnes Archi paketis (ja kui ei ole, proovi _Paigalda > AUR_, et kontrollida AUR-i).

Algupärane `vi` redaktor on samuti kohe olemas. Käivita faili redigeerimiseks terminalis `vi filename`.

Teemaga sobitamist pakutakse redaktoritele `VSCode`, `Cursor`, `VSCodium` ja `Helix`.

Süsteemiülese vaikeredaktori saad määrata jaotises `Seaded > Defaults > Editor`.

## Keskkond

Omarchy toetab suure hulga arenduskeskkondade seadistamist Omarchy menüü (`Super + Space`) jaotise _Paigalda > Development_ kaudu. Sealt leiad muidugi _Ruby on Railsi_, aga ka kõik kolm peamist JavaScripti käituskeskkonda (Node.js, Bun, Deno) ning populaarsed PHP raamistikud nagu Laravel ja Symfony. Ah, ja seal on ka Go, Rust, Python, Java, Elixir (koos Phoenixiga), .NET, OCaml, Zig, Clojure ja Scala. Valik on väga lai!

Enamikku neist keskkondadest haldab [Mise](https://mise.jdx.dev/). See on tööriist, mis võimaldab paigaldada ja käitada samas masinas mitut programmeerimiskeele versiooni. See on nagu rbenv või rvm Ruby jaoks või virtualenv Pythoni jaoks, kuid see töötab paljude erinevate keskkondade puhul.

Näiteks Ruby paigaldamiseks käivita `mise use -g ruby`, mis nii paigaldab Ruby kui ka määrab selle globaalseks vaikeversiooniks. Või kui sinu projektil on .ruby-version fail, saad lihtsalt käivitada selle projekti juurkaustas `mise i`.

## Docker

[Docker](https://www.docker.com/) ei vaja peaaegu tutvustamist. See võimaldab käitada isoleeritud konteinereid ja Omarchy paigaldab kõik, mis on selle heaks kasutamiseks vajalik, sealhulgas Dockeri enda ja [Docker Compose'i](https://docs.docker.com/compose/).

Vaikimisi *ei kuulu* sinu kasutaja gruppi `docker`. See grupp on sisuliselt paroolita root — kõik selle liikmed saavad käivitada `docker run -v /:/host` ja masina üle võtta —, nii et üksainus sinu nimel käiv pettunud skript või sõltuvus oleks muidu rootist ühe käsu kaugusel. Nii et käsureal käitad Dockerit `sudo` abil (`sudo docker ps`, `sudo docker compose up`) ja graafilised tööriistad, mis deemoniga suhtlevad — Windowsi virtuaalmasin — küsivad vajadusel autoriseerimist. Kui soovid grupivaba seadistuse mugavust tagasi ja mõistad kompromissi, luba see jaotises **Seaded > Security > Sudoless Docker** (või käivita `omarchy-setup-security-sudoless-docker`), mis lisab sind pärast hoiatust gruppi `docker`; seejärel töötavad tavaline `docker` ja alias `d` jälle ilma `sudo`-ta.

Tavalisi andmebaase kohalikuks arenduseks Dockeris saad seadistada Omarchy menüü jaotises _Paigalda > Development > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) võimaldab sul autentida oma GitHubi kontoga ja kloonida selle abil privaatreposid. See on ühendatud ühe laisalt laadiva mise tüvikuna, nii et esimesel korral, kui käivitad `gh`, paigaldab see end ise. Autentimiseks käivita `gh auth login`. Seejärel saad privaatreposid alla laadida käsuga `gh repo clone org/repo`.

Selle käsuga saad teha ka palju teisi GitHubi toiminguid. Kõikide võimaluste nägemiseks käivita lihtsalt `gh`.

Samuti on olemas laisalt paigaldav tüvik `ghui` jaoks, et hallata oma pull requeste TUI-s. Ja [lazygit](https://github.com/jesseduffield/lazygit) on eelpaigaldatud, kui soovid ka giti ennast TUI-st juhtida.
