# Programavimo įrankiai

## Alternatyvūs redaktoriai

Omarchy naujuose įdiegimuose pagal numatytuosius nustatymus naudoja Plain kaip redaktorių ir turi iš anksto įdiegtą [Neovim](https://neovim.io/), bet jei norite kažko įprastesnio ir labiau pažįstamo, galite paleisti Omarchy Menu (`Super + Space`) ir peržiūrėti parinktis skiltyje _Install > Editor_. Ten rasite VSCode, Cursor, Zed, Sublime Text, Helix, Vim ir Emacs. Jei nerasite to, ko ieškote, apsilankykite _Install > Package_ ir pažiūrėkite, ar jo nėra Arch pakete (o jei ne, pabandykite _Install > AUR_, kad patikrintumėte AUR).

Originalus `vi` redaktorius taip pat pasiekiamas iš karto. Paleiskite `vi filename`, kad redaguotumėte failą terminale.

Temų suderinimas siūlomas `VSCode`, `Cursor`, `VSCodium` ir `Helix`.

Visos sistemos numatytąjį redaktorių galite nustatyti skiltyje `Setup > Defaults > Editor`.

## Aplinka

Omarchy palaiko daugybės programavimo aplinkų nustatymą per Omarchy Menu (`Super + Space`) skiltį _Install > Development_. Žinoma, rasite _Ruby on Rails_, bet ir visus tris pagrindinius JavaScript vykdymo laikus (Node.js, Bun, Deno), taip pat populiarius PHP karkasus, tokius kaip Laravel ir Symfony. O taip, dar yra Go, Rust, Python, Java, Elixir (su Phoenix), .NET, OCaml, Zig, Clojure ir Scala. Pasirinkimas išties labai platus!

Daugumą šių aplinkų valdo [Mise](https://mise.jdx.dev/). Tai įrankis, leidžiantis įdiegti ir paleisti kelias tos pačios programavimo kalbos versijas tame pačiame kompiuteryje. Tai panašu į rbenv ar rvm, skirtus Ruby, arba virtualenv, skirtą Python, bet veikia su daugybe skirtingų aplinkų.

Norėdami įdiegti, pavyzdžiui, Ruby, paleistumėte `mise use -g ruby` – tai ir įdiegs Ruby, ir nustatys jį kaip visuotinį numatytąjį. Arba, jei jūsų projektas turi .ruby-version failą, galite tiesiog paleisti `mise i` to projekto šaknyje.

## Iš anksto įdiegti CLI įrankiai

`uv`, Node.js ir `playwright-cli` (kad agentai galėtų valdyti naršyklę, naudodami įdiegtą Chrome) įdiegiami kaip paketai, o `omarchy update` atnaujina juos kartu su likusia sistema. [Hunk](https://github.com/modem-dev/hunk) ir GitHub, Basecamp, Cloudflare bei HEY CLI pasiekiami vienu pasirinkimu skiltyje _Install > CLI_, o [programavimo agentai](17-ai.md) – skiltyje _Install > AI > CLI_.

mise valdo tik tuos vykdymo laikus, kuriuos nustatėte iš _Install > Development_; Omarchy savarankiškai per jį nieko neįdiegia. Paleiskite `omarchy update`, kad atnaujintumėte juos kartu su likusiu Omarchy; aliasas `mup` atnaujina tik mise valdomus įrankius. Norėdami pridėti kitą įrankį prie savo konfigūracijos, naudokite `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) vargu ar reikia pristatyti. Jis leidžia paleisti izoliuotus konteinerius, o Omarchy įdiegia viską, ko reikia, kad jis veiktų gerai, įskaitant patį Docker ir [Docker Compose](https://docs.docker.com/compose/).

Pagal numatytuosius nustatymus jūsų naudotojas *nėra* `docker` grupėje. Ta grupė iš esmės yra root be slaptažodžio – bet kas joje gali paleisti `docker run -v /:/host` ir perimti kompiuterį – todėl vienas kenkėjiškas skriptas ar priklausomybė, veikianti jūsų vardu, kitaip būtų vos per vieną komandą nuo root. Todėl komandinėje eilutėje Docker paleidžiate su `sudo` (`sudo docker ps`, `sudo docker compose up`), o grafiniai įrankiai, bendraujantys su demonu – Windows VM – paprašo autorizacijos, kai jos reikia. Jei norite grąžinti patogumą be grupės ir suprantate kompromisą, įjunkite tai iš **Setup > Security > Sudoless Docker** (arba paleiskite `omarchy-setup-security-sudoless-docker`), kas po įspėjimo pridės jus prie `docker` grupės; tada paprastas `docker` ir `d` aliasas vėl veiks be `sudo`.

Įprastas duomenų bazes vietiniam programavimui Docker galite nustatyti naudodami _Install > Development > Docker DB_ Omarchy meniu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) yra `gh`, skirtas dirbti su saugyklomis, problemomis ir pull request’ais iš terminalo. _Setup > Git_ įdiegia jį, kai pasirenkate ten prisijungti prie GitHub, arba įdiekite jį atskirai iš _Install > CLI > GitHub_. Tada `gh repo clone org/repo` klonuoja saugyklą; paleiskite `gh --help`, kad susipažintumėte su jo komandomis.

[Lazygit](https://github.com/jesseduffield/lazygit) yra iš anksto įdiegtas darbui su pačiu Git.
