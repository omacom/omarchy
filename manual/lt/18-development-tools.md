# Programavimo įrankiai

## Alternatyvūs redaktoriai

Omarchy naujuose įdiegimuose numatytuoju redaktoriumi pateikia Plain ir iš anksto įdiegtą [Neovim](https://neovim.io/), bet jei norėtumėte ko nors kiek labiau įprasto ir pažįstamo, galite paleisti Omarchy Menu (`Super + Space`) ir peržiūrėti parinktis skiltyje _Install > Editor_. Ten išvardyti VSCode, Cursor, Zed, Sublime Text, Helix, Vim ir Emacs. Jei nerasite to, ko ieškote, užsukite į _Install > Package_ ir pažiūrėkite, ar to nėra Arch pakete (o jei nėra, pabandykite _Install > AUR_ ir patikrinkite AUR).

Originalus `vi` redaktorius taip pat pasiekiamas iš karto. Paleiskite `vi filename`, kad redaguotumėte failą terminale.

Temų suderinimas siūlomas `VSCode`, `Cursor`, `VSCodium` ir `Helix`.

Visos sistemos numatytąjį redaktorių galite nustatyti skiltyje `Setup > Defaults > Editor`.

## Aplinka

Omarchy palaiko daugybės programavimo aplinkų nustatymą per Omarchy Menu (`Super + Space`) skiltį _Install > Development_. Ten, žinoma, rasite _Ruby on Rails_, bet taip pat ir visas tris pagrindines JavaScript vykdymo aplinkas (Node.js, Bun, Deno), taip pat populiarius PHP karkasus, tokius kaip Laravel ir Symfony. O, ir dar yra Go, Rust, Python, Java, Elixir (su Phoenix), .NET, OCaml, Zig, Clojure ir Scala. Tai labai platus pasirinkimas!

Daugumą šių aplinkų tvarko [Mise](https://mise.jdx.dev/). Tai įrankis, leidžiantis tame pačiame kompiuteryje įdiegti ir paleisti kelias programavimo kalbos versijas. Tai tarsi rbenv ar rvm, skirti Ruby, arba virtualenv, skirtas Python, bet jis veikia su daugybe skirtingų aplinkų.

Norėdami įdiegti, tarkime, Ruby, paleistumėte `mise use -g ruby` – tai ir įdiegs Ruby, ir nustatys jį kaip visuotinį numatytąjį. Arba, jei jūsų projektas turi .ruby-version failą, galite tiesiog paleisti `mise i` to projekto šakniniame kataloge.

## Iš anksto įdiegti CLI įrankiai

`uv`, Node.js ir `playwright-cli` (skirtas agentams valdyti naršyklę naudojant įdiegtą Chrome) pateikiami įdiegti kaip paketai, o `omarchy update` juos atnaujina kartu su likusia sistema. `ghui`, [Hunk](https://github.com/modem-dev/hunk) ir Basecamp, Cloudflare bei HEY CLI rasite vos pasirinkę skiltyje _Install > CLI_, o [programavimo agentus](17-ai.md) – skiltyje _Install > AI > CLI_.

mise tvarko tik tas vykdymo aplinkas, kurias nustatote skiltyje _Install > Development_; Omarchy per jį pati nieko neįdiegia. Paleiskite `omarchy update`, kad atnaujintumėte jas kartu su likusia Omarchy; `mup` slapyvardis atnaujina tik mise tvarkomus įrankius. Norėdami į savo konfigūraciją įtraukti kitą įrankį, naudokite `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) vargu ar reikia pristatyti. Jis leidžia paleisti izoliuotus konteinerius, o Omarchy įdiegia viską, ko reikia, kad jis gerai veiktų, įskaitant patį Docker ir [Docker Compose](https://docs.docker.com/compose/).

Pagal numatytuosius nustatymus jūsų naudotojas *nėra* `docker` grupėje. Ta grupė iš esmės yra root be slaptažodžio – bet kas joje gali paleisti `docker run -v /:/host` ir perimti kompiuterį – todėl vienas nesąžiningas scenarijus ar priklausomybė, veikianti jūsų vardu, kitaip būtų vos per vieną komandą nuo root. Taigi komandinėje eilutėje Docker paleidžiate su `sudo` (`sudo docker ps`, `sudo docker compose up`), o grafiniai įrankiai, bendraujantys su tarnyba – Windows VM – prireikus paprašo autorizacijos. Jei norite susigrąžinti patogumą dirbti be grupės ir suprantate kompromisą, įjunkite tai skiltyje **Setup > Security > Sudoless Docker** (arba paleiskite `omarchy-setup-security-sudoless-docker`) – po įspėjimo tai įtrauks jus į `docker` grupę; tuomet paprastas `docker` ir `d` slapyvardis vėl veiks be `sudo`.

Dažniausias vietinio kūrimo duomenų bazes Docker galite nustatyti naudodami _Install > Development > Docker DB_ Omarchy meniu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) yra `gh`, skirtas dirbti su saugyklomis, problemomis ir pull request'ais iš terminalo. _Setup > Git_ jį įdiegia, kai ten pasirenkate prisijungti prie GitHub, o tada `gh repo clone org/repo` klonuoja saugyklą. Paleiskite `gh --help`, kad susipažintumėte su jo komandomis.

_Install > CLI > GitHub_ įdiegia GitHub CLI, `gh`, kartu su `ghui` – terminalo sąsaja pull request'ams. [Lazygit](https://github.com/jesseduffield/lazygit) yra iš anksto įdiegtas darbui su pačiu Git.
