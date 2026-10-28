# Shell-tools

Naast de standaard Linux-tools wordt Omarchy ook geleverd met een heleboel verbeterde shell-tools. Hier zijn de belangrijkste.

## fzf

[fzf](https://junegunn.github.io/fzf/) geeft je fuzzy zoeken naar bestanden via de `ff`-alias. Ga naar een willekeurige map, typ `ff`, en je kunt fuzzy je weg vinden naar elk bestand in die boom, terwijl je aan de rechterkant een voorbeeld ziet van de bestanden waarop je je selectie verkleint.

Je kunt `Ctrl + R` gebruiken om met fzf fuzzy door je opdrachtgeschiedenis te zoeken.

Deze tool wordt ook door Neovim gebruikt wanneer je `Space Space` typt.

De volledige handleiding vind je via `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) is een vervanging voor cd. Het onthoudt de mappen waar je bent geweest, zodat je er de volgende keer gemakkelijker naartoe kunt springen. Stel dat je een keer `cd ~/.config/omarchy` doet. De volgende keer kun je gewoon `cd omarchy` doen (of zelfs gewoon `cd oma`), en Zoxide brengt je er direct naartoe.

De volledige handleiding vind je via `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) doorzoekt de inhoud van bestanden met `rg <pattern> <path>`, zoals `rg Controller app/` om alle vermeldingen van `Controller` in de map app te vinden.

Deze tool wordt ook door Neovim gebruikt wanneer je `Space S G` typt.

De volledige handleiding vind je via `man rg`.

## eza

[eza](https://eza.rocks/) is een vervanging voor ls. Het geeft je maplijsten met meer informatie, kleur en pictogrammen. Standaard is eza gealiased als ls. Je kunt ook `lt` gebruiken om een lijst te krijgen van twee niveaus diep nesten. `lsa` geeft je een lijst inclusief verborgen bestanden. En `lta` een geneste lijst met verborgen bestanden.

De volledige handleiding vind je via `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) is een gemakkelijker te gebruiken vervanging voor `find`. Gebruik `fd person.rb` om een bestand met de naam `person.rb` binnen de huidige boom te vinden. `fd person.rb /` doorzoekt het hele bestandssysteem. `fd person.rb / -H` doorzoekt het hele bestandssysteem, inclusief verborgen mappen.

De volledige handleiding vind je via `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) is `cat` met syntaxiskleuring, regelnummers en paging. Voer `bat somefile.rb` uit en je zult zien waarom het moeilijk is om terug te gaan. Het doet ook stilletjes elders werk voor je: het kleurt je man-pagina's, en het rendert de voorbeelden in `ff`.

De volledige handleiding vind je via `man bat`.

## tldr

[tldr](https://tldr.sh/) is het tegengif voor man-pagina's die openen met drie schermen geschiedenis voordat ze je één voorbeeld laten zien. `tldr tar` geeft je de handvol aanroepen die je eigenlijk wilde.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) downloadt video van YouTube en honderden andere sites. `yt-dlp <url>` pakt de best beschikbare kwaliteit in de huidige map.

De volledige handleiding vind je via `man yt-dlp`.

## try

[try](https://github.com/tobi/try) maakt het gemakkelijk om programmeerexperimenten te beheren met mappen met datumstempel. Alle experimenten leven in `~/Work/tries` en je kunt ze benaderen via `try`.

Omarchy voegt de `bin/`-map van een project niet automatisch toe aan `PATH`. Voer vertrouwde project-lokale tools uit met een expliciet relatief pad, zoals `bin/rails` of `./bin/dev`.
