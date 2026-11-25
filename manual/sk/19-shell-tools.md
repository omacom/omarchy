# Shell nástroje

Okrem štandardných linuxových nástrojov sa Omarchy dodáva aj s množstvom vylepšených shell nástrojov. Tu sú tie hlavné.

## fzf

[fzf](https://junegunn.github.io/fzf/) ti poskytuje fuzzy vyhľadávanie súborov prostredníctvom aliasu `ff`. Prejdi do ľubovoľného adresára, napíš `ff` a budeš môcť fuzzy vyhľadávaním nájsť ľubovoľný súbor v danom strome, pričom na pravej strane uvidíš náhľad súborov, na ktoré zužuješ výber.

Pomocou `Ctrl + R` môžeš použiť fzf na fuzzy prehľadávanie histórie príkazov.

Tento nástroj používa aj Neovim, keď napíšeš `Space Space`.

Úplný manuál nájdeš pomocou `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) je náhrada za cd. Pamätá si adresáre, v ktorých si bol, takže nabudúce do nich môžeš ľahšie preskočiť. Povedzme, že raz urobíš `cd ~/.config/omarchy`. Nabudúce stačí urobiť `cd omarchy` (alebo dokonca len `cd oma`) a Zoxide ťa tam prenesie priamo.

Úplný manuál nájdeš pomocou `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) prehľadáva obsah súborov pomocou `rg <pattern> <path>`, napríklad `rg Controller app/` nájde všetky zmienky o `Controller` v adresári app.

Tento nástroj používa aj Neovim, keď napíšeš `Space S G`.

Úplný manuál nájdeš pomocou `man rg`.

## eza

[eza](https://eza.rocks/) je náhrada za ls. Poskytuje ti výpisy adresárov s viacerými informáciami, farbami a ikonami. Predvolene je eza aliasovaná ako ls. Môžeš použiť aj `lt`, ak chceš výpis s dvomi úrovňami vnorenia. `lsa` ti poskytne výpis vrátane skrytých súborov. A `lta` vnorený výpis vrátane skrytých súborov.

Úplný manuál nájdeš pomocou `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) je ľahšie použiteľná náhrada za `find`. Pomocou `fd person.rb` nájdeš súbor s názvom `person.rb` v aktuálnom strome. `fd person.rb /` prehľadá celý súborový systém. `fd person.rb / -H` prehľadá celý súborový systém vrátane skrytých adresárov.

Úplný manuál nájdeš pomocou `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) je `cat` so zvýrazňovaním syntaxe, číslami riadkov a stránkovaním. Spusti `bat somefile.rb` a uvidíš, prečo je ťažké vrátiť sa späť. Potichu pre teba pracuje aj inde: farbí ti manuálové stránky a vykresľuje náhľady v `ff`.

Úplný manuál nájdeš pomocou `man bat`.

## tldr

[tldr](https://tldr.sh/) je protilátka na manuálové stránky, ktoré začínajú tromi obrazovkami histórie, skôr než ti ukážu jediný príklad. `tldr tar` ti poskytne tú hŕstku použití, ktoré si v skutočnosti chcel.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) sťahuje video z YouTube a stoviek ďalších stránok. `yt-dlp <url>` stiahne najlepšiu dostupnú kvalitu do aktuálneho adresára.

Úplný manuál nájdeš pomocou `man yt-dlp`.

## try

[try](https://github.com/tobi/try) uľahčuje správu programátorských experimentov pomocou adresárov s dátumovou pečiatkou. Všetky experimenty žijú v `~/Work/tries` a máš k nim prístup prostredníctvom `try`.

Omarchy nepridáva adresár `bin/` projektu do `PATH` automaticky. Dôveryhodné nástroje lokálne pre projekt spúšťaj s explicitnou relatívnou cestou, napríklad `bin/rails` alebo `./bin/dev`.
