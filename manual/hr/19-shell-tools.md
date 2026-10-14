# Alati ljuske

Osim standardnih Linux alata, Omarchy dolazi i s hrpom poboljšanih alata ljuske. Evo ključnih.

## fzf

[fzf](https://junegunn.github.io/fzf/) daje ti fuzzy pretraživanje datoteka putem aliasa `ff`. Otvori bilo koji direktorij, upiši `ff` i moći ćeš fuzzy pretraživanjem pronaći bilo koju datoteku u tom stablu, dok s desne strane vidiš pregled datoteka na koje sužavaš izbor.

Možeš koristiti `Ctrl + R` za korištenje fzf za fuzzy pretraživanje tvoje povijesti naredbi.

Ovaj alat koristi i Neovim kad upišeš `Space Space`.

Potpuni priručnik može se pronaći putem `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) je zamjena za cd. Pamti direktorije u kojima si bio, pa sljedeći put lakše skočiš do njih. Recimo da jednom izvršiš `cd ~/.config/omarchy`. Sljedeći put možeš samo izvršiti `cd omarchy` (ili čak samo `cd oma`) i Zoxide će te odvesti izravno tamo.

Potpuni priručnik može se pronaći putem `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) pretražuje sadržaj datoteka koristeći `rg <pattern> <path>`, poput `rg Controller app/` za pronalaženje svih spominjanja `Controller` u direktoriju app.

Ovaj alat koristi i Neovim kad upišeš `Space S G`.

Potpuni priručnik može se pronaći putem `man rg`.

## eza

[eza](https://eza.rocks/) je zamjena za ls. Daje ti popise direktorija s više informacija, bojama i ikonama. Prema zadanim postavkama, eza je aliasiran kao ls. Možeš koristiti i `lt` za popis dvije razine ugniježđenosti duboko. `lsa` daje ti popis uključujući skrivene datoteke. A `lta` ugniježđeni popis sa skrivenim datotekama.

Potpuni priručnik može se pronaći putem `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) je lakša zamjena za `find`. Koristi `fd person.rb` za pronalaženje datoteke pod nazivom `person.rb` unutar trenutnog stabla. `fd person.rb /` pretražit će cijeli datotečni sustav. `fd person.rb / -H` pretražuje cijeli datotečni sustav, uključujući skrivene direktorije.

Potpuni priručnik može se pronaći putem `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) je `cat` s isticanjem sintakse, brojevima redaka i paginacijom. Pokreni `bat somefile.rb` i vidjet ćeš zašto se teško vratiti natrag. Tiho radi posao za tebe i drugdje: on je taj koji boji tvoje man stranice i prikazuje preglede u `ff`.

Potpuni priručnik može se pronaći putem `man bat`.

## tldr

[tldr](https://tldr.sh/) protuotrov je za man stranice koje počinju s tri ekrana povijesti prije nego što ti pokažu jedan jedini primjer. `tldr tar` daje ti šačicu poziva koje si zapravo želio.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) preuzima video s YouTubea i stotina drugih stranica. `yt-dlp <url>` preuzima najbolju dostupnu kvalitetu u trenutni direktorij.

Potpuni priručnik može se pronaći putem `man yt-dlp`.

## try

[try](https://github.com/tobi/try) olakšava upravljanje programerskim eksperimentima s direktorijima označenima datumom. Svi eksperimenti nalaze se u `~/Work/tries` i možeš im pristupiti putem `try`.

Omarchy ne dodaje direktorij `bin/` projekta u `PATH` automatski. Pokreni pouzdane alate lokalne za projekt s eksplicitnom relativnom putanjom, poput `bin/rails` ili `./bin/dev`.
