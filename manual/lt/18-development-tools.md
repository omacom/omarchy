# Kūrimo įrankiai

## Alternatyvūs redaktoriai

Omarchy naujuose diegimuose pagal numatytuosius nustatymus pateikiama su Plain ir iš anksto įdiegtu [Neovim](https://neovim.io/), bet jei norėtumėte ko nors šiek tiek labiau įprasto ir pažįstamo, galite paleisti Omarchy meniu (`Super + Space`) ir peržiūrėti parinktis skiltyje _Install > Editor_. Ten išvardyti VSCode, Cursor, Zed, Sublime Text, Helix, Vim ir Emacs. Jei nerandate to, ko ieškote, užsukite į _Install > Package_ ir pažiūrėkite, ar to nėra Arch pakete (o jei ne, pabandykite _Install > AUR_ ir patikrinkite AUR).

Originalusis `vi` redaktorius taip pat pasiekiamas iš karto. Paleiskite `vi filename`, norėdami redaguoti failą terminale.

Temų suderinimas siūlomas `VSCode`, `Cursor`, `VSCodium` ir `Helix`.

Visos sistemos numatytąjį redaktorių galite nustatyti skiltyje `Setup > Defaults > Editor`.

## Aplinka

Omarchy palaiko daugybės kūrimo aplinkų parengimą per Omarchy meniu (`Super + Space`) skiltį _Install > Development_. Žinoma, rasite _Ruby on Rails_, bet taip pat visus tris pagrindinius JavaScript vykdymo laikus (Node.js, Bun, Deno), taip pat populiarius PHP karkasus, tokius kaip Laravel ir Symfony. O taip, dar yra Go, Rust, Python, Java, Elixir (su Phoenix), .NET, OCaml, Zig, Clojure ir Scala. Pasirinkimas išties labai platus!

Daugumą šių aplinkų tvarko [Mise](https://mise.jdx.dev/). Tai įrankis, leidžiantis tame pačiame kompiuteryje įdiegti ir paleisti kelias programavimo kalbos versijas. Tai tarsi rbenv arba rvm, skirti Ruby, arba virtualenv, skirtas Python, tik jis veikia su daugybe skirtingų aplinkų.

Norėdami įdiegti, tarkime, Ruby, paleistumėte `mise use -g ruby` – tai ir įdiegs Ruby, ir nustatys ją kaip visuotinę numatytąją. Arba, jei jūsų projektas turi .ruby-version failą, galite tiesiog paleisti `mise i` to projekto šakniniame kataloge.

## Iš anksto įdiegti CLI įrankiai

Omarchy tokius įrankius kaip `gh`, `uv` ir daugumą [kodavimo agentų](17-ai.md) padaro pasiekiamus per [tingųjį mise diegimą](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Pirmą kartą paleidus vieną iš jų, mise jį įdiegia. Kodavimo agentai prieš paleidimą patikrina, ar yra atnaujinimas, ne dažniau kaip kartą per keturias valandas; kiti įrankiai, pavyzdžiui, `gh` ir `uv`, pakartotinai naudoja įdiegtą versiją, kol jos neatnaujinsite.

Taip pat galite peržiūrėti numatytuosius arba įdiegti juos iš anksto:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Paleiskite `omarchy update`, norėdami atnaujinti įdiegtus įrankius kartu su likusia Omarchy dalimi. Aliases `mup` atnaujina tik mise tvarkomus įrankius. Norėdami į savo konfigūraciją įtraukti kitą įrankį, naudokite `mise use -g <tool>`.

Python parengimas taip pat įdiegia `uv` per mise. Pašalinus Python kūrimo aplinką, `uv` lieka pasiekiamas kaip savarankiškas įrankis.

### Savo diegimo naudojimas

mise komandos `PATH` yra prieš `~/.local/bin`, todėl įrankis, kurį įdiegėte patys, pavyzdžiui, su Claude Code ar Cursor nuosava diegimo programa, vis tiek paleidžia mise kopiją. Iš darbalaukio paleistos programos taip pat randa mise komandas prieš sistemos paketus, todėl programa, paleidžianti `gh`, gauna mise kopiją, net jei `github-cli` įdiegėte su pacman, o mise tą kopiją įdiegia pirmą kartą. Norėdami vietoj jos naudoti savąją, išjunkite mise kopiją faile `~/.config/mise/config.toml`. Pavyzdžiui, jei Cursor CLI įdiegėte patys:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Jei jau turite `[settings]` lentelę, įrašą pridėkite ten; išplėskite esamą `disable_tools` sąrašą, užuot jį pakeitę. Įsitikinkite, kad jūsų diegimas yra `PATH`. Naudokite mise įrankio pavadinimą, kuris gali skirtis nuo jo komandos: pavyzdžiui, `oh-my-pi` teikia `omp`. Numatytojo agento paleidyklė taip pat teikia pirmenybę vartotojo įdiegtam Cursor arba Muse, esančiam `~/.local/bin`.

### Numatytųjų pašalinimas ir atkūrimas

_Remove > Preinstalls_ pašalina iš anksto įdiegtas Omarchy žiniatinklio programas, TUI ir programas ir nurodo mise praleisti Omarchy įrankių deklaracijas jūsų vartotojui, įtraukiant jas į `ignored_config_paths` faile `~/.config/mise/miserc.toml`. _Install > Preinstalls_ jas sugrąžina ir vėl pašalina tą eilutę. Įrankiai, kuriuos deklaruojate patys – savo konfigūracijoje arba projekto `mise.toml` – bet kuriuo atveju veikia toliau. Jei pašalinę išankstinius diegimus pasirenkate numatytąjį agentą arba parengiate Python, tas įrankis įtraukiamas į jūsų pačių konfigūraciją. mise nustatymas taikomas tik jūsų vartotojui, o kiti vartotojai išlaiko savo pasirinkimą; tačiau programos yra paketai, todėl jų pašalinimas arba atkūrimas pakeičia jas visiems kompiuterio vartotojams.

## Docker

[Docker](https://www.docker.com/) vargu ar reikia pristatyti. Jis leidžia paleisti izoliuotus konteinerius, o Omarchy įdiegia viską, ko reikia, kad jis veiktų gerai, įskaitant patį Docker ir [Docker Compose](https://docs.docker.com/compose/).

Pagal numatytuosius nustatymus jūsų vartotojas *nėra* `docker` grupėje. Ta grupė iš esmės yra root be slaptažodžio – bet kas joje gali paleisti `docker run -v /:/host` ir perimti kompiuterį – todėl vienas piktybinis scenarijus ar priklausomybė, veikianti jūsų vardu, priešingu atveju būtų per vieną komandą nuo root. Taigi komandinėje eilutėje Docker paleidžiate su `sudo` (`sudo docker ps`, `sudo docker compose up`), o grafiniai įrankiai, bendraujantys su tarnyba – Windows VM – prireikus prašo autorizacijos. Jei norite susigrąžinti patogumą veikti be grupės ir suprantate kompromisą, įjunkite tai skiltyje **Setup > Security > Sudoless Docker** (arba paleiskite `omarchy-setup-security-sudoless-docker`) – tai po įspėjimo įtraukia jus į `docker` grupę; tada paprastas `docker` ir aliasas `d` vėl veikia be `sudo`.

Įprastas duomenų bazes vietiniam kūrimui Docker galite parengti naudodami _Install > Development > Docker DB_ Omarchy meniu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) pasiekiamas kaip `gh`, skirtas dirbti su saugyklomis, problemų įrašais ir traukimo užklausomis iš terminalo. Paleiskite `gh auth login`, norėdami jį įdiegti pirmojo naudojimo metu ir autentifikuotis, tada paleiskite `gh repo clone org/repo`, norėdami klonuoti saugyklą. Paleiskite `gh --help`, norėdami susipažinti su jo komandomis.

Norėdami terminalo sąsajos traukimo užklausoms, paleiskite `ghui`; mise jį taip pat įdiegia pirmojo naudojimo metu. [Lazygit](https://github.com/jesseduffield/lazygit) yra iš anksto įdiegtas darbui su pačiu Git.
