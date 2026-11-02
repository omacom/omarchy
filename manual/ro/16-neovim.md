# Neovim

[Neovim](https://neovim.io/) este o implementare modernă a [editorului vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) creat de Bill Joy încă din 1976. Este un editor modal în care modul de inserare și modul de comandă sunt separate și este un fel de superputere odată ce înveți chiar și doar un subset al setului incredibil de profund de comenzi cu taste. Dar are și o curbă de învățare serioasă!

Dacă ești complet nou în editarea în stil vim, îți recomand să te uiți la [seria Vim As Your Editor a lui ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) pe YouTube. Aceasta te va învăța elementele de bază. Să știi doar că, spre deosebire de editoarele obișnuite mai similare, îți va lua mai mult timp să ajungi la o competență de bază cu vim. Dar, odată ce o faci, răsplata este și ea mai mare.

Acum, Neovim este practic infinit configurabil. Dacă vrei cu adevărat să înnebunești, îți poți crea propria configurație Neovim de la zero. Există un curs grozav de la [Typecraft despre configurarea Neovim de la zero](https://www.youtube.com/watch?v=zHTeCSVAFNY). Și [ThePrimeagen are și el unul](https://www.youtube.com/watch?v=w7i4amO_zaE).

Dar Omarchy vine cu o configurare Neovim completă — pachetul `omarchy-nvim` — care a fost reglat cu drag ca să arate ce e mai bun din ce e posibil imediat. Fără să fii nevoit să scrii o singură linie de configurație! Este construit pe [LazyVim](https://www.lazyvim.org/), o distribuție de pluginuri și configurații Neovim. Este grozav.

## Elementele de bază LazyVim

Cum am menționat, nu te voi învăța vim în această scurtă introducere, dar pot să-ți arăt câteva elemente de bază ale LazyVim și cum să te descurci.

În primul rând, Neovim are ideea de tastă lider. Aceasta este practic poarta către toate comenzile. LazyVim a setat-o la `Space`. Așadar, apasă doar acea tastă, așteaptă o secundă și vei vedea o grămadă de opțiuni explicate inline, așa:

Iată câteva comenzi de bază pe care le folosesc tot timpul:

- `Space Space` - Caută difuz orice fișier din directorul curent.
- `Space S G` - Caută în toate fișierele folosind grep, cu previzualizare.
- `Space E` - Comută arborele de fișiere între pornit/oprit.
- `Ctrl + W W` - Sari din arborele de fișiere în editor și înapoi.
- `Shift + H` - Te muți la stânga între filele deschise (vim le numește buffere).
- `Shift + L` - Te muți la dreapta între filele deschise.
- `Space B D` - Închide o filă.
- `Space B O` - Închide toate celelalte file, mai puțin pe cea curentă.
- `Space G G` - Lansează LazyGit într-un panou plutitor din directorul curent.
- `Space U W` - Comută împachetarea lină.

Cât timp ești în arborele de fișiere (`Space E` ca să-l afișezi, `Ctrl + W W` ca să sari acolo), poți adăuga un fișier nou cu `a` sau un director nou cu `A`. Apasă `?` cât ești în arbore ca să vezi toate comenzile.

Dacă vrei să prinzi limbajul vim de bază, am scris despre [sintaxa în trei părți](https://world.hey.com/dhh/wonderful-vi-a1d034d3) și despre cum să reușești acele mișcări combinate tari!

Poți vedea toate comenzile posibile pe [pagina LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Pornirea Neovim

Poți porni Neovim folosind `Super + Shift + N` (maparea lansează editorul tău implicit, care este Neovim imediat), dar de obicei este mai ușor să-l conduci din terminal navigând în directorul în care vrei să lucrezi și tastând `n`. `n` este aliasul pentru `nvim`, care va folosi directorul prezent ca să deschidă implicit. Poți deschide un singur fișier cu `n myfile.txt`.

## Folosirea Neovim pentru editări sudo

Dacă trebuie să editezi fișiere pe care le poți schimba doar ca superutilizator, poți folosi neovim cu toate pluginurile tale configurate rulând `sudoedit /etc/sudoers.d/00-sudo-only-file`.
