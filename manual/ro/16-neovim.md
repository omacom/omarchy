# Neovim

[Neovim](https://neovim.io/) este o implementare modernă a [editorului vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) creat de Bill Joy tocmai în 1976. Este un editor modal în care modul de inserare și modul de comandă sunt separate și este cam o superputere odată ce înveți chiar și doar o parte din setul incredibil de bogat de comenzi din taste. Dar curba de învățare e al naibii de abruptă!

Dacă ești complet nou în editarea în stil vim, îți recomand să urmărești [seria Vim As Your Editor de la ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) pe YouTube. Acolo vei învăța elementele de bază. Doar să știi că, spre deosebire de editoarele mainstream mai asemănătoare cu ce știi deja, îți va lua mai mult timp să ajungi la o competență de bază în vim. Dar odată ce o faci, răsplata este și ea mai mare.

Acum, Neovim este practic infinit configurabil. Dacă chiar vrei să o iei razna, îți poți crea propria configurație Neovim de la zero. Există un curs excelent de la [Typecraft despre configurarea Neovim de la zero](https://www.youtube.com/watch?v=zHTeCSVAFNY). Și [ThePrimeagen are și el unul](https://www.youtube.com/watch?v=w7i4amO_zaE).

Dar Omarchy vine cu o configurație Neovim completă — pachetul `omarchy-nvim` — care a fost reglată cu dragoste ca să arate ce e mai bun din ce se poate obține imediat, din cutie. Fără să fie nevoie să scrii măcar o singură linie de configurație! Este construită pe [LazyVim](https://www.lazyvim.org/), o distribuție de pluginuri și configurații pentru Neovim. Este grozavă.

## Bazele LazyVim

După cum am menționat, nu te voi învăța vim în această scurtă introducere, dar îți pot arăta câteva noțiuni de bază despre LazyVim și cum să te descurci în el.

În primul rând, Neovim are conceptul de tastă leader. Aceasta este, practic, poarta de acces către toate comenzile. LazyVim a setat-o la `Space`. Așa că apas-o pur și simplu, așteaptă o secundă și vei vedea o grămadă de opțiuni explicate direct în linie, ca aici:

Iată câteva comenzi de bază pe care le folosesc tot timpul:

- `Space Space` - Caută fuzzy orice fișier din directorul curent.
- `Space S G` - Caută în toate fișierele folosind grep, cu previzualizare.
- `Space E` - Afișează/ascunde arborele de fișiere.
- `Ctrl + W W` - Sari din arborele de fișiere în editor și înapoi.
- `Shift + H` - Mergi la stânga printre filele deschise (vim le numește buffers).
- `Shift + L` - Mergi la dreapta printre filele deschise.
- `Space B D` - Închide o filă.
- `Space B O` - Închide toate celelalte file, mai puțin cea curentă.
- `Space G G` - Lansează LazyGit într-un panou flotant din directorul curent.
- `Space U W` - Activează/dezactivează încadrarea moale a textului.

Cât timp ești în arborele de fișiere (`Space E` pentru a-l afișa, `Ctrl + W W` pentru a sări acolo), poți adăuga un fișier nou cu `a` sau un director nou cu `A`. Apasă `?` cât timp ești în arbore pentru a vedea toate comenzile.

Dacă vrei să prinzi limbajul vim de bază, am scris despre [sintaxa în trei părți](https://world.hey.com/dhh/wonderful-vi-a1d034d3) și despre cum să scoți acele mișcări combo de zile mari!

Poți vedea toate comenzile posibile pe [pagina LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Pornirea Neovim

`Super + Shift + N` lansează editorul tău implicit, care pe instalările noi este Plain; alege Neovim în _Setup > Defaults > Editor_ ca să-l lanseze pe acesta în loc. Dar de obicei este mai ușor să-l conduci din terminal, navigând în directorul în care vrei să lucrezi și tastând `n`. `n` este aliasul pentru `nvim`, care va folosi directorul curent pentru a se deschide în mod implicit. Poți deschide un singur fișier cu `n myfile.txt`.

## Folosirea Neovim pentru editări cu sudo

Dacă trebuie să editezi fișiere pe care le poți schimba doar ca superutilizator, rulează `sudoedit /etc/sudoers.d/00-sudo-only-file`. Acesta deschide editorul tău implicit, așa că setează Neovim în _Setup > Defaults > Editor_ dacă îl vrei acolo cu toate pluginurile tale.
