# Shell įrankiai

Be standartinių Linux įrankių, Omarchy taip pat pristatoma su daugybe patobulintų shell įrankių. Štai svarbiausi.

## fzf

[fzf](https://junegunn.github.io/fzf/) suteikia failų neryškią paiešką per alias `ff`. Nueik į bet kurį katalogą, įrašyk `ff` ir galėsi neryškiai rasti kelią iki bet kurio failo tame medyje, dešinėje pusėje matydamas siaurinamų failų peržiūrą.

Galite naudoti `Ctrl + R`, kad neryškiai ieškotumėte per savo komandų istoriją naudodami fzf.

Šį įrankį taip pat naudoja Neovim, kai įvedi `Space Space`.

Visą vadovą gali rasti per `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) yra cd pakaitalas. Jis įsimena katalogus, kuriuose buvai, tad kitą kartą iki jų gali lengviau nušokti. Tarkim, vieną kartą atlikai `cd ~/.config/omarchy`. Kitą kartą gali tiesiog atlikti `cd omarchy` (ar net tiesiog `cd oma`), ir Zoxide nuves tave tiesiai ten.

Visą vadovą gali rasti per `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) ieško failų turinyje naudojant `rg <pattern> <path>`, pavyzdžiui, `rg Controller app/`, kad rastų visus `Controller` paminėjimus kataloge app.

Šį įrankį taip pat naudoja Neovim, kai įvedi `Space S G`.

Visą vadovą gali rasti per `man rg`.

## eza

[eza](https://eza.rocks/) yra ls pakaitalas. Jis pateikia katalogų sąrašus su daugiau informacijos, spalvų ir piktogramų. Pagal nutylėjimą eza yra susieta su alias ls. Taip pat gali naudoti `lt`, kad gautum dviejų lygių gylio įdėties sąrašą. `lsa` pateikia sąrašą įskaitant paslėptus failus. O `lta` — įdėtą sąrašą su paslėptais failais.

Visą vadovą gali rasti per `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) yra lengviau naudojamas `find` pakaitalas. Naudok `fd person.rb`, kad rastum failą pavadinimu `person.rb` dabartiniame medyje. `fd person.rb /` ieškos visoje failų sistemoje. `fd person.rb / -H` ieško visoje failų sistemoje, įskaitant paslėptus katalogus.

Visą vadovą gali rasti per `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) yra `cat` su sintaksės išryškinimu, eilučių numeriais ir puslapiais. Paleisk `bat somefile.rb` ir suprasi, kodėl sunku grįžti atgal. Jis taip pat tyliai dirba tau kitur: būtent jis nuspalvina tavo man puslapius ir atvaizduoja peržiūras `ff`.

Visą vadovą gali rasti per `man bat`.

## tldr

[tldr](https://tldr.sh/) yra priešnuodis man puslapiams, kurie prasideda trimis ekranais istorijos prieš parodant nors vieną pavyzdį. `tldr tar` pateikia saują iškvietimų, kurių iš tikrųjų norėjai.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) parsisiunčia vaizdo įrašus iš YouTube ir šimtų kitų svetainių. `yt-dlp <url>` paima geriausią prieinamą kokybę į dabartinį katalogą.

Visą vadovą gali rasti per `man yt-dlp`.

## try

[try](https://github.com/tobi/try) leidžia lengvai valdyti programavimo eksperimentus naudojant katalogus su datos antspaudais. Visi eksperimentai gyvena `~/Work/tries` ir juos gali pasiekti per `try`.

Omarchy automatiškai neprideda projekto `bin/` katalogo prie `PATH`. Patikimus projektui vietinius įrankius paleisk su aiškiu santykiniu keliu, pavyzdžiui, `bin/rails` arba `./bin/dev`.
