# Mga Tool ng Shell

Bukod sa mga standard na tool ng Linux, may kasama ring maraming pinahusay na tool ng shell ang Omarchy. Narito ang mga pangunahing iyon.

## fzf

Binibigyan ka ng [fzf](https://junegunn.github.io/fzf/) ng fuzzy finding ng mga file sa pamamagitan ng `ff` alias. Pumunta sa anumang direktoryo, i-type ang `ff`, at makakahanap ka nang fuzzy patungo sa anumang file sa tree na iyon, habang nakikita ang preview ng mga file na iyong pinapaliit sa kanang bahagi.

Maaari mong gamitin ang `Ctrl + R` para gamitin ang fzf na maghanap nang fuzzy sa kasaysayan ng iyong mga command.

Ginagamit din ang tool na ito ng Neovim kapag nag-type ka ng `Space Space`.

Makikita ang buong manual sa pamamagitan ng `man fzf`.

## Zoxide

Ang [Zoxide](https://github.com/ajeetdsouza/zoxide) ay kapalit ng cd. Naaalala nito ang mga direktoryong pinuntahan mo na, kaya mas madali kang makalukso sa mga ito sa susunod. Halimbawa, gawin mo ang `cd ~/.config/omarchy` nang isang beses. Sa susunod, maaari mo na lang gawin ang `cd omarchy` (o kahit `cd oma` lang), at dadalhin ka ng Zoxide nang direkta roon.

Makikita ang buong manual sa pamamagitan ng `man zoxide`.

## ripgrep

Hinahanap ng [ripgrep](https://github.com/BurntSushi/ripgrep) ang mga nilalaman ng mga file sa pamamagitan ng paggamit ng `rg <pattern> <path>`, tulad ng `rg Controller app/` para hanapin ang lahat ng pagbanggit ng `Controller` sa direktoryong app.

Ginagamit din ang tool na ito ng Neovim kapag nag-type ka ng `Space S G`.

Makikita ang buong manual sa pamamagitan ng `man rg`.

## eza

Ang [eza](https://eza.rocks/) ay kapalit ng ls. Binibigyan ka nito ng mga listahan ng direktoryo na may mas maraming impormasyon, kulay, at mga icon. Bilang default, ang eza ay ginawang alias bilang ls. Maaari mo ring gamitin ang `lt` para makakuha ng listahan ng dalawang antas ng nesting. Binibigyan ka ng `lsa` ng listahang kasama ang mga nakatagong file. At ng `lta` ng nested na listahang may mga nakatagong file.

Makikita ang buong manual sa pamamagitan ng `man eza`.

## fd

Ang [fd](https://github.com/sharkdp/fd) ay mas madaling gamiting kapalit ng `find`. Gamitin ang `fd person.rb` para hanapin ang file na tinatawag na `person.rb` sa loob ng kasalukuyang tree. Hahanapin ng `fd person.rb /` ang buong file system. Hahanapin ng `fd person.rb / -H` ang buong file system, kasama ang mga nakatagong direktoryo.

Makikita ang buong manual sa pamamagitan ng `man fd`.

## bat

Ang [bat](https://github.com/sharkdp/bat) ay `cat` na may syntax highlighting, mga numero ng linya, at paging. Patakbuhin ang `bat somefile.rb` at makikita mo kung bakit mahirap nang bumalik. Tahimik din itong gumagawa para sa iyo sa ibang lugar: ito ang nagkukulay sa iyong mga man page, at ang nagre-render sa mga preview sa `ff`.

Makikita ang buong manual sa pamamagitan ng `man bat`.

## tldr

Ang [tldr](https://tldr.sh/) ay ang lunas sa mga man page na nagsisimula sa tatlong screen ng kasaysayan bago magpakita sa iyo ng kahit isang halimbawa. Binibigyan ka ng `tldr tar` ng iilang invocation na talagang gusto mo.

## yt-dlp

Nagda-download ang [yt-dlp](https://github.com/yt-dlp/yt-dlp) ng video mula sa YouTube at daan-daang iba pang site. Kinukuha ng `yt-dlp <url>` ang pinakamahusay na kalidad na magagamit papunta sa kasalukuyang direktoryo.

Makikita ang buong manual sa pamamagitan ng `man yt-dlp`.

## try

Pinapadali ng [try](https://github.com/tobi/try) ang pamamahala ng mga eksperimento sa programming gamit ang mga direktoryong may date stamp. Nakatira ang lahat ng eksperimento sa `~/Work/tries` at maa-access mo ang mga ito sa pamamagitan ng `try`.

Hindi awtomatikong idinaragdag ng Omarchy ang `bin/` directory ng isang proyekto sa `PATH`. Patakbuhin ang mga pinagkakatiwalaang project-local tool gamit ang tahasang relative path, tulad ng `bin/rails` o `./bin/dev`.
