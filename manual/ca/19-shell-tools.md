# Eines de l'intèrpret d'ordres

A més de les eines estàndard de Linux, Omarchy també ve amb una pila d'eines millorades per a l'intèrpret d'ordres. Aquí tens les principals.

## fzf

[fzf](https://junegunn.github.io/fzf/) et dona cerca difusa de fitxers mitjançant l'àlies `ff`. Ves a qualsevol directori, escriu `ff` i podràs arribar amb cerca difusa a qualsevol fitxer d'aquell arbre, tot veient una previsualització dels fitxers que vas acotant a la dreta.

Pots fer servir `Ctrl + R` per usar fzf per cercar de manera difusa a l'historial d'ordres.

Neovim també fa servir aquesta eina quan escrius `Space Space`.

Trobareu el manual complet amb `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) és un substitut de cd. Recorda els directoris on has estat, perquè la propera vegada hi puguis saltar més fàcilment. Suposa que fas `cd ~/.config/omarchy` una vegada. La propera vegada pots fer simplement `cd omarchy` (o fins i tot només `cd oma`), i Zoxide t'hi portarà directament.

Trobareu el manual complet amb `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) cerca el contingut dels fitxers amb `rg <pattern> <path>`, com ara `rg Controller app/` per trobar totes les mencions de `Controller` al directori app.

Neovim també fa servir aquesta eina quan escrius `Space S G`.

Trobareu el manual complet amb `man rg`.

## eza

[eza](https://eza.rocks/) és un substitut de ls. Et dona llistats de directoris amb més informació, color i icones. Per defecte, eza té l'àlies ls. També pots fer servir `lt` per obtenir un llistat amb dos nivells de profunditat d'imbricació. `lsa` et dona un llistat que inclou els fitxers ocults. I `lta`, un llistat imbricat amb els fitxers ocults.

Trobareu el manual complet amb `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) és un substitut de `find` més fàcil de fer servir. Feu servir `fd person.rb` per trobar un fitxer anomenat `person.rb` dins de l'arbre actual. `fd person.rb /` cercarà a tot el sistema de fitxers. `fd person.rb / -H` cerca a tot el sistema de fitxers, incloent-hi els directoris ocults.

Trobareu el manual complet amb `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) és `cat` amb ressaltat de sintaxi, números de línia i paginació. Executa `bat somefile.rb` i veuràs per què costa tornar enrere. També fa feina per tu discretament en altres llocs: és el que dona color a les teves pàgines de manual i el que renderitza les previsualitzacions a `ff`.

Trobareu el manual complet amb `man bat`.

## tldr

[tldr](https://tldr.sh/) és l'antídot contra les pàgines de manual que s'obren amb tres pantalles d'història abans de mostrar-te un sol exemple. `tldr tar` et dona el grapat d'invocacions que en realitat volies.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) descarrega vídeo de YouTube i de centenars d'altres llocs. `yt-dlp <url>` agafa la millor qualitat disponible al directori actual.

Trobareu el manual complet amb `man yt-dlp`.

## try

[try](https://github.com/tobi/try) facilita la gestió d'experiments de programació amb directoris amb data. Tots els experiments viuen a `~/Work/tries` i hi pots accedir amb `try`.

Omarchy no afegeix automàticament el directori `bin/` d'un projecte a `PATH`. Executa les eines locals de projecte en què confies amb una ruta relativa explícita, com ara `bin/rails` o `./bin/dev`.
