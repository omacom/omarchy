# Strumenti della shell

Oltre agli strumenti Linux standard, Omarchy include anche una serie di strumenti della shell migliorati. Ecco i principali.

## fzf

[fzf](https://junegunn.github.io/fzf/) ti offre la ricerca fuzzy dei file tramite l'alias `ff`. Vai in una directory qualsiasi, digita `ff` e potrai trovare in modo fuzzy qualsiasi file in quell'albero, vedendo un'anteprima dei file che stai restringendo sul lato destro.

Puoi usare `Ctrl + R` per usare fzf per cercare in modo fuzzy nella cronologia dei comandi.

Questo strumento è usato anche da Neovim quando digiti `Space Space`.

Il manuale completo è disponibile con `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) è un sostituto di cd. Ricorda le directory in cui sei stato, così la prossima volta puoi saltarci più facilmente. Diciamo che fai una volta `cd ~/.config/omarchy`. La prossima volta puoi fare semplicemente `cd omarchy` (o addirittura `cd oma`) e Zoxide ti porterà direttamente lì.

Il manuale completo è disponibile con `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) cerca nel contenuto dei file usando `rg <pattern> <path>`, ad esempio `rg Controller app/` per trovare tutte le occorrenze di `Controller` nella directory app.

Questo strumento è usato anche da Neovim quando digiti `Space S G`.

Il manuale completo è disponibile con `man rg`.

## eza

[eza](https://eza.rocks/) è un sostituto di ls. Ti offre elenchi di directory con più informazioni, colori e icone. Per impostazione predefinita, eza è associato come alias a ls. Puoi anche usare `lt` per ottenere un elenco con due livelli di annidamento. `lsa` ti dà un elenco che include i file nascosti. E `lta` un elenco annidato con i file nascosti.

Il manuale completo è disponibile con `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) è un sostituto di `find` più semplice da usare. Usa `fd person.rb` per trovare un file chiamato `person.rb` nell'albero corrente. `fd person.rb /` cercherà nell'intero file system. `fd person.rb / -H` cerca nell'intero file system, incluse le directory nascoste.

Il manuale completo è disponibile con `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) è `cat` con evidenziazione della sintassi, numeri di riga e impaginazione. Esegui `bat somefile.rb` e capirai perché è difficile tornare indietro. Lavora anche silenziosamente per te altrove: è ciò che colora le pagine man e ciò che rende le anteprime in `ff`.

Il manuale completo è disponibile con `man bat`.

## tldr

[tldr](https://tldr.sh/) è l'antidoto alle pagine man che si aprono con tre schermate di storia prima di mostrarti un singolo esempio. `tldr tar` ti dà la manciata di invocazioni che volevi davvero.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) scarica video da YouTube e da centinaia di altri siti. `yt-dlp <url>` scarica la migliore qualità disponibile nella directory corrente.

Il manuale completo è disponibile con `man yt-dlp`.

## try

[try](https://github.com/tobi/try) semplifica la gestione di esperimenti di programmazione con directory contrassegnate dalla data. Tutti gli esperimenti vivono in `~/Work/tries` e puoi accedervi tramite `try`.

Omarchy non aggiunge automaticamente la directory `bin/` di un progetto a `PATH`. Esegui gli strumenti locali al progetto di cui ti fidi con un percorso relativo esplicito, come `bin/rails` o `./bin/dev`.
