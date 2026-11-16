# Programavimo įrankiai

## Alternatyvūs redaktoriai

Omarchy pagal numatytuosius nustatymus pateikiama su [Neovim](https://neovim.io/), bet jei norite kažko įprastesnio ir labiau pažįstamo, galite atverti Omarchy Menu (`Super + Space`) ir peržiūrėti parinktis skiltyje _Įdiegti > Redaktorius_. Ten išvardyti VSCode, Cursor, Zed, Sublime Text, Helix, Vim ir Emacs. Jei nerandate to, ko ieškote, žvilgtelėkite į _Įdiegti > Paketas_ ir patikrinkite, ar jo nėra Arch pakete (o jei nėra, pabandykite _Įdiegti > AUR_ ir patikrinkite AUR).

Originalus `vi` redaktorius taip pat pasiekiamas iš karto. Paleiskite `vi filename`, kad redaguotumėte failą terminale.

Temų suderinimas siūlomas `VSCode`, `Cursor`, `VSCodium` ir `Helix`.

Visos sistemos numatytąjį redaktorių galite nustatyti skiltyje `Setup > Defaults > Editor`.

## Aplinka

Omarchy palaiko daugybės programavimo aplinkų diegimą per Omarchy Menu (`Super + Space`) skiltį _Įdiegti > Programavimas_. Žinoma, rasite _Ruby on Rails_, bet taip pat visas tris pagrindines JavaScript vykdymo aplinkas (Node.js, Bun, Deno), taip pat populiarias PHP karkasų sistemas, tokias kaip Laravel ir Symfony. O, ir taip pat yra Go, Rust, Python, Java, Elixir (su Phoenix), .NET, OCaml, Zig, Clojure ir Scala. Tai labai platus pasirinkimas!

Daugumą šių aplinkų tvarko [Mise](https://mise.jdx.dev/). Tai įrankis, leidžiantis tame pačiame kompiuteryje įdiegti ir naudoti kelias programavimo kalbos versijas. Tai tarsi rbenv ar rvm, skirtos Ruby, arba virtualenv, skirta Python, bet veikia su daugybe skirtingų aplinkų.

Norėdami įdiegti, tarkime, Ruby, paleistumėte `mise use -g ruby` — tai ir įdiegs Ruby, ir nustatys ją kaip visuotinį numatytąjį variantą. Arba, jei jūsų projekte yra .ruby-version failas, galite tiesiog paleisti `mise i` to projekto šakniniame kataloge.

## Iš anksto įdiegti CLI įrankiai

Omarchy įrankius, tokius kaip `gh`, `uv`, ir daugumą [kodavimo agentų](17-ai.md) padaro pasiekiamus per [mise tingųjį diegimą](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Pirmą kartą paleidus vieną iš jų, mise jį įdiegia. Vėlesni paleidimai naudoja įdiegtą versiją; jie netikrina, ar yra naujinimas, kaskart paleidžiant.

Taip pat galite patikrinti numatytuosius nustatymus arba įdiegti juos iš anksto:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Paleiskite `omarchy update`, kad atnaujintumėte įdiegtus įrankius kartu su likusia Omarchy dalimi. Slapyvardis `mup` atnaujina tik mise tvarkomus įrankius. Norėdami pridėti kitą įrankį į savo konfigūraciją, naudokite `mise use -g <tool>`.

Python sąranka taip pat įdiegia `uv` per mise. Pašalinus Python programavimo aplinką, `uv` lieka pasiekiamas kaip savarankiškas įrankis.

### Savo paties diegimo naudojimas

mise komandos `PATH` yra prieš `~/.local/bin`, todėl įrankis, kurį įdiegėte patys, pavyzdžiui, naudodami Claude Code arba Cursor diegimo programą, vis tiek vykdo mise kopiją. Iš darbalaukio paleistos programos taip pat randa mise komandas prieš sistemos paketus, todėl programa, kuri paleidžia `gh`, gauna mise kopiją, net jei su pacman įdiegėte `github-cli`, o mise tą kopiją įdiegia pirmą kartą. Norėdami vietoj jos naudoti savo, išjunkite mise kopiją faile `~/.config/mise/config.toml`. Pavyzdžiui, jei Cursor CLI įdiegėte patys:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Jei jau turite `[settings]` lentelę, įrašą pridėkite ten; išplėskite esamą `disable_tools` sąrašą, o ne pakeiskite jį. Įsitikinkite, kad jūsų diegimas yra `PATH`. Naudokite mise įrankio pavadinimą, kuris gali skirtis nuo jo komandos: pavyzdžiui, `oh-my-pi` teikia `omp`. Numatytojo agento paleidimo priemonė taip pat teikia pirmenybę vartotojo įdiegtam Cursor arba Muse, esančiam `~/.local/bin`.

### Numatytųjų pašalinimas ir atkūrimas

_Remove Preinstalls_ priverčia mise praleisti Omarchy įrankių deklaracijas jūsų vartotojui, pridėdama jas prie `ignored_config_paths` faile `~/.config/mise/miserc.toml`. _Restore Preinstalls_ tą eilutę vėl pašalina. Įrankiai, kuriuos deklaruojate patys, savo konfigūracijoje arba projekto `mise.toml`, bet kuriuo atveju veikia toliau. Jei pašalinę išankstinius diegimus pasirinksite numatytąjį agentą arba sukursite Python aplinką, tas įrankis bus pridėtas į jūsų pačių konfigūraciją. Abu veiksmai taikomi tik jūsų vartotojui; kiti kompiuterio vartotojai išlaiko savo pasirinkimą.

## Docker

[Docker](https://www.docker.com/) vargu ar reikia pristatyti. Jis leidžia paleisti izoliuotus konteinerius, o Omarchy įdiegia viską, ko reikia, kad jis gerai veiktų, įskaitant patį Docker ir [Docker Compose](https://docs.docker.com/compose/).

Pagal numatytuosius nustatymus jūsų vartotojas *nėra* `docker` grupėje. Ta grupė iš esmės yra root be slaptažodžio — bet kas joje gali paleisti `docker run -v /:/host` ir perimti kompiuterį — todėl vienas nesąžiningas scenarijus ar priklausomybė, veikianti jūsų vardu, priešingu atveju būtų per vieną komandą nuo root. Taigi komandinėje eilutėje Docker paleidžiate su `sudo` (`sudo docker ps`, `sudo docker compose up`), o grafiniai įrankiai, kurie bendrauja su tarnyba — Windows VM — paprašo autorizacijos, kai jos reikia. Jei norite susigrąžinti patogumą be grupės ir suprantate kompromisą, įjunkite tai skiltyje **Sąranka > Sauga > Sudoless Docker** (arba paleiskite `omarchy-setup-security-sudoless-docker`), kuri po įspėjimo pridės jus į `docker` grupę; tada paprastas `docker` ir slapyvardis `d` vėl veiks be `sudo`.

Įprastas lokaliam programavimui skirtas duomenų bazes Docker galite sukurti naudodami Omarchy meniu punktą _Įdiegti > Programavimas > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) pasiekiamas kaip `gh` darbui su saugyklomis, problemomis ir pull request'ais iš terminalo. Paleiskite `gh auth login`, kad pirmą kartą naudojant jis būtų įdiegtas ir kad autentifikuotumėtės, tada paleiskite `gh repo clone org/repo`, kad klonuotumėte saugyklą. Paleiskite `gh --help`, kad susipažintumėte su jo komandomis.

Norėdami terminalo sąsajos pull request'ams, paleiskite `ghui`; mise jį taip pat įdiegia pirmą kartą naudojant. [Lazygit](https://github.com/jesseduffield/lazygit) yra iš anksto įdiegtas darbui su pačiu Git.
