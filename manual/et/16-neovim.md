# Neovim

[Neovim](https://neovim.io/) on [vi redaktori](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) kaasaegne teostus, mille Bill Joy lõi juba 1976. aastal. See on modaalne redaktor, kus sisestusrežiim ja käsurežiim on eraldi, ning see on omamoodi supervõime, kui oled selgeks õppinud kasvõi osa uskumatult mahukast klahvikäskude valikust. Aga selle õppimiskõver on ka päris järsk!

Kui vim-stiilis redigeerimine on sulle täiesti uus, soovitan vaadata YouTube'is [ThePrimeageni sarja Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R). See õpetab sulle põhitõed. Pea ainult meeles, et erinevalt sarnasematest peavoolu redaktoritest võtab vimiga põhipädevuse saavutamine kauem aega. Aga kui oled selle saavutanud, on ka tasu suurem.

Neovim on põhimõtteliselt lõputult seadistatav. Kui tahad tõesti hulluks minna, võid luua oma Neovimi seadistuse nullist. Typecraftil on suurepärane kursus [Neovimi nullist seadistamise kohta](https://www.youtube.com/watch?v=zHTeCSVAFNY). Ja [ThePrimeagenil on samuti üks](https://www.youtube.com/watch?v=w7i4amO_zaE).

Aga Omarchyga tuleb kaasa täielik Neovimi seadistus — pakett `omarchy-nvim` — mis on armastusega häälestatud näitama parimat, mis kohe karbist võttes võimalik on. Ilma et peaksid kirjutama ainsatki seadistusrida! See on ehitatud [LazyVimile](https://www.lazyvim.org/), Neovimi pluginate ja seadistuste distributsioonile. See on äge.

## LazyVimi põhitõed

Nagu mainitud, ei hakka ma sulle selles lühikeses sissejuhatuses vimi õpetama, kuid saan näidata sulle mõnda LazyVimi põhitõde ja seda, kuidas selles ringi liikuda.

Esiteks on Neovimil juhtklahvi idee. See on põhimõtteliselt värav kõigi käskude juurde. LazyVim on selleks määranud klahvi `Space`. Nii et vajuta lihtsalt seda, oota sekund, ja näed hulka valikuid, mida selgitatakse kohapeal järgmiselt:

Siin on mõned põhikäsud, mida ma kogu aeg kasutan:

- `Space Space` - Leia häguotsinguga suvaline fail praegusest kataloogist.
- `Space S G` - Otsi kõigist failidest grepiga koos eelvaatega.
- `Space E` - Lülita failipuu sisse/välja.
- `Ctrl + W W` - Hüppa failipuust redaktorisse ja tagasi.
- `Shift + H` - Liigu avatud vahekaartide (vim nimetab neid puhvriteks) vahel vasakule.
- `Shift + L` - Liigu avatud vahekaartide vahel paremale.
- `Space B D` - Sulge vahekaart.
- `Space B O` - Sulge kõik muud vahekaardid peale praeguse.
- `Space G G` - Käivita LazyGit hõljuvas paanis praegusest kataloogist.
- `Space U W` - Lülita pehme tekstimurdmine sisse/välja.

Kui oled failipuus (`Space E` selle näitamiseks, `Ctrl + W W` sinna hüppamiseks), saad lisada uue faili klahviga `a` või uue kataloogi klahviga `A`. Kõigi käskude nägemiseks vajuta puus olles klahvi `?`.

Kui tahad vim'i põhikeele omandada, olen kirjutanud [kolmeosalisest süntaksist](https://world.hey.com/dhh/wonderful-vi-a1d034d3) ja sellest, kuidas need ägedad komboliigutused ära teha!

Kõiki võimalikke käske näed [LazyVimi klahvimäärangute lehel](https://www.lazyvim.org/keymaps).

## Neovimi käivitamine

`Super + Shift + N` käivitab sinu vaikeredaktori, mis on uutel installidel Plain; vali _Setup > Defaults > Editor_ alt Neovim, et see käivitaks selle asemel Neovimi. Aga tavaliselt on lihtsam juhtida seda terminalist, liikudes kataloogi, kus soovid töötada, ja tippides `n`. `n` on `nvim` alias, mis kasutab vaikimisi avamiseks praegust kataloogi. Ühe faili saad avada käsuga `n myfile.txt`.

## Neovimi kasutamine sudo-redigeerimiseks

Kui pead redigeerima faile, mida saad muuta ainult superkasutajana, käivita `sudoedit /etc/sudoers.d/00-sudo-only-file`. See avab sinu vaikeredaktori, nii et määra _Setup > Defaults > Editor_ alt Neovim, kui soovid seda seal koos kõigi oma pluginatega.
