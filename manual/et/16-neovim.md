# Neovim

[Neovim](https://neovim.io/) on [vi redaktori](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) kaasaegne rakendus, mille lõi Bill Joy juba 1976. aastal. See on modaalne redaktor, kus sisestusrežiim ja käsurežiim on eraldatud, ja see on lausa supervõime, kui õpid ära kasvõi alamhulga uskumatult sügavast klahvikäskude kogumist. Kuid see on samuti üsna järsk õppimiskõver!

Kui oled vim-stiilis redigeerimises täiesti uus, soovitan sul vaadata [ThePrimeageni sarja Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) YouTube'is. See õpetab sulle põhitõed. Teadke lihtsalt, et erinevalt sarnasematest tavalistest redaktoritest kulub sul vimi põhioskuse saavutamiseks kauem aega. Kuid kui selle saavutad, on kasu samuti suurem.

Nüüd on Neovim põhimõtteliselt lõpmatult seadistatav. Kui sa päriselt hulluks minna tahad, saad nullist luua oma Neovimi seadistuse. Olemas on suurepärane kursus [Typecraftilt Neovimi nullist seadistamise kohta](https://www.youtube.com/watch?v=zHTeCSVAFNY). Ja [ThePrimeagenil on samuti üks](https://www.youtube.com/watch?v=w7i4amO_zaE).

Kuid Omarchy tarnitakse täieliku Neovimi seadistusega — paketiga `omarchy-nvim` —, mis on armastusega häälestatud, et tutvustada karbist välja võttes parimat, mis võimalik. Ilma et peaksid ühe rea seadistust kirjutama! See põhineb [LazyVimil](https://www.lazyvim.org/), Neovimi pluginate ja seadistuste distributsioonil. See on suurepärane.

## LazyVimi põhitõed

Nagu mainitud, ei hakka ma sulle selles lühikeses sissejuhatuses vimi õpetama, kuid saan näidata sulle mõnda LazyVimi põhitõde ja seda, kuidas ringi liikuda.

Esiteks on Neovimil liiderklahvi idee. See on põhimõtteliselt värav kõigile käskudele. LazyVim on seadnud selleks `Space`. Nii et vajuta lihtsalt seda, oota sekund ja näed hulka valikuid, mis on tekstis seletatud nii:

Siin on mõned põhikäsud, mida kogu aeg kasutan:

- `Space Space` - Leia hägusa otsinguga ükskõik milline fail praeguses kataloogis.
- `Space S G` - Otsi kõigist failidest grep abil koos eelvaatega.
- `Space E` - Lülita failipuu sisse/välja.
- `Ctrl + W W` - Hüppa failipuust redaktorisse ja tagasi.
- `Shift + H` - Liigu vasakule avatud vahelehtede vahel (vim nimetab neid puhvriteks).
- `Shift + L` - Liigu paremale avatud vahelehtede vahel.
- `Space B D` - Sulge vaheleht.
- `Space B O` - Sulge kõik peale praeguse vahelehed.
- `Space G G` - Käivita LazyGit ujuvas paanis praegusest kataloogist.
- `Space U W` - Lülita pehme ridade murtamine.

Kui oled failipuus (`Space E` avamiseks, `Ctrl + W W` sinna hüppamiseks), saad lisada uue faili `a` abil või uue kataloogi `A` abil. Vajuta puus olles `?`, et näha kõiki käske.

Kui soovid omandada vimi põhikeele, olen kirjutanud [kolmeosalisest süntaksist](https://world.hey.com/dhh/wonderful-vi-a1d034d3) ja sellest, kuidas neid vinged kombo-liigutusi teha!

Saad näha kõiki võimalikke käske [LazyVimi klahvikaartide lehel](https://www.lazyvim.org/keymaps).

## Neovimi käivitamine

Saad Neovimi käivitada `Super + Shift + N` abil (seos käivitab su vaikiredaktori, mis on karbist välja võttes Neovim), kuid tavaliselt on lihtsam juhtida seda terminalist, navigeerides kataloogi, milles töötada soovid, ja trükkides `n`. `n` on alias `nvim`-ile, mis kasutab vaikimisi avamiseks praegust kataloogi. Saad avada ühe faili `n myfile.txt` abil.

## Neovimi kasutamine sudo redigeerimiseks

Kui pead muutma faile, mida saad muuta ainult superkasutajana, saad kasutada neovimi kõigi oma seadistatud pluginatega, käivitades `sudoedit /etc/sudoers.d/00-sudo-only-file`.
