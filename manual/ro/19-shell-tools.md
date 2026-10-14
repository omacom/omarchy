# Instrumente de shell

Pe lângă instrumentele Linux standard, Omarchy vine și cu o mulțime de instrumente de shell îmbunătățite. Iată-le pe cele mai importante.

## fzf

[fzf](https://junegunn.github.io/fzf/) îți oferă căutare fuzzy de fișiere prin aliasul `ff`. Mergi în orice director, tastează `ff` și vei putea găsi fuzzy drumul către orice fișier din acel arbore, văzând în același timp o previzualizare a fișierelor pe care le restrângi, în partea dreaptă.

Poți folosi `Ctrl + R` ca să folosești fzf pentru a căuta fuzzy prin istoricul comenzilor tale.

Acest instrument este folosit și de Neovim când tastezi `Space Space`.

Manualul complet poate fi găsit prin `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) este un înlocuitor pentru cd. Ține minte directoarele în care ai fost, așa că data viitoare poți sări mai ușor la ele. Să zicem că faci o dată `cd ~/.config/omarchy`. Data viitoare poți face pur și simplu `cd omarchy` (sau chiar doar `cd oma`), iar Zoxide te va duce direct acolo.

Manualul complet poate fi găsit prin `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) caută în conținutul fișierelor folosind `rg <pattern> <path>`, de exemplu `rg Controller app/` ca să găsești toate mențiunile lui `Controller` în directorul app.

Acest instrument este folosit și de Neovim când tastezi `Space S G`.

Manualul complet poate fi găsit prin `man rg`.

## eza

[eza](https://eza.rocks/) este un înlocuitor pentru ls. Îți oferă listări de directoare cu mai multe informații, culoare și pictograme. Implicit, eza a fost aliasat ca ls. Poți folosi și `lt` ca să obții o listare cu două niveluri de imbricare. `lsa` îți oferă o listare care include fișierele ascunse. Iar `lta` o listare imbricată cu fișiere ascunse.

Manualul complet poate fi găsit prin `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) este un înlocuitor mai ușor de folosit pentru `find`. Folosește `fd person.rb` ca să găsești un fișier numit `person.rb` în arborele curent. `fd person.rb /` va căuta în întregul sistem de fișiere. `fd person.rb / -H` caută în întregul sistem de fișiere, inclusiv în directoarele ascunse.

Manualul complet poate fi găsit prin `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) este `cat` cu evidențiere de sintaxă, numere de linie și paginare. Rulează `bat somefile.rb` și vei înțelege de ce e greu să te întorci înapoi. Face treabă pentru tine în liniște și în altă parte: el colorează paginile man și el randează previzualizările din `ff`.

Manualul complet poate fi găsit prin `man bat`.

## tldr

[tldr](https://tldr.sh/) este antidotul pentru paginile man care se deschid cu trei ecrane de istorie înainte să-ți arate un singur exemplu. `tldr tar` îți dă cele câteva invocări pe care le voiai de fapt.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) descarcă video de pe YouTube și de pe alte sute de site-uri. `yt-dlp <url>` ia cea mai bună calitate disponibilă în directorul curent.

Manualul complet poate fi găsit prin `man yt-dlp`.

## try

[try](https://github.com/tobi/try) face ușoară gestionarea experimentelor de programare cu directoare ștampilate cu data. Toate experimentele trăiesc în `~/Work/tries` și le poți accesa prin `try`.

Omarchy nu adaugă automat directorul `bin/` al unui proiect la `PATH`. Rulează instrumentele locale ale proiectului în care ai încredere cu o cale relativă explicită, cum ar fi `bin/rails` sau `./bin/dev`.
