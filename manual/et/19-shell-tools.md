# Kesta tööriistad

Lisaks standardsetele Linuxi tööriistadele tuleb Omarchy ka hulga täiustatud kesta tööriistadega. Siin on peamised.

## fzf

[fzf](https://junegunn.github.io/fzf/) annab failide uduotsingu aliase `ff` kaudu. Mine suvalisse kausta, sisesta `ff` ja saad uduotsinguga leida tee iga failini selles puus, nähes paremal pool kitsendatavate failide eelvaadet.

Saad kasutada `Ctrl + R`, et kasutada fzf-i oma käskude ajaloo uduotsinguks.

Seda tööriista kasutab ka Neovim, kui sisestad `Space Space`.

Täieliku juhendi leiad käsuga `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) on cd asendus. See jätab meelde kaustad, kus oled olnud, nii et järgmisel korral saad sinna kergemini hüpata. Ütleme, et teed üks kord `cd ~/.config/omarchy`. Järgmine kord saad lihtsalt teha `cd omarchy` (või isegi ainult `cd oma`) ja Zoxide viib su otse sinna.

Täieliku juhendi leiad käsuga `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) otsib failide sisust käsuga `rg <pattern> <path>`, näiteks `rg Controller app/`, et leida kõik `Controller` mainimised kaustas app.

Seda tööriista kasutab ka Neovim, kui sisestad `Space S G`.

Täieliku juhendi leiad käsuga `man rg`.

## eza

[eza](https://eza.rocks/) on ls-i asendus. See annab kaustaloendid rohkem teabe, värvide ja ikoonidega. Vaikimisi on eza aliasena ls. Saad kasutada ka `lt`, et saada kahetasemeline pesastatud loend. `lsa` annab loendi koos peidetud failidega. Ja `lta` pesastatud loendi koos peidetud failidega.

Täieliku juhendi leiad käsuga `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) on lihtsamini kasutatav `find` asendus. Kasuta `fd person.rb`, et leida praeguses puus fail nimega `person.rb`. `fd person.rb /` otsib kogu failisüsteemist. `fd person.rb / -H` otsib kogu failisüsteemist, sealhulgas peidetud kaustadest.

Täieliku juhendi leiad käsuga `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) on `cat` süntaksi esiletõstu, reanumbrite ja lehitsemisega. Käivita `bat somefile.rb` ja näed, miks on raske tagasi minna. See töötab vaikselt ka mujal sinu heaks: see värvib sinu man-lehti ja renderdab eelvaateid käsus `ff`.

Täieliku juhendi leiad käsuga `man bat`.

## tldr

[tldr](https://tldr.sh/) on vastumürk man-lehtedele, mis algavad kolme ekraanitäie ajalooga enne, kui näitavad kasvõi üht näidet. `tldr tar` annab sulle need paar kutsumist, mida tegelikult tahtsid.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) laadib videot alla YouTube'ist ja sadadest teistest saitidest. `yt-dlp <url>` haarab parima saadaoleva kvaliteedi praegusesse kausta.

Täieliku juhendi leiad käsuga `man yt-dlp`.

## try

[try](https://github.com/tobi/try) teeb programmeerimiskatsetuste haldamise lihtsaks kuupäevatempliga kaustadega. Kõik katsetused elavad kaustas `~/Work/tries` ja saad neile ligi käsuga `try`.

Omarchy ei lisa projekti kausta `bin/` automaatselt `PATH`-i. Käivita usaldusväärseid projektikohaseid tööriistu selgesõnalise suhtelise teega, näiteks `bin/rails` või `./bin/dev`.
