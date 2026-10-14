# Kūrimo įrankiai

## Alternatyvūs redaktoriai

Pagal nutylėjimą Omarchy pristatoma kartu su [Neovim](https://neovim.io/), bet jei norėtumei kažko šiek tiek labiau įprasto ir pažįstamo, gali paleisti Omarchy meniu (`Super + Space`) ir peržiūrėti parinktis skiltyje _Įdiegti > Editor_. Ten išvardyti VSCode, Cursor, Zed, Sublime Text, Helix, Vim ir Emacs. Jei nerandi to, ko ieškai, užsuk į _Įdiegti > Package_ ir pažiūrėk, ar nėra Arch paketo (o jei nėra, bandyk _Įdiegti > AUR_ ir patikrink AUR).

Originalusis `vi` redaktorius taip pat prieinamas iš karto. Paleisk `vi filename`, kad redaguotum failą terminale.

Temų atitikmenys siūlomi programoms `VSCode`, `Cursor`, `VSCodium` ir `Helix`.

Visos sistemos numatytąjį redaktorių gali nustatyti skiltyje `Nuostatos > Defaults > Editor`.

## Aplinka

Omarchy palaiko daugybės kūrimo aplinkų paruošimą per Omarchy meniu skiltį _Įdiegti > Development_ (`Super + Space`). Žinoma, ten rasi _Ruby on Rails_, bet ir visus tris pagrindinius JavaScript vykdymo aplinkos variklius (Node.js, Bun, Deno), taip pat populiarius PHP karkasus, tokius kaip Laravel ir Symfony. O dar yra Go, Rust, Python, Java, Elixir (su Phoenix), .NET, OCaml, Zig, Clojure ir Scala. Pasirinkimas tikrai platus!

Dauguma šių aplinkų valdoma naudojant [Mise](https://mise.jdx.dev/). Tai įrankis, leidžiantis diegti ir paleisti kelias programavimo kalbos versijas tame pačiame kompiuteryje. Tai tarsi rbenv ar rvm skirtas Ruby arba virtualenv skirtas Python, bet veikiantis su daugybe skirtingų aplinkų.

Kad įdiegtum, pavyzdžiui, Ruby, turėtum paleisti `mise use -g ruby`, kuris ir įdiegs Ruby, ir nustatys ją kaip visuotinę numatytąją. Arba, jei tavo projektas turi .ruby-version failą, gali tiesiog paleisti `mise i` to projekto šaknyje.

## Docker

[Docker](https://www.docker.com/) sunkiai reikia pristatinėti. Jis leidžia paleisti izoliuotus konteinerius, o Omarchy įdiegia viską, ko reikia, kad jis gerai veiktų, įskaitant patį Docker ir [Docker Compose](https://docs.docker.com/compose/).

Pagal nutylėjimą tavo naudotojas *nėra* grupėje `docker`. Ta grupė iš esmės yra root be slaptažodžio — bet kas joje gali atlikti `docker run -v /:/host` ir perimti kompiuterį — tad vienas vienintelis nepageidaujamas scenarijus ar priklausomybė, veikianti tavo vardu, kitu atveju būtų vos per vieną komandą nuo root. Tad komandinėje eilutėje Docker paleidžiama su `sudo` (`sudo docker ps`, `sudo docker compose up`), o grafiniai įrankiai, kalbantys su tarnyba — Windows VM — paprašo leidimo, kai jo prireikia. Jei nori susigrąžinti patogumą be grupės ir supranti kompromisą, įjunk jį iš **Nuostatos > Security > Sudoless Docker** (arba paleisk `omarchy-setup-security-sudoless-docker`), kuris po įspėjimo įtraukia tave į grupę `docker`; tada paprastas `docker` ir alias `d` vėl veikia be `sudo`.

Įprastas duomenų bazes vietiniam kūrimui Docker'yje gali paruošti naudodamas _Įdiegti > Development > Docker DB_ Omarchy meniu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) leidžia autentifikuotis su savo GitHub paskyra ir naudojantis ja klonuoti privačias saugyklas. Jis prijungtas kaip vienas iš tingiai įsikraunančių mise trumpinių, tad pirmą kartą paleidus `gh`, jis pats įsidiegia. Kad autentifikuotumeisi, paleisk `gh auth login`. Tada gali iškviesti privačias saugyklas naudodamas `gh repo clone org/repo`.

Naudodamas šią komandą taip pat gali atlikti daugybę kitų GitHub operacijų. Tiesiog paleisk `gh`, kad pamatytum viską, kas įmanoma.

Yra ir tingiai įsidiegiantis trumpinys `ghui`, skirtas pull request'ams valdyti TUI sąsajoje. O [lazygit](https://github.com/jesseduffield/lazygit) yra iš anksto įdiegtas, jei norėtum ir pačią git valdyti iš TUI.
